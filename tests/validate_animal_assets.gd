extends SceneTree

const REQUIRED := [
    "lion",
    "bull",
    "crow",
    "snake",
    "monkey",
    "turtle",
    "dove",
    "hare",
]

func _init() -> void:
    var missing: Array[String] = []
    var invalid: Array[String] = []

    for id in REQUIRED:
        var found := ""
        for extension in ["glb", "gltf"]:
            var path := "res://assets/3d/animals/%s.%s" % [id, extension]
            if FileAccess.file_exists(path):
                found = path
                break
        if found.is_empty():
            missing.append(id)
            continue

        if ResourceLoader.load(found) == null:
            invalid.append(found)

    if not missing.is_empty():
        push_error("Missing required real animal assets: %s" % ", ".join(missing))
    if not invalid.is_empty():
        push_error("Required animal assets failed to load: %s" % ", ".join(invalid))

    if not missing.is_empty() or not invalid.is_empty():
        quit(1)
        return

    print("Real animal asset validation passed: %s" % ", ".join(REQUIRED))
    quit(0)
