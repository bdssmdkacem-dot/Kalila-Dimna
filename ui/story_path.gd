class_name StoryPath
extends Control

var node_positions := [
	Vector2(0.12, 0.72), Vector2(0.32, 0.42), Vector2(0.52, 0.68),
	Vector2(0.72, 0.36), Vector2(0.88, 0.62)
]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	if size.x <= 1.0:
		return
	var pts := PackedVector2Array()
	for p in node_positions:
		pts.append(Vector2(p.x * size.x, p.y * size.y))
	for i in range(pts.size() - 1):
		var a := pts[i]
		var b := pts[i + 1]
		var steps := 18
		for j in range(steps):
			var t0 := float(j) / steps
			var t1 := float(j + 1) / steps
			var p0 := a.lerp(b, t0)
			var p1 := a.lerp(b, t1)
			draw_line(p0, p1, Color("#b38b3d"), 12.0, true)
			draw_line(p0, p1, Color("#e4c66f"), 4.0, true)
	for p in pts:
		draw_circle(p, 34.0, Color(0.02, 0.10, 0.08, 0.75))
		draw_arc(p, 35.0, 0, TAU, 32, Color("#d9b45a"), 3.0, true)
