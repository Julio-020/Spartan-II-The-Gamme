extends Control


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const HistoriaVisual := preload("res://historia/historia_visual.gd")


const FONDOS := [
	[1980, Color(0.42, 0.15, 0.08), Color(0.9, 0.5, 0.22), Color(0.2, 0.07, 0.04), Color(1.0, 0.93, 0.8)],
	[2000, Color(0.07, 0.14, 0.36), Color(0.36, 0.55, 0.85), Color(0.05, 0.09, 0.2), Color(1.0, 1.0, 1.0)],
	[2010, Color(0.05, 0.27, 0.32), Color(0.4, 0.7, 0.62), Color(0.04, 0.14, 0.17), Color(0.95, 1.0, 0.97)],
	[2150, Color(0.05, 0.07, 0.2), Color(0.42, 0.28, 0.5), Color(0.04, 0.04, 0.12), Color(0.94, 0.96, 1.0)],
	[9999, Color(0.025, 0.015, 0.09), Color(0.32, 0.14, 0.46), Color(0.02, 0.01, 0.06), Color(0.97, 0.93, 1.0)],
]

var _m: Dictionary = {}


func configurar(datos: Dictionary) -> void:
	_m = datos
	if custom_minimum_size.x < 10.0:
		custom_minimum_size = Vector2(700.0, 150.0)
	queue_redraw()


func _fondo() -> Array:
	var era := int(str(_m.get("era", "1999")))
	for f: Array in FONDOS:
		if era < int(f[0]):
			return f
	return FONDOS[FONDOS.size() - 1]


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 10.0 or _m.is_empty():
		return
	var f := _fondo()
	var arriba: Color = f[1]
	var abajo: Color = f[2]
	var suelo: Color = f[3]
	var texto: Color = f[4]
	var tipo := HistoriaVisual.tipo(_m)
	var era := int(str(_m.get("era", "0")))
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(hash(str(_m.get("id", "")))) + 3


	var n := 16
	for i in range(n):
		var c := arriba.lerp(abajo, float(i) / float(n - 1))
		draw_rect(Rect2(0, h * float(i) / float(n), w, h / float(n) + 1.0), c)

	if era >= 2000:
		for i in range(26):
			draw_circle(Vector2(rng.randf() * w, rng.randf() * h * 0.5), rng.randf_range(0.7, 1.6), Color(1, 1, 1, rng.randf_range(0.3, 0.8)))

	var sx := w * rng.randf_range(0.5, 0.62)
	var sy := h * 0.52
	draw_circle(Vector2(sx, sy), h * 0.2, Color(1.0, 0.9, 0.7, 0.18))
	draw_circle(Vector2(sx, sy), h * 0.12, Color(1.0, 0.92, 0.75, 0.32))

	var hor := h * 0.76
	var pts := PackedVector2Array([Vector2(0, h)])
	for i in range(0, 29):
		var x := w * float(i) / 28.0
		pts.append(Vector2(x, hor + sin(float(i) * 0.7 + rng.randf()) * 6.0 + sin(float(i) * 0.23) * 5.0))
	pts.append(Vector2(w, h))
	draw_colored_polygon(pts, suelo)


	_nave(tipo, Vector2(w * 0.74, hor + 2.0), h / 150.0, texto, suelo)


	var fuente := EstiloUI.fuente_titulo()
	var tam := int(h * 0.56)
	var anio := str(_m.get("era", ""))
	draw_string_outline(fuente, Vector2(18.0, h * 0.62), anio, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, 10, Color(0, 0, 0, 0.45))
	draw_string(fuente, Vector2(18.0, h * 0.62), anio, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, texto)

	draw_rect(Rect2(0, h - 26.0, w, 26.0), Color(0, 0, 0, 0.5))
	draw_string(EstiloUI.fuente_titulo(), Vector2(18.0, h - 8.0), str(_m.get("nave", "")).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, w - 36.0, 15, texto)
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.12), false, 2.0)


func _poli(pts: Array, col: Color) -> void:
	var v := PackedVector2Array()
	for p: Vector2 in pts:
		v.append(p)
	draw_colored_polygon(v, col)


