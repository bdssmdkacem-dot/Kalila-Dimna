class_name AnimalStage
extends Control

const STORY_ACTORS := {
    "lion_bull": ["lion", "bull"],
    "crow_snake": ["crow", "snake"],
    "monkey_turtle": ["monkey", "turtle"],
    "dove_ring": ["dove"],
    "lion_hare": ["lion", "hare"],
}

var viewport: SubViewport
var world_root: Node3D
var actor_root: Node3D
var environment_root: Node3D
var camera: Camera3D
var time := 0.0
var segment_time := 0.0
var segment_duration := 3.0
var active_story_id := ""
var active_segment_index := -1
var transition_fade: ColorRect

func _ready() -> void:
    custom_minimum_size = Vector2(0, 0)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
    _build_stage()

func _build_stage() -> void:
    var container := SubViewportContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.stretch = true
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(container)

    transition_fade = ColorRect.new()
    transition_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    transition_fade.color = Color(0, 0, 0, 0)
    transition_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(transition_fade)

    viewport = SubViewport.new()
    viewport.size = Vector2i(900, 430)
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    container.add_child(viewport)

    world_root = Node3D.new()
    viewport.add_child(world_root)

    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#f3ead8")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#fff8e8")
    environment.ambient_light_energy = 0.8
    env.environment = environment
    world_root.add_child(env)

    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-45, -25, 0)
    key.light_energy = 1.25
    key.shadow_enabled = true
    world_root.add_child(key)

    var fill := OmniLight3D.new()
    fill.position = Vector3(-3, 3, 4)
    fill.light_energy = 2.0
    fill.omni_range = 12.0
    world_root.add_child(fill)

    var ground := MeshInstance3D.new()
    var ground_mesh := PlaneMesh.new()
    ground_mesh.size = Vector2(12, 6)
    ground.mesh = ground_mesh
    ground.material_override = _mat(Color("#d6c29b"))
    ground.rotation_degrees.x = -90
    world_root.add_child(ground)

    camera = Camera3D.new()
    camera.position = Vector3(0, 2.1, 7.2)
    camera.look_at_from_position(camera.position, Vector3(0, 1.0, 0))
    camera.fov = 42.0
    world_root.add_child(camera)

    environment_root = Node3D.new()
    world_root.add_child(environment_root)

    actor_root = Node3D.new()
    world_root.add_child(actor_root)

func show_segment(story_id: String, segment_index: int) -> void:
    active_story_id = story_id
    active_segment_index = segment_index
    segment_time = 0.0
    if transition_fade:
        transition_fade.color.a = 1.0
    _clear_environment()
    _build_story_environment(story_id, segment_index)
    _clear_actor()
    var actors: Array = STORY_ACTORS.get(story_id, [])
    var spacing := 1.9 if actors.size() > 1 else 0.0
    for i in actors.size():
        var actor := _make_animal(actors[i])
        _fit_animal_to_frame(actor, actors.size() > 1)
        actor.position = Vector3((i - float(actors.size() - 1) / 2.0) * spacing, 0, 0)
        actor.scale = Vector3.ONE * (0.95 if actors.size() > 1 else 1.15)
        actor_root.add_child(actor)
    actor_root.rotation.y = deg_to_rad(-6.0 + float(segment_index) * 4.0)
    _apply_story_segment_pose(story_id, segment_index)
    if transition_fade:
        var fade_tween := create_tween()
        fade_tween.tween_property(transition_fade, "color:a", 0.0, 0.38)

func start_cinematic(segment_index: int, duration: float) -> void:
    active_segment_index = segment_index
    segment_time = 0.0
    segment_duration = maxf(1.0, duration)

