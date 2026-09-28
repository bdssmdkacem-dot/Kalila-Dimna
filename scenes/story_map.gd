extends Control
## خريطة القصص: بطاقة لكل حكاية، تُفتح بالتسلسل.

const MENU := "res://scenes/main_menu.tscn"
const PLAYER := "res://scenes/story_player.tscn"


func _ready() -> void:
	var box := UI.page(self)
	box.add_child(UI.label("خريطة الحكايات", 84, UI.C_GREEN))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 26)
	scroll.add_child(list)

	for i in StoryLoader.stories.size():
		list.add_child(_make_card(i))

	var back := UI.button("رجوع", 46, 120)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU))
	box.add_child(back)


func _make_card(i: int) -> Button:
	var s: Dictionary = StoryLoader.stories[i]
	var unlocked := GameState.is_unlocked(i)

	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 230)
	card.disabled = not unlocked
	card.pressed.connect(_on_story_pressed.bind(s))

	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(m)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 10)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_child(v)

	var title := UI.label("%d. %s" % [i + 1, s.title], 56, UI.C_CARD)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(title)

	if unlocked:
		var stars := StarRow.new().setup(GameState.stars_of(s.id), 60.0)
		stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(stars)
	else:
		var lock := UI.label("مقفلة — أكمل الحكاية السابقة أولاً", 36, UI.C_CARD)
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(lock)
	return card


func _on_story_pressed(story: Dictionary) -> void:
	GameState.current_story = story
	get_tree().change_scene_to_file(PLAYER)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(MENU)