func _lander(o: Vector2, s: float, col: Color) -> void:

	_poli([o + Vector2(-16, -34) * s, o + Vector2(16, -34) * s, o + Vector2(12, -50) * s, o + Vector2(-12, -50) * s], col)
	for sg in [-1.0, 1.0]:
		draw_line(o + Vector2(sg * 14.0, -34.0) * s, o + Vector2(sg * 32.0, 0.0) * s, col, 3.0 * s, true)
		draw_line(o + Vector2(sg * 32.0 - 6.0, 0.0) * s, o + Vector2(sg * 32.0 + 6.0, 0.0) * s, col, 3.0 * s, true)
	draw_line(o + Vector2(0, -34) * s, o + Vector2(0, -4) * s, col, 3.0 * s, true)

	draw_line(o + Vector2(-8, -50) * s, o + Vector2(-14, -64) * s, col, 2.0 * s, true)
	draw_arc(o + Vector2(-14, -66) * s, 8.0 * s, PI * 1.05, PI * 1.95, 10, col, 2.4 * s, true)


func _nave(tipo: String, o: Vector2, s: float, col: Color, suelo: Color) -> void:
	var sombra := Color(0.0, 0.0, 0.0, 0.55)
	match tipo:
		"aterrizaje":
			_lander(o, s, sombra)

			draw_arc(o + Vector2(36, -108) * s, 30.0 * s, PI, TAU, 16, col, 3.0 * s, true)
			for i in range(5):
				var x := -30.0 + 15.0 * float(i)
				draw_line(o + Vector2(36 + x, -108) * s, o + Vector2(0, -50) * s, Color(col.r, col.g, col.b, 0.7), 1.0 * s, true)
		"rover":
			var b := o + Vector2(0, -2)
			_poli([b + Vector2(-34, -22) * s, b + Vector2(34, -22) * s, b + Vector2(30, -38) * s, b + Vector2(-30, -38) * s], sombra)
			draw_line(b + Vector2(14, -38) * s, b + Vector2(14, -60) * s, sombra, 3.0 * s, true)
			draw_circle(b + Vector2(14, -62) * s, 4.0 * s, sombra)
			for x in [-26.0, 0.0, 26.0]:
				draw_circle(b + Vector2(x, -9.0) * s, 11.0 * s, sombra)

			for i in range(5):
				draw_circle(b + Vector2(-60.0 - float(i) * 18.0, -2.0) * s, 2.2 * s, Color(0, 0, 0, 0.4))
		"restos":
			var choque := HistoriaVisual.modo(str(_m.get("id", ""))) == "choque"
			if choque:
				draw_set_transform(o + Vector2(0, 0), 0.42, Vector2.ONE)
				_lander(Vector2(0, 2), s, sombra)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

				for i in range(6):
					draw_circle(o + Vector2(10.0 + sin(float(i)) * 8.0, -46.0 - float(i) * 13.0) * s, (7.0 + float(i) * 2.2) * s, Color(0.08, 0.07, 0.07, 0.5 - float(i) * 0.06))
			else:
				_lander(o, s, sombra)

				for i in range(3):
					draw_arc(o + Vector2(-14, -66) * s, (16.0 + float(i) * 10.0) * s, -PI * 0.85, -PI * 0.15, 12, Color(col.r, col.g, col.b, 0.55 - float(i) * 0.12), 2.0 * s, true)
				draw_line(o + Vector2(-40, -92) * s, o + Vector2(14, -50) * s, Color(0.95, 0.25, 0.2, 0.9), 4.0 * s, true)
		"colonia":
			draw_line(o, o + Vector2(0, -78) * s, sombra, 4.0 * s, true)
			draw_circle(o + Vector2(0, -82) * s, 6.0 * s, Color(0.85, 0.65, 1.0))
			for i in range(3):
				draw_arc(o + Vector2(0, -82) * s, (16.0 + float(i) * 14.0) * s, -PI * 0.85, -PI * 0.15, 14, Color(0.85, 0.65, 1.0, 0.7 - float(i) * 0.2), 2.2 * s, true)
			_poli([o + Vector2(-44, 0) * s, o + Vector2(-36, -14) * s, o + Vector2(-8, -14) * s, o + Vector2(-2, 0) * s], sombra)
