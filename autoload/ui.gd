extends Node
## الهوية البصرية الموحدة لتطبيق كليلة ودمنة.
## مخطوطة دافئة + أخضر زمردي + ذهب معتّق + خط Amiri.

const C_PAPER := Color("#f4e3ba")
const C_PAPER_LIGHT := Color("#fff7df")
const C_PAPER_DEEP := Color("#d8c28f")
const C_INK := Color("#2e2117")
const C_GREEN := Color("#1f5c4a")
const C_GREEN_LIGHT := Color("#2f7a64")
const C_GREEN_DARK := Color("#143e33")
const C_GOLD := Color("#d6ad4f")
const C_GOLD_LIGHT := Color("#f0d487")
const C_GOLD_DARK := Color("#8a6d10")
const C_TERRACOTTA := Color("#a35c3d")
const C_GOOD := Color("#73c982")
const C_BAD := Color("#d66d61")
const C_MUTED := Color("#6e6a58")

const FONT_PATH := "res://assets/fonts/Amiri-Regular.ttf"
const BRAND_MARK_PATH := "res://icon.svg"
const PARCHMENT_PATH := "res://assets/images/new/story_map_parchment_new.svg"

func _ready() -> void:
	get_tree().root.theme = _build_theme()

func box(color: Color, radius: int = 20, border: int = 0, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(18)
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = border_color
	s.shadow_color = Color(0, 0, 0, 0.28)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 4)
	return s

func parchment_style(radius: int = 20, border: int = 2) -> StyleBoxFlat:
	var s := box(C_PAPER_LIGHT, radius, border, C_GOLD_DARK)
	s.shadow_color = Color(0.08, 0.05, 0.02, 0.30)
	s.shadow_size = 12
	s.shadow_offset = Vector2(0, 5)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

func _button_style(bg: Color, border: Color, radius: int = 18) -> StyleBoxFlat:
	var s := box(bg, radius, 2, border)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s

func _build_theme() -> Theme:
	var t := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		t.default_font = load(FONT_PATH) as Font
	t.default_font_size = 30

	t.set_stylebox("normal", "Button", _button_style(C_GREEN_DARK, C_GOLD_DARK))
	t.set_stylebox("hover", "Button", _button_style(C_GREEN, C_GOLD_LIGHT))
	t.set_stylebox("pressed", "Button", _button_style(Color("#0d3027"), C_GOLD))
	t.set_stylebox("focus", "Button", _button_style(C_GREEN, C_GOLD_LIGHT))
	t.set_stylebox("disabled", "Button", _button_style(Color("#5b6257"), Color("#777763")))

	t.set_color("font_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", C_GOLD_LIGHT)
	t.set_color("font_focus_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_disabled_color", "Button", Color("#d0c9ad"))
	t.set_font_size("font_size", "Button", 34)

	t.set_color("font_color", "Label", C_INK)
	t.set_constant("line_spacing", "Label", 7)
	t.set_stylebox("panel", "PanelContainer", parchment_style(20, 1))
	return t

func label(text: String, size: int = 40, color: Color = C_INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func button(text: String, size: int = 38, min_h: int = 68) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_h)
	b.add_theme_font_size_override("font_size", size)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return b

func icon_button(text: String, size: int = 28, diameter: int = 58) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(diameter, diameter)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_stylebox_override("normal", box(Color(0.03, 0.12, 0.09, 0.78), diameter / 2, 1, C_GOLD_DARK))
	b.add_theme_stylebox_override("hover", box(Color(0.08, 0.25, 0.18, 0.92), diameter / 2, 2, C_GOLD_LIGHT))
	b.add_theme_stylebox_override("pressed", box(Color(0.02, 0.08, 0.06, 0.94), diameter / 2, 2, C_GOLD))
	return b

func card_button(min_h: int = 190) -> Button:
	var b := Button.new()
	b.text = ""
	b.custom_minimum_size = Vector2(0, min_h)
	b.add_theme_stylebox_override("normal", _button_style(C_PAPER_LIGHT, C_GOLD_DARK, 18))
	b.add_theme_stylebox_override("hover", _button_style(Color("#fff0c9"), C_GOLD, 18))
	b.add_theme_stylebox_override("pressed", _button_style(Color("#ead7a8"), C_GOLD_LIGHT, 18))
	b.add_theme_stylebox_override("disabled", _button_style(Color("#c5b996"), Color("#8d856d"), 18))
	b.add_theme_color_override("font_color", C_INK)
	b.add_theme_color_override("font_hover_color", C_INK)
	b.add_theme_color_override("font_pressed_color", C_INK)
	return b

