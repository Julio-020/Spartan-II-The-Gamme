extends Node


signal giro_planeta(v: Vector2)
signal zoom_planeta(v: float)


static var usado: bool = false

var modo: String = "menu"
var _teclas_sostenidas: Dictionary = {}
var _rep_t: float = 0.0
var _rep_dir: Vector2i = Vector2i.ZERO
var _cursor: Vector2 = Vector2(640.0, 360.0)

const ZONA := 0.28


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if not event.is_echo() and not bool(event.get_meta("mando", false)):
			usado = false
		return
	if not (event is InputEventJoypadButton):
		return
	usado = true
	var e := event as InputEventJoypadButton
	var modal := _hay_modal()
	var foco := get_viewport().gui_get_focus_owner()
	var interfaz := modal or modo == "menu" or foco != null
	get_viewport().set_input_as_handled()
	if interfaz and foco == null and e.pressed:

		if _enfocar_primero():
			return
	var tecla := KEY_NONE
	match e.button_index:
		JOY_BUTTON_A:
			if modo == "planeta" and not modal and foco == null:
				_clic_ratón(e.pressed)
				return
			tecla = KEY_ENTER if interfaz else KEY_E
		JOY_BUTTON_B:
			tecla = KEY_ESCAPE
		JOY_BUTTON_X:
			tecla = KEY_SPACE
		JOY_BUTTON_Y:
			tecla = KEY_H
		JOY_BUTTON_BACK:
			tecla = KEY_J
		JOY_BUTTON_START:
			tecla = KEY_ESCAPE
		JOY_BUTTON_LEFT_SHOULDER:
			tecla = KEY_LEFT if (modal or modo == "menu") else KEY_R
		JOY_BUTTON_RIGHT_SHOULDER:
			tecla = KEY_RIGHT if (modal or modo == "menu") else KEY_F
		JOY_BUTTON_DPAD_UP:
			tecla = KEY_UP if (modal or modo != "mision") else KEY_1
		JOY_BUTTON_DPAD_DOWN:
			tecla = KEY_DOWN if (modal or modo != "mision") else KEY_3
		JOY_BUTTON_DPAD_LEFT:
			tecla = KEY_LEFT if (modal or modo != "mision") else KEY_R
		JOY_BUTTON_DPAD_RIGHT:
			tecla = KEY_RIGHT if (modal or modo != "mision") else KEY_2
	if tecla != KEY_NONE:
		_tecla(tecla, e.pressed)


func _hay_modal() -> bool:
	for n in get_tree().get_nodes_in_group("modal"):
		if n is CanvasItem and (n as CanvasItem).is_visible_in_tree():
			return true
		if n is CanvasLayer and (n as CanvasLayer).visible:
			return true
	return false


func _tecla(k: Key, pulsada: bool) -> void:
	var ev := InputEventKey.new()
	ev.keycode = k
	ev.physical_keycode = k
	ev.pressed = pulsada
	ev.set_meta("mando", true)
	Input.parse_input_event(ev)


func _mantener(k: Key, quiere: bool) -> void:
	var ahora: bool = _teclas_sostenidas.has(k)
	if quiere and not ahora:
		_teclas_sostenidas[k] = true
		_tecla(k, true)
	elif not quiere and ahora:
		_teclas_sostenidas.erase(k)
		_tecla(k, false)


func _clic_ratón(pulsada: bool) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = pulsada
	ev.position = get_viewport().get_mouse_position()
	ev.global_position = ev.position
	ev.button_mask = MOUSE_BUTTON_MASK_LEFT if pulsada else 0
	ev.set_meta("mando", true)
	Input.parse_input_event(ev)


func _enfocar_primero() -> bool:
	var res := _buscar_primero(get_tree().root)
	if res != null:
		res.grab_focus()
		return true
	return false


func _buscar_primero(raiz: Node) -> Control:
	var capas: Array = []
	_recoger_capas(raiz, capas)
	capas.sort_custom(func(a, b): return int(a.layer) > int(b.layer))
	for c in capas:
		if not (c as CanvasLayer).visible:
			continue
		var b := _primer_boton(c)
		if b != null:
			return b
	return null


func _recoger_capas(n: Node, salida: Array) -> void:
	if n is CanvasLayer:
		salida.append(n)
	for h in n.get_children():
		_recoger_capas(h, salida)


