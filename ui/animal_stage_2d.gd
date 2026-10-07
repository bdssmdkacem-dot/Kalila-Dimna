class_name AnimalStage2D
extends Control
## Shared realistic 2D story stage for all Kalila-Dimna tales.

const DESIGN_SIZE := Vector2(1280.0, 720.0)
const SAFE_LEFT := 70.0
const SAFE_RIGHT := 1210.0
const SAFE_TOP := 80.0
const SAFE_BOTTOM := 640.0

const REALISTIC_ASSETS := {
	"lion": "res://assets/images/characters/new/lion_story_new.svg",
	"bull": "res://assets/images/characters/new/bull_story_new.svg",
	"crow": "res://assets/images/characters/new/crow_story_new.svg",
	"snake": "res://assets/images/characters/new/snake_story_new.svg",
	"monkey": "res://assets/images/characters/new/monkey_story_new.svg",
	"turtle": "res://assets/images/characters/new/turtle_story_new.svg",
	"dove": "res://assets/images/characters/new/dove_story_new.svg",
	"mouse": "res://assets/images/characters/new/mouse_story_new.svg",
	"hare": "res://assets/images/characters/new/hare_story_new.svg",
	"rat": "res://assets/images/characters/new/rat_story_new.svg",
	"cat": "res://assets/images/characters/new/cat_story_new.svg",
	"owl": "res://assets/images/characters/new/owl_story_new.svg",
	"jackal": "res://assets/images/characters/new/jackal_story_new.svg",
	"duck": "res://assets/images/characters/new/duck_story_new.svg"
}
const FALLBACK_ASSETS := {
	"lion": "res://assets/images/characters/lion_2d.svg",
	"bull": "res://assets/images/characters/bull_2d.svg"
}
const BACKGROUND_ASSETS := {
	"lion_bull:forest": "res://assets/images/new/lion_bull_forest_new.svg",
	"lion_bull:river_meadow": "res://assets/images/new/lion_bull_river_new.svg",
	"crow_snake:forest": "res://assets/images/new/crow_snake_forest_new.svg",
	"monkey_turtle:river_meadow": "res://assets/images/new/monkey_turtle_river_new.svg",
	"dove_ring:forest": "res://assets/images/new/dove_ring_forest_new.svg",
	"lion_hare:forest": "res://assets/images/new/lion_hare_forest_new.svg",
	"lion_hare:river_meadow": "res://assets/images/new/lion_hare_well_new.svg",
	"rat_cat:forest": "res://assets/images/new/rat_cat_forest_new.svg",
	"rat_cat:trap": "res://assets/images/new/rat_cat_trap_new.svg",
	"rat_cat:sunset": "res://assets/images/new/rat_cat_sunset_new.svg",
	"owls_crows:forest": "res://assets/images/new/owls_crows_forest_new.svg",
	"owls_crows:council": "res://assets/images/new/owls_crows_council_new.svg",
	"owls_crows:sunset": "res://assets/images/new/owls_crows_sunset_new.svg",
	"jackal_lion:king_clearing": "res://assets/images/new/jackal_lion_king_clearing_new.svg",
	"jackal_lion:forest": "res://assets/images/new/jackal_lion_king_clearing_new.svg",
	"jackal_lion:council": "res://assets/images/new/jackal_lion_council_new.svg",
	"jackal_lion:sunset": "res://assets/images/new/jackal_lion_sunset_new.svg",
	"turtle_ducks:lake": "res://assets/images/new/turtle_ducks_lake_new.svg",
	"turtle_ducks:sky": "res://assets/images/new/turtle_ducks_sky_new.svg",
	"turtle_ducks:sunset": "res://assets/images/new/turtle_ducks_sunset_new.svg"
}
const BACKGROUND_TEX := preload("res://assets/images/new/lion_bull_forest_new.svg")
const FOREST_TEX := preload("res://assets/images/new/lion_bull_forest_new.svg")

