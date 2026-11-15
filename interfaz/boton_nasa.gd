extends Button


const COL_ACENTO := Color(0.99, 0.24, 0.13)
const COL_TEXTO := Color(0.94, 0.91, 0.87)
const CORTE := 9.0
const ANCHO_ICONO := 34.0


const ICONOS_POR_TEXTO := {
	"JUGAR": "jugar", "CONTINUAR": "jugar", "PARTIR": "jugar", "EXPEDICIÓN INFINITA": "expedicion",
	"DIARIO": "diario", "PILOTO": "piloto", "RUTAS": "rutas", "COMITÉ": "comite", "MÁS": "mas",
	"AYUDA Y CONTROLES": "ayuda", "EL PROGRAMA": "programa", "CONFIGURACIONES": "ajustes",
	"CRÉDITOS": "creditos", "SALIR DEL JUEGO": "salir", "VOLVER": "volver", "CAMBIAR PARTIDA": "partida",
	"GUARDAR": "ok", "SÍ, SALIR": "salir", "CANCELAR": "volver", "BORRAR": "borrar", "AL AZAR": "azar",
}

var icono: String = ""
var numero: String = ""
var color: Color = COL_ACENTO
var _t: float = 0.0
var _activo: bool = false
var _fondo: Control


func _init() -> void:
	flat = false
	focus_mode = Control.FOCUS_ALL
	var vacio := StyleBoxEmpty.new()
	for estado in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		add_theme_stylebox_override(estado, vacio)
	set_process(false)


func _ready() -> void:
	_fondo = Control.new()
	_fondo.show_behind_parent = true
	_fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fondo.draw.connect(_pintar.bind(_fondo))
	add_child(_fondo)
	if icono == "":
		icono = str(ICONOS_POR_TEXTO.get(text.strip_edges().to_upper(), ""))
	_margenes()
	mouse_entered.connect(_cambio_estado)
	mouse_exited.connect(_cambio_estado)
	focus_entered.connect(_cambio_estado)
	focus_exited.connect(_cambio_estado)


func _margenes() -> void:
	var izq := 20.0 + (ANCHO_ICONO if icono != "" else 0.0)
	var der := 14.0 + (34.0 if numero != "" else 0.0)
	for estado in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		var e := StyleBoxEmpty.new()
		e.content_margin_left = izq
		e.content_margin_right = der
		add_theme_stylebox_override(estado, e)


func _cambio_estado() -> void:
	var ahora := (is_hovered() or has_focus()) and not disabled
	if ahora and not _activo:
		_t = 0.0
	_activo = ahora
	set_process(_activo)
	_redibujar()


func _process(delta: float) -> void:
	_t += delta
	_redibujar()


func _pintar(c: CanvasItem) -> void:
	var w := size.x
	var h := size.y
	var corte := CORTE
	var marcado := _activo or button_pressed
	var forma := PackedVector2Array([Vector2(0.0, 0.0), Vector2(w - corte, 0.0), Vector2(w, corte), Vector2(w, h), Vector2(corte, h), Vector2(0.0, h - corte)])
	var fondo := Color(0.05, 0.04, 0.04, 0.62)
	var borde := Color(1.0, 1.0, 1.0, 0.16)
	var barra := Color(color.r, color.g, color.b, 0.55)
	if disabled:
		fondo.a = 0.35
		barra.a = 0.2
	if marcado:

		var parpadeo := 1.0
		if _activo and _t < 0.35:
			parpadeo = 0.55 + 0.45 * absf(sin(_t * 28.0))
		fondo = Color(color.r, color.g, color.b, 0.24 * parpadeo)
		borde = Color(color.r, color.g, color.b, 0.9 * parpadeo)
		barra = Color(color.r, color.g, color.b, 1.0)
	if button_pressed and not _activo:
		fondo.a = 0.3
	c.draw_colored_polygon(forma, fondo)
	var linea := PackedVector2Array(forma)
	linea.append(forma[0])
	c.draw_polyline(linea, borde, 1.5, true)

	c.draw_rect(Rect2(0.0, corte, 5.0, maxf(h - 2.0 * corte, 2.0)), barra)

	if _activo and _t < 0.6:
		var x := lerpf(5.0, w - corte, clampf(_t / 0.6, 0.0, 1.0))
		c.draw_line(Vector2(x, 2.0), Vector2(x, h - 2.0), Color(color.r, color.g, color.b, 0.45 * (1.0 - _t / 0.6)), 2.0)

	if icono != "":
		_icono(c, icono, Vector2(20.0 + ANCHO_ICONO * 0.5 - 6.0, h * 0.5), minf(h * 0.26, 10.0), _color_icono(marcado))

	if numero != "":
		var f := ThemeDB.fallback_font
		c.draw_string(f, Vector2(w - 40.0, h * 0.5 + 5.0), numero, HORIZONTAL_ALIGNMENT_RIGHT, 28.0, 12,
				Color(1.0, 1.0, 1.0, 0.38 if not marcado else 0.8))


func _color_icono(marcado: bool) -> Color:
	if disabled:
		return Color(1.0, 1.0, 1.0, 0.25)
	return color if marcado else Color(color.r, color.g, color.b, 0.78)


