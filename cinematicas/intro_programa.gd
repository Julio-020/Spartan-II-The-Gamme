extends CanvasLayer


signal cerrada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Historia := preload("res://historia/historia.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const Locutor := preload("res://sonido/locutor.gd")

const ORDEN := ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]

var _pag: int = 0
var _raiz: Control
var _caja: Control
var _emblema: Control
var _lbl_cod: Label
var _lbl_nombre: Label
var _lbl_rol: Label
var _lbl_def: Label
var _lbl_texto: Label
var _puntos: HBoxContainer
var _b_sig: Button
var _tw: Tween
var _loc: Locutor


func _ready() -> void:
	layer = 45
	add_to_group("modal")
	_construir()
	_mostrar(0)


func _total() -> int:
	return ORDEN.size() + 3


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				_cerrar()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_RIGHT:
				get_viewport().set_input_as_handled()
				_siguiente()
			KEY_LEFT:
				get_viewport().set_input_as_handled()
				if _pag > 0:
					_mostrar(_pag - 1)


func _cerrar() -> void:
	cerrada.emit()
	queue_free()


func _siguiente() -> void:
	if _pag + 1 >= _total():
		_cerrar()
	else:
		_mostrar(_pag + 1)


func _construir() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_raiz)
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.014, 0.018, 0.97)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.add_child(fondo)

	var sup := EstiloUI.etiqueta("PROGRAMA SPARTANS", 16, EstiloUI.COL_TENUE, true)
	sup.position = Vector2(56.0, 30.0)
	_raiz.add_child(sup)

	_caja = Control.new()
	_caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.add_child(_caja)

	_emblema = Emblema.new()
	_emblema.position = Vector2(110.0, 190.0)
	_emblema.size = Vector2(300.0, 300.0)
	_caja.add_child(_emblema)

	var col := VBoxContainer.new()
	col.position = Vector2(470.0, 150.0)
	col.size = Vector2(740.0, 420.0)
	col.add_theme_constant_override("separation", 12)
	_caja.add_child(col)
	_lbl_cod = EstiloUI.etiqueta("", 18, EstiloUI.COL_ACENTO, true)
	col.add_child(_lbl_cod)
	_lbl_nombre = EstiloUI.etiqueta("", 56, Color.WHITE, true)
	col.add_child(_lbl_nombre)
	_lbl_rol = EstiloUI.etiqueta("", 20, EstiloUI.COL_FRIO, true)
	col.add_child(_lbl_rol)
	_lbl_def = EstiloUI.etiqueta("", 17, EstiloUI.COL_TENUE)
	col.add_child(_lbl_def)
	col.add_child(EstiloUI.linea())
	_lbl_texto = EstiloUI.etiqueta("", 22, EstiloUI.COL_TEXTO)
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.custom_minimum_size = Vector2(720.0, 0.0)
	col.add_child(_lbl_texto)

	_puntos = HBoxContainer.new()
	_puntos.position = Vector2(56.0, 650.0)
	_puntos.add_theme_constant_override("separation", 10)
	_raiz.add_child(_puntos)

	_b_sig = EstiloUI.boton("SIGUIENTE", 22)
	_b_sig.position = Vector2(960.0, 628.0)
	_b_sig.custom_minimum_size = Vector2(260.0, 52.0)
	_b_sig.pressed.connect(_siguiente)
	_raiz.add_child(_b_sig)
	var saltar := EstiloUI.etiqueta("Esc para saltar  ·  ← atrás", 14, EstiloUI.COL_TENUE)
	saltar.position = Vector2(700.0, 644.0)
	_raiz.add_child(saltar)


func _mostrar(i: int) -> void:
	_pag = i
	if _loc != null:
		_loc.callar()
	var emb := _emblema as Emblema
	if i == 0:
		emb.codigo = "SP"
		emb.color = EstiloUI.COL_ACENTO
		_lbl_cod.text = "BIENVENIDO"
		_lbl_nombre.text = "SPARTANS II"
		_lbl_rol.text = "Programa de exploración de Marte"
		_lbl_def.text = ""
		_lbl_texto.text = Historia.PROGRAMA_INICIO
	elif i == _total() - 2:
		emb.codigo = "FO"
		emb.color = Color(0.45, 0.82, 1.0)
		_lbl_cod.text = "TU AYUDANTE"
		_lbl_nombre.text = "FOCOS"
		_lbl_rol.text = "Compañero holográfico del robot"
		_lbl_def.text = ""
		_lbl_texto.text = Historia.FOCOS_FRASE
	elif i == _total() - 1:
		emb.codigo = "★"
		emb.color = EstiloUI.COL_OK
		_lbl_cod.text = "TU MISIÓN"
		_lbl_nombre.text = "Diez misiones reales"
		_lbl_rol.text = "Y una decisión final: dónde aterrizar"
		_lbl_def.text = ""
		_lbl_texto.text = Historia.PROGRAMA_FIN
	else:
		var n: String = ORDEN[i - 1]
		var inf := Historia.jefe(n)
		emb.codigo = str(inf["cod"])
		emb.color = inf["color"]
		_lbl_cod.text = "CÓDIGO %s" % str(inf["cod"])
		_lbl_nombre.text = n
		_lbl_rol.text = str(inf["rol"])
		_lbl_def.text = "Defiende: %s" % str(inf["defiende"])
		_lbl_texto.text = "«%s»" % str(Historia.FRASES[n])
		_lbl_cod.add_theme_color_override("font_color", inf["color"])
		_voz(n, str(Historia.FRASES[n]))
	if i == 0 or i >= _total() - 2:
		_lbl_cod.add_theme_color_override("font_color", emb.color)
	emb.queue_redraw()
	_b_sig.text = "EMPEZAR" if i == _total() - 1 else "SIGUIENTE"
	for h in _puntos.get_children():
		h.queue_free()
	for k in range(_total()):
		var r := ColorRect.new()
		r.custom_minimum_size = Vector2(28.0 if k == i else 12.0, 6.0)
		r.color = EstiloUI.COL_ACENTO if k == i else Color(1, 1, 1, 0.22)
		_puntos.add_child(r)
	_caja.modulate.a = 0.0
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(_caja, "modulate:a", 1.0, 0.35)


func _voz(jefe: String, frase: String) -> void:
	if _loc == null:
		_loc = Locutor.new()
		add_child(_loc)
	_loc.decir(jefe, frase)


class Emblema extends Control:
	var codigo: String = ""
	var color: Color = Color.WHITE

	func _draw() -> void:
		var c := size * 0.5
		draw_circle(c, 140.0, Color(color, 0.10))
		draw_arc(c, 138.0, 0.0, TAU, 64, Color(color, 0.9), 4.0)
		draw_arc(c, 118.0, 0.0, TAU, 64, Color(color, 0.35), 2.0)
		for k in range(4):
			var a := PI * 0.5 * float(k) + PI * 0.25
			draw_line(c + Vector2(cos(a), sin(a)) * 122.0, c + Vector2(cos(a), sin(a)) * 138.0, Color(color, 0.9), 4.0)
		var f := EstiloUI.fuente_titulo()
		var tam := 84 if codigo.length() <= 3 else 60
		var ancho := f.get_string_size(codigo, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		draw_string(f, Vector2(c.x - ancho * 0.5, c.y + tam * 0.35), codigo, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)
