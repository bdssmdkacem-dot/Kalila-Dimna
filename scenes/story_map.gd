extends Control
## خريطة القصص: بطاقات حكايات بطابع مخطوطات، مع فتح متسلسل.

const MENU := "res://scenes/main_menu.tscn"
const PLAYER := "res://scenes/story_player.tscn"


func _ready() -> void:
	var box := UI.page(self)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	header.custom_minimum_size = Vector2(0, 84)
	box.add_child(header)

	var back := UI.button("رجوع", 30, 70)
	back.custom_minimum_size.x = 150
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU))
	header.add_child(back)

	var title_wrap := UI.title_block("خريطة الحكايات", "اختر حكاية وافتح صفحات جديدة من عالم كليلة ودمنة")
	title_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_wrap)

	var badge := UI.pill("%d حكايات" % StoryLoader.stories.size(), 28, UI.C_GOLD_DARK, Color("fff0c6"))
	badge.custom_minimum_size.x = 150
	header.add_child(badge)

	box.add_child(UI.section_divider())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)

	for i in StoryLoader.stories.size():
		list.add_child(_make_card(i))


func _make_card(i: int) -> Button:
	var s: Dictionary = StoryLoader.stories[i]
	var unlocked := GameState.is_unlocked(i)

	var card := UI.card_button(220)
	card.disabled = not unlocked
	card.pressed.connect(_on_story_pressed.bind(s))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(head)

	var number := UI.pill("حكاية %d" % (i + 1), 28, UI.C_PAPER_LIGHT, UI.C_GREEN_DARK)
	number.custom_minimum_size.x = 150
	head.add_child(number)

	var title := UI.label(s.title, 48, UI.C_GREEN_DARK if unlocked else UI.C_MUTED)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(title)

	var moral := UI.label("«%s»" % String(s.get("moral", "")), 30, UI.C_TERRACOTTA_DARK if unlocked else UI.C_MUTED)
	moral.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	moral.custom_minimum_size = Vector2(0, 50)
	content.add_child(moral)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 14)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(footer)

	if unlocked:
		var stars := StarRow.new().setup(GameState.stars_of(s.id), 50.0)
		stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		footer.add_child(stars)

		var status := UI.label("جاهزة للعب", 27, UI.C_GREEN)
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(status)
	else:
		var lock := UI.label("مقفلة · أكمل الحكاية السابقة أولاً", 27, UI.C_MUTED)
		lock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		footer.add_child(lock)

	return card


func _on_story_pressed(story: Dictionary) -> void:
	GameState.current_story = story
	get_tree().change_scene_to_file(PLAYER)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(MENU)
