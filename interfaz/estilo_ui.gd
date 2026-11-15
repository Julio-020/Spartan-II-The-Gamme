extends RefCounted


const Ajustes := preload("res://nucleo/ajustes.gd")

const COL_ACENTO := Color(0.99, 0.24, 0.13)
const COL_TEXTO := Color(0.96, 0.97, 1.0)
const COL_TENUE := Color(1.0, 1.0, 1.0, 0.72)
const COL_OK := Color(0.45, 0.95, 0.55)
const COL_AVISO := Color(1.0, 0.76, 0.22)
const COL_FRIO := Color(0.42, 0.64, 1.0)
const COL_PANEL := Color(0.02, 0.035, 0.09, 0.90)


const TAM_MIN := 14

const RUTA_TITULO := "res://fuentes/Inter-SemiBold.otf"
const RUTA_TEXTO := "res://fuentes/Inter-Medium.otf"

static var _f_titulo: Font = null
static var _f_texto: Font = null


static func _cargar(ruta: String) -> Font:
	if ResourceLoader.exists(ruta):
		var f := load(ruta) as Font
		if f != null:
			return f
	return ThemeDB.fallback_font


static func fuente_titulo() -> Font:
	if _f_titulo == null:
		_f_titulo = _cargar(RUTA_TITULO)
	return _f_titulo


static func fuente_texto() -> Font:
	if _f_texto == null:
		_f_texto = _cargar(RUTA_TEXTO)
	return _f_texto


static func instalar_tema() -> void:
	var t := ThemeDB.get_default_theme()
	if t != null:
		t.default_font = fuente_texto()
		t.default_font_size = 18
		t.set_constant("line_spacing", "Label", 3)


static func etiqueta(texto: String, tam: int, color: Color = COL_TEXTO, titulo: bool = false) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", fuente_titulo() if titulo else fuente_texto())
	l.add_theme_font_size_override("font_size", maxi(tam, TAM_MIN))
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.45))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func etiqueta_sub(texto: String, tam: int, color: Color = COL_TEXTO, titulo: bool = false) -> Label:
	return etiqueta(texto, roundi(float(tam) * Ajustes.factor_texto()), color, titulo)


static func etiqueta_contorno(texto: String, tam: int, color: Color = Color.WHITE, titulo: bool = true) -> Label:
	var l := etiqueta(texto, tam, color, titulo)
	l.add_theme_constant_override("outline_size", 7)
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	return l


static func panel(acento: Color = COL_ACENTO, margen: float = 16.0) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = COL_PANEL
	e.border_color = Color(1.0, 1.0, 1.0, 0.10)
	e.set_border_width_all(1)
	e.border_width_left = 4
	e.set_corner_radius_all(6)
	e.content_margin_left = margen + 4.0
	e.content_margin_right = margen
	e.content_margin_top = margen - 4.0
	e.content_margin_bottom = margen - 4.0
	e.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	e.shadow_size = 8

	e.border_color = Color(acento.r, acento.g, acento.b, 0.9)
	e.border_blend = false
	return e


static func caja(color: Color = Color(1.0, 1.0, 1.0, 0.06), radio: float = 4.0) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = color
	e.set_corner_radius_all(int(radio))
	e.content_margin_left = 10.0
	e.content_margin_right = 10.0
	e.content_margin_top = 5.0
	e.content_margin_bottom = 5.0
	return e


static func barra(color: Color, alto: float = 8.0) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0.0, alto)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(1.0, 1.0, 1.0, 0.12)
	fondo.set_corner_radius_all(2)
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = color
	relleno.set_corner_radius_all(2)
	b.add_theme_stylebox_override("background", fondo)
	b.add_theme_stylebox_override("fill", relleno)
	return b


static func linea(color: Color = Color(1.0, 1.0, 1.0, 0.16), alto: float = 2.0) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size = Vector2(0.0, alto)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func boton(texto: String, tam: int = 22) -> Button:
	var b := Button.new()
	b.text = texto
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(300.0, 52.0)
	b.add_theme_font_override("font", fuente_titulo())
	b.add_theme_font_size_override("font_size", tam)
	b.add_theme_color_override("font_color", COL_TEXTO)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", COL_ACENTO)
	b.add_theme_stylebox_override("normal", _estilo_boton(false))
	b.add_theme_stylebox_override("hover", _estilo_boton(true))
	b.add_theme_stylebox_override("pressed", _estilo_boton(true))
	b.add_theme_stylebox_override("focus", _estilo_boton(true))
	b.add_theme_stylebox_override("disabled", _estilo_boton_apagado())
	b.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 0.35))
	return b


static func _estilo_boton_apagado() -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = Color(0.05, 0.04, 0.04, 0.35)
	e.border_color = Color(1.0, 1.0, 1.0, 0.07)
	e.border_width_left = 2
	e.set_corner_radius_all(6)
	e.content_margin_left = 24.0
	e.content_margin_right = 24.0
	return e


static func _estilo_boton(activo: bool) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	if activo:
		e.bg_color = Color(COL_ACENTO.r, COL_ACENTO.g, COL_ACENTO.b, 0.25)
		e.border_color = COL_ACENTO
		e.border_width_left = 6
	else:
		e.bg_color = Color(0.05, 0.04, 0.04, 0.55)
		e.border_color = Color(1.0, 1.0, 1.0, 0.14)
		e.border_width_left = 2
	e.set_corner_radius_all(6)
	e.content_margin_left = 24.0
	e.content_margin_right = 24.0
	return e


static func tecla(texto: String) -> PanelContainer:
	var p := PanelContainer.new()
	var e := StyleBoxFlat.new()
	e.bg_color = Color(1.0, 1.0, 1.0, 0.10)
	e.border_color = Color(1.0, 1.0, 1.0, 0.45)
	e.set_border_width_all(1)
	e.border_width_bottom = 3
	e.set_corner_radius_all(4)
	e.content_margin_left = 8.0
	e.content_margin_right = 8.0
	e.content_margin_top = 1.0
	e.content_margin_bottom = 1.0
	p.add_theme_stylebox_override("panel", e)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(etiqueta(texto, 15, COL_TEXTO, true))
	return p
