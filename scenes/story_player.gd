extends Control
## قالب السرد النهائي: مشهد واقعي + بطاقة مخطوطة + قرار/اختبار.

const MAP := "res://scenes/story_map.tscn"
const RESULT := "res://scenes/result.tscn"
const VOICE_DIR := "res://assets/audio/voice/"
const READ_SECONDS_PER_CHAR := 0.055

var story: Dictionary
var segments: Array = []
var idx := -1
var mistakes := 0
var text_done := false
var tween: Tween
var pending_next_index := -1

var progress_lbl: Label
var stars_lbl: Label
var speaker_lbl: Label
var text_lbl: Label
var feedback_lbl: Label
var options_box: VBoxContainer
var options_panel: PanelContainer
var next_btn: Button
var replay_btn: Button
var audio: AudioStreamPlayer
var animal_stage: AnimalStage2D

func _ready() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_RTL
	story = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return

	segments = story.segments
	_build_ui()
	await get_tree().process_frame
	_next_segment()

func _build_ui() -> void:
	var backdrop := CinematicBackdrop.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.055, 0.04, 0.28)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	margin.add_child(column)

	var top := PanelContainer.new()
	top.custom_minimum_size = Vector2(0, 56)
	top.add_theme_stylebox_override("panel", UI.box(Color(0.04, 0.15, 0.11, 0.92), 16, 1, UI.C_GOLD_DARK))
	column.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 7)
	top.add_child(top_row)

	var back := UI.icon_button("‹", 31, 50)
	back.tooltip_text = "خريطة الحكايات"
	back.pressed.connect(_go_map)
	top_row.add_child(back)

	progress_lbl = UI.label("%d/%d" % [int(story.get("order", 1)), StoryLoader.stories.size()], 20, UI.C_GOLD_LIGHT)
	progress_lbl.custom_minimum_size = Vector2(58, 46)
	top_row.add_child(progress_lbl)

	var title := UI.label(String(story.title), 28, UI.C_PAPER_LIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)

	stars_lbl = UI.label("★★★", 22, UI.C_GOLD_LIGHT)
	stars_lbl.custom_minimum_size = Vector2(82, 46)
	top_row.add_child(stars_lbl)

	replay_btn = UI.icon_button("◉", 24, 50)
	replay_btn.tooltip_text = "إعادة الاستماع"
	replay_btn.visible = false
	replay_btn.pressed.connect(func():
		if audio and audio.stream:
			audio.play()
	)
	top_row.add_child(replay_btn)

	var stage_frame := PanelContainer.new()
	stage_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_frame.custom_minimum_size = Vector2(0, 245)
	stage_frame.add_theme_stylebox_override("panel", UI.box(Color(0.02, 0.07, 0.05, 0.96), 18, 2, UI.C_GOLD_DARK))
	column.add_child(stage_frame)

	animal_stage = AnimalStage2D.new()
	animal_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	animal_stage.custom_minimum_size = Vector2(0, 245)
	animal_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_frame.add_child(animal_stage)

	var dialogue := PanelContainer.new()
	dialogue.custom_minimum_size = Vector2(0, 148)
	dialogue.add_theme_stylebox_override("panel", UI.parchment_style(18, 2))
	column.add_child(dialogue)

	var speech := VBoxContainer.new()
	speech.add_theme_constant_override("separation", 2)
	dialogue.add_child(speech)

	speaker_lbl = UI.label("", 19, UI.C_GOLD_DARK)
	speaker_lbl.custom_minimum_size = Vector2(0, 27)
	speech.add_child(speaker_lbl)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	speech.add_child(scroll)

	text_lbl = UI.label("", 23, UI.C_INK)
	text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.custom_minimum_size = Vector2(0, 88)
	text_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
	text_lbl.gui_input.connect(_on_card_input)
	scroll.add_child(text_lbl)

	feedback_lbl = UI.label("", 17, UI.C_GOOD)
	feedback_lbl.custom_minimum_size = Vector2(0, 24)
	speech.add_child(feedback_lbl)

	options_panel = PanelContainer.new()
	options_panel.custom_minimum_size = Vector2(0, 0)
	options_panel.add_theme_stylebox_override("panel", UI.box(Color(0.035, 0.12, 0.09, 0.94), 18, 2, UI.C_GOLD_DARK))
	options_panel.visible = false
	column.add_child(options_panel)

	var options_scroll := ScrollContainer.new()
	options_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	options_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	options_panel.add_child(options_scroll)

	options_box = VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 6)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_scroll.add_child(options_box)

	var controls := HBoxContainer.new()
	controls.custom_minimum_size = Vector2(0, 54)
	controls.add_theme_constant_override("separation", 7)
	column.add_child(controls)

	next_btn = UI.button("ابدأ الحكاية  →", 25, 54)
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_btn.pressed.connect(_on_next_pressed)
	controls.add_child(next_btn)

	audio = AudioStreamPlayer.new()
	add_child(audio)

func _speaker_for_segment(i: int) -> String:
	if i < 0 or i >= segments.size():
		return "الراوي"
	var speaker := String(segments[i].get("speaker", ""))
	match speaker:
		"lion": return "الأسد · بينغالاكا"
		"bull": return "الثور · سانجيفاكا"
		"crow": return "الغراب"
		"snake": return "الحيّة"
		"monkey": return "القرد"
		"turtle": return "الغَيْلَم · السلحفاة"
		"dove": return "المطوّقة · الحمامة"
		"hare": return "الأرنب"
		_: return "الراوي"

