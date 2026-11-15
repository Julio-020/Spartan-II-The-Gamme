extends Control


const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const COL_FONDO := Color(0.06, 0.05, 0.09, 0.95)
const COL_TRAJE := Color(0.88, 0.89, 0.93)
const COL_TRAJE_SOMBRA := Color(0.62, 0.64, 0.72)
const COL_TRAJE_OSCURO := Color(0.40, 0.42, 0.50)
const COL_CASCO := Color(0.95, 0.96, 0.98)
const COL_CASCO_SOMBRA := Color(0.72, 0.74, 0.82)
const COL_VISOR := Color(0.05, 0.07, 0.13)
const ACENTO := [Color(0.25, 0.68, 1.0), Color(1.0, 0.42, 0.68)]
const PIELES := [Color(0.97, 0.79, 0.66), Color(0.87, 0.66, 0.49), Color(0.67, 0.46, 0.31), Color(0.43, 0.28, 0.19)]
const PELOS := [Color(0.10, 0.08, 0.08), Color(0.36, 0.21, 0.11), Color(0.86, 0.69, 0.36), Color(0.72, 0.29, 0.12)]
const RADIO := 47.0

const MOSTRAR_ROSTRO := false

var genero: int = 0:
	set(v):
		genero = clampi(v, 0, 1)
		queue_redraw()
var piel: int = 0:
	set(v):
		piel = clampi(v, 0, PIELES.size() - 1)
		queue_redraw()
var pelo: int = 1:
	set(v):
		pelo = clampi(v, 0, PELOS.size() - 1)
		queue_redraw()

var _s: float = 1.0
var _o: Vector2 = Vector2.ZERO


func _init() -> void:
	custom_minimum_size = Vector2(64.0, 64.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _pt(x: float, y: float, recortar: bool = false) -> Vector2:
	var p := Vector2(x, y)
	if recortar:
		var d := p - Vector2(50.0, 50.0)
		if d.length() > RADIO - 1.0:
			p = Vector2(50.0, 50.0) + d.normalized() * (RADIO - 1.0)
	return _o + p * _s


func _elipse(cx: float, cy: float, rx: float, ry: float, a0: float = 0.0,
		a1: float = TAU, n: int = 32, recortar: bool = false) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n + 1):
		var a := lerpf(a0, a1, float(i) / float(n))
		pts.append(_pt(cx + rx * cos(a), cy + ry * sin(a), recortar))
	return pts


