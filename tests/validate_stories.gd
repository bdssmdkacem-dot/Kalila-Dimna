extends SceneTree
## فحص بنية ملفات القصص. التشغيل:
##   godot --headless -s tests/validate_stories.gd
## يخرج بالرمز 1 عند وجود خطأ (يُستخدم في GitHub Actions).

func _initialize() -> void:
	var errors := 0
	var ids := {}
	var orders := {}
	var files := DirAccess.get_files_at("res://data/stories/")
	for f in files:
		if not f.ends_with(".json"):
			continue
		var txt := FileAccess.get_file_as_string("res://data/stories/" + f)
		var d = JSON.parse_string(txt)
		if not (d is Dictionary):
			printerr("✗ %s: JSON غير صالح" % f); errors += 1; continue
		for k in ["id", "order", "title", "moral", "segments"]:
			if not d.has(k):
				printerr("✗ %s: الحقل '%s' مفقود" % [f, k]); errors += 1
		if d.has("id"):
			if ids.has(d.id):
				printerr("✗ %s: id مكرر" % f); errors += 1
			ids[d.id] = true
		if d.has("order"):
			if orders.has(int(d.order)):
				printerr("✗ %s: order مكرر" % f); errors += 1
			orders[int(d.order)] = true
		if d.has("segments"):
			if not (d.segments is Array) or d.segments.is_empty():
				printerr("✗ %s: segments فارغ" % f); errors += 1
			else:
				for i in d.segments.size():
					var s = d.segments[i]
					if not s.has("text") or String(s.text).strip_edges() == "":
						printerr("✗ %s: المقطع %d بلا نص" % [f, i + 1]); errors += 1
					if s.has("challenge"):
						var c = s.challenge
						var n: int = c.options.size() if c.has("options") else 0
						if n < 2 or not c.has("question") or not c.has("answer") or int(c.answer) < 0 or int(c.answer) >= n:
							printerr("✗ %s: تحدٍّ غير صالح في المقطع %d" % [f, i + 1]); errors += 1
		print("✓ ", f)
	if ids.is_empty():
		printerr("✗ لا توجد قصص"); errors += 1
	print("انتهى الفحص: %d خطأ" % errors)
	quit(1 if errors > 0 else 0)
