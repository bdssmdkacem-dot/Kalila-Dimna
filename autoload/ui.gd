extends Node
## ثيم اللعبة + دوال مساعدة لبناء الواجهات بالكود (RTL).

const C_BG := Color("f3e6c4")
const C_INK := Color("3b2a17")
const C_GREEN := Color("1f5c4a")
const C_GREEN_HOVER := Color("287a62")
const C_GREEN_DARK := Color("174637")
const C_GOLD := Color("c9a227")
const C_GOLD_DARK := Color("8a6d10")
const C_GOOD := Color("2e7d32")
const C_BAD := Color("b23a3a")
const C_CARD := Color("fff8e6")
const FONT_PATH := "res://assets/fonts/Amiri-Regular.ttf"


func _ready() -> void:
	var root := get_tree().root
	root.theme = _build_theme()


func box(color: Color, radius: int = 28, border: int = 0, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(24)
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = border_color
	return s


func _build_theme() -> Theme:
	var t := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		t.default_font = load(FONT_PATH) as Font
	t.default_font_size = 44
	t.set_stylebox("normal", "Button", box(C_GREEN))
	t.set_stylebox("hover", "Button", box(C_GREEN_HOVER))
	t.set_stylebox("pressed", "Button", box(C_GREEN_DARK))
	t.set_stylebox("focus", "Button", box(Color.TRANSPARENT, 28, 5, C_GOLD))
	t.set_stylebox("disabled", "Button", box(Color("b9ad8d")))
	t.set_color("font_color", "Button", C_CARD)
	t.set_color("font_hover_color", "Button", C_CARD)
	t.set_color("font_pressed_color", "Button", C_CARD)
	t.set_color("font_focus_color", "Button", C_CARD)
	t.set_color("font_disabled_color", "Button", Color("fff8e6"))
	t.set_font_size("font_size", "Button", 46)
	t.set_color("font_color", "Label", C_INK)
	t.set_constant("line_spacing", "Label", 16)
	t.set_stylebox("panel", "PanelContainer", box(C_CARD, 32, 4, C_GOLD))
	return t


func label(text: String, size: int = 44, color: Color = C_INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func button(text: String, size: int = 46, min_h: int = 130) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_h)
	b.add_theme_font_size_override("font_size", size)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return b


## يبني خلفية + هوامش + VBox ويعيده لإضافة المحتوى.
func page(root: Control) -> VBoxContainer:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.layout_direction = Control.LAYOUT_DIRECTION_RTL
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var band := ColorRect.new()
	band.color = C_GREEN
	band.set_anchors_preset(Control.PRESET_TOP_WIDE)
	band.custom_minimum_size = Vector2(0, 28)
	root.add_child(band)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 48)
	m.add_theme_constant_override("margin_right", 48)
	m.add_theme_constant_override("margin_top", 90)
	m.add_theme_constant_override("margin_bottom", 70)
	root.add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 28)
	m.add_child(v)
	return v


func spacer(h: int = 40) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c
