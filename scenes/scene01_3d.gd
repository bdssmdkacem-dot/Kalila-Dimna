extends Node3D
## مشهد حكاية الأسد والثور: عرض ثلاثي الأبعاد بملء الشاشة مع سرد متزامن.

const GLB_PATH := "res://assets/3d/kalila_dimna_scene01_v2.glb"
const STORY_MAP := "res://scenes/story_map.tscn"
const VOICE_DIR := "res://assets/audio/voice/"
const FALLBACK_SECONDS_PER_CHAR := 0.055

@onready var camera: Camera3D = $Camera3D
@onready var glb_root: Node3D = $KalilaDimnaGLB

var story: Dictionary = {}
var segments: Array = []
var segment_index := -1
var audio: AudioStreamPlayer
var speaker_label: Label
var dialogue_label: Label
var progress_label: Label
var next_button: Button
var auto_advance_tween: Tween
var busy := false
var camera_center := Vector3.ZERO
var camera_distance := 10.0
var camera_tween: Tween
var scene_tween: Tween
var startup_guard: CanvasLayer
var startup_message: Label
var startup_button: Button
var animation_players: Array[AnimationPlayer] = []
var active_character_tween: Tween

func _ready() -> void:
	_create_startup_guard()
	story = GameState.current_story
	if story.is_empty():
		_show_startup_error("لا توجد حكاية محددة. سنعيدك إلى الخريطة.")
		get_tree().call_deferred("change_scene_to_file", STORY_MAP)
		return
	segments = story.get("segments", [])
	if not ResourceLoader.exists(GLB_PATH):
		push_error("SCENE01 3D: GLB NOT FOUND: " + GLB_PATH)
		_show_startup_error("تعذّر تحميل مشهد الحكاية. اضغط للعودة إلى الخريطة.")
		return

	var camera_ready := await _setup_camera()
	if not camera_ready:
		return
	_build_overlay()
	_cache_animation_players(glb_root)
	if segments.is_empty():
		dialogue_label.text = "تعذّر العثور على مقاطع هذه الحكاية."
		next_button.text = "العودة إلى الخريطة"
		_hide_startup_guard()
		return
	_hide_startup_guard()
	_play_next_segment()

func _create_startup_guard() -> void:
	startup_guard = CanvasLayer.new()
	startup_guard.layer = 100
	add_child(startup_guard)
	var panel := ColorRect.new()
	panel.color = Color("#143e33")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	startup_guard.add_child(panel)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.offset_left = -300
	box.offset_right = 300
	box.offset_top = -120
	box.offset_bottom = 120
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	startup_message = Label.new()
	startup_message.text = "جاري فتح الحكاية…"
	startup_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	startup_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	startup_message.add_theme_font_size_override("font_size", 30)
	startup_message.add_theme_color_override("font_color", Color("#f4e3ba"))
	startup_message.custom_minimum_size.y = 90
	box.add_child(startup_message)
	startup_button = Button.new()
	startup_button.text = "العودة إلى الخريطة"
	startup_button.visible = false
	startup_button.custom_minimum_size.y = 64
	startup_button.pressed.connect(_go_map)
	box.add_child(startup_button)

func _hide_startup_guard() -> void:
	if startup_guard:
		startup_guard.queue_free()
		startup_guard = null

func _show_startup_error(message: String) -> void:
	if startup_message:
		startup_message.text = message
	if startup_button:
		startup_button.visible = true

func _setup_camera() -> bool:
	await get_tree().process_frame
	camera.current = true
	camera.near = 0.05
	camera.far = 2000.0
	var bounds := _collect_bounds(glb_root)
	if bounds.size.length() > 0.01:
		var center := bounds.position + bounds.size * 0.5
		camera_center = center
		var radius := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z)) * 0.5
		radius = maxf(radius, 2.0)
		# Portrait framing: use the narrower horizontal field of view so the scene
		# remains large on a phone rather than appearing as a distant miniature.
		var distance := maxf(radius * 1.05, 6.0)
		camera_distance = distance
		camera.position = center + Vector3(distance * 0.38, distance * 0.23, distance * 0.78)
		camera.look_at(center, Vector3.UP)
		camera.fov = 48.0
	else:
		camera_center = Vector3.ZERO
		camera_distance = 10.0
		camera.position = Vector3(0.0, 5.0, 10.0)
		camera.look_at(camera_center, Vector3.UP)
		camera.fov = 48.0
		# A scene with no visible geometry would otherwise look like a black/empty screen.
		# Stop here and keep the visible recovery UI instead.
		_show_startup_error("تعذّر العثور على عناصر مرئية في مشهد الحكاية.")
		return false
	return true

