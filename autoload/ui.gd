extends Node
## هوية اللعبة + أدوات بناء الواجهات (RTL).
## لغة التصميم: مخطوطة دافئة + أخضر الغابة + ذهب العناوين + طين دافئ للأفعال الثانوية.

const C_PAPER := Color("f4e3ba")
const C_PAPER_LIGHT := Color("fff8e7")
const C_PAPER_DEEP := Color("e5c98f")
const C_INK := Color("2e2117")
const C_GREEN := Color("1f5c4a")
const C_GREEN_LIGHT := Color("2f7a64")
const C_GREEN_DARK := Color("143e33")
const C_GOLD := Color("d6ad4f")
const C_GOLD_LIGHT := Color("f0d487")
const C_GOLD_DARK := Color("8a6d10")
const C_TERRACOTTA := Color("a35c3d")
const C_TERRACOTTA_DARK := Color("7e402b")
const C_GOOD := Color("2e7d32")
const C_BAD := Color("a84444")
const C_CARD := Color("fff7df")
const C_MUTED := Color("8e7b5b")
const FONT_PATH := "res://assets/fonts/Amiri-Regular.ttf"
const BRAND_MARK_PATH := "res://assets/branding/brand_mark.svg"
const PARCHMENT_PATH := "res://assets/branding/parchment.svg"


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
	s.shadow_color = Color(0.08, 0.05, 0.02, 0.16)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 3)
	return s


func _button_style(bg: Color, border: Color, radius: int = 20) -> StyleBoxFlat:
	var s := box(bg, radius, 2, border)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


func _build_theme() -> Theme:
	var t := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		t.default_font = load(FONT_PATH) as Font
	t.default_font_size = 36

	t.set_stylebox("normal", "Button", _button_style(C_GREEN, C_GOLD_DARK))
	t.set_stylebox("hover", "Button", _button_style(C_GREEN_LIGHT, C_GOLD_LIGHT))
	t.set_stylebox("pressed", "Button", _button_style(C_GREEN_DARK, C_GOLD))
	t.set_stylebox("focus", "Button", _button_style(C_GREEN, C_GOLD_LIGHT))
	t.set_stylebox("disabled", "Button", _button_style(Color("b9a987"), Color("a08e6a")))
	t.set_color("font_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", C_GOLD_LIGHT)
	t.set_color("font_focus_color", "Button", C_PAPER_LIGHT)
	t.set_color("font_disabled_color", "Button", Color("f5ecd8"))
	t.set_font_size("font_size", "Button", 42)

	t.set_color("font_color", "Label", C_INK)
	t.set_color("font_outline_color", "Label", Color(0, 0, 0, 0))
	t.set_constant("line_spacing", "Label", 12)

	t.set_stylebox("panel", "PanelContainer", box(C_CARD, 28, 2, C_GOLD))
	return t


func label(text: String, size: int = 44, color: Color = C_INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func button(text: String, size: int = 46, min_h: int = 116) -> Button:
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
	b.add_theme_stylebox_override("normal", _button_style(C_CARD, Color("c4a85b"), 26))
	b.add_theme_stylebox_override("hover", _button_style(Color("fff9e8"), C_GOLD, 26))
	b.add_theme_stylebox_override("pressed", _button_style(Color("f2e1b8"), C_GOLD_DARK, 26))
	b.add_theme_stylebox_override("disabled", _button_style(Color("d8ceb7"), Color("b5a789"), 26))
	return b


func pill(text_value: String, size: int = 30, fg: Color = C_GOLD_DARK, bg: Color = Color("fff1c9")) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, 18, 1, Color("c5a459")))
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
	v.add_theme_constant_override("separation", 2)
	var t := label(title, 78, C_GREEN)
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.12))
	t.add_theme_constant_override("shadow_offset_y", 3)
	v.add_child(t)
	if subtitle != "":
		v.add_child(label(subtitle, 34, C_GOLD_DARK))
	return v


## يبني خلفية المخطوطة + الهوامش + VBox موحّد لكل الشاشات.
func page(root: Control) -> VBoxContainer:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.layout_direction = Control.LAYOUT_DIRECTION_RTL

	var bg := TextureRect.new()
	if ResourceLoader.exists(PARCHMENT_PATH):
		bg.texture = load(PARCHMENT_PATH) as Texture2D
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	var wash := ColorRect.new()
	wash.color = Color(0.10, 0.07, 0.03, 0.025)
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(wash)

	var top_band := ColorRect.new()
	top_band.color = C_GREEN_DARK
	top_band.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_band.custom_minimum_size = Vector2(0, 18)
	top_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top_band)

	var gold_line := ColorRect.new()
	gold_line.color = C_GOLD
	gold_line.set_anchors_preset(Control.PRESET_TOP_WIDE)
	gold_line.offset_top = 18
	gold_line.offset_bottom = 22
	gold_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(gold_line)

	var bottom_line := ColorRect.new()
	bottom_line.color = Color(0.54, 0.40, 0.12, 0.34)
	bottom_line.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_line.offset_top = -4
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bottom_line)

	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 56)
	m.add_theme_constant_override("margin_right", 56)
	m.add_theme_constant_override("margin_top", 42)
	m.add_theme_constant_override("margin_bottom", 42)
	root.add_child(m)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 20)
	m.add_child(v)
	return v


func section_divider() -> HSeparator:
	var h := HSeparator.new()
	h.custom_minimum_size = Vector2(0, 6)
	h.add_theme_constant_override("separation", 0)
	h.modulate = C_GOLD
	return h


func spacer(h: int = 40) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c