func _poli(lista: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for p in lista:
		pts.append(_pt(p[0], p[1]))
	draw_colored_polygon(pts, col)


func _linea(x0: float, y0: float, x1: float, y1: float, col: Color, ancho: float) -> void:
	draw_line(_pt(x0, y0), _pt(x1, y1), col, maxf(ancho * _s, 1.0), true)


func _draw() -> void:
	_s = minf(size.x, size.y) / 100.0
	_o = (size - Vector2(100.0, 100.0) * _s) * 0.5
	var acento: Color = ACENTO[genero]
	var centro := _pt(50.0, 50.0)
	var tono: Color = PIELES[piel]
	var tono_s := tono.darkened(0.16)
	var col_pelo: Color = PELOS[pelo]


	draw_circle(centro, 48.0 * _s, COL_FONDO)
	for e in [[24.0, 18.0, 1.1], [70.0, 14.0, 0.9], [84.0, 30.0, 1.0], [14.0, 40.0, 0.8],
			[36.0, 10.0, 0.7], [58.0, 8.0, 0.8], [88.0, 52.0, 0.7]]:
		draw_circle(_pt(e[0], e[1]), e[2] * _s, Color(1.0, 1.0, 1.0, 0.7))
	draw_circle(_pt(21.0, 28.0), 4.4 * _s, Color(0.86, 0.44, 0.22, 0.85))
	draw_circle(_pt(19.8, 26.8), 2.4 * _s, Color(0.98, 0.62, 0.36, 0.6))
	var horiz := PackedVector2Array()
	horiz.append_array(_elipse(50.0, 50.0, 47.0, 47.0, 0.18 * PI, 0.82 * PI, 18, true))
	draw_colored_polygon(horiz, Color(0.42, 0.17, 0.09, 0.9))


	if genero == 1:
		var coleta := [[62.0, 26.0], [72.0, 28.0], [82.0, 41.0], [87.0, 58.0],
				[82.0, 77.0], [75.0, 84.0], [76.0, 68.0], [72.0, 53.0], [64.0, 40.0]]
		_poli(coleta, col_pelo)
		_poli([[78.0, 40.0], [83.0, 52.0], [82.0, 66.0], [78.0, 78.0], [80.0, 62.0], [78.0, 50.0]],
				col_pelo.lightened(0.18))
		draw_circle(_pt(66.0, 32.0), 3.6 * _s, acento)


	_poli([[22.0, 74.0], [26.0, 62.0], [34.0, 66.0], [30.0, 80.0]], COL_TRAJE_OSCURO)
	_poli([[78.0, 74.0], [74.0, 62.0], [66.0, 66.0], [70.0, 80.0]], COL_TRAJE_OSCURO)


	var hombros := PackedVector2Array()
	hombros.append_array(_elipse(50.0, 100.0, 35.0, 30.0, PI, TAU, 28, true))
	for i in range(9):
		hombros.append(_pt(85.0 - 70.0 * float(i) / 8.0, 100.0, true))
	draw_colored_polygon(hombros, COL_TRAJE)
	var sombra := PackedVector2Array()
	sombra.append_array(_elipse(50.0, 100.0, 35.0, 30.0, PI * 1.5, TAU, 14, true))
	for i in range(5):
		sombra.append(_pt(85.0 - 35.0 * float(i) / 4.0, 100.0, true))
	draw_colored_polygon(sombra, COL_TRAJE_SOMBRA)
	_linea(50.0, 74.0, 50.0, 95.0, COL_TRAJE_SOMBRA, 1.2)
	draw_polyline(_elipse(50.0, 100.0, 31.0, 25.0, PI + 0.10, PI + 0.80, 10, true),
			acento, 3.0 * _s, true)
	draw_polyline(_elipse(50.0, 100.0, 31.0, 25.0, TAU - 0.80, TAU - 0.10, 10, true),
			acento, 3.0 * _s, true)

	_poli([[22.0, 83.0], [29.0, 80.0], [31.0, 87.0], [24.0, 90.0]], COL_TRAJE_OSCURO)
	_poli([[23.4, 84.0], [28.2, 82.0], [29.2, 85.6], [24.4, 87.6]], acento)

	draw_polyline(PackedVector2Array([_pt(38.0, 70.0), _pt(35.0, 79.0), _pt(40.0, 90.0)]),
			COL_TRAJE_OSCURO, 2.0 * _s, true)
	draw_polyline(PackedVector2Array([_pt(62.0, 70.0), _pt(65.0, 79.0), _pt(60.0, 90.0)]),
			COL_TRAJE_OSCURO, 2.0 * _s, true)

	var fuente: Font = EstiloUI.fuente_titulo()
	draw_string(fuente, _pt(38.0, 94.0), "II", HORIZONTAL_ALIGNMENT_CENTER,
			24.0 * _s, int(10.0 * _s), acento)


	draw_colored_polygon(_elipse(50.0, 67.0, 19.0, 6.5, 0.0, TAU, 24), COL_TRAJE_OSCURO)
	draw_colored_polygon(_elipse(50.0, 65.5, 19.0, 6.0, 0.0, TAU, 24), COL_TRAJE_SOMBRA)
	draw_circle(_pt(36.0, 66.0), 1.3 * _s, acento)
	draw_circle(_pt(64.0, 66.0), 1.3 * _s, acento)


	draw_colored_polygon(_elipse(25.0, 45.0, 4.6, 8.0, 0.0, TAU, 14), COL_TRAJE_OSCURO)
	draw_colored_polygon(_elipse(75.0, 45.0, 4.6, 8.0, 0.0, TAU, 14), COL_TRAJE_OSCURO)
	draw_circle(_pt(25.0, 45.0), 1.7 * _s, acento)
	draw_circle(_pt(75.0, 45.0), 1.7 * _s, acento)


	if genero == 0:
		_linea(65.0, 26.0, 69.0, 15.0, COL_TRAJE_SOMBRA, 2.2)
		draw_circle(_pt(69.0, 14.5), 2.8 * _s, acento)


	draw_circle(_pt(50.0, 44.0), 26.0 * _s, COL_CASCO_SOMBRA)
	draw_circle(_pt(48.6, 42.4), 24.6 * _s, COL_CASCO)
	_poli([[44.0, 21.0], [56.0, 21.0], [55.0, 23.2], [45.0, 23.2]], COL_CASCO_SOMBRA)
	_poli([[46.0, 23.8], [54.0, 23.8], [53.4, 25.0], [46.6, 25.0]], COL_CASCO_SOMBRA)


	var vrx := 18.0 if genero == 0 else 17.0
	var vry := 15.5 if genero == 0 else 16.0
	var vy := 45.0
	draw_colored_polygon(_elipse(50.0, vy, vrx + 1.6, vry + 1.6, 0.0, TAU, 40), COL_TRAJE_SOMBRA)
	draw_colored_polygon(_elipse(50.0, vy, vrx, vry, 0.0, TAU, 40), COL_VISOR)

	if MOSTRAR_ROSTRO:
		var frx := 15.2 if genero == 0 else 14.4
		var fry := 14.4 if genero == 0 else 14.8
		draw_colored_polygon(_elipse(50.0, 46.5, frx, fry, 0.0, TAU, 36), tono)
		draw_colored_polygon(_elipse(55.5, 48.0, frx * 0.55, fry * 0.85, -PI * 0.5, PI * 0.5, 16), tono_s)
		draw_colored_polygon(_elipse(48.5, 46.0, frx * 0.82, fry * 0.9, 0.0, TAU, 32), tono)
		var rubor := Color(1.0, 0.45, 0.45, 0.20 if genero == 1 else 0.10)
		draw_circle(_pt(41.0, 52.0), 2.6 * _s, rubor)
		draw_circle(_pt(59.0, 52.0), 2.6 * _s, rubor)


		if genero == 0:
			var corto: Array = [[63.2, 41.5], [60.0, 37.2], [55.5, 39.4], [50.0, 36.0],
					[44.5, 39.4], [40.0, 37.2], [36.8, 41.5]]
			var tapa := PackedVector2Array()
			tapa.append_array(_elipse(50.0, 41.5, 13.4, 12.6, PI, TAU, 24))
			draw_colored_polygon(tapa, col_pelo)
			_poli(corto, col_pelo)
			_poli([[40.0, 33.0], [50.0, 31.0], [47.0, 34.5]], col_pelo.lightened(0.2))
		else:
			var tapa2 := PackedVector2Array()
			tapa2.append_array(_elipse(50.0, 42.0, 13.6, 13.0, PI, TAU, 24))
			draw_colored_polygon(tapa2, col_pelo)
			_poli([[63.5, 42.0], [58.0, 37.5], [50.0, 40.5], [43.0, 38.0], [40.0, 42.0], [36.4, 42.0]], col_pelo)
			_poli([[36.4, 41.0], [34.6, 50.0], [36.6, 58.0], [40.4, 52.0], [39.0, 43.0]], col_pelo)
			_poli([[63.6, 41.0], [65.4, 50.0], [63.4, 58.0], [59.6, 52.0], [61.0, 43.0]], col_pelo)
			_poli([[40.0, 33.0], [51.0, 31.0], [47.0, 35.0]], col_pelo.lightened(0.2))


		var ojo_y := 47.0
		for lado in [-1.0, 1.0]:
			var ox: float = 50.0 + 6.2 * lado
			draw_colored_polygon(_elipse(ox, ojo_y, 3.1, 2.1, 0.0, TAU, 14), Color(0.98, 0.98, 1.0))
			draw_circle(_pt(ox + 0.3 * lado, ojo_y + 0.1), 1.45 * _s, Color(0.20, 0.14, 0.10))
			draw_circle(_pt(ox - 0.2 + 0.3 * lado, ojo_y - 0.5), 0.45 * _s, Color(1.0, 1.0, 1.0))
			var ceja_y := ojo_y - 4.2
			var grosor := 1.9 if genero == 0 else 1.1
			_linea(ox - 3.4 * lado, ceja_y + 0.8, ox + 3.4 * lado, ceja_y - (0.7 if genero == 1 else 0.0),
					col_pelo.darkened(0.15), grosor)
			if genero == 1:
				_linea(ox + 2.9 * lado, ojo_y - 0.8, ox + 4.0 * lado, ojo_y - 1.8, Color(0.10, 0.07, 0.07), 0.9)
		_linea(50.0, 48.5, 49.0, 53.2, tono_s, 1.1)
		_linea(49.0, 53.2, 51.4, 53.4, tono_s, 1.1)
		var col_boca := Color(0.62, 0.22, 0.24) if genero == 0 else Color(0.82, 0.24, 0.36)
		draw_polyline(_elipse(50.0, 55.2, 3.6, 1.7, 0.15 * PI, 0.85 * PI, 10), col_boca,
				(1.3 if genero == 0 else 1.9) * _s, true)
	else:

		draw_colored_polygon(_elipse(48.0, 47.5, 10.5, 6.8, 0.0, TAU, 28),
				Color(acento.r * 0.45, acento.g * 0.45, acento.b * 0.55, 0.75))
		draw_colored_polygon(_elipse(44.0, 44.0, 3.6, 2.0, 0.0, TAU, 14), Color(1.0, 1.0, 1.0, 0.75))


	draw_colored_polygon(_elipse(50.0, vy, vrx, vry, 0.0, TAU, 40),
			Color(acento.r * 0.4, acento.g * 0.5, acento.b * 0.8, 0.11))
	draw_colored_polygon(PackedVector2Array([_pt(36.0, 36.0), _pt(46.0, 31.0), _pt(41.0, 36.5), _pt(34.5, 41.0)]),
			Color(1.0, 1.0, 1.0, 0.42))
	draw_colored_polygon(PackedVector2Array([_pt(60.0, 56.0), _pt(65.0, 50.0), _pt(63.0, 57.5), _pt(58.5, 60.0)]),
			Color(acento.r, acento.g, acento.b, 0.40))
	draw_polyline(_elipse(50.0, vy, vrx, vry, 0.0, TAU, 40), Color(1.0, 1.0, 1.0, 0.22), 1.2 * _s, true)


	draw_arc(centro, 46.5 * _s, 0.0, TAU, 72, acento, maxf(2.5 * _s, 1.5), true)
