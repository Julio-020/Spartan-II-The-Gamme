extends CanvasLayer


signal terminada

const Historia := preload("res://historia/historia.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const RadioPanel := preload("res://mision/radio_panel.gd")

const VEL_ESCRITURA := 0.022
const ALTO_BARRA := 64.0

var sala: Control
var _lineas: Array = []
var _i: int = -1
var _caja: PanelContainer
var _insignia_pos: Control
var _lbl_nombre: Label
var _lbl_rol: Label
var _lbl_texto: Label
var _lbl_pie: Label
var _tw: Tween = null
var _escrito: bool = true
var _cerrando: bool = false


func _ready() -> void:
	layer = 40
	_lineas = HistoriaEstado.lineas_comite()
	_construir()
	if sala != null:
		sala.call("mostrar_comite")
	_caja.modulate.a = 0.0
	get_tree().create_timer(2.2).timeout.connect(_siguiente)


func _construir() -> void:
	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(raiz)
	for arriba: bool in [true, false]:
		var b := ColorRect.new()
		b.color = Color.BLACK
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.anchor_left = 0.0
		b.anchor_right = 1.0
		b.anchor_top = 0.0 if arriba else 1.0
		b.anchor_bottom = 0.0 if arriba else 1.0
		raiz.add_child(b)
		var tb := create_tween()
		if arriba:
			tb.tween_property(b, "offset_bottom", ALTO_BARRA, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		else:
			tb.tween_property(b, "offset_top", -ALTO_BARRA, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var tit := EstiloUI.etiqueta("EL COMITÉ  ·  ANTES DE LA FUENTE DE LA SEÑAL", 16, EstiloUI.COL_AVISO, true)
	tit.anchor_left = 0.0
	tit.anchor_right = 1.0
	tit.offset_top = 20.0
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(tit)
	_lbl_pie = EstiloUI.etiqueta("ENTER o clic: seguir   ·   ESC: saltar la escena", 14, EstiloUI.COL_TENUE)
	_lbl_pie.anchor_left = 0.0
	_lbl_pie.anchor_right = 1.0
	_lbl_pie.anchor_top = 1.0
	_lbl_pie.anchor_bottom = 1.0
	_lbl_pie.offset_top = -44.0
	_lbl_pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_lbl_pie)
	_caja = PanelContainer.new()
	_caja.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 22.0))
	_caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caja.anchor_left = 0.5
	_caja.anchor_right = 0.5
	_caja.anchor_top = 1.0
	_caja.anchor_bottom = 1.0
	_caja.offset_left = -470.0
	_caja.offset_right = 470.0
	_caja.offset_bottom = -ALTO_BARRA - 18.0
	_caja.offset_top = -ALTO_BARRA - 190.0
	_caja.grow_vertical = Control.GROW_DIRECTION_BEGIN
	raiz.add_child(_caja)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 18)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caja.add_child(fila)
	var ins := RadioPanel.Insignia.new()
	ins.custom_minimum_size = Vector2(84.0, 84.0)
	ins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ins.fuente = EstiloUI.fuente_titulo()
	ins.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	fila.add_child(ins)
	_insignia_pos = ins
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(v)
	var cab := HBoxContainer.new()
	cab.add_theme_constant_override("separation", 12)
	cab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(cab)
	_lbl_nombre = EstiloUI.etiqueta("", 24, Color.WHITE, true)
	cab.add_child(_lbl_nombre)
	_lbl_rol = EstiloUI.etiqueta("", 15, EstiloUI.COL_TENUE)
	_lbl_rol.size_flags_vertical = Control.SIZE_SHRINK_END
	cab.add_child(_lbl_rol)
	_lbl_texto = EstiloUI.etiqueta("", 21, EstiloUI.COL_TEXTO)
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.custom_minimum_size = Vector2(740.0, 76.0)
	v.add_child(_lbl_texto)


func _mostrar_linea(l: Dictionary) -> void:
	var j := str(l["j"])
	var inf := Historia.jefe(j)
	var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
	var ins := _insignia_pos as RadioPanel.Insignia
	ins.codigo = str(inf.get("cod", "???"))
	ins.color = col
	_lbl_nombre.text = j
	_lbl_nombre.add_theme_color_override("font_color", col)
	_lbl_rol.text = str(inf.get("rol", ""))
	_lbl_texto.text = "«%s»" % str(l["t"])
	_lbl_texto.visible_ratio = 0.0
	_caja.add_theme_stylebox_override("panel", EstiloUI.panel(col, 22.0))
	_escrito = false
	if sala != null:
		sala.call("foco_comite", j)
	if _tw != null:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(_lbl_texto, "visible_ratio", 1.0, maxf(0.8, float(str(l["t"]).length()) * VEL_ESCRITURA))
	_tw.tween_callback(func(): _escrito = true)


func _siguiente() -> void:
	if _cerrando:
		return
	_i += 1
	if _i >= _lineas.size():
		_terminar()
		return
	if _i == 0:
		create_tween().tween_property(_caja, "modulate:a", 1.0, 0.5)
	_mostrar_linea(_lineas[_i])
	if _i == _lineas.size() - 1:
		_lbl_pie.text = "ENTER o clic: entrar en la misión   ·   ESC: saltar"


func _avanzar() -> void:
	if _i < 0:
		return
	if not _escrito:
		if _tw != null:
			_tw.kill()
		_lbl_texto.visible_ratio = 1.0
		_escrito = true
		return
	_siguiente()


func _terminar() -> void:
	if _cerrando:
		return
	_cerrando = true
	if _tw != null:
		_tw.kill()
	if sala != null:
		sala.call("foco_comite", "")
	var tw := create_tween()
	tw.tween_property(_caja, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func():
		terminada.emit()
		queue_free())


func _unhandled_input(event: InputEvent) -> void:
	if _cerrando:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_avanzar()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				_terminar()
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_avanzar()
		get_viewport().set_input_as_handled()