func _load_voice(i: int) -> AudioStream:
	var ogg_path := "%s%s_%02d.ogg" % [VOICE_DIR, story.id, i + 1]
	var mp3_path := "%s%s_%02d.mp3" % [VOICE_DIR, story.id, i + 1]
	for path in [ogg_path, mp3_path]:
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
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
	animal_stage.show_segment(story.id, idx, seg.get("scene", {}))
	animal_stage.set_speaker(String(seg.get("speaker", "")))

	speaker_lbl.text = _speaker_for_segment(idx)
	text_lbl.text = String(seg.get("text", ""))
	text_lbl.visible_ratio = 0.0
	feedback_lbl.text = ""
	text_done = false
	pending_next_index = -1
	_clear_options()

	next_btn.disabled = true
	if idx == 0:
		next_btn.text = "ابدأ الحكاية  →"
	elif idx == segments.size() - 1:
		next_btn.text = "إنهاء الحكاية  ✦"
	else:
		next_btn.text = "التالي  →"

	audio.stop()
	var duration: float = maxf(1.5, text_lbl.text.length() * READ_SECONDS_PER_CHAR)
	var stream := _load_voice(idx)
	if stream:
		audio.stream = stream
		audio.play()
		duration = maxf(1.0, stream.get_length())
		replay_btn.visible = true
	else:
		replay_btn.visible = false

	animal_stage.start_cinematic(idx, duration)

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(text_lbl, "visible_ratio", 1.0, duration)
	tween.finished.connect(_on_text_done)

func _on_card_input(ev: InputEvent) -> void:
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
	options_panel.custom_minimum_size.y = 148
	options_box.add_child(UI.section_label("◆  ماذا سيفعل؟"))

	var q := UI.label(String(interaction.question), 20, UI.C_PAPER_LIGHT)
	q.custom_minimum_size = Vector2(0, 34)
	options_box.add_child(q)

	var opts: Array = interaction.options
	var order := range(opts.size())
	order.shuffle()
	var answer := int(interaction.answer)

	if opts.size() == 2:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 7)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		options_box.add_child(row)
		for i in order:
			var b := UI.card_button(76)
			b.text = String(opts[i])
			b.add_theme_font_size_override("font_size", 20)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.pressed.connect(_on_story_choice.bind(b, i, interaction))
			row.add_child(b)
	else:
		for i in order:
			var b := UI.card_button(56)
			b.text = String(opts[i])
			b.add_theme_font_size_override("font_size", 19)
			b.pressed.connect(_on_story_choice.bind(b, i, interaction))
			options_box.add_child(b)

func _on_story_choice(btn: Button, choice_index: int, interaction: Dictionary) -> void:
	var correct := choice_index == int(interaction.answer)
	pending_next_index = int(interaction.next_correct if correct else interaction.next_wrong)

	for c in options_box.get_children():
		if c is Button:
			c.disabled = true
		elif c is HBoxContainer:
			for child in c.get_children():
				if child is Button:
					child.disabled = true

	if correct:
		feedback_lbl.add_theme_color_override("font_color", UI.C_GOOD)
		feedback_lbl.text = "أحسنت! اختيارك يغيّر مجرى الحكاية."
	else:
		mistakes += 1
		feedback_lbl.add_theme_color_override("font_color", UI.C_BAD)
		feedback_lbl.text = "اختيار مختلف… لنرَ ماذا يحدث."

	next_btn.disabled = false
	next_btn.text = "متابعة الحكاية  →"

func _show_challenge(ch: Dictionary) -> void:
	options_panel.visible = true
	options_panel.custom_minimum_size.y = 148
	options_box.add_child(UI.section_label("◆  اختبر فهمك"))

	var q := UI.label(String(ch.question), 20, UI.C_PAPER_LIGHT)
	q.custom_minimum_size = Vector2(0, 34)
	options_box.add_child(q)

	var answer := int(ch.answer)
	var opts: Array = ch.options
	var order := range(opts.size())
	order.shuffle()

	if opts.size() == 2:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 7)
		options_box.add_child(row)
		for i in order:
			var b := UI.card_button(72)
			b.text = String(opts[i])
			b.add_theme_font_size_override("font_size", 19)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.pressed.connect(_on_option.bind(b, i == answer))
			row.add_child(b)
	else:
		for i in order:
			var b := UI.card_button(50)
			b.text = String(opts[i])
			b.add_theme_font_size_override("font_size", 18)
			b.pressed.connect(_on_option.bind(b, i == answer))
			options_box.add_child(b)

func _on_option(btn: Button, correct: bool) -> void:
	if correct:
		feedback_lbl.add_theme_color_override("font_color", UI.C_GOOD)
		feedback_lbl.text = "أحسنت! إجابة صحيحة."
		for c in options_box.get_children():
			if c is Button:
				c.disabled = true
			elif c is HBoxContainer:
				for child in c.get_children():
					if child is Button:
						child.disabled = true
		btn.add_theme_stylebox_override("disabled", UI.box(UI.C_GOOD, 16, 1, UI.C_GOLD_DARK))
		next_btn.disabled = false
	else:
		mistakes += 1
		feedback_lbl.add_theme_color_override("font_color", UI.C_BAD)
		feedback_lbl.text = "حاول مرة أخرى."
		btn.disabled = true

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
		options_panel.custom_minimum_size.y = 0
	if options_box:
		for c in options_box.get_children():
			c.queue_free()

func _finish() -> void:
	var stars := 3 if mistakes == 0 else (2 if mistakes <= 2 else 1)
	GameState.set_stars(story.id, stars)
	GameState.last_stars = stars
	UI.transition_to(self, RESULT)

func _go_map() -> void:
	UI.transition_to(self, MAP)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_map()