func _primer_boton(n: Node) -> Control:
	if n is Control:
		var c := n as Control
		if not c.is_visible_in_tree():
			return null
		if (c is BaseButton or c is Slider or c is OptionButton) and c.focus_mode != Control.FOCUS_NONE:
			return c
	for h in n.get_children():
		var r := _primer_boton(h)
		if r != null:
			return r
	return null


func _process(delta: float) -> void:
	if Input.get_connected_joypads().is_empty():
		if not _teclas_sostenidas.is_empty():
			for k in _teclas_sostenidas.keys():
				_mantener(k, false)
		return
	var id: int = Input.get_connected_joypads()[0]
	var izq := Vector2(Input.get_joy_axis(id, JOY_AXIS_LEFT_X), Input.get_joy_axis(id, JOY_AXIS_LEFT_Y))
	var der := Vector2(Input.get_joy_axis(id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(id, JOY_AXIS_RIGHT_Y))
	var lt := Input.get_joy_axis(id, JOY_AXIS_TRIGGER_LEFT)
	var rt := Input.get_joy_axis(id, JOY_AXIS_TRIGGER_RIGHT)
	if izq.length() > ZONA or der.length() > ZONA or lt > 0.4 or rt > 0.4:
		usado = true
	var modal := _hay_modal()
	var interfaz := modal or modo == "menu" or get_viewport().gui_get_focus_owner() != null
	if modo == "mision" and not interfaz:
		_mantener(KEY_W, izq.y < -ZONA)
		_mantener(KEY_S, izq.y > ZONA)
		_mantener(KEY_A, izq.x < -ZONA)
		_mantener(KEY_D, izq.x > ZONA)
		_mantener(KEY_SHIFT, rt > 0.4)
		if der.length() > ZONA:
			_mover_ratón_relativo(der * 14.0)
		return
	for k in [KEY_W, KEY_S, KEY_A, KEY_D, KEY_SHIFT]:
		_mantener(k, false)
	if modo == "planeta" and not interfaz:
		_cursor = get_viewport().get_mouse_position()
		if izq.length() > ZONA:
			_cursor += izq * 620.0 * delta
			var r := get_viewport().get_visible_rect().size
			_cursor = Vector2(clampf(_cursor.x, 0.0, r.x - 1.0), clampf(_cursor.y, 0.0, r.y - 1.0))
			get_viewport().warp_mouse(_cursor)
			var ev := InputEventMouseMotion.new()
			ev.position = _cursor
			ev.global_position = _cursor
			ev.relative = izq * 620.0 * delta
			ev.set_meta("mando", true)
			Input.parse_input_event(ev)
		if der.length() > ZONA:
			giro_planeta.emit(der * delta)
		if absf(rt - lt) > 0.3:
			zoom_planeta.emit((lt - rt) * delta)
		return

	var d := Vector2i.ZERO
	if izq.length() > 0.6:
		if absf(izq.x) > absf(izq.y):
			d = Vector2i(1 if izq.x > 0.0 else -1, 0)
		else:
			d = Vector2i(0, 1 if izq.y > 0.0 else -1)
	if d == Vector2i.ZERO:
		_rep_dir = Vector2i.ZERO
		_rep_t = 0.0
		return
	if d != _rep_dir:
		_rep_dir = d
		_rep_t = 0.35
		_pulso_flecha(d)
	else:
		_rep_t -= delta
		if _rep_t <= 0.0:
			_rep_t = 0.16
			_pulso_flecha(d)


func _pulso_flecha(d: Vector2i) -> void:
	var k := KEY_NONE
	if d.x > 0:
		k = KEY_RIGHT
	elif d.x < 0:
		k = KEY_LEFT
	elif d.y > 0:
		k = KEY_DOWN
	elif d.y < 0:
		k = KEY_UP
	if k == KEY_NONE:
		return
	if get_viewport().gui_get_focus_owner() == null and _enfocar_primero():
		return
	_tecla(k, true)
	_tecla(k, false)


func _mover_ratón_relativo(rel: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.relative = rel
	ev.position = get_viewport().get_mouse_position()
	ev.button_mask = MOUSE_BUTTON_MASK_RIGHT
	ev.set_meta("mando", true)
	Input.parse_input_event(ev)
