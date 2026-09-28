extends Node
## يقرأ كل ملفات القصص من data/stories ويرتبها حسب الحقل order.

const DIR := "res://data/stories/"

var stories: Array = []


func _ready() -> void:
	for f in DirAccess.get_files_at(DIR):
		if not f.ends_with(".json"):
			continue
		var file := FileAccess.open(DIR + f, FileAccess.READ)
		if file == null:
			push_warning("تعذّر فتح " + f)
			continue
		var data = JSON.parse_string(file.get_as_text())
		if data is Dictionary:
			stories.append(data)
		else:
			push_warning("ملف قصة غير صالح: " + f)
	stories.sort_custom(func(a, b): return int(a.order) < int(b.order))


func index_of(id: String) -> int:
	for i in stories.size():
		if stories[i].id == id:
			return i
	return -1
