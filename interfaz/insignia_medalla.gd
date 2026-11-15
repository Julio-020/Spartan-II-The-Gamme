extends Control


var id: String = ""
var color: Color = Color.WHITE
var apagada: bool = false
var tam: float = 96.0

var _t: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(tam, tam * 1.2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if not apagada:
		_t += delta
		queue_redraw()


func _draw() -> void:
	var c := Vector2(tam * 0.5, tam * 0.5)
	var r := tam * 0.42
	var col := Color(0.35, 0.35, 0.4) if apagada else color

	var cinta := Color(col.r * 0.7, col.g * 0.7, col.b * 0.7, 1.0)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.55, r * 0.6), c + Vector2(-r * 0.15, r * 0.85), c + Vector2(-r * 0.4, r * 1.3), c + Vector2(-r * 0.85, r * 0.95)]), cinta)
	draw_colored_polygon(PackedVector2Array([c + Vector2(r * 0.55, r * 0.6), c + Vector2(r * 0.15, r * 0.85), c + Vector2(r * 0.4, r * 1.3), c + Vector2(r * 0.85, r * 0.95)]), cinta.darkened(0.15))

	draw_circle(c, r, col.darkened(0.45))
	draw_circle(c, r * 0.94, col)
	draw_circle(c, r * 0.78, col.darkened(0.38))
	draw_arc(c, r * 0.86, 0.0, TAU, 48, col.lightened(0.35), 2.0)
	_simbolo(c, r * 0.55, col.lightened(0.55) if not apagada else Color(0.6, 0.6, 0.65))

	if not apagada:
		var b := fposmod(_t * 0.35, 1.6) - 0.3
		if b > 0.0 and b < 1.0:
			var x := c.x - r + b * 2.0 * r
			draw_line(Vector2(x, c.y - r * 0.7), Vector2(x - r * 0.35, c.y + r * 0.7), Color(1, 1, 1, 0.35 * sin(b * PI)), 6.0)


func _simbolo(c: Vector2, s: float, k: Color) -> void:
	match id:
		"ruta":

			draw_line(c + Vector2(-s, s * 0.5), c + Vector2(s * 0.8, -s * 0.5), k, 4.0)
			draw_colored_polygon(PackedVector2Array([c + Vector2(s, -s * 0.6), c + Vector2(s * 0.35, -s * 0.55), c + Vector2(s * 0.75, -s * 0.05)]), k)
			draw_circle(c + Vector2(-s, s * 0.5), 4.0, k)
		"bateria":
			var rc := Rect2(c + Vector2(-s * 0.8, -s * 0.45), Vector2(s * 1.4, s * 0.9))
			draw_rect(rc, k, false, 3.0)
			draw_rect(Rect2(c + Vector2(s * 0.6, -s * 0.18), Vector2(s * 0.22, s * 0.36)), k)
			for i in range(3):
				draw_rect(Rect2(c + Vector2(-s * 0.68 + float(i) * s * 0.42, -s * 0.3), Vector2(s * 0.32, s * 0.6)), k)
		"curioso":
			draw_arc(c + Vector2(-s * 0.1, -s * 0.1), s * 0.55, 0.0, TAU, 28, k, 4.0)
			draw_line(c + Vector2(s * 0.3, s * 0.3), c + Vector2(s * 0.85, s * 0.85), k, 6.0)
			draw_circle(c + Vector2(-s * 0.1, -s * 0.1), s * 0.12, k)
		"superviviente":

			draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.7, -s * 0.7), c + Vector2(s * 0.7, -s * 0.7), c + Vector2(s * 0.7, s * 0.1), c + Vector2(0, s * 0.95), c + Vector2(-s * 0.7, s * 0.1)]), k)
			draw_colored_polygon(PackedVector2Array([c + Vector2(s * 0.12, -s * 0.55), c + Vector2(-s * 0.35, s * 0.1), c + Vector2(-s * 0.02, s * 0.1), c + Vector2(-s * 0.15, s * 0.65), c + Vector2(s * 0.38, -s * 0.12), c + Vector2(s * 0.05, -s * 0.12)]), Color(0.15, 0.1, 0.12))
		"decisivo":

			draw_line(c + Vector2(0, s * 0.8), c + Vector2(0, 0), k, 4.0)
			draw_line(c, c + Vector2(-s * 0.65, -s * 0.65), k, 4.0)
			draw_line(c, c + Vector2(s * 0.65, -s * 0.65), k, 4.0)
			draw_circle(c + Vector2(-s * 0.65, -s * 0.65), 5.0, k)
			draw_circle(c + Vector2(s * 0.65, -s * 0.65), 5.0, k)
		_:

			var pts := PackedVector2Array()
			for i in range(10):
				var rr := s if i % 2 == 0 else s * 0.45
				var a := -PI * 0.5 + float(i) * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * rr)
			draw_colored_polygon(pts, k)
