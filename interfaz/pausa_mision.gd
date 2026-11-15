extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")

signal salir

var _caja: VBoxContainer
var _confirmando: bool = false


func _ready() -> void:
	layer = 70
	add_to_group("modal")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var fondo := ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.62)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 26.0))
	panel.custom_minimum_size = Vector2(520, 0)
	centro.add_child(panel)
	_caja = VBoxContainer.new()
	_caja.add_theme_constant_override("separation", 12)
	panel.add_child(_caja)
	_pintar()


func _limpiar() -> void:
	for c in _caja.get_children():
		_caja.remove_child(c)
		c.queue_free()


func _pintar() -> void:
	_limpiar()
	_confirmando = false
	_caja.add_child(EstiloUI.etiqueta("PAUSA", 34, EstiloUI.COL_ACENTO, true))
	_caja.add_child(EstiloUI.linea())
	var b1 := EstiloUI.boton("CONTINUAR", 22)
	b1.pressed.connect(_continuar)
	_caja.add_child(b1)
	var b2 := EstiloUI.boton("VOLVER AL PLANETA", 22)
	b2.pressed.connect(_pintar_confirmar)
	_caja.add_child(b2)
	var l := EstiloUI.etiqueta("ESC: continuar", 15, EstiloUI.COL_TENUE)
	_caja.add_child(l)
	b1.call_deferred("grab_focus")


func _pintar_confirmar() -> void:
	_limpiar()
	_confirmando = true
	_caja.add_child(EstiloUI.etiqueta("¿VOLVER AL PLANETA?", 30, EstiloUI.COL_AVISO, true))
	_caja.add_child(EstiloUI.linea())
	var t := EstiloUI.etiqueta("La misión no contará como completada y perderás lo que llevas en el robot. Los datos de ciencia ya guardados se conservan.", 18, EstiloUI.COL_TEXTO)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(470, 0)
	_caja.add_child(t)
	var b_no := EstiloUI.boton("NO, SEGUIR JUGANDO", 22)
	b_no.pressed.connect(_continuar)
	_caja.add_child(b_no)
	var b_si := EstiloUI.boton("SÍ, SALIR", 22)
	b_si.pressed.connect(_salir)
	_caja.add_child(b_si)
	b_no.call_deferred("grab_focus")


func _continuar() -> void:
	queue_free()


func _salir() -> void:
	salir.emit()
	queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		if _confirmando:
			_pintar()
		else:
			_continuar()
