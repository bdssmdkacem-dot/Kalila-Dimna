extends Node
## التقدّم والنجوم (يُحفظ في user://save.json).

const SAVE_PATH := "user://save.json"

var stars: Dictionary = {}          # story_id -> 0..3
var current_story: Dictionary = {}
var last_stars := 0


func _ready() -> void:
	load_game()


func stars_of(id: String) -> int:
	return int(stars.get(id, 0))


func is_unlocked(index: int) -> bool:
	if index <= 0:
		return true
	var prev: Dictionary = StoryLoader.stories[index - 1]
	return stars_of(prev.id) > 0


func set_stars(id: String, n: int) -> void:
	stars[id] = maxi(stars_of(id), n)
	save_game()


func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(stars))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		stars = d
