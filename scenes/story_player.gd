extends Control
## تشغيل الحكاية: نص يظهر تدريجياً متزامناً مع الصوت (إن وُجد)،
## ثم تحدٍّ اختياري بعد كل مقطع.

const MAP := "res://scenes/story_map.tscn"
const RESULT := "res://scenes/result.tscn"
const VOICE_DIR := "res://assets/audio/voice/"
const READ_SECONDS_PER_CHAR := 0.055

var story: Dictionary
var segments: Array
var idx := -1
var mistakes := 0
var text_done := false
var tween: Tween

var progress_lbl: Label
var speaker_lbl: Label
var text_lbl: Label
var feedback_lbl: Label
var options_box: VBoxContainer
var options_panel: PanelContainer
var next_btn: Button
var replay_btn: Button
var audio: AudioStreamPlayer
var animal_stage: AnimalStage2D
var pending_next_index := -1


func _ready() -> void:
	story = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return
	segments = story.segments
	_build_ui()
	# The story stage is inside a VBoxContainer. Wait until the container has
	# assigned its real size before rendering the first segment.
	await _wait_for_story_layout()
	_next_segment()


func _wait_for_story_layout() -> void:
	if animal_stage == null:
		return
	for _i in range(8):
		if animal_stage.size.x > 0.0 and animal_stage.size.y > 0.0:
			return
		await get_tree().process_frame

func _build_ui() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_RTL

	animal_stage = AnimalStage2D.new()
	animal_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	animal_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(animal_stage)

	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.03, 0.025, 0.08)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 18.0
	top_panel.offset_right = -18.0
	top_panel.offset_top = 18.0
	top_panel.offset_bottom = 82.0
	top_panel.add_theme_stylebox_override("panel", _top_bar_style())
	top_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(top_panel)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	top_panel.add_child(top)

	var back := UI.button("رجوع", 25, 46)
	back.custom_minimum_size = Vector2(105, 46)
	back.add_theme_stylebox_override("normal", UI.box(Color(0.08, 0.20, 0.16, 0.92), 16, 1, UI.C_GOLD_DARK))
	back.add_theme_stylebox_override("hover", UI.box(Color(0.12, 0.29, 0.23, 0.96), 16, 1, UI.C_GOLD_LIGHT))
	back.pressed.connect(_go_map)
	top.add_child(back)

	var title := UI.label(story.title, 31, UI.C_PAPER_LIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(title)

	progress_lbl = UI.label("", 24, UI.C_GOLD_LIGHT)
	progress_lbl.custom_minimum_size = Vector2(112, 46)
	progress_lbl.add_theme_stylebox_override("normal", UI.box(Color(0.08, 0.20, 0.16, 0.92), 16, 1, UI.C_GOLD_DARK))
	top.add_child(progress_lbl)

	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 18.0
	bottom.offset_right = -18.0
	bottom.offset_top = -214.0
	bottom.offset_bottom = -12.0
	bottom.mouse_filter = Control.MOUSE_FILTER_STOP
	bottom.add_theme_stylebox_override("panel", _story_overlay_style())
	add_child(bottom)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	bottom.add_child(content)

	speaker_lbl = UI.label("", 27, UI.C_GOLD_LIGHT)
	speaker_lbl.custom_minimum_size = Vector2(0, 34)
	speaker_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speaker_lbl.add_theme_stylebox_override("normal", UI.box(Color(0.10, 0.22, 0.17, 0.86), 15, 1, Color(0.78, 0.62, 0.23, 0.75)))
	content.add_child(speaker_lbl)

	var speech_scroll := ScrollContainer.new()
	speech_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	speech_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	speech_scroll.custom_minimum_size = Vector2(0, 70)
	content.add_child(speech_scroll)

	text_lbl = UI.label("", 31, UI.C_PAPER_LIGHT)
	text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.custom_minimum_size = Vector2(0, 66)
	text_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	text_lbl.add_theme_constant_override("shadow_offset_x", 2)
	text_lbl.add_theme_constant_override("shadow_offset_y", 2)
	speech_scroll.add_child(text_lbl)

	feedback_lbl = UI.label("", 23, UI.C_GOOD)
	feedback_lbl.custom_minimum_size = Vector2(0, 28)
	feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(feedback_lbl)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	content.add_child(controls)

	replay_btn = UI.button("أعد الاستماع", 24, 48)
	replay_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	replay_btn.add_theme_stylebox_override("normal", UI.box(Color(0.08, 0.20, 0.16, 0.92), 15, 1, UI.C_GOLD_DARK))
	replay_btn.pressed.connect(func(): audio.play())
	controls.add_child(replay_btn)

	next_btn = UI.button("التالي", 28, 48)
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_btn.pressed.connect(_on_next_pressed)
	controls.add_child(next_btn)

	options_panel = PanelContainer.new()
	options_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	options_panel.offset_left = 55.0
	options_panel.offset_right = -55.0
	options_panel.offset_top = -380.0
	options_panel.offset_bottom = -222.0
	options_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	options_panel.visible = false
	options_panel.add_theme_stylebox_override("panel", _options_overlay_style())
	add_child(options_panel)

	var options_scroll := ScrollContainer.new()
	options_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	options_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	options_panel.add_child(options_scroll)
	options_box = VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 7)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_scroll.add_child(options_box)

	audio = AudioStreamPlayer.new()
	add_child(audio)

