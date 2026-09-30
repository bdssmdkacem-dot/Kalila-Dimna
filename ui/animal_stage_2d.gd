class_name AnimalStage2D
extends Control
## مسرح قصصي 2D للأسد والثور.
## يحافظ على واجهة AnimalStage القديمة: show_segment / set_speaker / start_cinematic.

const DESIGN_SIZE := Vector2(1200.0, 760.0)
const SAFE_LEFT := 105.0
const SAFE_RIGHT := 1095.0
const SAFE_TOP := 115.0
const SAFE_BOTTOM := 670.0

var world: Node2D
var background: Sprite2D
var forest_background: Sprite2D
var actors: Node2D
var lion: Sprite2D
var bull: Sprite2D
var active_story_id := ""
var active_segment_index := -1
var speaking_actor := ""
var segment_time := 0.0
var segment_duration := 3.0
var shot := "wide"
var scene_data: Dictionary = {}
var base_world_scale := 1.0
var target_world_scale := 1.0
var target_world_position := Vector2.ZERO
var actor_targets := {}
var actor_base_scales := {}
var transition_fade: ColorRect
var scene_glow: ColorRect
var vignette: ColorRect

const LION_TEX := preload("res://assets/images/characters/lion_2d.svg")
const BULL_TEX := preload("res://assets/images/characters/bull_2d.svg")
const BACKGROUND_TEX := preload("res://assets/images/backgrounds/lion_bull_2d.svg")
const FOREST_TEX := preload("res://assets/images/backgrounds/lion_bull_forest_2d.svg")

func _ready() -> void:
	clip_contents = true
	_build_stage()
	_rescale_to_control()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rescale_to_control()

func _build_stage() -> void:
	world = Node2D.new()
	world.name = "StoryWorld2D"
	add_child(world)

	background = Sprite2D.new()
	background.name = "Background"
	background.texture = BACKGROUND_TEX
	background.position = DESIGN_SIZE * 0.5
	background.centered = true
	world.add_child(background)

	forest_background = Sprite2D.new()
	forest_background.name = "ForestBackground"
	forest_background.texture = FOREST_TEX
	forest_background.position = DESIGN_SIZE * 0.5
	forest_background.centered = true
	world.add_child(forest_background)

	actors = Node2D.new()
	actors.name = "Actors"
	world.add_child(actors)

	transition_fade = ColorRect.new()
	transition_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_fade.color = Color(0, 0, 0, 0)
	transition_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(transition_fade)
	_build_visual_overlays()

func _build_visual_overlays() -> void:
	# Subtle cinematic overlays keep the stage feeling like a composed illustration,
	# while the actual story assets remain untouched.
	scene_glow = ColorRect.new()
	scene_glow.name = "SceneGlow"
	scene_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_glow.color = Color(1.0, 0.90, 0.62, 0.055)
	scene_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scene_glow)

	vignette = ColorRect.new()
	vignette.name = "Vignette"
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.05, 0.10, 0.08, 0.075)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	# Keep overlays behind the transition layer but above the illustrated world.
	move_child(scene_glow, get_child_count() - 2)
	move_child(vignette, get_child_count() - 2)


func _rescale_to_control() -> void:
	if world == null:
		return
	var scale_factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	base_world_scale = scale_factor
	world.scale = Vector2.ONE * scale_factor
	world.position = (size - DESIGN_SIZE * scale_factor) * 0.5
	_apply_camera_target_immediately()

func _clear_actors() -> void:
	if actors == null:
		return
	for child in actors.get_children():
		child.queue_free()
	lion = null
	bull = null
	actor_targets.clear()
	actor_base_scales.clear()