func _apply_story_segment_pose(story_id: String, segment_index: int) -> void:
    if story_id != "lion_bull" or actor_root == null or camera == null:
        return
    var lion := actor_root.get_node_or_null("lion") as Node3D
    var bull := actor_root.get_node_or_null("bull") as Node3D
    if lion:
        lion.visible = true
    if bull:
        bull.visible = true

    # Story 1 cinematic blocking: reveal, first dialogue, friendship,
    # then tension and reconciliation. The same two real animal actors are
    # reused throughout so transitions stay smooth and voice-ready.
    match segment_index:
        8, 9, 10:
            if bull:
                bull.visible = false
            camera.position = Vector3(0.0, 2.15, 6.8)
            camera.look_at(Vector3(0, 1.05, 0))
        11:
            if bull:
                bull.visible = true
                bull.scale = Vector3.ONE * 0.9
            camera.position = Vector3(0.2, 2.0, 6.5)
            camera.look_at(Vector3(0, 1.0, 0))
        12:
            camera.position = Vector3(0.0, 2.0, 6.1)
            camera.look_at(Vector3(0, 1.05, 0))
        13, 14:
            camera.position = Vector3(0.0, 2.0, 5.8)
            camera.look_at(Vector3(0, 1.0, 0))
        15, 16:
            camera.position = Vector3(0.0, 2.05, 5.9)
            camera.look_at(Vector3(0, 1.0, 0))
        17, 18, 19:
            camera.position = Vector3(0.0, 2.1, 6.1)
            camera.look_at(Vector3(0, 1.0, 0))
        20, 21, 22:
            camera.position = Vector3(0.0, 2.2, 6.8)
            camera.look_at(Vector3(0, 0.95, 0))
        23, 24, 25:
            camera.position = Vector3(0.15, 2.25, 6.4)
            camera.look_at(Vector3(0, 1.0, 0))
        26:
            camera.position = Vector3(0.0, 2.0, 6.0)
            camera.look_at(Vector3(0, 1.0, 0))
        27, 28:
            camera.position = Vector3(0.0, 2.05, 5.8)
            camera.look_at(Vector3(0, 1.0, 0))
        29:
            camera.position = Vector3(0.0, 2.4, 7.8)
            camera.look_at(Vector3(0, 0.85, 0))
        _:
            camera.position = Vector3(0, 2.1, 7.2)
            camera.look_at(Vector3(0, 1.0, 0))

