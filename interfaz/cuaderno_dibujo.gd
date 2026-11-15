extends Control


const LAPIZ := Color(0.2, 0.22, 0.3)
const LAPIZ_SUAVE := Color(0.2, 0.22, 0.3, 0.35)
const PAPEL := Color(0.94, 0.91, 0.82)
const ROJO := Color(0.72, 0.28, 0.18)

var _m: Dictionary = {}
var _e: Dictionary = {}


func configurar(mision: Dictionary, entrada: Dictionary) -> void:
	_m = mision
	_e = entrada
	if custom_minimum_size.x < 10.0:
		custom_minimum_size = Vector2(380.0, 230.0)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 10.0 or _m.is_empty():
		return
	var amb: Dictionary = _m.get("amb", {})
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(hash(str(_m.get("id", "")))) + 17
	draw_rect(Rect2(0, 0, w, h), PAPEL)
	draw_rect(Rect2(0, 0, w, h), LAPIZ_SUAVE, false, 1.5)
	draw_rect(Rect2(w * 0.5 - 30.0, -6.0, 60.0, 16.0), Color(0.85, 0.8, 0.6, 0.75))

	var hor := h * 0.62

	var elev := float(amb.get("sol_elev", 45.0))
	var sy := lerpf(hor - 14.0, 36.0, clampf(elev / 65.0, 0.0, 1.0))
	var sx := lerpf(w * 0.18, w * 0.82, rng.randf())
	draw_arc(Vector2(sx, sy), 13.0, 0.0, TAU, 20, LAPIZ, 1.6, true)
	for i in range(10):
		var a := TAU * float(i) / 10.0
		draw_line(Vector2(sx, sy) + Vector2(cos(a), sin(a)) * 18.0, Vector2(sx, sy) + Vector2(cos(a), sin(a)) * 25.0, LAPIZ, 1.2, true)


	var polvo := float(amb.get("polvo", 0.3))
	var nrayas := int(round(polvo * 6.0))
	for i in range(nrayas):
		var y := 20.0 + float(i) * (hor - 40.0) / 6.0 + rng.randf_range(-4.0, 4.0)
		var pts := PackedVector2Array()
		var x0 := rng.randf_range(8.0, w * 0.35)
		for j in range(14):
			pts.append(Vector2(x0 + float(j) * 14.0, y + sin(float(j) * 0.9 + float(i)) * 3.0))
		draw_polyline(pts, LAPIZ_SUAVE, 1.2, true)
	var niebla := float(amb.get("niebla", 0.3))
	if niebla > 0.5:
		for i in range(3):
			draw_line(Vector2(10.0, hor - 6.0 - float(i) * 6.0), Vector2(w - 10.0, hor - 6.0 - float(i) * 6.0), LAPIZ_SUAVE, 1.0)


	var amp := 8.0 + 16.0 * rng.randf() + 6.0 * float(amb.get("cuevas", 0) > 0)
	var perfil := PackedVector2Array()
	var ph := rng.randf() * 6.0
	for i in range(0, 41):
		var x := w * float(i) / 40.0
		var y := hor - amp * (0.5 + 0.5 * sin(float(i) * 0.35 + ph)) * (0.6 + 0.4 * sin(float(i) * 0.9 + ph * 2.0)) - 4.0
		perfil.append(Vector2(x, y))
	draw_polyline(perfil, LAPIZ, 1.8, true)
	draw_line(Vector2(0, hor), Vector2(w, hor), LAPIZ, 1.2, true)

	var x := 6.0
	while x < w - 6.0:
		var y1 := hor + 5.0 + rng.randf_range(0.0, 6.0)
		draw_line(Vector2(x, y1), Vector2(x - 8.0, y1 + 12.0 + rng.randf_range(0.0, 10.0)), LAPIZ_SUAVE, 1.0)
		x += 11.0


	if int(amb.get("cuevas", 0)) > 0:
		var cx := w * rng.randf_range(0.55, 0.8)
		draw_arc(Vector2(cx, hor - 2.0), 22.0, PI, TAU, 14, LAPIZ, 2.0, true)
		var pts := PackedVector2Array()
		for i in range(0, 13):
			var a := PI + PI * float(i) / 12.0
			pts.append(Vector2(cx + cos(a) * 18.0, hor - 2.0 + sin(a) * 16.0))
		pts.append(Vector2(cx + 18.0, hor - 2.0))
		pts.append(Vector2(cx - 18.0, hor - 2.0))
		draw_colored_polygon(pts, Color(0.2, 0.22, 0.3, 0.75))


	if int(amb.get("remolinos", 0)) > 0:
		var rx := w * rng.randf_range(0.3, 0.6)
		var esp := PackedVector2Array()
		for i in range(0, 36):
			var t := float(i) / 35.0
			esp.append(Vector2(rx + sin(t * 14.0) * (4.0 + 16.0 * t), hor + 20.0 - t * 48.0))
		draw_polyline(esp, LAPIZ, 1.3, true)


	if absf(float(_m.get("lat_real", _m.get("lat", 0.0)))) >= 65.0:
		for i in range(26):
			draw_circle(Vector2(rng.randf_range(6.0, w - 6.0), rng.randf_range(10.0, h - 28.0)), 1.6, Color(1, 1, 1, 0.95))
			draw_arc(Vector2(rng.randf_range(6.0, w - 6.0), rng.randf_range(10.0, hor)), 2.2, 0.0, TAU, 8, LAPIZ_SUAVE, 1.0, true)


	var ry := hor + 26.0
	var rx0 := 44.0
	draw_rect(Rect2(rx0, ry - 14.0, 34.0, 11.0), PAPEL)
	draw_rect(Rect2(rx0, ry - 14.0, 34.0, 11.0), LAPIZ, false, 1.6)
	draw_line(Vector2(rx0 + 24.0, ry - 14.0), Vector2(rx0 + 24.0, ry - 24.0), LAPIZ, 1.6, true)
	draw_rect(Rect2(rx0 + 20.0, ry - 28.0, 9.0, 4.0), LAPIZ)
	for dx in [6.0, 17.0, 28.0]:
		draw_arc(Vector2(rx0 + dx, ry - 1.0), 4.0, 0.0, TAU, 10, LAPIZ, 1.5, true)
	var bx := w - 54.0
	var xx := rx0 + 44.0
	while xx < bx - 12.0:
		draw_circle(Vector2(xx, ry + 1.0 + sin(xx * 0.12) * 2.0), 1.3, LAPIZ)
		xx += 9.0
	draw_line(Vector2(bx, ry + 2.0), Vector2(bx, ry - 26.0), LAPIZ, 1.6, true)
	draw_colored_polygon(PackedVector2Array([Vector2(bx, ry - 26.0), Vector2(bx + 16.0, ry - 21.0), Vector2(bx, ry - 16.0)]), ROJO)


	var total := int(_e.get("total", 0))
	var n := int(_e.get("muestras", 0))
	for i in range(mini(total, 10)):
		var c := Vector2(16.0 + float(i) * 16.0, h - 14.0)
		var rombo := PackedVector2Array([c + Vector2(0, -6), c + Vector2(5, 0), c + Vector2(0, 6), c + Vector2(-5, 0)])
		if i < n:
			draw_colored_polygon(rombo, ROJO)
		else:
			var cerrado := rombo.duplicate()
			cerrado.append(rombo[0])
			draw_polyline(cerrado, LAPIZ, 1.2, true)


	var hz := int(_e.get("hallazgos", 0))
	for i in range(mini(hz, 4)):
		var c := Vector2(w - 20.0 - float(i) * 24.0, h - 16.0)
		for a in range(4):
			var v := Vector2.from_angle(PI * 0.25 * float(a))
			draw_line(c - v * 7.0, c + v * 7.0, ROJO, 1.5, true)
		draw_line(c + Vector2(0, -8), c + Vector2(0, 8), ROJO, 1.5, true)
		draw_arc(c, 11.0, 0.0, TAU, 14, LAPIZ_SUAVE, 1.0, true)