func _make_actor(id: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = id
	sprite.texture = LION_TEX if id == "lion" else BULL_TEX
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return sprite

func _add_actor(id: String, position: Vector2, height: float) -> Sprite2D:
	var sprite := _make_actor(id)
	actors.add_child(sprite)
	var texture_size := sprite.texture.get_size()
	var scale_factor := height / maxf(1.0, texture_size.y)
	sprite.scale = Vector2.ONE * scale_factor
	sprite.position = position
	actor_base_scales[id] = sprite.scale
	actor_targets[id] = position
	return sprite

func show_segment(story_id: String, segment_index: int, data: Dictionary = {}) -> void:
	active_story_id = story_id
	active_segment_index = segment_index
	scene_data = data
	segment_time = 0.0
	shot = String(data.get("shot", _shot_for_segment(story_id, segment_index)))

	if transition_fade:
		transition_fade.color.a = 1.0
	_clear_actors()

	if story_id != "lion_bull":
		return

	var place := String(scene_data.get("place", _place_for_segment(segment_index)))
	_update_scene_mood(place)
	forest_background.visible = place == "forest"
	background.visible = place != "forest"

	lion = _add_actor("lion", Vector2(380, 495), 335.0)
	bull = _add_actor("bull", Vector2(820, 500), 320.0)

	_apply_visibility_and_blocking(segment_index)
	_configure_shot(shot)

	if transition_fade:
		var fade_tween := create_tween()
		fade_tween.tween_property(transition_fade, "color:a", 0.0, 0.28)

func _update_scene_mood(place: String) -> void:
	if scene_glow == null or vignette == null:
		return
	if place == "forest":
		scene_glow.color = Color(0.88, 0.95, 0.72, 0.045)
		vignette.color = Color(0.04, 0.12, 0.08, 0.085)
	else:
		scene_glow.color = Color(0.75, 0.92, 1.0, 0.055)
		vignette.color = Color(0.04, 0.10, 0.12, 0.065)


func set_speaker(actor_id: String) -> void:
	speaking_actor = actor_id
	if speaking_actor != "lion" and speaking_actor != "bull":
		speaking_actor = ""
	_configure_shot(shot)

func start_cinematic(segment_index: int, duration: float) -> void:
	active_segment_index = segment_index
	segment_time = 0.0
	segment_duration = maxf(1.0, duration)

func _shot_for_segment(story_id: String, segment_index: int) -> String:
	if story_id != "lion_bull":
		return "wide"
	match segment_index:
		0, 1, 3, 5, 7, 9, 17, 19, 22, 23, 25, 28, 29:
			return "wide"
		2, 4, 6, 8, 10, 12, 14, 15, 18, 20, 21, 24, 26, 27:
			return "speaker_close"
		11, 13, 16:
			return "two_shot"
		_: return "wide"

func _place_for_segment(segment_index: int) -> String:
	match segment_index:
		0, 1, 2, 7, 8, 9, 10, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29:
			return "forest"
		3, 4, 5, 6, 11, 12, 13, 14, 15, 16:
			return "river_meadow"
		_: return "forest"

func _apply_visibility_and_blocking(segment_index: int) -> void:
	if lion == null or bull == null:
		return

	lion.visible = false
	bull.visible = false
	lion.position = Vector2(420, 505)
	bull.position = Vector2(930, 515)
	lion.rotation = 0.0
	bull.rotation = 0.0

	var actors_data: Array = scene_data.get("actors", [])
	for actor_id in actors_data:
		if actor_id == "lion":
			lion.visible = true
		if actor_id == "bull":
			bull.visible = true

	# Bull's meadow/water scenes are deliberately positioned toward the river.
	# Later conversation scenes use a wide two-shot, never a cropped bull.
	if bull.visible:
		bull.position = Vector2(930, 515)
	if lion.visible:
		lion.position = Vector2(420, 505)

	match segment_index:
		7, 8, 9, 10:
			if lion.visible:
				lion.position = Vector2(470, 505)
		11, 12, 13, 14, 15, 16:
			if lion.visible:
				lion.position = Vector2(365, 505)
			if bull.visible:
				bull.position = Vector2(930, 515)
		17, 18, 19:
			if lion.visible:
				lion.position = Vector2(350, 505)
			if bull.visible:
				bull.position = Vector2(850, 515)
		20, 21, 22:
			if lion.visible:
				lion.position = Vector2(405, 505)
			if bull.visible:
				bull.position = Vector2(795, 515)
		23, 24, 25:
			if lion.visible:
				lion.position = Vector2(320, 510)
			if bull.visible:
				bull.position = Vector2(880, 515)
		26:
			if lion.visible:
				lion.position = Vector2(340, 505)
			if bull.visible:
				bull.position = Vector2(860, 515)
		27, 28, 29:
			if lion.visible:
				lion.position = Vector2(400, 505)
			if bull.visible:
				bull.position = Vector2(800, 515)

	actor_targets["lion"] = lion.position
	actor_targets["bull"] = bull.position
	_keep_actors_inside_safe_frame()

func _configure_shot(shot_type: String) -> void:
	target_world_scale = 1.0
	target_world_position = Vector2.ZERO

	match shot_type:
		"wide":
			target_world_scale = 1.0
			target_world_position = Vector2.ZERO
		"speaker_close":
			target_world_scale = 1.28
			var target := _speaker_position()
			target_world_position = DESIGN_SIZE * 0.5 - target * target_world_scale
		"two_shot":
			target_world_scale = 1.08
			var midpoint := (lion.position + bull.position) * 0.5
			target_world_position = DESIGN_SIZE * 0.5 - midpoint * target_world_scale
		"reaction":
			target_world_scale = 1.18
			var reaction_actor := "bull" if speaking_actor == "lion" else "lion"
			var node := actors.get_node_or_null(reaction_actor) as Sprite2D
			if node:
				target_world_position = DESIGN_SIZE * 0.5 - node.position * target_world_scale

func _speaker_position() -> Vector2:
	var node := actors.get_node_or_null(speaking_actor) as Sprite2D
	if node and node.visible:
		return node.position + Vector2(0, -55)
	return DESIGN_SIZE * 0.5

func _apply_camera_target_immediately() -> void:
	if world == null:
		return
	world.scale = Vector2.ONE * base_world_scale * target_world_scale
	world.position = (size - DESIGN_SIZE * world.scale.x) * 0.5 + target_world_position * base_world_scale

func _keep_actors_inside_safe_frame() -> void:
	if lion:
		lion.position.x = clampf(lion.position.x, SAFE_LEFT + 115.0, SAFE_RIGHT - 115.0)
		lion.position.y = clampf(lion.position.y, SAFE_TOP + 145.0, SAFE_BOTTOM - 25.0)
	if bull:
		# Extra horizontal/vertical margin prevents the broad bull silhouette
		# from touching or crossing the screen edge in close shots.
		bull.position.x = clampf(bull.position.x, SAFE_LEFT + 155.0, SAFE_RIGHT - 155.0)
		bull.position.y = clampf(bull.position.y, SAFE_TOP + 150.0, SAFE_BOTTOM - 20.0)

func _process(delta: float) -> void:
	if world == null or active_story_id != "lion_bull":
		return

	segment_time += delta
	_apply_story_motion(delta)

	var desired_scale := base_world_scale * target_world_scale
	world.scale = world.scale.lerp(Vector2.ONE * desired_scale, minf(delta * 3.2, 1.0))
	var desired_position := (size - DESIGN_SIZE * desired_scale) * 0.5 + target_world_position * base_world_scale
	world.position = world.position.lerp(desired_position, minf(delta * 3.2, 1.0))

	if speaking_actor != "":
		var speaker := actors.get_node_or_null(speaking_actor) as Sprite2D
		if speaker:
			var base: Vector2 = actor_base_scales.get(speaking_actor, speaker.scale)
			var pulse := 1.0 + sin(segment_time * 7.0) * 0.012
			speaker.scale = base * pulse

func _apply_story_motion(delta: float) -> void:
	if lion == null or bull == null:
		return

	for id in ["lion", "bull"]:
		var node := actors.get_node_or_null(id) as Sprite2D
		if node == null:
			continue
		var target: Vector2 = actor_targets.get(id, node.position)
		node.position = node.position.lerp(target, minf(delta * 2.2, 1.0))

	# Distinct 2D staging beats: reveal, dialogue, friendship, distance, choice.
	match active_segment_index:
		8:
			lion.rotation = lerpf(lion.rotation, deg_to_rad(-4.0), minf(delta * 3.0, 1.0))
		9:
			lion.position.y = lerpf(lion.position.y, 490.0, minf(delta * 1.2, 1.0))
		10:
			lion.position.x = lerpf(lion.position.x, 485.0, minf(delta * 0.9, 1.0))
		11:
			bull.position.x = lerpf(bull.position.x, 815.0, minf(delta * 1.1, 1.0))
		12:
			bull.position.y = lerpf(bull.position.y, 500.0, minf(delta * 1.0, 1.0))
		13, 14, 15:
			lion.rotation = lerpf(lion.rotation, deg_to_rad(3.0), minf(delta * 1.4, 1.0))
			bull.rotation = lerpf(bull.rotation, deg_to_rad(-3.0), minf(delta * 1.4, 1.0))
		17, 18, 19:
			lion.position.x = lerpf(lion.position.x, actor_targets["lion"].x - 12.0, minf(delta, 1.0))
			bull.position.x = lerpf(bull.position.x, actor_targets["bull"].x + 12.0, minf(delta, 1.0))
		20, 21, 22:
			lion.position.y += sin(segment_time * 1.8) * 0.10
			bull.position.y += sin(segment_time * 1.8 + 1.0) * 0.10
		23, 24, 25:
			lion.position.x = lerpf(lion.position.x, actor_targets["lion"].x - 20.0, minf(delta * 0.8, 1.0))
			bull.position.x = lerpf(bull.position.x, actor_targets["bull"].x + 20.0, minf(delta * 0.8, 1.0))
		26:
			bull.rotation = lerpf(bull.rotation, deg_to_rad(-4.0), minf(delta * 1.8, 1.0))
		27:
			lion.position.x = lerpf(lion.position.x, 410.0, minf(delta * 0.9, 1.0))
			bull.position.x = lerpf(bull.position.x, 790.0, minf(delta * 0.9, 1.0))
		28:
			lion.position.x = lerpf(lion.position.x, 455.0, minf(delta * 0.7, 1.0))
			bull.position.x = lerpf(bull.position.x, 745.0, minf(delta * 0.7, 1.0))
		29:
			lion.position.y = lerpf(lion.position.y, 515.0, minf(delta * 0.5, 1.0))
			bull.position.y = lerpf(bull.position.y, 520.0, minf(delta * 0.5, 1.0))

	_keep_actors_inside_safe_frame()
