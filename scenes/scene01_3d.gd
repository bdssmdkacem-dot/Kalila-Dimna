extends Node3D
## PHASE 53 - Scene 01 gameplay camera.
## The Blender GLB is now the actual 3D story environment.

const GLB_PATH := "res://assets/3d/kalila_dimna_scene01_v2.glb"
const STORY_MAP := "res://scenes/story_map.tscn"

@onready var camera: Camera3D = $Camera3D
@onready var glb_root: Node3D = $KalilaDimnaGLB

func _ready() -> void:
	if not ResourceLoader.exists(GLB_PATH):
		push_error("SCENE01 3D: GLB NOT FOUND: " + GLB_PATH)
		return

	await get_tree().process_frame
	camera.current = true

	# Gameplay composition: focus on the central clearing instead of
	# framing the complete 60m forest as a miniature map.
	camera.position = Vector3(13.5, 8.5, 15.5)
	camera.look_at(Vector3(0.0, 3.0, 0.0), Vector3.UP)
	camera.fov = 58.0

	var mesh_count := _count_visuals(glb_root)
	print("SCENE01 3D TEST: PASS")
	print("GLB: ", GLB_PATH)
	print("VISIBLE NODES: ", mesh_count)
	print("CAMERA: ", camera.position)

func _count_visuals(root: Node) -> int:
	var count := 0
	for node in root.get_children():
		if node is VisualInstance3D:
			count += 1
		count += _count_visuals(node)
	return count

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(STORY_MAP)