func _top_bar_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.16, 0.13, 0.86)
	style.border_color = Color(0.84, 0.69, 0.32, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(20)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style


func _story_overlay_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.065, 0.052, 0.92)
	style.border_color = Color(0.88, 0.72, 0.34, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(24)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 5)
	return style


func _options_overlay_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.09, 0.07, 0.96)
	style.border_color = Color(0.84, 0.69, 0.32, 0.96)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.30)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	return style


func _speaker_for_segment(_story_id: String, i: int) -> String:
	if i < 0 or i >= segments.size():
		return "الراوي"
	var speaker := String(segments[i].get("speaker", ""))
	match speaker:
		"lion":
			return "بينغالاكا · الأسد"
		"bull":
			return "سانجيفاكا · الثور"
		"crow":
			return "الغراب"
		"snake":
			return "الحيّة"
		"monkey":
			return "القرد"
		"turtle":
			return "الغَيْلَم · السلحفاة"
		"dove":
			return "المطوّقة · الحمامة"
		"hare":
			return "الأرنب"
		_:
			return "الراوي"


func _load_voice(i: int) -> AudioStream:
	# Prefer OGG for packaged voice assets, but accept MP3 recordings directly.
	var ogg_path := "%s%s_%02d.ogg" % [VOICE_DIR, story.id, i + 1]
	var mp3_path := "%s%s_%02d.mp3" % [VOICE_DIR, story.id, i + 1]
	for path in [ogg_path, mp3_path]:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream:
				return stream
	return null


func _next_segment() -> void:
	if pending_next_index >= 0:
		_advance_after_choice()
		return
	idx += 1
	if idx >= segments.size():
		_finish()
		return
	var seg: Dictionary = segments[idx]
	progress_lbl.text = "%d / %d" % [idx + 1, segments.size()]
	animal_stage.show_segment(story.id, idx, seg.get("scene", {}))
	var segment_speaker := String(seg.get("speaker", ""))
	animal_stage.set_speaker(segment_speaker)
	speaker_lbl.text = _speaker_for_segment(story.id, idx)
	text_lbl.text = seg.text
	text_lbl.visible_ratio = 0.0
	feedback_lbl.text = ""
	text_done = false
	pending_next_index = -1
	_clear_options()
	next_btn.disabled = true
	next_btn.text = "النهاية" if idx == segments.size() - 1 else "التالي"

	audio.stop()
	var duration: float = maxf(2.0, text_lbl.text.length() * READ_SECONDS_PER_CHAR)
	var stream := _load_voice(idx)
	if stream:
		audio.stream = stream
		audio.play()
		duration = maxf(1.0, stream.get_length())
	replay_btn.visible = stream != null
	animal_stage.start_cinematic(idx, duration)

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(text_lbl, "visible_ratio", 1.0, duration)
	tween.finished.connect(_on_text_done)


func _on_card_input(ev: InputEvent) -> void:
	# لمسة على النص = إظهاره كاملاً
	if ev is InputEventMouseButton and ev.pressed and not text_done:
		if tween:
			tween.kill()
		text_lbl.visible_ratio = 1.0
		_on_text_done()


func _on_text_done() -> void:
	if text_done:
		return
	text_done = true
	var seg: Dictionary = segments[idx]
	if seg.has("interaction"):
		_show_story_interaction(seg.interaction)
	elif seg.has("challenge"):
		_show_challenge(seg.challenge)
	else:
		next_btn.disabled = false

