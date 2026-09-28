extends SceneTree

const EXPECTED := {
    "lion_bull": ["lion", "bull"],
    "crow_snake": ["crow", "snake"],
    "monkey_turtle": ["monkey", "turtle"],
    "dove_ring": ["dove"],
    "lion_hare": ["lion", "hare"],
}

func _init() -> void:
    var file := FileAccess.open("res://data/animals.json", FileAccess.READ)
    if file == null:
        push_error("Missing data/animals.json")
        quit(1)
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("animals.json is not an object")
        quit(1)
        return
    var stories: Dictionary = parsed.get("stories", {})
    if stories.size() != EXPECTED.size():
        push_error("Expected %d animal story mappings, got %d" % [EXPECTED.size(), stories.size()])
        quit(1)
        return
    for story_id in EXPECTED:
        if stories.get(story_id, []) != EXPECTED[story_id]:
            push_error("Animal mapping mismatch for %s" % story_id)
            quit(1)
            return
    print("Animal mapping validation passed")
    quit(0)
