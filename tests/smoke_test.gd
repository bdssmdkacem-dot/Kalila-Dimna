extends SceneTree
## اختبار دخان: يفتح كل الشاشات ويمرّ بحكاية كاملة.
##   godot --headless -s tests/smoke_test.gd

func _initialize() -> void:
	_run()


func _run() -> void:
	var ok := true
	for p in ["main_menu", "story_map"]:
		change_scene_to_file("res://scenes/%s.tscn" % p)
		await process_frame
		await process_frame
		if current_scene == null:
			printerr("✗ فشل تحميل " + p); ok = false
		else:
			print("✓ ", p)

	var loader = root.get_node("StoryLoader")
	var state = root.get_node("GameState")
	if loader.stories.size() < 1:
		printerr("✗ لا توجد قصص محمّلة"); ok = false

	state.stars = {}
	for story in loader.stories:
		state.current_story = story
		change_scene_to_file("res://scenes/story_player.tscn")
		await process_frame
		await process_frame
		var player = current_scene
		for i in story.segments.size():
			player._on_card_input(_click())
			await process_frame
			var seg: Dictionary = story.segments[i]
			if seg.has("challenge"):
				var btns: Array = player.options_box.get_children().filter(func(c): return c is Button)
				if btns.size() != seg.challenge.options.size():
					printerr("✗ عدد الأزرار خاطئ"); ok = false
				player._on_option(btns[0], false)
				player._on_option(btns[1], true)
			if player.next_btn.disabled:
				printerr("✗ زر التالي معطّل: %s/%d" % [story.id, i + 1]); ok = false
			player._next_segment()
			await process_frame
		await process_frame
		await process_frame
		if current_scene.name != "Result":
			printerr("✗ لم نصل إلى شاشة النتيجة: " + story.id); ok = false
		else:
			print("✓ أُكملت الحكاية ", story.id, " نجوم=", state.last_stars)

	change_scene_to_file("res://scenes/story_map.tscn")
	await process_frame
	await process_frame
	if not state.is_unlocked(loader.stories.size() - 1):
		printerr("✗ الفتح المتسلسل لا يعمل"); ok = false
	DirAccess.remove_absolute("user://save.json")
	print("الاختبار: ", "نجح" if ok else "فشل")
	quit(0 if ok else 1)


func _click() -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.pressed = true
	return e
