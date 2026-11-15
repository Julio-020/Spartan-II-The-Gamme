extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Historia := preload("res://historia/historia.gd")
signal terminada

const DURACION := 44.4
const T_TITULO := 37.2
const COL_ACENTO := Color(0.99, 0.24, 0.13)
const COL_TEXTO := Color(0.94, 0.91, 0.87)


const TARJETAS := [
	[2.0, 5.4, "Durante 50 años\nenviamos robots a Marte."],
	[6.0, 9.8, "Cada uno midió el suelo, el aire y el polvo.\nTodos dejaron datos valiosos."],
	[10.4, 14.2, "HOY"],
	[14.8, 19.2, "La primera nave con personas\nya viene en camino. Llega en 158 días."],
	[19.8, 24.4, "Nadie sabe dónde debe aterrizar.\nCinco jefes defienden cinco ideas distintas."],
	[25.0, 30.0, "Diez misiones reales, de Viking a Perseverance,\nnos enseñaron cómo es cada lugar."],
	[30.6, 35.0, "Tú eres el piloto. FOCOS te acompaña.\nVisita esos diez lugares\ny elige dónde aterrizar."],
	[35.4, 37.0, "Encuentra. Recoge. Regresa."],
]
const T_JEFES := [20.4, 24.8]


var audio = null

var t: float = 0.0

var _raiz: Control
var _negro: ColorRect
var _barras: Control
var _lbl_tarjeta: Label
var _fila_titulo: HBoxContainer
var _lbl_sub: Label
var _lbl_salto: Label
var _fv: FontVariation
var _impacto_hecho: bool = false
var _fin: bool = false
var _fila_jefes: HBoxContainer


func _ready() -> void:
	layer = 25
	_construir()


func _construir() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)


	_barras = Control.new()
	_barras.set_anchors_preset(Control.PRESET_FULL_RECT)
	_barras.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_barras)
	var arriba := ColorRect.new()
	arriba.color = Color.BLACK
	arriba.anchor_right = 1.0
	arriba.anchor_bottom = 0.11
	arriba.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barras.add_child(arriba)
	var abajo := ColorRect.new()
	abajo.color = Color.BLACK
	abajo.anchor_right = 1.0
	abajo.anchor_top = 0.89
	abajo.anchor_bottom = 1.0
	abajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barras.add_child(abajo)


	_lbl_tarjeta = Label.new()
	_lbl_tarjeta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_tarjeta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_tarjeta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_tarjeta.anchor_left = 0.15
	_lbl_tarjeta.anchor_right = 0.85
	_lbl_tarjeta.anchor_top = 0.62
	_lbl_tarjeta.anchor_bottom = 0.82
	_lbl_tarjeta.add_theme_font_size_override("font_size", 32)
	_lbl_tarjeta.add_theme_color_override("font_color", COL_TEXTO)
	_lbl_tarjeta.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_lbl_tarjeta.add_theme_constant_override("outline_size", 8)
	_lbl_tarjeta.modulate.a = 0.0
	_lbl_tarjeta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_lbl_tarjeta)


	_fila_jefes = HBoxContainer.new()
	_fila_jefes.add_theme_constant_override("separation", 34)
	_fila_jefes.alignment = BoxContainer.ALIGNMENT_CENTER
	_fila_jefes.anchor_left = 0.05
	_fila_jefes.anchor_right = 0.95
	_fila_jefes.anchor_top = 0.38
	_fila_jefes.anchor_bottom = 0.5
	_fila_jefes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fila_jefes.modulate.a = 0.0
	_raiz.add_child(_fila_jefes)
	for n in ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]:
		var inf := Historia.jefe(n)
		var v := VBoxContainer.new()
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var l1 := Label.new()
		l1.text = n
		l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l1.add_theme_font_size_override("font_size", 30)
		l1.add_theme_color_override("font_color", inf["color"])
		l1.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		l1.add_theme_constant_override("outline_size", 8)
		var l2 := Label.new()
		l2.text = str(inf["defiende"])
		l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l2.add_theme_font_size_override("font_size", 18)
		l2.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		l2.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		l2.add_theme_constant_override("outline_size", 6)
		v.add_child(l1)
		v.add_child(l2)
		_fila_jefes.add_child(v)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(centro)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(col)

	_fv = FontVariation.new()
	_fv.base_font = EstiloUI.fuente_titulo()
	_fv.spacing_glyph = 60
	_fv.variation_embolden = 0.7

	_fila_titulo = HBoxContainer.new()
	_fila_titulo.add_theme_constant_override("separation", 28)
	_fila_titulo.alignment = BoxContainer.ALIGNMENT_CENTER
	_fila_titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fila_titulo.modulate.a = 0.0
	col.add_child(_fila_titulo)
	_fila_titulo.add_child(_label_titulo("SPARTANS", COL_TEXTO, 120))
	_fila_titulo.add_child(_label_titulo("II", COL_ACENTO, 120))

	_lbl_sub = Label.new()
	_lbl_sub.text = "EXPLORACIÓN Y RECOLECCIÓN EN MARTE"
	_lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_sub.add_theme_font_size_override("font_size", 24)
	_lbl_sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	_lbl_sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_lbl_sub.add_theme_constant_override("outline_size", 6)
	_lbl_sub.modulate.a = 0.0
	_lbl_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_lbl_sub)


	_negro = ColorRect.new()
	_negro.color = Color.BLACK
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_negro)

	_lbl_salto = Label.new()
	_lbl_salto.text = "Esc · clic: saltar introducción"
	_lbl_salto.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_salto.anchor_left = 1.0
	_lbl_salto.anchor_right = 1.0
	_lbl_salto.anchor_top = 1.0
	_lbl_salto.anchor_bottom = 1.0
	_lbl_salto.offset_left = -420.0
	_lbl_salto.offset_right = -24.0
	_lbl_salto.offset_top = -44.0
	_lbl_salto.offset_bottom = -14.0
	_lbl_salto.add_theme_font_size_override("font_size", 16)
	_lbl_salto.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	_lbl_salto.modulate.a = 0.0
	_lbl_salto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_lbl_salto)


