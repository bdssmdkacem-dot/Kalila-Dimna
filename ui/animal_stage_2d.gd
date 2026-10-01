class_name AnimalStage2D
extends Control
## Shared realistic 2D story stage for all Kalila-Dimna tales.

const DESIGN_SIZE := Vector2(1200.0, 760.0)
const SAFE_LEFT := 90.0
const SAFE_RIGHT := 1110.0
const SAFE_TOP := 105.0
const SAFE_BOTTOM := 675.0

const REALISTIC_ASSETS := {
	"lion": "res://assets/images/characters/lion_2d_realistic.webp",
	"bull": "res://assets/images/characters/bull_2d_realistic.webp",
	"crow": "res://assets/images/characters/crow_realistic.webp",
	"snake": "res://assets/images/characters/snake_realistic.webp",
	"monkey": "res://assets/images/characters/monkey_realistic.webp",
	"turtle": "res://assets/images/characters/turtle_realistic.webp",
	"dove": "res://assets/images/characters/dove_realistic.webp",
	"mouse": "res://assets/images/characters/mouse_realistic.webp",
	"hare": "res://assets/images/characters/hare_realistic.webp"
}
const FALLBACK_ASSETS := {
	"lion": "res://assets/images/characters/lion_2d.svg",
	"bull": "res://assets/images/characters/bull_2d.svg"
}
const BACKGROUND_ASSETS := {
	"01_lion_bull:forest": "res://assets/images/backgrounds/lion_bull_forest_realistic.webp",
	"01_lion_bull:river_meadow": "res://assets/images/backgrounds/lion_bull_river_meadow_realistic.webp",
	"02_crow_snake:forest": "res://assets/images/backgrounds/crow_snake_forest_realistic.webp",
	"03_monkey_turtle:river_meadow": "res://assets/images/backgrounds/monkey_turtle_river_realistic.webp",
	"04_dove_ring:forest": "res://assets/images/backgrounds/dove_ring_forest_realistic.webp",
	"05_lion_hare:forest": "res://assets/images/backgrounds/lion_hare_forest_realistic.webp",
	"05_lion_hare:river_meadow": "res://assets/images/backgrounds/lion_hare_well_realistic.webp"
}
const BACKGROUND_TEX := preload("res://assets/images/backgrounds/lion_bull_2d.svg")
const FOREST_TEX := preload("res://assets/images/backgrounds/lion_bull_forest_2d.svg")

var world: Node2D
var background: Sprite2D
var forest_background: Sprite2D
var actors: Node2D
var active_actor_nodes: Dictionary = {}
var actor_targets: Dictionary = {}
var actor_base_scales: Dictionary = {}
var active_story_id := ""
var active_segment_index := -1
var speaking_actor := ""
var segment_time := 0.0
var shot := "wide"
var scene_data: Dictionary = {}
var base_world_scale := 1.0
var target_world_scale := 1.0
var target_world_position := Vector2.ZERO
var transition_fade: ColorRect
var scene_glow: ColorRect
var vignette: ColorRect

func _ready() -> void:
	clip_contents = true
	_build_stage()
	_rescale_to_control()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rescale_to_control()

func _build_stage() -> void:
	world = Node2D.new()
	add_child(world)
	background = Sprite2D.new()
	background.texture = BACKGROUND_TEX
	background.position = DESIGN_SIZE * 0.5
	world.add_child(background)
	forest_background = Sprite2D.new()
	forest_background.texture = FOREST_TEX
	forest_background.position = DESIGN_SIZE * 0.5
	world.add_child(forest_background)
	actors = Node2D.new()
	world.add_child(actors)
	scene_glow = ColorRect.new()
	scene_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scene_glow)
	vignette = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)
	transition_fade = ColorRect.new()
	transition_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_fade.color = Color(0,0,0,0)
	transition_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(transition_fade)

func _rescale_to_control() -> void:
	if world == null: return
	base_world_scale = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	world.scale = Vector2.ONE * base_world_scale
	world.position = (size - DESIGN_SIZE * base_world_scale) * 0.5

func _clear_actors() -> void:
	for child in actors.get_children(): child.queue_free()
	active_actor_nodes.clear()
	actor_targets.clear()
	actor_base_scales.clear()

func _texture_for(id: String) -> Texture2D:
	var realistic := String(REALISTIC_ASSETS.get(id, ""))
	if realistic != "" and ResourceLoader.exists(realistic):
		return load(realistic) as Texture2D
	var fallback := String(FALLBACK_ASSETS.get(id, ""))
	if fallback != "" and ResourceLoader.exists(fallback):
		return load(fallback) as Texture2D
	return null

