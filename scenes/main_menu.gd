extends Control

const MAP := "res://scenes/story_map.tscn"
const FOREST_BG := "res://assets/images/new/main_menu_forest.svg"

func _ready() -> void:
	var page := UI.page(self, "forest")

	var top := HBoxContainer.new()
	top.custom_minimum_size = Vector2(0, 62)
	top.add_theme_constant_override("separation", 10)
	page.add_child(top)

	var settings := UI.icon_button("⚙", 29, 56)
	settings.tooltip_text = "الإعدادات"
	top.add_child(settings)

	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(top_spacer)

	var book := UI.icon_button("▤", 30, 56)
	book.tooltip_text = "خريطة الحكايات"
	book.pressed.connect(func(): UI.transition_to(self, MAP))
	top.add_child(book)

	var hero := VBoxContainer.new()
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.alignment = BoxContainer.ALIGNMENT_CENTER
	hero.add_theme_constant_override("separation", 6)
	page.add_child(hero)

	var dark_card := PanelContainer.new()
	dark_card.custom_minimum_size = Vector2(0, 0)
	dark_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dark_card.add_theme_stylebox_override("panel", UI.box(Color(0.015, 0.07, 0.055, 0.30), 28, 1, Color(0.84, 0.67, 0.29, 0.36)))
	hero.add_child(dark_card)

	var content_box := VBoxContainer.new()
	content_box.alignment = BoxContainer.ALIGNMENT_CENTER
	content_box.add_theme_constant_override("separation", 6)
	dark_card.add_child(content_box)

	var mark := UI.brand_mark(116)
	content_box.add_child(mark)

	var title := UI.label("كليلة ودمنة", 70, UI.C_GOLD_LIGHT)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
	title.add_theme_constant_override("shadow_offset_y", 4)
	content_box.add_child(title)

	var subtitle := UI.label("حِكم وأمثال من زمن بعيد", 27, UI.C_PAPER_LIGHT)
	content_box.add_child(subtitle)

	var divider := UI.section_divider()
	divider.custom_minimum_size.x = 230
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content_box.add_child(divider)

	var intro := UI.label("استمع إلى الحكاية، اختر طريقها، واكتشف الحكمة.", 22, UI.C_PAPER_DEEP)
	intro.custom_minimum_size = Vector2(0, 42)
	content_box.add_child(intro)

	var start := UI.button("ابدأ الحكاية  →", 35, 72)
	start.custom_minimum_size.x = 300
	start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start.add_theme_stylebox_override("normal", UI._button_style(UI.C_GREEN_DARK, UI.C_GOLD, 18))
	start.add_theme_stylebox_override("hover", UI._button_style(UI.C_GREEN, UI.C_GOLD_LIGHT, 18))
	start.pressed.connect(func(): UI.transition_to(self, MAP))
	content_box.add_child(start)

	var meta := UI.label("%d حكايات  ·  اختيارات  ·  نجوم  ·  عِبر" % StoryLoader.stories.size(), 18, Color(0.86, 0.82, 0.68, 0.82))
	content_box.add_child(meta)

	var footer := UI.label("رحلة تفاعلية للأطفال والعائلة", 16, Color(0.78, 0.78, 0.66, 0.75))
	footer.custom_minimum_size = Vector2(0, 30)
	page.add_child(footer)

	var intro_tween := create_tween().set_parallel(true)
	dark_card.modulate.a = 0.0
	dark_card.scale = Vector2(0.97, 0.97)
	intro_tween.tween_property(dark_card, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE)
	intro_tween.tween_property(dark_card, "scale", Vector2.ONE, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	mark.modulate.a = 0.0
	intro_tween.tween_property(mark, "modulate:a", 1.0, 0.55).set_delay(0.10)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
