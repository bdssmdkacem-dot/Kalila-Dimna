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

func _ready() -> void:
	story = GameState.current_story
	if story.is_empty():
		push_warning("SCENE01: no selected story; returning to map")
		get_tree().call_deferred("change_scene_to_file", STORY_MAP)
		return
	segments = story.get("segments", [])
	if not ResourceLoader.exists(GLB_PATH):
		push_error("SCENE01 3D: GLB NOT FOUND: " + GLB_PATH)
		get_tree().call_deferred("change_scene_to_file", STORY_MAP)
		return

	await _setup_camera()
	_build_overlay()
	if segments.is_empty():
		dialogue_label.text = "تعذّر العثور على مقاطع هذه الحكاية."
		next_button.text = "العودة إلى الخريطة"
		return
	_play_next_segment()

func _setup_camera() -> void:
	await get_tree().process_frame
	camera.current = true
	camera.near = 0.05
	camera.far = 2000.0
	var bounds := _collect_bounds(glb_root)
	if bounds.size.length() > 0.01:
		var center := bounds.position + bounds.size * 0.5
		var radius := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z)) * 0.5
		radius = maxf(radius, 2.0)
		# Portrait framing: use the narrower horizontal field of view so the scene
		# remains large on a phone rather than appearing as a distant miniature.
		var distance := maxf(radius * 1.35, 7.0)
		camera.position = center + Vector3(distance * 0.62, distance * 0.30, distance)
		camera.look_at(center, Vector3.UP)
		camera.fov = 48.0
	else:
		camera.position = Vector3(0.0, 5.0, 10.0)
		camera.look_at(Vector3.ZERO, Vector3.UP)
		camera.fov = 48.0

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
	if auto_advance_tween and auto_advance_tween.is_running():
		auto_advance_tween.kill()
	var voice := _voice_path(segment_index)
	var mp3_voice := "%s%s_%02d.mp3" % [VOICE_DIR, String(story.get("id", "lion_bull")), segment_index + 1]
	for path in [voice, mp3_voice]:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream:
				audio.stream = stream
				audio.play()
				return
	# Keep the spoken-text pacing when a particular clip is not available.
	var duration := maxf(2.0, dialogue_label.text.length() * FALLBACK_SECONDS_PER_CHAR)
	auto_advance_tween = create_tween()
	auto_advance_tween.tween_interval(duration)
	auto_advance_tween.tween_callback(_finish_segment)

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
	audio.stop()
	get_tree().change_scene_to_file(STORY_MAP)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_map()
