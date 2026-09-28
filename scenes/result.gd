extends Control
## شاشة النتيجة: النجوم + العبرة + التالي.

const MAP := "res://scenes/story_map.tscn"
const PLAYER := "res://scenes/story_player.tscn"


func _ready() -> void:
	var story: Dictionary = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return
	var box := UI.page(self)
	box.add_child(UI.label("أحسنت!", 110, UI.C_GREEN))
	box.add_child(UI.label(story.title, 56, UI.C_GOLD_DARK))

	var stars := StarRow.new().setup(GameState.last_stars, 120.0)
	stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(stars)

	var card := PanelContainer.new()
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(card)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 24)
	card.add_child(v)
	v.add_child(UI.label("العبرة", 60, UI.C_GREEN))
	v.add_child(UI.label(story.moral, 54))

	var idx := StoryLoader.index_of(story.id)
	if idx >= 0 and idx + 1 < StoryLoader.stories.size():
		var nxt := UI.button("الحكاية التالية", 52, 130)
		nxt.pressed.connect(_play.bind(StoryLoader.stories[idx + 1]))
		box.add_child(nxt)

	var again := UI.button("أعد الحكاية", 46, 120)
	again.pressed.connect(_play.bind(story))
	box.add_child(again)

	var map := UI.button("خريطة الحكايات", 46, 120)
	map.pressed.connect(func(): get_tree().change_scene_to_file(MAP))
	box.add_child(map)


func _play(story: Dictionary) -> void:
	GameState.current_story = story
	get_tree().change_scene_to_file(PLAYER)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(MAP)
