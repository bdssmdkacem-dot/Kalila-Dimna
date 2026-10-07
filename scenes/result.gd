extends Control
## نهاية سينمائية للحكاية مع مكافأة واضحة ومسار متابعة.

const MAP := "res://scenes/story_map.tscn"
const PLAYER := "res://scenes/story_player.tscn"

func _ready() -> void:
	var story: Dictionary = GameState.current_story
	if story.is_empty():
		get_tree().change_scene_to_file(MAP)
		return

	var fx := RewardFX.new()
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fx)

	var page := UI.page(self)
	page.alignment = BoxContainer.ALIGNMENT_CENTER

	var hero := UI.hero_panel()
	hero.custom_minimum_size = Vector2(0, 620)
	hero.modulate.a = 0.0
	hero.scale = Vector2(0.97, 0.97)
	page.add_child(hero)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 10)
	hero.add_child(content)

	var complete := UI.label("✦  اكتملت الرحلة  ✦", 32, UI.C_GOLD)
	content.add_child(complete)
	var story_title := UI.label(story.title, 66, UI.C_GOLD_LIGHT)
	content.add_child(story_title)

	var stars := StarRow.new().setup(GameState.last_stars, 82.0)
	stars.modulate.a = 0.0
	stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(stars)

	var quote := UI.label("«%s»" % story.moral, 36, UI.C_PAPER)
	quote.custom_minimum_size = Vector2(0, 100)
	content.add_child(quote)

	var divider := UI.section_divider()
	divider.custom_minimum_size.x = 300
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(divider)

	var idx := StoryLoader.index_of(story.id)
	if idx >= 0 and idx + 1 < StoryLoader.stories.size():
		var nxt := UI.button("الحكاية التالية  →", 44, 92)
		nxt.custom_minimum_size.x = 390
		nxt.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		nxt.pressed.connect(func(): _transition_to_story(StoryLoader.stories[idx + 1]))
		content.add_child(nxt)

	var again := UI.button("إعادة الحكاية", 30, 68)
	again.custom_minimum_size.x = 260
	again.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	again.add_theme_stylebox_override("normal", UI.box(Color(0.04, 0.15, 0.12, 0.78), 16, 1, Color("#53645b")))
	again.pressed.connect(func(): _transition_to_story(story))
	content.add_child(again)

	var map := UI.button("العودة إلى الطريق", 29, 68)
	map.custom_minimum_size.x = 260
	map.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	map.add_theme_stylebox_override("normal", UI.box(Color(0.04, 0.15, 0.12, 0.70), 16, 1, Color("#53645b")))
	map.pressed.connect(func(): UI.transition_to(self, MAP))
	content.add_child(map)

	var intro_tween := create_tween().set_parallel(true)
	intro_tween.tween_property(hero, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(hero, "scale", Vector2.ONE, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(complete, "modulate", Color(1.12, 1.06, 0.82), 0.65).set_delay(0.25)
	intro_tween.tween_property(stars, "modulate:a", 1.0, 0.7).set_delay(0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(complete, "modulate", Color.WHITE, 0.8).set_delay(0.9)
	
func _transition_to_story(next_story: Dictionary) -> void:
	GameState.current_story = next_story
	UI.transition_to(self, PLAYER)

func _play(story: Dictionary) -> void:
	_transition_to_story(story)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(MAP)
