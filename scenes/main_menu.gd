extends Control

const MAP := "res://scenes/story_map.tscn"


func _ready() -> void:
	var box := UI.page(self)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(UI.label("كليلة ودمنة", 130, UI.C_GREEN))
	box.add_child(UI.label("حكايات الحكمة والعبرة", 56, UI.C_GOLD_DARK))
	box.add_child(StarRow.new().setup(3, 90.0))
	box.get_child(-1).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(UI.spacer(80))
	var play := UI.button("ابدأ الحكايات", 64, 180)
	play.pressed.connect(func(): get_tree().change_scene_to_file(MAP))
	box.add_child(play)
	var quit := UI.button("خروج", 48, 130)
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
