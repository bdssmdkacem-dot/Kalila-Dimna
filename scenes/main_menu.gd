extends Control

const MAP := "res://scenes/story_map.tscn"

func _ready() -> void:
	var page := UI.page(self)
	page.alignment = BoxContainer.ALIGNMENT_CENTER

	var hero := UI.hero_panel()
	hero.custom_minimum_size = Vector2(0, 690)
	page.add_child(hero)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 10)
	hero.add_child(content)

	content.add_child(UI.brand_mark(205))

	var eyebrow := UI.label("مكتبة الحكايات الشرقية", 25, UI.C_GOLD)
	eyebrow.custom_minimum_size = Vector2(0, 38)
	content.add_child(eyebrow)

	var title := UI.label("كليلة ودمنة", 92, UI.C_GOLD_LIGHT)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	title.add_theme_constant_override("shadow_offset_y", 5)
	content.add_child(title)

	var subtitle := UI.label("حين تتكلم الحيوانات… تبدأ الحكمة.", 38, UI.C_PAPER)
	content.add_child(subtitle)

	var line := UI.section_divider()
	line.custom_minimum_size.x = 360
	line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(line)

	var intro := UI.label("حكايات تفاعلية بصوتٍ ومشهدٍ وقرارٍ يغيّر طريق القصة.", 29, UI.C_PAPER_DEEP)
	intro.custom_minimum_size = Vector2(0, 58)
	content.add_child(intro)

	var play := UI.button("ابدأ الرحلة  ✦", 48, 104)
	play.custom_minimum_size.x = 430
	play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play.pressed.connect(func(): get_tree().change_scene_to_file(MAP))
	content.add_child(play)

	var meta := UI.label("٥ حكايات  ·  أصوات  ·  اختيارات  ·  عِبر", 23, UI.C_MUTED)
	content.add_child(meta)

	var quit := UI.button("خروج", 28, 64)
	quit.custom_minimum_size.x = 150
	quit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit.add_theme_stylebox_override("normal", UI.box(Color(0.03, 0.11, 0.09, 0.72), 16, 1, Color("#485a52")))
	quit.add_theme_stylebox_override("hover", UI.box(Color(0.06, 0.18, 0.14, 0.90), 16, 1, UI.C_GOLD))
	quit.pressed.connect(func(): get_tree().quit())
	content.add_child(quit)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
