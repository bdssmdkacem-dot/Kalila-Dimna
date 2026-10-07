extends Control
## خريطة الحكايات — مخطوطة عمودية موحدة لكل القصص.

const MENU := "res://scenes/main_menu.tscn"
const PLAYER := "res://scenes/story_player.tscn"

const STORY_ICONS := {
	"lion_bull": "res://assets/images/new/lion_medallion_new.svg",
	"crow_snake": "res://assets/images/new/crow_medallion_new.svg",
	"monkey_turtle": "res://assets/images/new/monkey_medallion_new.svg",
	"dove_ring": "res://assets/images/new/dove_medallion_new.svg",
	"lion_hare": "res://assets/images/new/hare_medallion_new.svg",
	"rat_cat": "res://assets/images/new/rat_medallion_new.svg",
	"owls_crows": "res://assets/images/new/owl_medallion_new.svg",
	"jackal_lion": "res://assets/images/new/jackal_medallion_new.svg",
	"turtle_ducks": "res://assets/images/new/duck_medallion_new.svg"
}

func _ready() -> void:
	var page := UI.page(self, "parchment")

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 62)
	header.add_theme_constant_override("separation", 8)
	page.add_child(header)

	var back := UI.icon_button("‹", 34, 56)
	back.tooltip_text = "رجوع"
	back.pressed.connect(func(): UI.transition_to(self, MENU))
	header.add_child(back)

	var title_wrap := UI.title_block("خريطة الحكايات", "اختر محطة لتفتح حكاية جديدة")
	title_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_wrap)

	var badge := UI.pill("%d/%d  ★" % [_completed_count(), StoryLoader.stories.size()], 22, UI.C_GOLD_DARK, Color("#ead7a6"))
	badge.custom_minimum_size.x = 108
	header.add_child(badge)

	var stage := Control.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.custom_minimum_size = Vector2(0, 0)
	page.add_child(stage)

	var path_layer := StoryPath.new()
	path_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(path_layer)

	var hint := UI.label("رحلة الحكمة", 22, UI.C_GOLD_DARK)
	hint.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hint.offset_top = 0
	hint.offset_bottom = 34
	stage.add_child(hint)

	for i in StoryLoader.stories.size():
		_add_node(stage, i)

func _completed_count() -> int:
	var count := 0
	for s in StoryLoader.stories:
		if GameState.stars_of(String(s.id)) > 0:
			count += 1
	return count

func _animal_texture(story: Dictionary) -> Texture2D:
	var path := String(STORY_ICONS.get(String(story.id), ""))
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _add_node(stage: Control, i: int) -> void:
	var unlocked := GameState.is_unlocked(i)
	var s: Dictionary = StoryLoader.stories[i]
	var pos: Vector2 = StoryPath.NODE_POSITIONS[i]

	var node := Button.new()
	node.text = ""
	node.focus_mode = Control.FOCUS_NONE
	node.disabled = not unlocked
	node.custom_minimum_size = Vector2(96, 96)
	node.anchor_left = pos.x
	node.anchor_right = pos.x
	node.anchor_top = pos.y
	node.anchor_bottom = pos.y
	node.offset_left = -48
	node.offset_right = 48
	node.offset_top = -48
	node.offset_bottom = 48
	node.add_theme_stylebox_override("normal", UI.box(UI.C_GREEN_DARK, 48, 2, UI.C_GOLD_DARK))
	node.add_theme_stylebox_override("hover", UI.box(UI.C_GREEN, 48, 3, UI.C_GOLD_LIGHT))
	node.add_theme_stylebox_override("pressed", UI.box(Color("#0b2a21"), 48, 3, UI.C_GOLD))
	node.add_theme_stylebox_override("disabled", UI.box(Color("#38423d"), 48, 2, Color("#6d6b5a")))

	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 12
	icon.offset_right = -12
	icon.offset_top = 12
	icon.offset_bottom = -12
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = _animal_texture(s)
	icon.modulate = Color.WHITE if unlocked else Color(0.35, 0.36, 0.31, 0.72)
	node.add_child(icon)

	if not unlocked:
		var lock := UI.label("🔒", 25, UI.C_PAPER_LIGHT)
		lock.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		lock.offset_left = -34
		lock.offset_right = -5
		lock.offset_top = -38
		lock.offset_bottom = -5
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.add_child(lock)

	node.pressed.connect(_on_story_pressed.bind(s))
	stage.add_child(node)

	var card := PanelContainer.new()
	card.anchor_left = pos.x + 0.08
	card.anchor_right = 0.93
	card.anchor_top = pos.y - 0.065
	card.anchor_bottom = pos.y + 0.065
	card.offset_top = -4
	card.offset_bottom = 4
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", UI.parchment_style(16, 2))
	if not unlocked:
		card.modulate = Color(0.72, 0.69, 0.58, 0.75)
	stage.add_child(card)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	card.add_child(row)

	var title := UI.label("%d  ·  %s" % [i + 1, s.title], 22 if unlocked else 20, UI.C_INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(title)

	var stars := UI.label(UI.star_text(GameState.stars_of(String(s.id))), 19, UI.C_GOLD_DARK)
	stars.custom_minimum_size.x = 74
	row.add_child(stars)

func _on_story_pressed(story: Dictionary) -> void:
	GameState.current_story = story
	UI.transition_to(self, PLAYER)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		UI.transition_to(self, MENU)
