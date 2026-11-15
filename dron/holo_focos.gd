extends Control


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")

const ANCHO_AVATAR := 132.0
const ALTO := 218.0
const ANCHO_TEXTO := 340.0
const LETRAS_POR_SEG := 46.0

var _color: Color = Color(0.45, 0.82, 1.0)
var _alfa: float = 0.0
var _vida: float = 0.0
var _t: float = 0.0
var _habla: float = 0.0
var _letras: float = 0.0
var _total: int = 0
var _glitch: float = 0.0
var _prox_glitch: float = 3.0
var _caja: PanelContainer
var _lbl_texto: Label
var _lbl_nombre: Label
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(ANCHO_AVATAR + ANCHO_TEXTO + 12.0, ALTO)
	size = custom_minimum_size
	_rng.randomize()
	_caja = PanelContainer.new()
	_caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caja.position = Vector2(0.0, 28.0)
	_caja.custom_minimum_size = Vector2(ANCHO_TEXTO, 0.0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caja.add_child(v)
	_lbl_nombre = EstiloUI.etiqueta_sub("FOCOS  ·  HOLO", 15, _color, true)
	v.add_child(_lbl_nombre)
	_lbl_texto = EstiloUI.etiqueta_sub("", 16, EstiloUI.COL_TEXTO)
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.custom_minimum_size = Vector2(ANCHO_TEXTO - 36.0, 0.0)
	v.add_child(_lbl_texto)
	add_child(_caja)
	visible = false
	modulate.a = 0.0


func decir(texto: String, color: Color, seg: float = 5.0) -> void:
	_color = color
	_lbl_texto.text = texto
	_lbl_texto.visible_characters = 0
	_total = texto.length()
	_letras = 0.0
	_habla = 1.0
	_vida = seg + float(_total) / LETRAS_POR_SEG
	_glitch = 0.25
	var e := StyleBoxFlat.new()
	e.bg_color = Color(color.r * 0.08, color.g * 0.1, color.b * 0.12, 0.62)
	e.border_color = Color(color.r, color.g, color.b, 0.7)
	e.set_border_width_all(1)
	e.border_width_left = 3
	e.set_corner_radius_all(5)
	e.content_margin_left = 14.0
	e.content_margin_right = 14.0
	e.content_margin_top = 8.0
	e.content_margin_bottom = 10.0
	_caja.add_theme_stylebox_override("panel", e)
	_lbl_nombre.add_theme_color_override("font_color", color)
	visible = true


func esta_hablando() -> bool:
	return visible and _vida > 0.0


func ocultar() -> void:
	_vida = 0.0
	_alfa = 0.0
	modulate.a = 0.0
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	if _vida > 0.0:
		_vida -= delta
		_alfa = move_toward(_alfa, 1.0, delta * 4.0)
	else:
		_alfa = move_toward(_alfa, 0.0, delta * 2.2)
		if _alfa <= 0.0:
			visible = false
			return
	modulate.a = _alfa
	if _habla > 0.0:
		_letras += LETRAS_POR_SEG * delta
		_lbl_texto.visible_characters = mini(int(_letras), _total)
		if int(_letras) >= _total:
			_habla = 0.0

	_prox_glitch -= delta
	if _prox_glitch <= 0.0:
		_prox_glitch = _rng.randf_range(2.5, 6.0)
		_glitch = 0.18
	_glitch = maxf(_glitch - delta, 0.0)
	_caja.position.y = ALTO - _caja.size.y - 8.0
	queue_redraw()


func _draw() -> void:
	if _alfa <= 0.01:
		return
	var cx := size.x - ANCHO_AVATAR * 0.5
	var base_y := size.y - 20.0
	var c := _color
	var parp := 0.88 + 0.12 * sin(_t * 31.0) + (0.25 * _rng.randf() if _glitch > 0.0 else 0.0)

	for i in range(3):
		var r := 24.0 + 13.0 * float(i) + 2.0 * sin(_t * 2.0 + float(i))
		_elipse(Vector2(cx, base_y), r, r * 0.3, Color(c.r, c.g, c.b, (0.55 - 0.15 * float(i)) * parp), 1.6, 28)
	var haz_top := base_y - 118.0
	var haz := PackedVector2Array([Vector2(cx - 22.0, base_y), Vector2(cx + 22.0, base_y), Vector2(cx + 46.0, haz_top), Vector2(cx - 46.0, haz_top)])
	var cols := PackedColorArray([Color(c.r, c.g, c.b, 0.26 * parp), Color(c.r, c.g, c.b, 0.26 * parp), Color(c.r, c.g, c.b, 0.0), Color(c.r, c.g, c.b, 0.0)])
	draw_polygon(haz, cols)

	var bob := 4.0 * sin(_t * 2.1)
	var centro := Vector2(cx, base_y - 112.0 + bob)
	if _glitch > 0.0:
		_figura(centro + Vector2(4.0, 0.0), Color(1.0, 0.45, 0.9), 0.35)
		_figura(centro + Vector2(-3.0, 1.0), Color(0.3, 1.0, 1.0), 0.35)
	_figura(centro, c, parp)

	var x0 := cx - ANCHO_AVATAR * 0.5
	var y := base_y - 190.0
	while y < base_y + 4.0:
		draw_line(Vector2(x0, y), Vector2(x0 + ANCHO_AVATAR, y), Color(c.r, c.g, c.b, 0.07), 1.0)
		y += 4.0
	var banda := base_y - fposmod(_t * 55.0, 190.0)
	draw_rect(Rect2(x0, banda, ANCHO_AVATAR, 5.0), Color(c.r, c.g, c.b, 0.16))


func _figura(p: Vector2, c: Color, k: float) -> void:
	var fino := Color(c.r, c.g, c.b, 0.95 * k)
	var relleno := Color(c.r, c.g, c.b, 0.17 * k)

	for s in [-1.0, 1.0]:
		var ala := PackedVector2Array([p + Vector2(s * 34.0, -6.0), p + Vector2(s * 66.0, -20.0 + 3.0 * sin(_t * 9.0)), p + Vector2(s * 62.0, -8.0), p + Vector2(s * 36.0, 6.0)])
		draw_colored_polygon(ala, relleno)
		draw_polyline(PackedVector2Array([ala[0], ala[1], ala[2], ala[3], ala[0]]), Color(c.r, c.g, c.b, 0.6 * k), 1.2)

	var cab := PackedVector2Array()
	for i in range(10):
		var a := TAU * float(i) / 10.0 + 0.157
		cab.append(p + Vector2(cos(a) * 32.0, sin(a) * 31.0))
	draw_colored_polygon(cab, relleno)
	var cerr := PackedVector2Array(cab)
	cerr.append(cab[0])
	draw_polyline(cerr, fino, 2.0)

	draw_arc(p + Vector2(0.0, 52.0), 40.0, deg_to_rad(205.0), deg_to_rad(335.0), 18, Color(c.r, c.g, c.b, 0.8 * k), 2.0)
	draw_arc(p + Vector2(0.0, 52.0), 28.0, deg_to_rad(215.0), deg_to_rad(325.0), 14, Color(c.r, c.g, c.b, 0.45 * k), 1.5)

	draw_rect(Rect2(p + Vector2(-23.0, -8.0), Vector2(46.0, 13.0)), Color(c.r, c.g, c.b, 0.28 * k))
	draw_rect(Rect2(p + Vector2(-23.0, -8.0), Vector2(46.0, 13.0)), fino, false, 1.2)
	var abre := fposmod(_t, 3.4) > 0.16
	var ojo_h := 7.0 if abre else 1.5
	for s in [-1.0, 1.0]:
		draw_rect(Rect2(p + Vector2(s * 10.0 - 4.0, -5.0 + (7.0 - ojo_h) * 0.5), Vector2(8.0, ojo_h)), Color(1.0, 1.0, 1.0, 0.95 * k))

	for i in range(7):
		var amp := 2.0
		if _habla > 0.0:
			amp = 2.0 + 8.0 * absf(sin(_t * 17.0 + float(i) * 1.7)) * (0.55 + 0.45 * sin(_t * 5.0 + float(i)))
		draw_rect(Rect2(p + Vector2(-17.0 + float(i) * 5.5, 14.0 - amp * 0.5), Vector2(3.0, amp)), Color(c.r, c.g, c.b, 0.9 * k))

	_elipse(p + Vector2(0.0, -34.0), 44.0, 9.0, Color(c.r, c.g, c.b, 0.55 * k), 1.5, 36, _t * 1.4, 0.7)
	_elipse(p + Vector2(0.0, -34.0), 30.0, 6.0, Color(c.r, c.g, c.b, 0.9 * k), 2.0, 36, -_t * 2.3, 0.35)


func _elipse(c: Vector2, rx: float, ry: float, col: Color, grosor: float, seg: int, giro: float = 0.0, fraccion: float = 1.0) -> void:
	var pts := PackedVector2Array()
	var n := maxi(int(float(seg) * fraccion), 2)
	for i in range(n + 1):
		var a := giro + TAU * fraccion * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, col, grosor)
