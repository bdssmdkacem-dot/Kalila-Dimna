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

func _ready() -> void:
    custom_minimum_size = Vector2(0, 430)
    _build_stage()

func _build_stage() -> void:
    var container := SubViewportContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.stretch = true
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(container)

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
    camera.fov = 35.0
    world_root.add_child(camera)

    environment_root = Node3D.new()
    world_root.add_child(environment_root)

    actor_root = Node3D.new()
    world_root.add_child(actor_root)

func show_segment(story_id: String, segment_index: int) -> void:
    _clear_environment()
    _build_story_environment(story_id, segment_index)
    _clear_actor()
    var actors: Array = STORY_ACTORS.get(story_id, [])
    var spacing := 1.9 if actors.size() > 1 else 0.0
    for i in actors.size():
        var actor := _make_animal(actors[i])
        actor.position = Vector3((i - float(actors.size() - 1) / 2.0) * spacing, 0, 0)
        actor.scale = Vector3.ONE * (0.95 if actors.size() > 1 else 1.15)
        actor_root.add_child(actor)
    actor_root.rotation.y = deg_to_rad(-6.0 + float(segment_index) * 4.0)

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
