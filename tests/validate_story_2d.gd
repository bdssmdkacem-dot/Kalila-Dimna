extends SceneTree

const REQUIRED := [
    "res://ui/animal_stage_2d.gd",
    "res://assets/images/characters/lion_2d_realistic.webp",
    "res://assets/images/characters/bull_2d_realistic.webp",
    "res://assets/images/backgrounds/lion_bull_2d.svg",
]

func _init() -> void:
    var missing: Array[String] = []
    for path in REQUIRED:
        if not FileAccess.file_exists(path):
            missing.append(path)

    var stage := load("res://ui/animal_stage_2d.gd")
    if stage == null:
        missing.append("res://ui/animal_stage_2d.gd (load failed)")

    var player_source := FileAccess.get_file_as_string("res://scenes/story_player.gd")
    if not player_source.contains("AnimalStage2D.new()"):
        missing.append("story_player.gd does not instantiate AnimalStage2D")

    if not missing.is_empty():
        push_error("2D story validation failed: %s" % ", ".join(missing))
        quit(1)
        return

    print("2D lion/bull story validation passed")
    quit(0)


func _validate_all_story_scene_metadata() -> void:
	var story_paths := [
		"res://data/stories/01_lion_bull.json",
		"res://data/stories/02_crow_snake.json",
		"res://data/stories/03_monkey_turtle.json",
		"res://data/stories/04_dove_ring.json",
		"res://data/stories/05_lion_hare.json"
	]
	for path in story_paths:
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			push_error("Missing story: " + path)
			continue
		var data = JSON.parse_string(f.get_as_text())
		if typeof(data) != TYPE_DICTIONARY:
			push_error("Invalid story JSON: " + path)
			continue
		for i in range(data.get("segments", []).size()):
			var seg: Dictionary = data.segments[i]
			var scene: Dictionary = seg.get("scene", {})
			if scene.is_empty():
				push_error("Missing 2D scene metadata: %s segment %d" % [path, i])
			elif scene.get("actors", []).is_empty():
				push_error("Missing 2D actors: %s segment %d" % [path, i])
