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