func _background_for(story_id: String, place: String, explicit_path: String) -> Texture2D:
	if explicit_path != "" and ResourceLoader.exists(explicit_path):
		return load(explicit_path) as Texture2D
	var key := "%s:%s" % [story_id, place]
	var path := String(BACKGROUND_ASSETS.get(key, ""))
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _height_for(id: String) -> float:
	match id:
		"lion": return 335.0
		"bull": return 320.0
		"crow": return 235.0
		"snake": return 230.0
		"monkey": return 285.0
		"turtle": return 210.0
		"dove": return 175.0
		"mouse": return 145.0
		"hare": return 245.0
		_: return 260.0

func _add_actor(id: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = id
	s.texture = _texture_for(id)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	actors.add_child(s)
	if s.texture:
		s.scale = Vector2.ONE * (_height_for(id) / maxf(1.0, s.texture.get_size().y))
	s.position = pos
	actor_base_scales[id] = s.scale
	actor_targets[id] = pos
	active_actor_nodes[id] = s
	return s

func show_segment(story_id: String, segment_index: int, data: Dictionary = {}) -> void:
	active_story_id = story_id
	active_segment_index = segment_index
	scene_data = data
	segment_time = 0.0
	shot = String(data.get("shot", "wide"))
	_clear_actors()
	var place := String(data.get("place", "forest"))
	var explicit_background := String(data.get("background", ""))
	var realistic_background := _background_for(story_id, place, explicit_background)
	if realistic_background:
		background.texture = realistic_background
		forest_background.texture = realistic_background
		background.visible = true
		forest_background.visible = false
	else:
		background.texture = BACKGROUND_TEX
		forest_background.texture = FOREST_TEX
		forest_background.visible = place == "forest"
		background.visible = place != "forest"
	scene_glow.color = Color(0.82,0.94,0.78,0.045) if place == "forest" else Color(0.72,0.90,1.0,0.055)
	vignette.color = Color(0.04,0.10,0.08,0.07)
	var list: Array = data.get("actors", [])
	var count := list.size()
	for i in range(count):
		var id := String(list[i])
		var x := 600.0 if count == 1 else (330.0 + float(i) * 540.0)
		_add_actor(id, Vector2(x, 505.0))
	_keep_actors_inside_safe_frame()
	_configure_shot(shot)
	transition_fade.color.a = 1.0
	var tw := create_tween()
	tw.tween_property(transition_fade, "color:a", 0.0, 0.28)

func set_speaker(actor_id: String) -> void:
	speaking_actor = actor_id if active_actor_nodes.has(actor_id) else ""
	_configure_shot(shot)

func start_cinematic(segment_index: int, duration: float) -> void:
	active_segment_index = segment_index
	segment_time = 0.0

func _configure_shot(kind: String) -> void:
	target_world_scale = 1.0
	target_world_position = Vector2.ZERO
	if kind == "speaker_close" and speaking_actor != "":
		var n := active_actor_nodes.get(speaking_actor) as Sprite2D
		if n:
			target_world_scale = 1.24
			target_world_position = DESIGN_SIZE*0.5 - n.position*target_world_scale
	elif kind == "two_shot" and active_actor_nodes.size() >= 2:
		var a := active_actor_nodes.values()[0] as Sprite2D
		var b := active_actor_nodes.values()[1] as Sprite2D
		var mid := (a.position+b.position)*0.5
		target_world_scale = 1.06
		target_world_position = DESIGN_SIZE*0.5-mid*target_world_scale
	elif kind == "reaction" and speaking_actor != "":
		var ids := active_actor_nodes.keys()
		for id in ids:
			if id != speaking_actor:
				var n := active_actor_nodes[id] as Sprite2D
				target_world_scale = 1.16
				target_world_position = DESIGN_SIZE*0.5-n.position*target_world_scale
				break

func _keep_actors_inside_safe_frame() -> void:
	for id in active_actor_nodes:
		var n := active_actor_nodes[id] as Sprite2D
		n.position.x = clampf(n.position.x, SAFE_LEFT+80.0, SAFE_RIGHT-80.0)
		n.position.y = clampf(n.position.y, SAFE_TOP+100.0, SAFE_BOTTOM-20.0)
		actor_targets[id] = n.position

func _process(delta: float) -> void:
	if world == null: return
	segment_time += delta
	for id in active_actor_nodes:
		var n := active_actor_nodes[id] as Sprite2D
		var target: Vector2 = actor_targets.get(id,n.position)
		n.position = n.position.lerp(target,minf(delta*2.4,1.0))
	var desired_scale := base_world_scale*target_world_scale
	world.scale = world.scale.lerp(Vector2.ONE*desired_scale,minf(delta*3.2,1.0))
	var desired_pos := (size-DESIGN_SIZE*desired_scale)*0.5 + target_world_position*base_world_scale
	world.position = world.position.lerp(desired_pos,minf(delta*3.2,1.0))
	if speaking_actor != "" and active_actor_nodes.has(speaking_actor):
		var n := active_actor_nodes[speaking_actor] as Sprite2D
		var base: Vector2 = actor_base_scales.get(speaking_actor,n.scale)
		n.scale = base*(1.0+sin(segment_time*7.0)*0.012)
