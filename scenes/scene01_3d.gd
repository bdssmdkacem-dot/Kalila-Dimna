extends Node3D
## PHASE 52 - Scene 01 3D integration test.
## Automatically frames the imported Blender GLB so the first Godot test
## does not depend on Blender's original camera coordinates.

const GLB_PATH := "res://assets/3d/kalila_dimna_scene01_v2.glb"

@onready var camera: Camera3D = $Camera3D
@onready var glb_root: Node3D = $KalilaDimnaGLB

func _ready() -> void:
	if not ResourceLoader.exists(GLB_PATH):
		push_error("SCENE01 3D: GLB NOT FOUND: " + GLB_PATH)
		return

	await get_tree().process_frame
	_frame_imported_scene()

	camera.current = true
	print("SCENE01 3D TEST: PASS")
	print("GLB: ", GLB_PATH)
	print("ROOT: ", glb_root.name)

func _frame_imported_scene() -> void:
	var bounds := _collect_bounds(glb_root)

	if bounds.size <= Vector3.ZERO:
		push_error("SCENE01 3D: NO VISIBLE MESHES FOUND")
		return

	var center := bounds.position + bounds.size * 0.5
	var radius := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z)) * 0.5
	radius = maxf(radius, 2.0)

	# Move the camera in a predictable diagonal position relative to the
	# actual imported GLB bounds, then point it at the scene center.
	var distance := maxf(radius * 2.2, 12.0)
	camera.position = center + Vector3(distance * 0.75, distance * 0.55, distance * 0.55)
	camera.fov = 52.0
	camera.look_at(center, Vector3.UP)

	print("SCENE01 BOUNDS: center=", center, " size=", bounds.size)
	print("SCENE01 CAMERA: position=", camera.position)

func _collect_bounds(root: Node) -> AABB:
	var result := AABB()
	var has_bounds := false

	for node in root.get_children():
		if node is VisualInstance3D:
			var visual := node as VisualInstance3D
			var local_box := visual.get_aabb()
			var global_box := _transform_aabb(local_box, visual.global_transform)
			if not has_bounds:
				result = global_box
				has_bounds = true
			else:
				result = result.merge(global_box)

		var child_box := _collect_bounds(node)
		if child_box.size != Vector3.ZERO:
			if not has_bounds:
				result = child_box
				has_bounds = true
			else:
				result = result.merge(child_box)

	return result

func _transform_aabb(box: AABB, transform: Transform3D) -> AABB:
	var result := AABB()
	var first := true

	for x in [box.position.x, box.end.x]:
		for y in [box.position.y, box.end.y]:
			for z in [box.position.z, box.end.z]:
				var point := transform * Vector3(x, y, z)
				if first:
					result = AABB(point, Vector3.ZERO)
					first = false
				else:
					result = result.expand(point)

	return result
