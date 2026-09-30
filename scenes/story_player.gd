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
var next_btn: Button
var replay_btn: Button
var audio: AudioStreamPlayer
var animal_stage: AnimalStage


func _ready() -> void:
	story = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return
	segments = story.segments
	_build_ui()
	_next_segment()


func _build_ui() -> void:
	var box := UI.page(self)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	box.add_child(top)
	var back := UI.button("رجوع", 40, 100)
	back.pressed.connect(_go_map)
	top.add_child(back)
	top.add_child(UI.label(story.title, 60, UI.C_GREEN))
	progress_lbl = UI.label("", 40, UI.C_GOLD_DARK)
	progress_lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
	top.add_child(progress_lbl)

	animal_stage = AnimalStage.new()
	animal_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	animal_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(animal_stage)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 205)
	card.size_flags_vertical = Control.SIZE_SHRINK_END
	card.gui_input.connect(_on_card_input)
	card.add_theme_stylebox_override("panel", _story_bubble_style())
	box.add_child(card)

	var speech := VBoxContainer.new()
	speech.add_theme_constant_override("separation", 6)
	card.add_child(speech)

	speaker_lbl = UI.label("", 34, UI.C_GREEN)
	speaker_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech.add_child(speaker_lbl)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	speech.add_child(scroll)

	text_lbl = UI.label("", 44)
	text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.custom_minimum_size = Vector2(0, 150)
	scroll.add_child(text_lbl)

	feedback_lbl = UI.label("", 44, UI.C_BAD)
	box.add_child(feedback_lbl)

	options_box = VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 18)
	box.add_child(options_box)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	replay_btn = UI.button("أعد الاستماع", 40, 120)
	replay_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	replay_btn.pressed.connect(func(): audio.play())
	row.add_child(replay_btn)
	next_btn = UI.button("التالي", 50, 120)
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_btn.pressed.connect(_next_segment)
	row.add_child(next_btn)

	audio = AudioStreamPlayer.new()
	add_child(audio)



func _speaker_for_segment(story_id: String, i: int) -> String:
	if story_id == "lion_bull":
		match i:
			2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28:
				return "🦁 بينغالاكا"
			3, 5, 7, 11, 13, 15, 17, 19, 21, 27:
				return "🐂 سانجيفاكا"
			_:
				return "📖 الراوي"
	return "📖 الراوي"

func _story_bubble_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#fffaf0")
	style.border_color = Color("#d7b15a")
	style.set_border_width_all(3)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

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
	idx += 1
	if idx >= segments.size():
		_finish()
		return
	var seg: Dictionary = segments[idx]
	progress_lbl.text = "%d / %d" % [idx + 1, segments.size()]
	animal_stage.show_segment(story.id, idx)
	speaker_lbl.text = _speaker_for_segment(story.id, idx)
	text_lbl.text = seg.text
	text_lbl.visible_ratio = 0.0
	feedback_lbl.text = ""
	text_done = false
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
	if seg.has("challenge"):
		_show_challenge(seg.challenge)
	else:
		next_btn.disabled = false


func _clear_options() -> void:
	for c in options_box.get_children():
		c.queue_free()


func _show_challenge(ch: Dictionary) -> void:
	options_box.add_child(UI.label(ch.question, 50, UI.C_GREEN))
	var answer := int(ch.answer)
	var opts: Array = ch.options
	var order := range(opts.size())
	order.shuffle()
	for i in order:
		var b := UI.button(opts[i], 44, 115)
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