func _collect_bounds(root: Node) -> AABB:
	var result := AABB()
	var found := false
	for node in root.find_children("*", "VisualInstance3D", true, false):
		var visual := node as VisualInstance3D
		var box := visual.get_aabb()
		if box.size.length() <= 0.001:
			continue
		var transformed := _transform_aabb(box, visual.global_transform)
		if not found:
			result = transformed
			found = true
		else:
			result = result.merge(transformed)
	return result

func _transform_aabb(box: AABB, transform: Transform3D) -> AABB:
	var result := AABB()
	var first := true
	for x in [box.position.x, box.end.x]:
		for y in [box.position.y, box.end.y]:
			for z in [box.position.z, box.end.z]:
				var point := transform * Vector3(x, y, z)
				if first:
					result = AABB(point, Vector3.ZERO)
					first = false
				else:
					result = result.expand(point)
	return result

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.layout_direction = Control.LAYOUT_DIRECTION_RTL
	layer.add_child(root)

	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 14
	top.offset_right = -14
	top.offset_top = 14
	top.offset_bottom = 86
	top.add_theme_stylebox_override("panel", UI.box(Color(0.02, 0.08, 0.06, 0.82), 18, 2, UI.C_GOLD_DARK))
	root.add_child(top)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	top.add_child(top_row)
	var back := UI.icon_button("‹", 28, 48)
	back.tooltip_text = "العودة إلى خريطة الحكايات"
	back.pressed.connect(_go_map)
	top_row.add_child(back)
	var title := UI.label("حكاية الأسد والثور", 26, UI.C_GOLD_LIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)
	progress_label = UI.label("", 18, UI.C_PAPER_LIGHT)
	progress_label.custom_minimum_size.x = 72
	top_row.add_child(progress_label)

	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 12
	bottom.offset_right = -12
	bottom.offset_top = -228
	bottom.offset_bottom = -12
	bottom.add_theme_stylebox_override("panel", UI.box(Color(0.015, 0.055, 0.04, 0.90), 22, 2, UI.C_GOLD_DARK))
	root.add_child(bottom)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	bottom.add_child(content)
	speaker_label = UI.label("الراوي", 20, UI.C_GOLD_LIGHT)
	speaker_label.custom_minimum_size.y = 30
	content.add_child(speaker_label)
	dialogue_label = UI.label("", 23, UI.C_PAPER_LIGHT)
	dialogue_label.custom_minimum_size.y = 102
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(dialogue_label)
	next_button = UI.button("متابعة الحكاية  →", 23, 54)
	next_button.pressed.connect(_on_next_pressed)
	content.add_child(next_button)

	audio = AudioStreamPlayer.new()
	audio.bus = "Master"
	audio.finished.connect(_on_audio_finished)
	add_child(audio)

func _speaker_name(value: String) -> String:
	match value:
		"lion": return "الأسد · بينغالاكا"
		"bull": return "الثور · سانجيفاكا"
		_: return "الراوي"

func _cache_animation_players(root: Node) -> void:
	animation_players.clear()
	for node in root.find_children("*", "AnimationPlayer", true, false):
		var player := node as AnimationPlayer
		if player:
			animation_players.append(player)

func _play_character_animation(seg: Dictionary) -> void:
	if animation_players.is_empty():
		return
	var speaker := String(seg.get("speaker", "")).to_lower()
	var scene_data: Dictionary = seg.get("scene", {})
	var requested := String(scene_data.get("animation", "")).to_lower()
	var preferred: Array[String] = []
	if requested != "":
		preferred.append(requested)
	if speaker == "lion":
		preferred.append_array(["lion_talk", "lion_talking", "lion_idle", "idle_lion"])
	elif speaker == "bull":
		preferred.append_array(["bull_talk", "bull_talking", "bull_idle", "idle_bull"])
	preferred.append_array(["talk", "talking", "idle"])
	for player in animation_players:
		var library := player.get_animation_library("")
		if library == null:
			continue
		var names := library.get_animation_list()
		var selected := ""
		for wanted in preferred:
			for animation_name in names:
				if String(animation_name).to_lower() == wanted:
					selected = animation_name
					break
			if selected != "":
				break
		if selected == "":
			for animation_name in names:
				var lower := String(animation_name).to_lower()
				if speaker != "" and lower.contains(speaker) and (lower.contains("talk") or lower.contains("idle")):
					selected = animation_name
					break
		if selected == "":
			for animation_name in names:
				var lower := String(animation_name).to_lower()
				if lower.contains("idle") or lower.contains("talk"):
					selected = animation_name
					break
		if selected != "":
			if player.current_animation != selected:
				player.play(selected, -1.0, 1.0, false)
			else:
				player.play(selected)
	
func _voice_path(index: int) -> String:
	return "%s%s_%02d.ogg" % [VOICE_DIR, String(story.get("id", "lion_bull")), index + 1]

