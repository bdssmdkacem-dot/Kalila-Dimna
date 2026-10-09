extends SceneTree

const SCENE_PATH := "res://scenes/scene01_3d.tscn"
const SCRIPT_PATH := "res://scenes/scene01_3d.gd"
const STORY_PATH := "res://data/stories/01_lion_bull.json"
const GLB_PATH := "res://assets/3d/kalila_dimna_scene01_v2.glb"

func _init() -> void:
	var errors: Array[String] = []
	var tscn_source := FileAccess.get_file_as_string(SCENE_PATH)
	var script_source := FileAccess.get_file_as_string(SCRIPT_PATH)

	if tscn_source.contains('path="res://assets/3d/kalila_dimna_scene01_v2.glb"'):
		errors.append("scene01_3d.tscn still hard-links the GLB as an ext_resource")
	if not tscn_source.contains('[node name="KalilaDimnaGLB" type="Node3D" parent="."]'):
		errors.append("scene01_3d.tscn is missing the safe GLB placeholder node")
	if not script_source.contains("func _load_glb_safely() -> bool:"):
		errors.append("scene01_3d.gd is missing safe runtime GLB loading")
	if not script_source.contains('push_error("SCENE01 3D: GLB LOAD FAILED: " + GLB_PATH)'):
		errors.append("scene01_3d.gd is missing an explicit GLB-load failure path")
	if not FileAccess.file_exists(GLB_PATH):
		errors.append("scene01 GLB is missing from the repository")
	elif load(GLB_PATH) == null:
		errors.append("scene01 GLB fails to import/load in Godot")

	var story_parse := JSON.new()
	var story_file := FileAccess.open(STORY_PATH, FileAccess.READ)
	if story_file == null or story_parse.parse(story_file.get_as_text()) != OK:
		errors.append("lion-bull story JSON cannot be read or parsed")

	# The -s test runner does not register project autoload names for scripts
	# instantiated by this test. Check resources here; Android export validates the project.
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		errors.append("scene01_3d.tscn cannot be loaded as a PackedScene")

	if not errors.is_empty():
		push_error("Scene01 boot validation failed: %s" % "; ".join(errors))
		quit(1)
		return

	print("Scene01 boot-safety validation passed: no static GLB dependency, runtime fallback present, and scene/GLB resources load")
	quit(0)
