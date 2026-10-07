class_name CinematicBackdrop
extends Control

@export var variant := "forest"
var pulse := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 1.0 or s.y <= 1.0:
		return

	draw_rect(Rect2(Vector2.ZERO, s), Color("#071c19"))

	# Slow parallax light: the background never feels static.
	var drift := Vector2(sin(pulse * 0.18) * s.x * 0.018, cos(pulse * 0.14) * s.y * 0.010)
	var center := Vector2(s.x * 0.52, s.y * 0.34) + drift
	for i in range(12, 0, -1):
		var r := s.x * (0.035 + i * 0.032)
		var a := 0.006 + (12 - i) * 0.002
		draw_circle(center, r, Color(0.86, 0.68, 0.31, a))

	var moon := Vector2(s.x * 0.78, s.y * 0.22) + drift * 0.45
	var breathe := 1.0 + sin(pulse * 0.9) * 0.025
	draw_circle(moon, minf(s.x, s.y) * 0.11 * breathe, Color(0.96, 0.82, 0.48, 0.08))
	draw_circle(moon, minf(s.x, s.y) * 0.075 * breathe, Color("#f2d58a"))
	draw_circle(moon + Vector2(-8, -6), minf(s.x, s.y) * 0.061, Color("#fff4c9"))

	var h := s.y * 0.62
	var hill_shift := sin(pulse * 0.10) * 10.0
	var hills := PackedVector2Array([
		Vector2(0, h + 80), Vector2(s.x * 0.12, h - 20 + hill_shift),
		Vector2(s.x * 0.25, h + 36), Vector2(s.x * 0.40, h - 65 - hill_shift),
		Vector2(s.x * 0.55, h + 18), Vector2(s.x * 0.72, h - 44 + hill_shift),
		Vector2(s.x * 0.88, h + 20), Vector2(s.x, h - 10),
		Vector2(s.x, s.y), Vector2(0, s.y)
	])
	draw_colored_polygon(hills, Color("#0a2923"))

	for x in range(-30, int(s.x) + 60, 70):
		var base := s.y
		var th := 120.0 + fmod(abs(float(x) * 1.73), 150.0)
		_draw_tree(Vector2(x, base), th, Color("#051411"))

	for i in range(26):
		var px := fmod(float(i * 137 + 53) + sin(pulse * 0.12 + i) * 10.0, s.x)
		var py := fmod(float(i * 71 + 31) + pulse * (8.0 + i % 4), s.y * 0.72)
		var rr := 1.5 + float(i % 3)
		var alpha := 0.10 + (sin(pulse * 1.4 + i) + 1.0) * 0.05
		draw_circle(Vector2(px, py), rr, Color(0.95, 0.78, 0.38, alpha))

	draw_rect(Rect2(0, 0, s.x, 26), Color(0, 0, 0, 0.22))
	draw_rect(Rect2(0, s.y - 110, s.x, 110), Color(0, 0, 0, 0.20))

func _draw_tree(base: Vector2, height: float, color: Color) -> void:
	var trunk := Rect2(base.x - 6, base.y - height * 0.36, 12, height * 0.36)
	draw_rect(trunk, color)
	var crown := PackedVector2Array([
		Vector2(base.x, base.y - height),
		Vector2(base.x - height * 0.30, base.y - height * 0.45),
		Vector2(base.x - height * 0.18, base.y - height * 0.48),
		Vector2(base.x - height * 0.38, base.y - height * 0.16),
		Vector2(base.x, base.y - height * 0.32),
		Vector2(base.x + height * 0.38, base.y - height * 0.16),
		Vector2(base.x + height * 0.18, base.y - height * 0.48),
		Vector2(base.x + height * 0.30, base.y - height * 0.45)
	])
	draw_colored_polygon(crown, color)
