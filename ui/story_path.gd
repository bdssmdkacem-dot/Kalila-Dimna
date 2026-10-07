class_name StoryPath
extends Control

# مسار عمودي يشبه خريطة المخطوطة في التصميم المرجعي.
const NODE_POSITIONS := [
	Vector2(0.22, 0.07),
	Vector2(0.78, 0.18),
	Vector2(0.22, 0.30),
	Vector2(0.78, 0.42),
	Vector2(0.22, 0.54),
	Vector2(0.78, 0.66),
	Vector2(0.22, 0.78),
	Vector2(0.78, 0.90),
	Vector2(0.50, 0.94)
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
	if size.x <= 1.0 or size.y <= 1.0:
		return

	var pts := PackedVector2Array()
	for p in NODE_POSITIONS:
		pts.append(Vector2(p.x * size.x, p.y * size.y))

	for i in range(pts.size() - 1):
		var a := pts[i]
		var b := pts[i + 1]
		draw_line(a, b, Color(0.35, 0.27, 0.12, 0.18), 18.0, true)
		draw_line(a, b, Color(0.55, 0.41, 0.16, 0.46), 4.0, true)

	for i in range(pts.size()):
		var p := pts[i]
		var wave := (sin(pulse * 1.5 - i * 0.8) + 1.0) * 0.5
		draw_circle(p, 48.0 + wave * 4.0, Color(0.55, 0.41, 0.16, 0.035))
		draw_circle(p, 40.0, Color(0.24, 0.17, 0.08, 0.12))
		draw_arc(p, 42.0, 0, TAU, 40, Color("#8a6d10"), 2.0, true)