var world: Node2D
var background: Sprite2D
var forest_background: Sprite2D
var actors: Node2D
var shadows: Node2D
var active_actor_nodes: Dictionary = {}
var actor_shadows: Dictionary = {}
var actor_targets: Dictionary = {}
var actor_base_scales: Dictionary = {}
var actor_phase: Dictionary = {}
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
var background_target_offset := Vector2.ZERO
var background_offset := Vector2.ZERO
var scene_intro_time := 0.0

func _ready() -> void:
	clip_contents = true
	# The stage lives inside a VBoxContainer; give it a real minimum height so
	# the first layout pass cannot collapse the rendering area to zero.
	custom_minimum_size = Vector2(0.0, 220.0)
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
	background.position = size * 0.5
	background.z_index = -20
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(background)

	forest_background = Sprite2D.new()
	forest_background.texture = FOREST_TEX
	forest_background.position = size * 0.5
	forest_background.z_index = -19
	forest_background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(forest_background)

	shadows = Node2D.new()
	shadows.z_index = 2
	world.add_child(shadows)

	actors = Node2D.new()
	actors.z_index = 3
	world.add_child(actors)

	scene_glow = ColorRect.new()
	scene_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scene_glow)

	vignette = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	# Keep the transition layer transparent by default. Story startup must never
	# depend on a black overlay tween to reveal the scene.
	transition_fade = ColorRect.new()
	transition_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_fade.color = Color(0, 0, 0, 0)
	transition_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(transition_fade)

func _rescale_to_control() -> void:
	if world == null:
		return
	# Container layout can briefly report a zero size while the scene is being
	# constructed. Never propagate that into world.scale.
	if size.x <= 0.0 or size.y <= 0.0:
		return
	base_world_scale = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	world.scale = Vector2.ONE * base_world_scale
	world.position = (size - DESIGN_SIZE * base_world_scale) * 0.5
	_fit_background(background)
	_fit_background(forest_background)

func _fit_background(sprite: Sprite2D) -> void:
	if sprite == null or sprite.texture == null:
		return
	var tex_size := sprite.texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0 or size.x <= 0.0 or size.y <= 0.0:
		return
	# Full-stage cover: the scene image fills every visible pixel of the story area.
	var cover_scale := maxf(size.x / tex_size.x, size.y / tex_size.y)
	sprite.scale = Vector2.ONE * cover_scale
	sprite.position = size * 0.5

func _clear_actors() -> void:
	for child in actors.get_children(): child.queue_free()
	for child in shadows.get_children(): child.queue_free()
	active_actor_nodes.clear()
	actor_shadows.clear()
	actor_targets.clear()
	actor_base_scales.clear()
	actor_phase.clear()

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
		"crow": return 260.0
		"snake": return 245.0
		"monkey": return 300.0
		"turtle": return 225.0
		"dove": return 205.0
		"mouse": return 165.0
		"hare": return 260.0
		"rat": return 175.0
		"cat": return 275.0
		"owl": return 235.0
		"jackal": return 275.0
		"duck": return 210.0
		_: return 260.0

func _shadow_size_for(id: String) -> Vector2:
	match id:
		"lion": return Vector2(118.0, 28.0)
		"bull": return Vector2(122.0, 30.0)
		"monkey": return Vector2(78.0, 22.0)
		"hare": return Vector2(72.0, 19.0)
		"turtle": return Vector2(70.0, 17.0)
		"snake": return Vector2(76.0, 14.0)
		"mouse": return Vector2(48.0, 12.0)
		_: return Vector2(58.0, 15.0)

func _create_shadow(id: String, pos: Vector2) -> Polygon2D:
	var shadow := Polygon2D.new()
	shadow.name = "%s_shadow" % id
	var points := PackedVector2Array()
	var shadow_size := _shadow_size_for(id)
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(Vector2(cos(angle) * shadow_size.x * 0.5, sin(angle) * shadow_size.y * 0.5))
	shadow.polygon = points
	shadow.color = Color(0.02, 0.03, 0.02, 0.20)
	shadow.position = Vector2(pos.x, pos.y + 8.0)
	shadow.scale = Vector2(0.94, 0.94)
	shadows.add_child(shadow)
	return shadow

