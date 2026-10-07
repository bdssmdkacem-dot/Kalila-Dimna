class_name StoryPath
extends Control

const NODE_POSITIONS := [
	Vector2(0.12, 0.72), Vector2(0.32, 0.42), Vector2(0.52, 0.68),
	Vector2(0.72, 0.36), Vector2(0.88, 0.62)
]
var node_positions := NODE_POSITIONS
var pulse := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	if size.x <= 1.0:
		return
	var pts := PackedVector2Array()
	for p in NODE_POSITIONS:
		pts.append(Vector2(p.x * size.x, p.y * size.y))
	for i in range(pts.size() - 1):
		var a := pts[i]
		var b := pts[i + 1]
		var steps := 24
		for j in range(steps):
			var t0 := float(j) / steps
			var t1 := float(j + 1) / steps
			var p0 := a.lerp(b, t0)
			var p1 := a.lerp(b, t1)
			draw_line(p0, p1, Color(0.70, 0.54, 0.24, 0.24), 18.0, true)
			draw_line(p0, p1, Color("#e4c66f"), 4.0, true)
	for i in range(pts.size()):
		var p := pts[i]
		var wave := (sin(pulse * 1.6 - i * 0.8) + 1.0) * 0.5
		draw_circle(p, 38.0 + wave * 5.0, Color(0.86, 0.68, 0.30, 0.05 + wave * 0.05))
		draw_circle(p, 34.0, Color(0.02, 0.10, 0.08, 0.82))
		draw_arc(p, 35.0, 0, TAU, 32, Color("#d9b45a"), 3.0, true)
		draw_arc(p, 29.0, -PI * 0.35, PI * 0.35, 18, Color(0.96, 0.82, 0.48, 0.45), 2.0, true)
