class_name RewardFX
extends Control

var time := 0.0
var particles: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(42):
		particles.append({
			"origin": Vector2(0.5, 0.40),
			"angle": TAU * float(i) / 42.0 + sin(i * 4.7) * 0.15,
			"speed": 80.0 + float((i * 37) % 120),
			"size": 2.0 + float(i % 4),
			"phase": float(i) * 0.17
		})
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.38)
	var pulse := 1.0 + sin(time * 2.2) * 0.05
	draw_circle(center, minf(size.x, size.y) * 0.22 * pulse, Color(0.95, 0.78, 0.38, 0.035))
	draw_circle(center, minf(size.x, size.y) * 0.13 * pulse, Color(0.95, 0.82, 0.48, 0.045))
	for p in particles:
		var age := fmod(time + float(p.phase), 2.4)
		var distance := float(p.speed) * age
		var pos := center + Vector2(cos(float(p.angle)), sin(float(p.angle))) * distance
		pos.y += 85.0 * age * age
		if pos.y > size.y * 0.82:
			continue
		var alpha := clampf(1.0 - age / 2.4, 0.0, 1.0) * 0.72
		var sz := float(p.size)
		draw_circle(pos, sz, Color(0.95, 0.78, 0.38, alpha))