func _add_actor(id: String, pos: Vector2, entrance_index: int = 0) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = id
	s.texture = _texture_for(id)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.modulate = Color(1, 1, 1, 0)
	actors.add_child(s)
	if s.texture:
		s.scale = Vector2.ONE * (_height_for(id) / maxf(1.0, s.texture.get_size().y))
	var final_scale := s.scale
	var entrance_offset := Vector2.ZERO
	if entrance_index % 2 == 0:
		entrance_offset = Vector2(-24.0, 18.0)
	else:
		entrance_offset = Vector2(24.0, 18.0)
	if id == "crow" or id == "dove":
		entrance_offset = Vector2(0.0, -20.0)
	elif id == "snake" or id == "turtle" or id == "mouse":
		entrance_offset = Vector2(18.0, 12.0)
	s.position = pos + entrance_offset
	s.scale = final_scale * 0.965
	actor_base_scales[id] = final_scale
	s.z_index = 100 + int(pos.y)
	actor_targets[id] = pos
	actor_phase[id] = float(abs(id.hash()) % 1000) * 0.013
	active_actor_nodes[id] = s
	var shadow := _create_shadow(id, pos)
	actor_shadows[id] = shadow
	var entrance := create_tween()
	entrance.set_parallel(true)
	entrance.tween_property(s, "position", pos, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	entrance.tween_property(s, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	entrance.tween_property(s, "scale", final_scale, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return s

func show_segment(story_id: String, segment_index: int, data: Dictionary = {}) -> void:
	active_story_id = story_id
	active_segment_index = segment_index
	scene_data = data
	segment_time = 0.0
	scene_intro_time = 0.0
	speaking_actor = ""
	shot = String(data.get("shot", "wide"))
	_clear_actors()
	var place := String(data.get("place", "forest"))
	background_target_offset = _background_focus(story_id, place, String(data.get("shot", "wide")))
	background_offset = background_target_offset
	var explicit_background := String(data.get("background", ""))
	var realistic_background := _background_for(story_id, place, explicit_background)
	if realistic_background:
		background.texture = realistic_background
		forest_background.texture = realistic_background
		_fit_background(background)
		_fit_background(forest_background)
		background.visible = true
		forest_background.visible = false
	else:
		background.texture = BACKGROUND_TEX
		forest_background.texture = FOREST_TEX
		_fit_background(background)
		_fit_background(forest_background)
		forest_background.visible = place == "forest"
		background.visible = place != "forest"
	scene_glow.color = Color(0.82,0.94,0.78,0.045) if place == "forest" else Color(0.72,0.90,1.0,0.055)
	vignette.color = Color(0.04,0.10,0.08,0.07)
	var list: Array = data.get("actors", [])
	var count := list.size()
	for i in range(count):
		var id := String(list[i])
		_add_actor(id, _actor_position(story_id, place, id, i, count), i)
	_keep_actors_inside_safe_frame()
	_configure_shot(shot)
	# Do not gate scene visibility behind a black fade. This avoids a permanent
	# black screen if Android pauses or interrupts a startup tween.
	transition_fade.color.a = 0.72
	var scene_tween := create_tween()
	scene_tween.tween_property(transition_fade, "color:a", 0.0, 0.42).set_trans(Tween.TRANS_SINE)

func _background_focus(story_id: String, place: String, shot_kind: String) -> Vector2:
	match story_id:
		"lion_bull":
			if place == "river_meadow": return Vector2(0.0, -18.0 if shot_kind == "speaker_close" else 0.0)
			return Vector2(0.0, 10.0 if shot_kind == "wide" else 0.0)
		"crow_snake":
			return Vector2(0.0, -12.0 if shot_kind == "speaker_close" else 4.0)
		"monkey_turtle":
			return Vector2(0.0, -16.0 if shot_kind != "wide" else 0.0)
		"dove_ring":
			return Vector2(0.0, -12.0 if shot_kind == "speaker_close" else 0.0)
		"lion_hare":
			if place == "forest": return Vector2(0.0, 8.0 if shot_kind == "wide" else -4.0)
			if place == "well": return Vector2(0.0, -14.0 if shot_kind == "speaker_close" else -8.0)
			return Vector2(0.0, -10.0)
		"rat_cat": return Vector2(0.0, 5.0)
		"owls_crows": return Vector2(0.0, -8.0)
		"jackal_lion": return Vector2(0.0, 4.0)
		"turtle_ducks": return Vector2(0.0, -8.0)
	return Vector2.ZERO

func _actor_position(story_id: String, place: String, actor_id: String, index: int, count: int) -> Vector2:
	match story_id:
		"lion_bull":
			# Keep the large animals in the middle band so the dialogue card has clear space below.
			if place == "river_meadow":
				if actor_id == "lion": return Vector2(390.0, 415.0)
				if actor_id == "bull": return Vector2(875.0, 440.0)
			if actor_id == "lion": return Vector2(440.0, 415.0)
			if actor_id == "bull": return Vector2(840.0, 440.0)
		"crow_snake":
			# Keep the crow high in the canopy, shift it toward the palace flight path,
			# and keep the snake close to the den in the final forest shot.
			if place == "palace":
				if actor_id == "crow": return Vector2(930.0, 220.0)
			if place == "burrow":
				if actor_id == "crow": return Vector2(620.0, 315.0)
				if actor_id == "snake": return Vector2(780.0, 470.0)
			if actor_id == "crow": return Vector2(805.0, 275.0)
			if actor_id == "snake": return Vector2(735.0, 475.0)
		"monkey_turtle":
			# The monkey reads as a tree-side character while the turtle stays close to the river surface.
			if actor_id == "monkey": return Vector2(410.0, 315.0)
			if actor_id == "turtle": return Vector2(875.0, 475.0)
		"dove_ring":
			# Keep the dove airborne and bring the mouse upward so the two-shot remains readable.
			if actor_id == "dove": return Vector2(620.0, 285.0)
			if actor_id == "mouse": return Vector2(850.0, 475.0)
		"lion_hare":
			# The well scenes need the pair slightly higher to keep the well and dialogue visible.
			if place == "forest":
				if actor_id == "lion": return Vector2(425.0, 410.0)
				if actor_id == "hare": return Vector2(850.0, 450.0)
			if actor_id == "lion": return Vector2(420.0, 405.0)
			if actor_id == "hare": return Vector2(835.0, 455.0)
	var x := 640.0 if count == 1 else (350.0 + float(index) * 580.0)
	return Vector2(x, 460.0)

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
			target_world_scale = 1.12
			target_world_position = DESIGN_SIZE*0.5 - n.position*target_world_scale
			var focus_delta := (n.position - DESIGN_SIZE * 0.5)
			background_target_offset = Vector2(
				clampf(-focus_delta.x * 0.035, -18.0, 18.0),
				clampf(-focus_delta.y * 0.025, -12.0, 12.0)
			)
	elif kind == "two_shot" and active_actor_nodes.size() >= 2:
		var a := active_actor_nodes.values()[0] as Sprite2D
		var b := active_actor_nodes.values()[1] as Sprite2D
		var mid := (a.position+b.position)*0.5
		target_world_scale = 1.03
		target_world_position = DESIGN_SIZE*0.5-mid*target_world_scale
		background_target_offset = Vector2(
			clampf((DESIGN_SIZE.x * 0.5 - mid.x) * 0.025, -12.0, 12.0),
			clampf((DESIGN_SIZE.y * 0.5 - mid.y) * 0.018, -8.0, 8.0)
		)
	elif kind == "reaction" and speaking_actor != "":
		var ids := active_actor_nodes.keys()
		for id in ids:
			if id != speaking_actor:
				var n := active_actor_nodes[id] as Sprite2D
				target_world_scale = 1.10
				target_world_position = DESIGN_SIZE*0.5-n.position*target_world_scale
				var reaction_delta := (n.position - DESIGN_SIZE * 0.5)
				background_target_offset = Vector2(
					clampf(-reaction_delta.x * 0.03, -14.0, 14.0),
					clampf(-reaction_delta.y * 0.02, -10.0, 10.0)
				)
				break

func _keep_actors_inside_safe_frame() -> void:
	for id in active_actor_nodes:
		var n := active_actor_nodes[id] as Sprite2D
		n.position.x = clampf(n.position.x, SAFE_LEFT+80.0, SAFE_RIGHT-80.0)
		n.position.y = clampf(n.position.y, SAFE_TOP+100.0, SAFE_BOTTOM-20.0)
		actor_targets[id] = n.position

func _motion_amount(id: String) -> Vector2:
	var t := segment_time
	var phase := float(actor_phase.get(id, 0.0))
	match id:
		"lion": return Vector2(sin(t * 0.55 + phase) * 3.0, sin(t * 1.15 + phase) * 1.5)
		"bull": return Vector2(sin(t * 0.65 + phase) * 3.5, sin(t * 1.0 + phase) * 1.2)
		"crow", "dove": return Vector2(sin(t * 1.15 + phase) * 10.0, sin(t * 1.8 + phase) * 7.0)
		"snake": return Vector2(sin(t * 1.35 + phase) * 6.0, sin(t * 2.1 + phase) * 2.0)
		"monkey": return Vector2(sin(t * 0.9 + phase) * 5.0, sin(t * 1.7 + phase) * 2.5)
		"turtle", "mouse": return Vector2(sin(t * 0.8 + phase) * 2.0, sin(t * 1.4 + phase) * 1.0)
		"hare": return Vector2(sin(t * 1.25 + phase) * 4.0, sin(t * 2.0 + phase) * 2.0)
		"rat": return Vector2(sin(t * 1.05 + phase) * 2.5, sin(t * 1.8 + phase) * 1.2)
		"cat", "jackal": return Vector2(sin(t * 0.7 + phase) * 3.0, sin(t * 1.1 + phase) * 1.3)
		"owl", "duck": return Vector2(sin(t * 0.8 + phase) * 2.0, sin(t * 1.5 + phase) * 1.5)
	return Vector2.ZERO

func _idle_amount(id: String) -> Vector2:
	if id == "crow" or id == "dove":
		return Vector2(0.0, sin(segment_time * 1.8 + float(actor_phase.get(id, 0.0))) * 2.5)
	if id == "snake":
		return Vector2(sin(segment_time * 1.2 + float(actor_phase.get(id, 0.0))) * 1.4, 0.0)
	if id == "turtle" or id == "mouse":
		return Vector2(0.0, sin(segment_time * 1.5 + float(actor_phase.get(id, 0.0))) * 0.7)
	return Vector2(0.0, sin(segment_time * 1.15 + float(actor_phase.get(id, 0.0))) * 1.1)

func _process(delta: float) -> void:
	if world == null: return
	segment_time += delta
	scene_intro_time += delta
	for id in active_actor_nodes:
		var n := active_actor_nodes[id] as Sprite2D
		var target: Vector2 = actor_targets.get(id,n.position)
		n.position = n.position.lerp(target,minf(delta*2.4,1.0))
		var idle := _idle_amount(id) + _motion_amount(id)
		n.position += idle * minf(delta * 4.0, 1.0)
		if actor_shadows.has(id):
			var shadow := actor_shadows[id] as Polygon2D
			shadow.position = Vector2(target.x + idle.x * 0.35, target.y + 8.0)
			shadow.z_index = 1
			shadow.scale = Vector2.ONE * (1.0 + sin(segment_time * 1.1 + float(actor_phase.get(id, 0.0))) * 0.025)
	var desired_scale := base_world_scale*target_world_scale
	world.scale = world.scale.lerp(Vector2.ONE*desired_scale,minf(delta*3.2,1.0))
	var desired_pos := (size-DESIGN_SIZE*desired_scale)*0.5 + target_world_position*base_world_scale
	world.position = world.position.lerp(desired_pos,minf(delta*3.2,1.0))
	background_offset = background_offset.lerp(background_target_offset, minf(delta * 2.0, 1.0))
	background.position = size * 0.5 + background_offset
	forest_background.position = size * 0.5 + background_offset
	if speaking_actor != "" and active_actor_nodes.has(speaking_actor):
		var n := active_actor_nodes[speaking_actor] as Sprite2D
		var base: Vector2 = actor_base_scales.get(speaking_actor,n.scale)
		n.scale = base*(1.0+sin(segment_time*7.0)*0.012)
