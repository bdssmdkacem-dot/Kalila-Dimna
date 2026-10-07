extends Control

const MAP := "res://scenes/story_map.tscn"

func _ready() -> void:
	var page := UI.page(self)
	page.alignment = BoxContainer.ALIGNMENT_CENTER

	var hero := UI.hero_panel()
	hero.custom_minimum_size = Vector2(0, 690)
	hero.modulate.a = 0.0
	hero.scale = Vector2(0.96, 0.96)
	page.add_child(hero)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 10)
	hero.add_child(content)

	var mark := UI.brand_mark(205)
	mark.modulate.a = 0.0
	mark.scale = Vector2(0.82, 0.82)
	content.add_child(mark)

	var eyebrow := UI.label("مكتبة الحكايات الشرقية", 25, UI.C_GOLD)
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

	var meta := UI.label("%d حكايات  ·  أصوات  ·  اختيارات  ·  عِبر" % StoryLoader.stories.size(), 23, UI.C_MUTED)
	content.add_child(meta)

	var quit := UI.button("خروج", 28, 64)
	quit.custom_minimum_size.x = 150
	quit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit.add_theme_stylebox_override("normal", UI.box(Color(0.03, 0.11, 0.09, 0.72), 16, 1, Color("#485a52")))
	quit.add_theme_stylebox_override("hover", UI.box(Color(0.06, 0.18, 0.14, 0.90), 16, 1, UI.C_GOLD))
	quit.pressed.connect(func(): get_tree().quit())
	content.add_child(quit)

	var intro_tween := create_tween().set_parallel(true)
	intro_tween.tween_property(hero, "modulate:a", 1.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(hero, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(mark, "modulate:a", 1.0, 0.8).set_delay(0.12)
	intro_tween.tween_property(mark, "scale", Vector2.ONE, 0.9).set_delay(0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var glow := create_tween().set_loops()
	glow.tween_property(mark, "modulate", Color(1.08, 1.03, 0.86), 1.8).set_trans(Tween.TRANS_SINE)
	glow.tween_property(mark, "modulate", Color.WHITE, 1.8).set_trans(Tween.TRANS_SINE)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