func _show_story_interaction(interaction: Dictionary) -> void:
	options_panel.visible = true
	options_box.add_child(UI.pill("لحظة القرار", 26, UI.C_PAPER_LIGHT, UI.C_GREEN_DARK))
	var q := UI.label(String(interaction.question), 30, UI.C_PAPER)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	options_box.add_child(q)
	var answer := int(interaction.answer)
	var opts: Array = interaction.options
	var order := range(opts.size())
	order.shuffle()
	for i in order:
		var b := UI.button(String(opts[i]), 29, 68)
		b.custom_minimum_size.x = 190
		b.add_theme_stylebox_override("normal", UI.box(UI.C_GREEN, 18, 1, UI.C_GOLD_DARK))
		b.add_theme_stylebox_override("hover", UI.box(UI.C_GREEN_LIGHT, 18, 1, UI.C_GOLD_LIGHT))
		b.pressed.connect(_on_story_choice.bind(b, i, interaction))
		options_box.add_child(b)


func _on_story_choice(btn: Button, choice_index: int, interaction: Dictionary) -> void:
	var correct := choice_index == int(interaction.answer)
	pending_next_index = int(interaction.next_correct if correct else interaction.next_wrong)
	for c in options_box.get_children():
		if c is Button:
			c.disabled = true
	if correct:
		feedback_lbl.add_theme_color_override("font_color", UI.C_GOOD)
		feedback_lbl.text = "أحسنت! قرارك يغيّر ما سيحدث الآن."
	else:
		mistakes += 1
		feedback_lbl.add_theme_color_override("font_color", UI.C_BAD)
		feedback_lbl.text = "هذا القرار يقود إلى نتيجة مختلفة في الحكاية."
	next_btn.disabled = false
	next_btn.text = "متابعة الحكاية"

func _advance_after_choice() -> void:
	var target := pending_next_index
	pending_next_index = -1
	idx = target - 1
	_next_segment()

func _on_next_pressed() -> void:
	if pending_next_index >= 0:
		_advance_after_choice()
	else:
		_next_segment()

func _clear_options() -> void:
	if options_panel:
		options_panel.visible = false
	for c in options_box.get_children():
		c.queue_free()


func _show_challenge(ch: Dictionary) -> void:
	options_panel.visible = true
	options_box.add_child(UI.pill("اختبر فهمك", 26, UI.C_PAPER_LIGHT, UI.C_GREEN_DARK))
	var q := UI.label(String(ch.question), 30, UI.C_INK)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	options_box.add_child(q)
	var answer := int(ch.answer)
	var opts: Array = ch.options
	var order := range(opts.size())
	order.shuffle()
	for i in order:
		var b := UI.button(String(opts[i]), 29, 68)
		b.custom_minimum_size.x = 190
		b.add_theme_stylebox_override("normal", UI.box(UI.C_GREEN, 18, 1, UI.C_GOLD_DARK))
		b.add_theme_stylebox_override("hover", UI.box(UI.C_GREEN_LIGHT, 18, 1, UI.C_GOLD_LIGHT))
		b.pressed.connect(_on_option.bind(b, i == answer))
		options_box.add_child(b)


func _on_option(btn: Button, correct: bool) -> void:
	if correct:
		feedback_lbl.add_theme_color_override("font_color", UI.C_GOOD)
		feedback_lbl.text = "أحسنت! إجابة صحيحة"
		for c in options_box.get_children():
			if c is Button:
				c.disabled = true
		btn.add_theme_stylebox_override("disabled", UI.box(UI.C_GOOD))
		next_btn.disabled = false
	else:
		mistakes += 1
		feedback_lbl.add_theme_color_override("font_color", UI.C_BAD)
		feedback_lbl.text = "حاول مرة أخرى"
		btn.disabled = true
		btn.add_theme_stylebox_override("disabled", UI.box(UI.C_BAD))


func _finish() -> void:
	var stars := 3 if mistakes == 0 else (2 if mistakes <= 2 else 1)
	GameState.set_stars(story.id, stars)
	GameState.last_stars = stars
	get_tree().change_scene_to_file(RESULT)


func _go_map() -> void:
	get_tree().change_scene_to_file(MAP)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_map()
