extends Control


const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const COL_FONDO := Color(0.045, 0.035, 0.035, 0.95)
const COL_REJILLA := Color(1.0, 1.0, 1.0, 0.07)
const COL_A := Color(0.25, 0.82, 1.0)
const COL_B := Color(0.35, 1.0, 0.5)
const COL_EVENTO := {
	"muestra": Color(1.0, 0.62, 0.25),
	"entrega": Color(0.35, 1.0, 0.5),
	"foto": Color(0.78, 0.55, 1.0),
	"dato": Color(0.45, 0.82, 1.0),
	"suceso": Color(1.0, 0.35, 0.3),
}

var progreso: float = 1.0:
	set(v):
		progreso = clampf(v, 0.0, 1.0)
		queue_redraw()

var _ruta: PackedVector2Array = PackedVector2Array()
var _eventos: Array = []
var _dist_base: float = 300.0
var _color_ruta: Color = Color(1.0, 0.82, 0.3)
var _fuente: Font


func _init() -> void:
	custom_minimum_size = Vector2(280.0, 220.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fuente = EstiloUI.fuente_titulo()


func poner(ruta: Array, eventos: Array, dist_base: float, fallida: bool = false) -> void:
	_ruta = PackedVector2Array()
	for p in ruta:
		if p is Vector2:
			_ruta.append(p)
		else:
			_ruta.append(Vector2(float(p[0]), float(p[1])))
	_eventos = []
	for e in eventos:
		if e is Dictionary:
			_eventos.append([float(e["u"]), float(e["v"]), str(e["t"])])
		else:
			_eventos.append([float(e[0]), float(e[1]), str(e[2])])
	_dist_base = dist_base
	_color_ruta = Color(1.0, 0.72, 0.25) if fallida else Color(1.0, 0.82, 0.3)
	queue_redraw()


func _limites() -> Rect2:
	var r := Rect2(Vector2(0.0, 0.0), Vector2(_dist_base, 0.0))
	for p in _ruta:
		r = r.expand(p)
	var m := maxf(r.size.x, r.size.y) * 0.12 + 6.0
	return r.grow(m)


func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(0.0, 0.0, w, h), COL_FONDO)
	draw_rect(Rect2(0.0, 0.0, w, h), Color(1.0, 1.0, 1.0, 0.12), false, 1.0)
	var lim := _limites()
	var esc := minf((w - 20.0) / maxf(lim.size.x, 1.0), (h - 20.0) / maxf(lim.size.y, 1.0))
	var ox := (w - lim.size.x * esc) * 0.5 - lim.position.x * esc
	var oy := (h - lim.size.y * esc) * 0.5 - lim.position.y * esc
	var a_pant := func(p: Vector2) -> Vector2:
		return Vector2(ox + p.x * esc, oy + p.y * esc)


	var paso := 50.0
	for cand in [10.0, 20.0, 50.0, 100.0, 200.0]:
		if lim.size.x / cand < 12.0 and lim.size.y / cand < 12.0:
			paso = cand
			break
	var x0 := floorf(lim.position.x / paso) * paso
	var x := x0
	while x <= lim.end.x:
		var px: float = a_pant.call(Vector2(x, 0.0)).x
		if px > 2.0 and px < w - 2.0:
			draw_line(Vector2(px, 2.0), Vector2(px, h - 2.0), COL_REJILLA, 1.0)
		x += paso
	var y0 := floorf(lim.position.y / paso) * paso
	var yy := y0
	while yy <= lim.end.y:
		var py: float = a_pant.call(Vector2(0.0, yy)).y
		if py > 2.0 and py < h - 2.0:
			draw_line(Vector2(2.0, py), Vector2(w - 2.0, py), COL_REJILLA, 1.0)
		yy += paso


	var pa: Vector2 = a_pant.call(Vector2.ZERO)
	var pb: Vector2 = a_pant.call(Vector2(_dist_base, 0.0))
	draw_dashed_line(pa, pb, Color(1.0, 1.0, 1.0, 0.25), 1.5, 6.0)


	if _ruta.size() >= 2:
		var largo := 0.0
		for i in range(1, _ruta.size()):
			largo += _ruta[i].distance_to(_ruta[i - 1])
		var limite := largo * progreso
		var acum := 0.0
		var pts := PackedVector2Array()
		pts.append(a_pant.call(_ruta[0]))
		for i in range(1, _ruta.size()):
			var seg := _ruta[i].distance_to(_ruta[i - 1])
			if acum + seg > limite:
				var t := (limite - acum) / maxf(seg, 0.0001)
				pts.append(a_pant.call(_ruta[i - 1].lerp(_ruta[i], t)))
				break
			pts.append(a_pant.call(_ruta[i]))
			acum += seg
		if pts.size() >= 2:
			draw_polyline(pts, Color(0.0, 0.0, 0.0, 0.5), 5.0, true)
			draw_polyline(pts, _color_ruta, 2.8, true)

		if progreso < 0.999:
			draw_circle(pts[pts.size() - 1], 4.0, Color.WHITE)


	for e in _eventos:
		var c: Color = COL_EVENTO.get(str(e[2]), Color.WHITE)
		var pe: Vector2 = a_pant.call(Vector2(float(e[0]), float(e[1])))
		draw_circle(pe, 4.6, Color(0.0, 0.0, 0.0, 0.7))
		draw_circle(pe, 3.2, c)


	draw_circle(pa, 8.0, Color(0.0, 0.0, 0.0, 0.6))
	draw_circle(pa, 6.0, COL_A)
	draw_string(_fuente, pa + Vector2(-4.0, -11.0), "A", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, COL_A)
	draw_rect(Rect2(pb - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), COL_B)
	draw_rect(Rect2(pb - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), Color(0.0, 0.0, 0.0, 0.6), false, 1.5)
	draw_string(_fuente, pb + Vector2(-4.0, -11.0), "B", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, COL_B)


	var km := paso / 10.0
	var largo_px := paso * esc
	var by := h - 12.0
	draw_line(Vector2(12.0, by), Vector2(12.0 + largo_px, by), Color(1.0, 1.0, 1.0, 0.7), 2.0)
	draw_string(_fuente, Vector2(14.0 + largo_px, by + 4.0), "%d km" % int(km), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(1.0, 1.0, 1.0, 0.7))