func _play_next_segment() -> void:
	if busy:
		return
	segment_index += 1
	if segment_index >= segments.size():
		_go_map()
		return
	busy = true
	var seg: Dictionary = segments[segment_index]
	dialogue_label.text = String(seg.get("text", ""))
	speaker_label.text = _speaker_name(String(seg.get("speaker", "")))
	progress_label.text = "%d/%d" % [segment_index + 1, segments.size()]
	next_button.text = "التالي  →"
	audio.stop()
	audio.stream = null
	if auto_advance_tween and auto_advance_tween.is_running():
		auto_advance_tween.kill()
	var voice := _voice_path(segment_index)
	var mp3_voice := "%s%s_%02d.mp3" % [VOICE_DIR, String(story.get("id", "lion_bull")), segment_index + 1]
	var loaded_voice := false
	for path in [voice, mp3_voice]:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream:
				audio.stream = stream
				loaded_voice = true
				break
	# Set the camera motion only after the current audio stream is known.
	_apply_cinematic_shot(seg)
	_play_character_animation(seg)
	if loaded_voice:
		audio.play()
		return
	# Keep the spoken-text pacing when a particular clip is not available.
	var duration := maxf(2.0, dialogue_label.text.length() * FALLBACK_SECONDS_PER_CHAR)
	auto_advance_tween = create_tween()
	auto_advance_tween.tween_interval(duration)
	auto_advance_tween.tween_callback(_finish_segment)

func _apply_cinematic_shot(seg: Dictionary) -> void:
	# Narration-aware framing: gently change shot size and focus for each line.
	var scene_data: Dictionary = seg.get("scene", {})
	var shot := String(scene_data.get("shot", "wide"))
	var speaker := String(seg.get("speaker", ""))
	var factor := 1.0
	match shot:
		"speaker_close": factor = 0.76
		"two_shot": factor = 0.88
		_: factor = 1.0
	var horizontal := 0.0
	if speaker == "lion":
		horizontal = -camera_distance * 0.07
	elif speaker == "bull":
		horizontal = camera_distance * 0.07
	var target_position := camera_center + Vector3(
		horizontal + camera_distance * 0.38 * factor,
		camera_distance * 0.23 * factor,
		camera_distance * 0.78 * factor
	)
	var target_look := camera_center
	if speaker == "lion":
		target_look.x -= camera_distance * 0.06
	elif speaker == "bull":
		target_look.x += camera_distance * 0.06
	var target_rotation := Basis.looking_at(target_look - target_position, Vector3.UP).get_euler()
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween().set_parallel(true)
	camera_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(camera, "position", target_position, 0.7)
	camera_tween.tween_property(camera, "rotation", target_rotation, 0.7)

	# Add a restrained cinematic body sway when the imported asset has no usable animation.
	# This is deliberately tiny so the camera remains the main storytelling motion.
	if active_character_tween and active_character_tween.is_running():
		active_character_tween.kill()
	if scene_tween and scene_tween.is_running():
		scene_tween.kill()
	var duration := 2.5
	if audio and audio.stream:
		duration = maxf(1.0, audio.stream.get_length())
	else:
		duration = maxf(2.0, String(seg.get("text", "")).length() * FALLBACK_SECONDS_PER_CHAR)
	var base_rotation := glb_root.rotation.y
	active_character_tween = create_tween()
	active_character_tween.tween_property(glb_root, "rotation:y", base_rotation + (0.006 if speaker == "lion" else -0.006), duration * 0.5).set_trans(Tween.TRANS_SINE)
	active_character_tween.tween_property(glb_root, "rotation:y", base_rotation, duration * 0.5).set_trans(Tween.TRANS_SINE)
	scene_tween = create_tween()
	scene_tween.tween_property(glb_root, "rotation:y", base_rotation + 0.012, duration * 0.5).set_trans(Tween.TRANS_SINE)
	scene_tween.tween_property(glb_root, "rotation:y", base_rotation, duration * 0.5).set_trans(Tween.TRANS_SINE)

func _on_audio_finished() -> void:
	_finish_segment()

func _finish_segment() -> void:
	if not busy:
		return
	busy = false
	next_button.text = "متابعة الحكاية  →"

func _on_next_pressed() -> void:
	if segment_index >= segments.size() or segments.is_empty():
		_go_map()
		return
	if busy:
		audio.stop()
		if auto_advance_tween and auto_advance_tween.is_running():
			auto_advance_tween.kill()
			busy = false
		else:
			busy = false
		_play_next_segment()
	else:
		_play_next_segment()

func _go_map() -> void:
	if audio:
		audio.stop()
	if not ResourceLoader.exists(STORY_MAP):
		_show_startup_error("تعذّر العثور على خريطة الحكايات.")
		return
	var err := get_tree().change_scene_to_file(STORY_MAP)
	if err != OK:
		push_error("SCENE01: failed to return to map: %s" % err)
		_show_startup_error("تعذّر فتح الخريطة. يمكنك إعادة تشغيل التطبيق.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_map()
