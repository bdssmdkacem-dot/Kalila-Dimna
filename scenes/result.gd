extends Control

const MAP := "res://scenes/story_map.tscn"
const PLAYER := "res://scenes/story_player.tscn"

func _ready() -> void:
	var story: Dictionary = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return

	var page := UI.page(self, "parchment")
	page.alignment = BoxContainer.ALIGNMENT_CENTER

	var hero := PanelContainer.new()
	hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero.custom_minimum_size = Vector2(0, 470)
	hero.add_theme_stylebox_override("panel", UI.parchment_style(24, 2))
	page.add_child(hero)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 6)
	hero.add_child(content)

	var complete := UI.label("✦  اكتملت الحكاية  ✦", 25, UI.C_GOLD_DARK)
	content.add_child(complete)

	var title := UI.label(String(story.title), 50, UI.C_GREEN_DARK)
	content.add_child(title)

	var stars := UI.label(UI.star_text(GameState.last_stars), 46, UI.C_GOLD_DARK)
	stars.custom_minimum_size = Vector2(0, 62)
	content.add_child(stars)

	var moral_title := UI.label("الحكمة", 20, UI.C_GOLD_DARK)
	content.add_child(moral_title)

	var quote := UI.label("«%s»" % String(story.moral), 28, UI.C_INK)
	quote.custom_minimum_size = Vector2(0, 82)
	content.add_child(quote)

	var divider := UI.section_divider()
	divider.custom_minimum_size.x = 230
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(divider)

	var idx := StoryLoader.index_of(String(story.id))
	if idx >= 0 and idx + 1 < StoryLoader.stories.size():
		var next := UI.button("الحكاية التالية  →", 27, 60)
		next.custom_minimum_size.x = 290
		next.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		next.pressed.connect(func(): _transition_to_story(StoryLoader.stories[idx + 1]))
		content.add_child(next)

	var again := UI.button("إعادة الحكاية", 21, 52)
	again.custom_minimum_size.x = 230
	again.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	again.add_theme_stylebox_override("normal", UI._button_style(UI.C_GREEN_DARK, UI.C_GOLD_DARK, 16))
	again.pressed.connect(func(): _transition_to_story(story))
	content.add_child(again)

	var map := UI.button("العودة إلى الخريطة", 20, 50)
	map.custom_minimum_size.x = 230
	map.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	map.add_theme_stylebox_override("normal", UI._button_style(UI.C_GREEN, UI.C_GOLD_DARK, 16))
	map.pressed.connect(func(): UI.transition_to(self, MAP))
	content.add_child(map)

func _transition_to_story(next_story: Dictionary) -> void:
	GameState.current_story = next_story
	UI.transition_to(self, PLAYER)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		UI.transition_to(self, MAP)
