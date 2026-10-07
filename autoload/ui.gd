extends Node
## نظام بصري سينمائي موحّد لكليلة ودمنة: غابة ليلية، زمرد عميق، ذهب معتّق، وإضاءة هادئة.

const C_PAPER := Color("#f4e8ca")
const C_PAPER_LIGHT := Color("#fff8e8")
const C_PAPER_DEEP := Color("#cdbb8a")
const C_INK := Color("#16211e")
const C_GREEN := Color("#0d4a3c")
const C_GREEN_LIGHT := Color("#176a54")
const C_GREEN_DARK := Color("#061f1a")
const C_GOLD := Color("#d9b45a")
const C_GOLD_LIGHT := Color("#f5dc91")
const C_GOLD_DARK := Color("#92702a")
const C_TERRACOTTA := Color("#a75b42")
const C_TERRACOTTA_DARK := Color("#713b2e")
const C_GOOD := Color("#73c982")
const C_BAD := Color("#e27a6f")
const C_CARD := Color("#102c25")
const C_MUTED := Color("#9eab9e")
const FONT_PATH := "res://assets/fonts/Amiri-Regular.ttf"
const BRAND_MARK_PATH := "res://assets/branding/brand_mark.svg"

func _ready() -> void:
	get_tree().root.theme = _build_theme()

func box(color: Color, radius: int = 24, border: int = 0, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(20)
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = border_color
	s.shadow_color = Color(0, 0, 0, 0.36)
	s.shadow_size = 14
	s.shadow_offset = Vector2(0, 5)
	return s

func _button_style(bg: Color, border: Color, radius: int = 18) -> StyleBoxFlat:
	var s := box(bg, radius, 1, border)
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 13
	s.content_margin_bottom = 13
	return s

func _build_theme() -> Theme:
	var t := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		t.default_font = load(FONT_PATH) as Font
	t.default_font_size = 34
	t.set_stylebox("normal", "Button", _button_style(C_GREEN, C_GOLD_DARK))
	t.set_stylebox("hover", "Button", _button_style(C_GREEN_LIGHT, C_GOLD_LIGHT))
	t.set_stylebox("pressed", "Button", _button_style(C_GREEN_DARK, C_GOLD))
	t.set_stylebox("focus", "Button", _button_style(C_GREEN, C_GOLD_LIGHT))
	t.set_stylebox("disabled", "Button", _button_style(Color("#263833"), Color("#52645d")))
	t.set_color("font_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", C_GOLD_LIGHT)
	t.set_color("font_focus_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_disabled_color", C_MUTED)
	t.set_font_size("font_size", "Button", 40)
	t.set_color("font_color", "Label", C_PAPER)
	t.set_constant("line_spacing", "Label", 10)
	t.set_stylebox("panel", "PanelContainer", box(C_CARD, 26, 1, Color("#8b713a")))
	return t

func label(text: String, size: int = 44, color: Color = C_PAPER) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func button(text: String, size: int = 46, min_h: int = 104) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_h)
	b.add_theme_font_size_override("font_size", size)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return b

func card_button(min_h: int = 220) -> Button:
	var b := Button.new()
	b.text = ""
	b.custom_minimum_size = Vector2(0, min_h)
	b.add_theme_stylebox_override("normal", _button_style(Color("#102f27"), Color("#725d2c"), 24))
	b.add_theme_stylebox_override("hover", _button_style(Color("#174b3c"), C_GOLD, 24))
	b.add_theme_stylebox_override("pressed", _button_style(Color("#0a241e"), C_GOLD_LIGHT, 24))
	b.add_theme_stylebox_override("disabled", _button_style(Color("#14231f"), Color("#384842"), 24))
	return b

func pill(text_value: String, size: int = 30, fg: Color = C_GOLD_LIGHT, bg: Color = Color("#153c31")) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, 16, 1, Color("#7d6631")))
	p.custom_minimum_size = Vector2(0, 50)
	var l := label(text_value, size, fg)
	l.custom_minimum_size = Vector2(0, 38)
	p.add_child(l)
	return p

func brand_mark(size: int = 180) -> TextureRect:
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
	var t := label(title, 78, C_GOLD_LIGHT)
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	t.add_theme_constant_override("shadow_offset_y", 4)
	v.add_child(t)
	if subtitle != "":
		var sub := label(subtitle, 34, C_PAPER_DEEP)
		v.add_child(sub)
	return v

func hero_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(Color(0.02, 0.09, 0.07, 0.84), 34, 1, Color(0.83, 0.66, 0.29, 0.62)))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p

## خلفية سينمائية موحدة. لا نستخدم ورقاً مسطحاً كهوية رئيسية؛ المشهد هو البطل.
func page(root: Control) -> VBoxContainer:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.layout_direction = Control.LAYOUT_DIRECTION_RTL

	var bg := CinematicBackdrop.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var tint := ColorRect.new()
	tint.color = Color(0.01, 0.04, 0.03, 0.20)
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tint)

	var top := ColorRect.new()
	top.color = Color(0.84, 0.68, 0.30, 0.72)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size = Vector2(0, 2)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)

	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 48)
	m.add_theme_constant_override("margin_right", 48)
	m.add_theme_constant_override("margin_top", 34)
	m.add_theme_constant_override("margin_bottom", 30)
	root.add_child(m)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	m.add_child(v)
	return v

func section_divider() -> HSeparator:
	var h := HSeparator.new()
	h.custom_minimum_size = Vector2(0, 3)
	h.add_theme_constant_override("separation", 0)
	h.modulate = C_GOLD
	return h

func transition_to(root: Control, path: String, duration: float = 0.28) -> void:
	var fade := ColorRect.new()
	fade.color = Color(0.015, 0.035, 0.03, 0.0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(fade)
	var tw := root.create_tween()
	tw.tween_property(fade, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	await tw.finished
	get_tree().change_scene_to_file(path)


func story_card_style() -> StyleBoxFlat:
	var s := box(Color(0.035, 0.10, 0.08, 0.96), 30, 1, Color(0.83, 0.67, 0.31, 0.86))
	s.shadow_color = Color(0, 0, 0, 0.48)
	s.shadow_size = 22
	s.shadow_offset = Vector2(0, 8)
	s.content_margin_left = 26
	s.content_margin_right = 26
	s.content_margin_top = 20
	s.content_margin_bottom = 20
	return s

func decision_style(bg: Color = C_GREEN) -> StyleBoxFlat:
	var s := box(bg, 22, 1, C_GOLD_DARK)
	s.shadow_color = Color(0, 0, 0, 0.34)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 4)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

func section_label(text_value: String) -> Label:
	var l := label(text_value, 21, C_GOLD)
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_outline_color", Color(0,0,0,0.35))
	return l

func spacer(h: int = 40) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c