func _icono(c: CanvasItem, nombre: String, p: Vector2, r: float, col: Color) -> void:
	var g := 1.8
	match nombre:
		"jugar":
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 0.7, -r), p + Vector2(r, 0.0), p + Vector2(-r * 0.7, r)]), col)
		"expedicion":
			c.draw_arc(p, r, 0.0, TAU, 24, col, g, true)
			c.draw_line(p + Vector2(-r * 0.55, r * 0.55), p + Vector2(r * 0.55, -r * 0.55), col, g)
			c.draw_circle(p, 1.8, col)
		"diario":
			c.draw_rect(Rect2(p + Vector2(-r * 0.8, -r), Vector2(r * 1.6, r * 2.0)), col, false, g)
			c.draw_line(p + Vector2(-r * 0.3, -r * 0.4), p + Vector2(r * 0.4, -r * 0.4), col, 1.4)
			c.draw_line(p + Vector2(-r * 0.3, 0.1), p + Vector2(r * 0.4, 0.1), col, 1.4)
		"piloto":
			c.draw_arc(p + Vector2(0.0, -r * 0.35), r * 0.5, 0.0, TAU, 16, col, g, true)
			c.draw_arc(p + Vector2(0.0, r * 1.05), r * 0.95, PI * 1.15, PI * 1.85, 12, col, g, true)
		"rutas":
			var a := p + Vector2(-r, r * 0.7)
			var b := p + Vector2(-r * 0.1, -r * 0.5)
			var c2 := p + Vector2(r * 0.4, r * 0.3)
			var d := p + Vector2(r, -r * 0.8)
			c.draw_polyline(PackedVector2Array([a, b, c2, d]), col, 1.5, true)
			for q in [a, d]:
				c.draw_circle(q, 2.4, col)
		"comite":
			for i in range(5):
				var ang := -PI * 0.5 + float(i) * TAU / 5.0
				c.draw_circle(p + Vector2(cos(ang), sin(ang)) * r * 0.85, 2.2, col)
			c.draw_arc(p, r * 0.35, 0.0, TAU, 12, col, 1.4, true)
		"mas":
			for i in range(3):
				c.draw_circle(p + Vector2(float(i - 1) * r * 0.8, 0.0), 2.0, col)
		"ayuda":
			c.draw_arc(p, r, 0.0, TAU, 24, col, g, true)
			c.draw_string(ThemeDB.fallback_font, p + Vector2(-4.0, 5.0), "?", HORIZONTAL_ALIGNMENT_CENTER, 8.0, 13, col)
		"programa":
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(0.0, -r), p + Vector2(r * 0.45, r * 0.5), p + Vector2(-r * 0.45, r * 0.5)]), col)
			c.draw_line(p + Vector2(-r * 0.8, r * 0.9), p + Vector2(r * 0.8, r * 0.9), col, g)
		"ajustes":
			c.draw_arc(p, r * 0.55, 0.0, TAU, 14, col, g, true)
			for i in range(8):
				var ang := float(i) * TAU / 8.0
				c.draw_line(p + Vector2(cos(ang), sin(ang)) * r * 0.75, p + Vector2(cos(ang), sin(ang)) * r, col, 2.4)
		"creditos":
			var pts := PackedVector2Array()
			for i in range(10):
				var rr := r if i % 2 == 0 else r * 0.45
				var ang := -PI * 0.5 + float(i) * TAU / 10.0
				pts.append(p + Vector2(cos(ang), sin(ang)) * rr)
			pts.append(pts[0])
			c.draw_polyline(pts, col, 1.5, true)
		"salir":
			c.draw_rect(Rect2(p + Vector2(-r * 0.9, -r), Vector2(r * 1.0, r * 2.0)), col, false, g)
			c.draw_line(p + Vector2(-r * 0.1, 0.0), p + Vector2(r, 0.0), col, g)
			c.draw_line(p + Vector2(r * 0.5, -r * 0.45), p + Vector2(r, 0.0), col, g)
			c.draw_line(p + Vector2(r * 0.5, r * 0.45), p + Vector2(r, 0.0), col, g)
		"volver":
			c.draw_line(p + Vector2(r, 0.0), p + Vector2(-r, 0.0), col, g)
			c.draw_line(p + Vector2(-r * 0.2, -r * 0.7), p + Vector2(-r, 0.0), col, g)
			c.draw_line(p + Vector2(-r * 0.2, r * 0.7), p + Vector2(-r, 0.0), col, g)
		"partida":
			c.draw_rect(Rect2(p + Vector2(-r * 0.9, -r * 0.9), Vector2(r * 1.8, r * 1.8)), col, false, g)
			c.draw_rect(Rect2(p + Vector2(-r * 0.4, -r * 0.9), Vector2(r * 0.8, r * 0.7)), col, false, 1.4)
		"ok":
			c.draw_polyline(PackedVector2Array([p + Vector2(-r, 0.0), p + Vector2(-r * 0.25, r * 0.7), p + Vector2(r, -r * 0.7)]), col, 2.2, true)
		"borrar":
			c.draw_line(p + Vector2(-r * 0.8, -r * 0.8), p + Vector2(r * 0.8, r * 0.8), col, g)
			c.draw_line(p + Vector2(r * 0.8, -r * 0.8), p + Vector2(-r * 0.8, r * 0.8), col, g)
		"azar":
			c.draw_rect(Rect2(p + Vector2(-r * 0.85, -r * 0.85), Vector2(r * 1.7, r * 1.7)), col, false, g)
			for q in [Vector2(-0.35, -0.35), Vector2(0.35, 0.35), Vector2(0.0, 0.0)]:
				c.draw_circle(p + q * r, 1.4, col)


func _redibujar() -> void:
	if _fondo != null:
		_fondo.queue_redraw()