func _label_titulo(texto: String, color: Color, tam: int) -> Label:
	var ls := LabelSettings.new()
	ls.font = _fv
	ls.font_size = tam
	ls.font_color = color
	ls.outline_size = 10
	ls.outline_color = Color(0.0, 0.0, 0.0, 0.9)
	ls.shadow_size = 16
	ls.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	ls.shadow_offset = Vector2(5.0, 8.0)
	var l := Label.new()
	l.text = texto
	l.label_settings = ls
	return l


func _process(delta: float) -> void:
	if _fin:
		return
	t += delta


	_negro.color.a = 1.0 - clampf(t / 2.5, 0.0, 1.0)
	_lbl_salto.modulate.a = clampf((t - 1.0) / 1.0, 0.0, 1.0) * 0.8


	var a_tarjeta := 0.0
	for tar in TARJETAS:
		var ini: float = tar[0]
		var fin: float = tar[1]
		if t >= ini and t <= fin:
			_lbl_tarjeta.text = tar[2]
			a_tarjeta = minf((t - ini) / 0.9, (fin - t) / 0.9)
			break
	_lbl_tarjeta.modulate.a = clampf(a_tarjeta, 0.0, 1.0)


	var salida := clampf((DURACION - t) / 1.5, 0.0, 1.0)
	if t >= T_TITULO:
		if not _impacto_hecho:
			_impacto_hecho = true
			if audio != null:
				audio.impacto()
		var p := clampf((t - T_TITULO) / 2.2, 0.0, 1.0)
		var e := 1.0 - pow(1.0 - p, 3.0)
		_fv.spacing_glyph = int(lerpf(60.0, 10.0, e))
		_fila_titulo.modulate.a = clampf(p * 2.0, 0.0, 1.0) * salida
		_lbl_sub.modulate.a = clampf((t - T_TITULO - 1.6) / 1.2, 0.0, 1.0) * salida
	_barras.modulate.a = salida

	var aj := minf(clampf((t - T_JEFES[0]) / 0.8, 0.0, 1.0), clampf((T_JEFES[1] - t) / 0.8, 0.0, 1.0))
	_fila_jefes.modulate.a = aj

	if t >= DURACION:
		terminar()


func _unhandled_input(event: InputEvent) -> void:
	if _fin:
		return
	var saltar := false
	if event is InputEventKey and event.pressed and not event.echo:
		saltar = event.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]
	elif event is InputEventMouseButton and event.pressed:
		saltar = true
	if saltar:
		get_viewport().set_input_as_handled()
		terminar()


func terminar() -> void:
	if _fin:
		return
	_fin = true
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():
		terminada.emit()
		queue_free())
