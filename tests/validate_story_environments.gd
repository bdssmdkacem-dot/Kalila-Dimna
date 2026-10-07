extends SceneTree

const REQUIRED := {
    "lion_bull": ["meadow", "trees", "rocks", "flowers"],
    "crow_snake": ["forest", "rocks", "bushes"],
    "monkey_turtle": ["river", "trees", "reeds"],
    "dove_ring": ["garden", "trees", "flowers", "perch"],
    "lion_hare": ["meadow_variant", "trees", "rocks"],
    "rat_cat": ["forest", "trap", "rocks"],
    "owls_crows": ["forest", "rocks", "bushes"],
    "jackal_lion": ["meadow_variant", "trees", "rocks"],
    "turtle_ducks": ["river", "trees", "reeds"],
}

func _init() -> void:
    # Keep this validation aligned with the runtime story mapping in AnimalStage.
    var stage := load("res://ui/animal_stage.gd")
    if stage == null:
        push_error("AnimalStage script is missing")
        quit(1)
        return

    var source := FileAccess.get_file_as_string("res://ui/animal_stage.gd")
    var missing: Array[String] = []
    var runtime_ids := ["lion_bull", "crow_snake", "monkey_turtle", "dove_ring", "lion_hare", "rat_cat", "owls_crows", "jackal_lion", "turtle_ducks"]

    for story_id in runtime_ids:
        if not source.contains("\"%s\":" % story_id):
            missing.append(story_id)

    if not missing.is_empty():
        push_error("Story environment mapping is missing: %s" % ", ".join(missing))
        quit(1)
        return

    print("Story 3D environment validation passed: %s" % ", ".join(runtime_ids))
    quit(0)