func pill(text_value: String, size: int = 26, fg: Color = C_GOLD_LIGHT, bg: Color = C_GREEN_DARK) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, 16, 1, C_GOLD_DARK))
	p.custom_minimum_size = Vector2(0, 46)
	var l := label(text_value, size, fg)
	l.custom_minimum_size = Vector2(0, 36)
	p.add_child(l)
	return p

func brand_mark(size: int = 150) -> TextureRect:
	var t := TextureRect.new()
	if ResourceLoader.exists(BRAND_MARK_PATH):
		t.texture = load(BRAND_MARK_PATH) as Texture2D
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(size, size)
	t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func title_block(title: String, subtitle: String = "") -> VBoxContainer:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 0)

	var t := label(title, 62, C_GREEN_DARK)
	t.add_theme_color_override("font_shadow_color", Color(1, 0.93, 0.70, 0.45))
	t.add_theme_constant_override("shadow_offset_y", 2)
	v.add_child(t)

	if subtitle != "":
		var sub := label(subtitle, 28, C_MUTED)
		v.add_child(sub)
	return v

func hero_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(Color(0.03, 0.13, 0.10, 0.55), 28, 2, Color(0.84, 0.67, 0.29, 0.82)))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p

func page(root: Control, background_mode: String = "parchment") -> VBoxContainer:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.layout_direction = Control.LAYOUT_DIRECTION_RTL

	if background_mode == "forest":
		var bg := TextureRect.new()
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.texture = load("res://assets/images/new/main_menu_forest.svg") as Texture2D
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(bg)
	else:
		var paper := TextureRect.new()
		if ResourceLoader.exists(PARCHMENT_PATH):
			paper.texture = load(PARCHMENT_PATH) as Texture2D
		paper.set_anchors_preset(Control.PRESET_FULL_RECT)
		paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		paper.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(paper)

	var tint := ColorRect.new()
	tint.color = Color(0.03, 0.09, 0.06, 0.08) if background_mode == "parchment" else Color(0.01, 0.035, 0.025, 0.24)
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tint)

	var top := ColorRect.new()
	top.color = Color(0.84, 0.68, 0.30, 0.78)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size = Vector2(0, 2)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)

	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 18)
	m.add_theme_constant_override("margin_right", 18)
	m.add_theme_constant_override("margin_top", 16)
	m.add_theme_constant_override("margin_bottom", 14)
	root.add_child(m)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	m.add_child(v)
	return v

func section_divider() -> HSeparator:
	var h := HSeparator.new()
	h.custom_minimum_size = Vector2(0, 2)
	h.add_theme_constant_override("separation", 0)
	h.modulate = C_GOLD
	return h

func transition_to(root: Control, path: String, duration: float = 0.22) -> void:
	# Never leave a failed scene change behind an opaque black/fade screen.
	if not ResourceLoader.exists(path):
		push_error("UI: target scene does not exist: " + path)
		return
	var fade := ColorRect.new()
	fade.color = Color(0.02, 0.06, 0.045, 0.0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(fade)
	var tw := root.create_tween()
	tw.tween_property(fade, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	await tw.finished
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("UI: scene change failed (%s): %s" % [err, path])
		fade.queue_free()

func story_card_style() -> StyleBoxFlat:
	return parchment_style(18, 2)

func decision_style(bg: Color = C_GREEN_DARK) -> StyleBoxFlat:
	return _button_style(bg, C_GOLD_DARK, 16)

func section_label(text_value: String) -> Label:
	var l := label(text_value, 21, C_GOLD_DARK)
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_outline_color", Color(1, 0.96, 0.82, 0.40))
	return l

func spacer(h: int = 30) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func star_text(value: int = 3, total: int = 3) -> String:
	var out := ""
	for i in total:
		out += "★" if i < value else "☆"
	return out
