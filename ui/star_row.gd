class_name StarRow
extends Control
## صف نجوم مرسومة بالكود (لا تحتاج خطوطاً ولا صوراً).

var filled := 0
var total := 3
var star_size := 70.0
var gap := 14.0


func setup(f: int, sz: float = 70.0, t: int = 3) -> StarRow:
	filled = f
	star_size = sz
	total = t
	custom_minimum_size = Vector2(t * sz + (t - 1) * gap, sz)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()
	return self


func _draw() -> void:
	for i in total:
		var cx := star_size * 0.5 + i * (star_size + gap)
		var cy := star_size * 0.5
		var pts := PackedVector2Array()
		for k in 10:
			var r: float = star_size * 0.5 if k % 2 == 0 else star_size * 0.22
			var a: float = -PI / 2.0 + k * PI / 5.0
			pts.append(Vector2(cx + r * cos(a), cy + r * sin(a)))
		var on := i < filled
		draw_colored_polygon(pts, UI.C_GOLD if on else Color("ddd3b8"))
		pts.append(pts[0])
		draw_polyline(pts, UI.C_GOLD_DARK if on else Color("b9ad8d"), 3.0)
