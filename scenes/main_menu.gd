extends Control

const MAP := "res://scenes/story_map.tscn"


func _ready() -> void:
	var box := UI.page(self)
	box.alignment = BoxContainer.ALIGNMENT_CENTER

	box.add_child(UI.brand_mark(190))
	box.add_child(UI.spacer(4))

	var title := UI.title_block("كليلة ودمنة", "حكايات الحيوان والحكمة")
	box.add_child(title)

	var intro := UI.label(
		"اقرأ الحكاية، استمع إليها، واتخذ القرار في اللحظة المناسبة.",
		34,
		UI.C_INK
	)
	intro.custom_minimum_size = Vector2(0, 72)
	box.add_child(intro)

	var count_badge := UI.pill("٥ حكايات · مغامرة واحدة مليئة بالحكمة", 28, UI.C_GOLD_DARK, Color("fff0c6"))
	count_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(count_badge)

	box.add_child(UI.spacer(18))

	var play := UI.button("ابدأ الحكايات", 52, 112)
	play.custom_minimum_size.x = 440
	play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play.pressed.connect(func(): get_tree().change_scene_to_file(MAP))
	box.add_child(play)

	var quit := UI.button("خروج", 34, 78)
	quit.custom_minimum_size.x = 220
	quit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit.add_theme_stylebox_override("normal", UI.box(Color("f0dfb7"), 18, 1, Color("b79b61")))
	quit.add_theme_stylebox_override("hover", UI.box(Color("fff2cf"), 18, 1, UI.C_GOLD))
	quit.add_theme_stylebox_override("pressed", UI.box(Color("e5ca96"), 18, 1, UI.C_GOLD_DARK))
	quit.add_theme_color_override("font_color", UI.C_GREEN_DARK)
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
