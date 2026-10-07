extends Control
## خريطة رحلة سينمائية: كل حكاية محطة على طريق واحد.

const MENU := "res://scenes/main_menu.tscn"
const PLAYER := "res://scenes/story_player.tscn"

func _ready() -> void:
	var page := UI.page(self)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 74)
	header.add_theme_constant_override("separation", 14)
	page.add_child(header)

	var back := UI.button("‹  رجوع", 27, 62)
	back.custom_minimum_size.x = 145
	back.pressed.connect(func(): UI.transition_to(self, MENU))
	header.add_child(back)

	var title_wrap := UI.title_block("طريق الحكايات", "كل محطة تفتح لك حكاية جديدة")
	title_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_wrap)

	var badge := UI.pill("%d حكايات" % StoryLoader.stories.size(), 24)
	badge.custom_minimum_size.x = 150
	header.add_child(badge)

	var stage := Control.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.custom_minimum_size = Vector2(0, 610)
	page.add_child(stage)

	var path_layer := StoryPath.new()
	path_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(path_layer)

	var title := UI.label("اختر محطتك", 30, UI.C_PAPER)
	title.position = Vector2(0, 8)
	title.size = Vector2(stage.size.x, 52)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	stage.add_child(title)

	for i in StoryLoader.stories.size():
		_add_node(stage, i)

func _add_node(stage: Control, i: int) -> void:
	var unlocked := GameState.is_unlocked(i)
	var s: Dictionary = StoryLoader.stories[i]
	var node := Button.new()
	node.text = "✦" if unlocked else "🔒"
	node.add_theme_font_size_override("font_size", 48)
	node.custom_minimum_size = Vector2(148, 148)
	node.disabled = not unlocked
	node.add_theme_stylebox_override("normal", UI.box(Color("#102f27"), 74, 2, UI.C_GOLD_DARK))
	node.add_theme_stylebox_override("hover", UI.box(Color("#1d5a47"), 74, 3, UI.C_GOLD_LIGHT))
	node.add_theme_stylebox_override("pressed", UI.box(Color("#09261f"), 74, 3, UI.C_GOLD))
	node.add_theme_stylebox_override("disabled", UI.box(Color("#172521"), 66, 2, Color("#4b5853")))
	node.add_theme_color_override("font_color", UI.C_GOLD_LIGHT)
	node.pressed.connect(_on_story_pressed.bind(s))

	var pos := StoryPath.new().node_positions[i]
	node.anchor_left = pos.x
	node.anchor_right = pos.x
	node.anchor_top = pos.y
	node.anchor_bottom = pos.y
	node.offset_left = -66
	node.offset_right = 66
	node.offset_top = -66
	node.offset_bottom = 66
	stage.add_child(node)

	var caption := UI.label("%d  ·  %s" % [i + 1, s.title], 25, UI.C_PAPER if unlocked else UI.C_MUTED)
	caption.anchor_left = pos.x - 0.12
	caption.anchor_right = pos.x + 0.12
	caption.anchor_top = pos.y
	caption.anchor_bottom = pos.y
	caption.offset_top = 72
	caption.offset_bottom = 126
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(caption)

func _on_story_pressed(story: Dictionary) -> void:
	GameState.current_story = story
	UI.transition_to(self, PLAYER)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		UI.transition_to(self, MENU)
