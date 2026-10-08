extends Node3D
## PHASE 52 - Scene 01 3D integration test.
## Imports the Blender GLB and prepares a stable Godot 3D camera.

const GLB_PATH := "res://assets/3d/kalila_dimna_scene01_v2.glb"

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	if not ResourceLoader.exists(GLB_PATH):
		push_error("SCENE01 3D: GLB NOT FOUND: " + GLB_PATH)
		return

	camera.current = true
	print("SCENE01 3D TEST: PASS")
	print("GLB: ", GLB_PATH)
	print("ROOT: ", get_node("KalilaDimnaGLB").name)

func _process(_delta: float) -> void:
	# Keep the first integration test deterministic.
	camera.look_at(Vector3(0, 3, 0), Vector3.UP)
