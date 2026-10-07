extends Control
## شاشة النتيجة: نهاية الحكاية + النجوم + العبرة + الحركة التالية.

const MAP := "res://scenes/story_map.tscn"
const PLAYER := "res://scenes/story_player.tscn"


func _ready() -> void:
	var story: Dictionary = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return

	var box := UI.page(self)
	box.alignment = BoxContainer.ALIGNMENT_CENTER

	box.add_child(UI.brand_mark(132))
	box.add_child(UI.label("انتهت الحكاية", 34, UI.C_GOLD_DARK))
	box.add_child(UI.label(story.title, 58, UI.C_GREEN))
	box.add_child(UI.spacer(4))

	var stars := StarRow.new().setup(GameState.last_stars, 92.0)
	stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(stars)

	var card := PanelContainer.new()
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", UI.box(UI.C_CARD, 30, 2, UI.C_GOLD))
	box.add_child(card)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)

	v.add_child(UI.pill("العِبرة", 30, UI.C_PAPER_LIGHT, UI.C_GREEN_DARK))
	v.add_child(UI.label(story.moral, 45, UI.C_INK))

	var idx := StoryLoader.index_of(story.id)
	if idx >= 0 and idx + 1 < StoryLoader.stories.size():
		var nxt := UI.button("الحكاية التالية", 48, 100)
		nxt.pressed.connect(_play.bind(StoryLoader.stories[idx + 1]))
		box.add_child(nxt)

	var again := UI.button("أعد الحكاية", 38, 86)
	again.add_theme_stylebox_override("normal", UI.box(Color("f0dfb7"), 20, 1, Color("b79b61")))
	again.add_theme_stylebox_override("hover", UI.box(Color("fff2cf"), 20, 1, UI.C_GOLD))
	again.add_theme_color_override("font_color", UI.C_GREEN_DARK)
	again.pressed.connect(_play.bind(story))
	box.add_child(again)

	var map := UI.button("خريطة الحكايات", 38, 86)
	map.add_theme_stylebox_override("normal", UI.box(Color("f0dfb7"), 20, 1, Color("b79b61")))
	map.add_theme_stylebox_override("hover", UI.box(Color("fff2cf"), 20, 1, UI.C_GOLD))
	map.add_theme_color_override("font_color", UI.C_GREEN_DARK)
	map.pressed.connect(func(): get_tree().change_scene_to_file(MAP))
	box.add_child(map)


func _play(story: Dictionary) -> void:
	GameState.current_story = story
	get_tree().change_scene_to_file(PLAYER)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(MAP)