func _animate_story_segment(delta: float) -> void:
    if active_story_id != "lion_bull" or active_segment_index < 8 or active_segment_index > 29:
        return
    segment_time += delta
    var p := clampf(segment_time / segment_duration, 0.0, 1.0)
    var lion := actor_root.get_node_or_null("lion") as Node3D
    var bull := actor_root.get_node_or_null("bull") as Node3D
    if lion == null or bull == null or camera == null:
        return

    # 09-13: mysterious sound -> reveal -> first confrontation.
    if active_segment_index == 8:
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(-18.0 + sin(segment_time * 3.0) * 2.0), minf(delta * 5.0, 1.0))
        camera.position = camera.position.lerp(Vector3(0.15, 2.25, 6.65), minf(delta * 1.8, 1.0))
    elif active_segment_index == 9:
        camera.position = camera.position.lerp(Vector3(0.0, 2.35, 7.6), minf(delta * 1.4, 1.0))
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(8.0), minf(delta * 2.0, 1.0))
    elif active_segment_index == 10:
        lion.position.x = lerpf(lion.position.x, 0.65, minf(delta * 0.65, 1.0))
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(-8.0), minf(delta * 2.0, 1.0))
        camera.position = camera.position.lerp(Vector3(0.25, 2.1, 6.9), minf(delta * 1.5, 1.0))
    elif active_segment_index == 11:
        var reveal := clampf(p * 1.6, 0.0, 1.0)
        bull.visible = true
        bull.scale = Vector3.ONE * lerpf(0.9, 1.0, reveal)
        camera.position = camera.position.lerp(Vector3(0.0, 1.95, 5.7), minf(delta * 1.7, 1.0))
    elif active_segment_index == 12:
        bull.visible = true
        bull.scale = Vector3.ONE
        lion.position.x = lerpf(lion.position.x, -0.9, minf(delta * 1.2, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.0, 5.2), minf(delta * 1.6, 1.0))

    # 14-19: both characters relax as the misunderstanding turns into friendship.
    elif active_segment_index == 13:
        lion.position.x = lerpf(lion.position.x, -0.95, minf(delta * 1.0, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.95, minf(delta * 1.0, 1.0))
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(10.0), minf(delta * 2.0, 1.0))
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-10.0), minf(delta * 2.0, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.0, 5.7), minf(delta * 1.5, 1.0))
    elif active_segment_index == 14:
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(18.0), minf(delta * 2.0, 1.0))
        camera.position = camera.position.lerp(Vector3(-0.55, 2.05, 5.45), minf(delta * 1.4, 1.0))
    elif active_segment_index == 15:
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-16.0), minf(delta * 2.0, 1.0))
        camera.position = camera.position.lerp(Vector3(0.45, 2.05, 5.45), minf(delta * 1.4, 1.0))
    elif active_segment_index == 16:
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(12.0), minf(delta * 1.5, 1.0))
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-12.0), minf(delta * 1.5, 1.0))
    elif active_segment_index == 17:
        lion.position.x = lerpf(lion.position.x, -0.9, minf(delta * 0.8, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.9, minf(delta * 0.8, 1.0))
    elif active_segment_index == 18:
        lion.position.x = lerpf(lion.position.x, -0.7, minf(delta * 0.9, 1.0))
        camera.position = camera.position.lerp(Vector3(-0.25, 2.0, 5.35), minf(delta * 1.3, 1.0))
    elif active_segment_index == 19:
        bull.position.x = lerpf(bull.position.x, 0.7, minf(delta * 0.9, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.0, 5.6), minf(delta * 1.2, 1.0))

    # 20-22: a brighter friendship montage with gentle camera movement.
    elif active_segment_index == 20:
        var orbit := sin(p * PI) * 0.45
        camera.position = camera.position.lerp(Vector3(orbit, 2.25, 6.5), minf(delta * 1.0, 1.0))
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(12.0), minf(delta, 1.0))
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-12.0), minf(delta, 1.0))
    elif active_segment_index == 21:
        camera.position = camera.position.lerp(Vector3(-0.45, 2.15, 6.0), minf(delta * 1.1, 1.0))
        lion.position.x = lerpf(lion.position.x, -0.85, minf(delta * 0.8, 1.0))
    elif active_segment_index == 22:
        camera.position = camera.position.lerp(Vector3(0.45, 2.15, 6.0), minf(delta * 1.1, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.85, minf(delta * 0.8, 1.0))

    # 23-27: rumors create distance; the camera becomes more restrained.
    elif active_segment_index == 23:
        camera.position = camera.position.lerp(Vector3(0.0, 2.35, 6.8), minf(delta * 1.0, 1.0))
        lion.position.x = lerpf(lion.position.x, -1.2, minf(delta * 0.7, 1.0))
        bull.position.x = lerpf(bull.position.x, 1.2, minf(delta * 0.7, 1.0))
    elif active_segment_index == 24:
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(28.0), minf(delta * 1.6, 1.0))
        camera.position = camera.position.lerp(Vector3(-0.35, 2.25, 6.35), minf(delta * 1.0, 1.0))
    elif active_segment_index == 25:
        lion.position.x = lerpf(lion.position.x, -1.35, minf(delta * 0.6, 1.0))
        bull.position.x = lerpf(bull.position.x, 1.35, minf(delta * 0.6, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.4, 7.1), minf(delta * 0.9, 1.0))
    elif active_segment_index == 26:
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-28.0), minf(delta * 1.5, 1.0))
        camera.position = camera.position.lerp(Vector3(0.35, 2.2, 6.35), minf(delta * 1.0, 1.0))
    elif active_segment_index == 27:
        # The choice to talk brings both characters back into the same frame.
        lion.position.x = lerpf(lion.position.x, -0.95, minf(delta * 0.7, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.95, minf(delta * 0.7, 1.0))
        lion.rotation.y = lerpf(lion.rotation.y, deg_to_rad(12.0), minf(delta * 1.4, 1.0))
        bull.rotation.y = lerpf(bull.rotation.y, deg_to_rad(-12.0), minf(delta * 1.4, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.05, 5.8), minf(delta * 1.3, 1.0))

    # 28-30: apology, acceptance, then a wide moral-ending tableau.
    elif active_segment_index == 28:
        lion.position.x = lerpf(lion.position.x, -0.65, minf(delta * 0.7, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.65, minf(delta * 0.7, 1.0))
        camera.position = camera.position.lerp(Vector3(-0.2, 2.0, 5.55), minf(delta * 1.1, 1.0))
    elif active_segment_index == 29:
        lion.position.x = lerpf(lion.position.x, -0.75, minf(delta * 0.5, 1.0))
        bull.position.x = lerpf(bull.position.x, 0.75, minf(delta * 0.5, 1.0))
        camera.position = camera.position.lerp(Vector3(0.0, 2.55, 7.9), minf(delta * 0.8, 1.0))

    camera.look_at(Vector3(0, 1.0, 0))
func _clear_environment() -> void:
    if environment_root == null:
        return
    for child in environment_root.get_children():
        child.queue_free()


func _build_story_environment(story_id: String, segment_index: int) -> void:
    if environment_root == null:
        return

    # Each story gets its own 3D visual language. These are real MeshInstance3D
    # scene elements, not 2D decorations, and are kept behind the animal actors.
    match story_id:
        "lion_bull":
            _make_meadow_environment(3, 2, true)
        "crow_snake":
            _make_forest_rocks_environment(4, 3)
        "monkey_turtle":
            _make_river_forest_environment()
        "dove_ring":
            _make_dove_garden_environment()
        "lion_hare":
            _make_meadow_environment(5, 3, false)
        _:
            _make_meadow_environment(2, 1, true)

    environment_root.rotation.y = deg_to_rad(float(segment_index) * 1.5)


func _make_meadow_environment(tree_count: int, rock_count: int, flowers: bool) -> void:
    for i in tree_count:
        var x := -4.5 + float(i) * (9.0 / maxf(1.0, float(tree_count - 1)))
        _make_tree(environment_root, Vector3(x, 0, -1.8 - fmod(float(i), 2.0) * 0.8), 0.9 + fmod(float(i), 3.0) * 0.12)
    for i in rock_count:
        var x := -4.0 + float(i) * 2.5
        _make_rock(environment_root, Vector3(x, 0.18, 0.9 + fmod(float(i), 2.0) * 0.4), 0.45 + fmod(float(i), 3.0) * 0.12)
    if flowers:
        for i in 8:
            _make_flower(environment_root, Vector3(-4.5 + float(i) * 1.25, 0.08, 0.7 + fmod(float(i), 3.0) * 0.25))


func _make_forest_rocks_environment(tree_count: int, rock_count: int) -> void:
    for i in tree_count:
        var x := -4.6 + float(i) * 3.05
        _make_tree(environment_root, Vector3(x, 0, -2.0), 1.05 + fmod(float(i), 2.0) * 0.18)
    for i in rock_count:
        _make_rock(environment_root, Vector3(-3.5 + float(i) * 2.4, 0.18, 0.5 + fmod(float(i), 2.0)), 0.5 + fmod(float(i), 2.0) * 0.15)
    for i in 5:
        _make_bush(environment_root, Vector3(-4.2 + float(i) * 2.1, 0.3, -0.2), 0.65)


func _make_river_forest_environment() -> void:
    var water := MeshInstance3D.new()
    var water_mesh := PlaneMesh.new()
    water_mesh.size = Vector2(10, 2.4)
    water.mesh = water_mesh
    water.position = Vector3(0, 0.025, -1.0)
    water.rotation_degrees.x = -90
    water.material_override = _mat(Color("#6ea7ad"))
    environment_root.add_child(water)
    for x in [-4.2, 4.2]:
        _make_tree(environment_root, Vector3(x, 0, -2.2), 1.1)
        _make_reeds(environment_root, Vector3(x * 0.65, 0, 0.4))
    for i in 6:
        _make_rock(environment_root, Vector3(-3.8 + i * 1.5, 0.16, 0.65), 0.32 + fmod(float(i), 2.0) * 0.12)


func _make_dove_garden_environment() -> void:
    for i in 3:
        _make_tree(environment_root, Vector3(-4.0 + i * 4.0, 0, -2.0), 0.95)
    for i in 6:
        _make_bush(environment_root, Vector3(-4.2 + i * 1.7, 0.28, 0.1), 0.55)
    for i in 7:
        _make_flower(environment_root, Vector3(-4.0 + i * 1.3, 0.08, 0.65))
    var perch := MeshInstance3D.new()
    var post := CylinderMesh.new()
    post.top_radius = 0.09
    post.bottom_radius = 0.13
    post.height = 1.5
    perch.mesh = post
    perch.position = Vector3(3.0, 0.75, -0.6)
    perch.material_override = _mat(Color("#8a633f"))
    environment_root.add_child(perch)


func _make_tree(parent: Node3D, pos: Vector3, scale_factor: float) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE * scale_factor
    parent.add_child(root)
    _cylinder(root, Vector3(0, 1.15, 0), Vector3(0.28, 2.3, 0.28), Color("#725033"))
    _sphere(root, Vector3(0, 2.35, 0), Vector3(1.35, 1.0, 1.15), Color("#4d7544"))
    _sphere(root, Vector3(-0.65, 2.15, 0.15), Vector3(0.8, 0.7, 0.75), Color("#5f874b"))
    _sphere(root, Vector3(0.65, 2.15, 0.1), Vector3(0.8, 0.7, 0.75), Color("#5f874b"))


func _make_bush(parent: Node3D, pos: Vector3, scale_factor: float) -> void:
    var root := Node3D.new()
    root.position = pos
    root.scale = Vector3.ONE * scale_factor
    parent.add_child(root)
    _sphere(root, Vector3(-0.35, 0.35, 0), Vector3(0.7, 0.5, 0.65), Color("#5d8448"))
    _sphere(root, Vector3(0.35, 0.4, 0.05), Vector3(0.75, 0.55, 0.7), Color("#4f743e"))


func _make_rock(parent: Node3D, pos: Vector3, scale_factor: float) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 0.8
    _part(parent, mesh, pos, _mat(Color("#8d8270")), Vector3(scale_factor, scale_factor * 0.7, scale_factor * 0.85))


func _make_flower(parent: Node3D, pos: Vector3) -> void:
    _cylinder(parent, pos + Vector3(0, 0.18, 0), Vector3(0.035, 0.35, 0.035), Color("#5b7f3f"))
    _sphere(parent, pos + Vector3(0, 0.38, 0), Vector3(0.16, 0.12, 0.16), Color("#d7a64a"))


func _make_reeds(parent: Node3D, pos: Vector3) -> void:
    for i in 4:
        _cylinder(parent, pos + Vector3(-0.25 + i * 0.17, 0.35, fmod(float(i), 2.0) * 0.15), Vector3(0.035, 0.7, 0.035), Color("#557b4a"))


func _process(delta: float) -> void:
    time += delta
    _animate_story_segment(delta)
    if actor_root:
        actor_root.position.y = sin(time * 1.8) * 0.035
        for child in actor_root.get_children():
            if child is Node3D:
                child.rotation.y += delta * 0.18

func _clear_actor() -> void:
    if actor_root == null:
        return
    for child in actor_root.get_children():
        child.queue_free()

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.9
    return m

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, material: Material, scale := Vector3.ONE) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.mesh = mesh
    n.position = pos
    n.scale = scale
    n.material_override = material
    parent.add_child(n)
    return n

func _sphere(parent: Node3D, pos: Vector3, scale: Vector3, color: Color) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    return _part(parent, mesh, pos, _mat(color), scale)

func _cylinder(parent: Node3D, pos: Vector3, scale: Vector3, color: Color) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.5
    mesh.bottom_radius = 0.5
    mesh.height = 1.0
    return _part(parent, mesh, pos, _mat(color), scale)

func _cone(parent: Node3D, pos: Vector3, scale: Vector3, color: Color) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = 0.5
    mesh.height = 1.0
    return _part(parent, mesh, pos, _mat(color), scale)

func _make_animal(id: String) -> Node3D:
    var imported := _load_real_animal(id)
    if imported != null:
        imported.name = id
        return imported

    if OS.has_feature("release"):
        push_error("Required real animal asset is missing or failed to load: %s" % id)
        var release_root := Node3D.new()
        release_root.name = "%s_missing_asset" % id
        return release_root

    push_warning("Using procedural animal fallback in a non-release build: %s" % id)
    var root := Node3D.new()
    root.name = id
    match id:
        "lion": _make_lion(root)
        "bull": _make_bull(root)
        "crow": _make_bird(root, Color("#252735"), Color("#11131b"))
        "snake": _make_snake(root)
        "monkey": _make_monkey(root)
        "turtle": _make_turtle(root)
        "dove": _make_bird(root, Color("#e8e8df"), Color("#a9a9a2"))
        "hare": _make_hare(root)
        _: _make_hare(root)
    return root

func _fit_animal_to_frame(root: Node3D, is_pair: bool) -> void:
    # Imported GLB/GLTF files can have very different origins and sizes.
    # Normalize every actor so the full body is visible and centered on Android.
    var bounds := AABB()
    var found := false
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var node: Node = stack.pop_back()
        if node is MeshInstance3D and node.mesh != null:
            var local_box := (node as MeshInstance3D).get_aabb()
            var t: Transform3D = root.global_transform.affine_inverse() * (node as MeshInstance3D).global_transform
            for corner in _aabb_corners(local_box):
                var p := t * corner
                if not found:
                    bounds = AABB(p, Vector3.ZERO)
                    found = true
                else:
                    bounds = bounds.expand(p)
        for child in node.get_children():
            stack.append(child)
    if not found or bounds.size.y <= 0.01:
        return
    var target_height := 1.65 if is_pair else 1.9
    var uniform := target_height / bounds.size.y
    root.scale *= Vector3.ONE * uniform
    # Re-center after scaling so feet sit on the stage and no model is clipped.
    var center_x := bounds.position.x + bounds.size.x * 0.5
    var center_z := bounds.position.z + bounds.size.z * 0.5
    root.position = Vector3(-center_x * uniform, -bounds.position.y * uniform, -center_z * uniform)

func _aabb_corners(box: AABB) -> Array[Vector3]:
    var p := box.position
    var s := box.size
    return [
        p,
        p + Vector3(s.x, 0, 0),
        p + Vector3(0, s.y, 0),
        p + Vector3(0, 0, s.z),
        p + Vector3(s.x, s.y, 0),
        p + Vector3(s.x, 0, s.z),
        p + Vector3(0, s.y, s.z),
        p + s,
    ]

func _load_real_animal(id: String) -> Node3D:
    var candidates := [
        "res://assets/3d/animals/%s.glb" % id,
        "res://assets/3d/animals/%s.gltf" % id,
    ]
    for path in candidates:
        if not ResourceLoader.exists(path):
            continue
        var packed := load(path) as PackedScene
        if packed == null:
            push_warning("Animal asset exists but could not be loaded: %s" % path)
            continue
        var instance := packed.instantiate()
        if instance is Node3D:
            _start_first_animation(instance)
            return instance
    return null

func _start_first_animation(root: Node) -> void:
    for child in root.get_children():
        if child is AnimationPlayer:
            var names: PackedStringArray = child.get_animation_list()
            for animation_name in names:
                if animation_name != "RESET":
                    child.play(animation_name)
                    return
        _start_first_animation(child)

func _make_lion(r: Node3D) -> void:
    var fur := Color("#c98b3c")
    var mane := Color("#70411f")
    _sphere(r, Vector3(0, 0.9, 0), Vector3(1.35, 0.72, 0.72), fur)
    _sphere(r, Vector3(0, 1.35, -0.02), Vector3(0.78, 0.78, 0.78), mane)
    _sphere(r, Vector3(0, 1.38, -0.36), Vector3(0.55, 0.48, 0.42), fur)
    for x in [-0.38, 0.38]:
        _cylinder(r, Vector3(x, 0.48, 0), Vector3(0.18, 0.75, 0.18), fur)

func _make_bull(r: Node3D) -> void:
    var body := Color("#6d4b32")
    _sphere(r, Vector3(0, 0.85, 0), Vector3(1.35, 0.78, 0.72), body)
    _sphere(r, Vector3(0, 1.4, -0.22), Vector3(0.72, 0.72, 0.68), body)
    _sphere(r, Vector3(0, 1.28, -0.62), Vector3(0.42, 0.28, 0.25), Color("#9b7356"))
    for x in [-0.42, 0.42]:
        _cylinder(r, Vector3(x, 0.45, 0), Vector3(0.2, 0.8, 0.2), body)
        _cone(r, Vector3(x * 1.25, 1.68, -0.15), Vector3(0.16, 0.45, 0.16), Color("#e8d3a4"))

func _make_bird(r: Node3D, body: Color, wing: Color) -> void:
    _sphere(r, Vector3(0, 1.0, 0), Vector3(1.0, 0.65, 0.55), body)
    _sphere(r, Vector3(0, 1.38, -0.38), Vector3(0.55, 0.55, 0.55), body)
    _cone(r, Vector3(0, 1.34, -0.83), Vector3(0.18, 0.35, 0.18), Color("#c98932"))
    _sphere(r, Vector3(-0.42, 1.05, -0.02), Vector3(0.48, 0.18, 0.6), wing)
    _sphere(r, Vector3(0.42, 1.05, -0.02), Vector3(0.48, 0.18, 0.6), wing)

func _make_snake(r: Node3D) -> void:
    var green := Color("#587b3b")
    for i in 7:
        var x := (float(i) - 3.0) * 0.28
        var z := sin(float(i) * 0.9) * 0.16
        _sphere(r, Vector3(x, 0.35 + abs(z), z), Vector3(0.42, 0.24, 0.32), green)

func _make_monkey(r: Node3D) -> void:
    var fur := Color("#8a5b38")
    var face := Color("#c58f64")
    _sphere(r, Vector3(0, 0.95, 0), Vector3(1.05, 0.7, 0.65), fur)
    _sphere(r, Vector3(0, 1.5, -0.08), Vector3(0.62, 0.68, 0.62), fur)
    _sphere(r, Vector3(0, 1.43, -0.57), Vector3(0.38, 0.32, 0.25), face)
    for x in [-0.35, 0.35]:
        _sphere(r, Vector3(x, 1.58, -0.16), Vector3(0.18, 0.2, 0.08), face)
        _cylinder(r, Vector3(x, 0.48, 0), Vector3(0.15, 0.7, 0.15), fur)

func _make_turtle(r: Node3D) -> void:
    var shell := Color("#496d43")
    var skin := Color("#8aa65b")
    _sphere(r, Vector3(0, 0.65, 0), Vector3(1.3, 0.55, 0.95), shell)
    for x in [-0.72, 0.72]:
        for z in [-0.38, 0.38]:
            _sphere(r, Vector3(x, 0.35, z), Vector3(0.28, 0.22, 0.32), skin)
    _sphere(r, Vector3(0, 0.7, -0.82), Vector3(0.42, 0.38, 0.38), skin)

func _make_hare(r: Node3D) -> void:
    var fur := Color("#b58d69")
    _sphere(r, Vector3(0, 0.85, 0), Vector3(1.0, 0.62, 0.58), fur)
    _sphere(r, Vector3(0, 1.4, -0.25), Vector3(0.58, 0.62, 0.55), fur)
    for x in [-0.2, 0.2]:
        _sphere(r, Vector3(x, 1.95, -0.2), Vector3(0.12, 0.58, 0.12), fur)
