extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Historia := preload("res://historia/historia.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Locutor := preload("res://sonido/locutor.gd")
const MusicaFinal := preload("res://sonido/musica_final.gd")

var final_id: String = "eco"

var _datos: Dictionary = {}
var _lineas: Array = []
var _i: int = -1
var _t: float = 0.0
var _dur: float = 3.0
var _loc: Locutor
var _lienzo: Fondo
var _lbl_jefe: Label
var _lbl_texto: Label
var _lbl_titulo: Label
var _lbl_pie: Label
var _boton: Button
var _mus: AudioStreamPlayer
var _mus_gen: MusicaFinal = null
var _fin: bool = false
var _color: Color = Color.WHITE


func configurar(id: String) -> void:
	final_id = id


func _ready() -> void:
	layer = 70
	add_to_group("modal")
	_datos = HistoriaEstado.final_datos(final_id)
	_lineas = HistoriaEstado.final_lineas(final_id)
	_color = _datos.get("color", Color.WHITE)
	_construir()
	_preparar_musica()
	_loc = Locutor.new()
	add_child(_loc)

	_lienzo.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_lienzo, "modulate:a", 1.0, 1.4)
	tw.tween_interval(3.2)
	tw.tween_callback(_siguiente)


func _construir() -> void:
	_lienzo = Fondo.new()
	_lienzo.color_final = _color
	_lienzo.semilla = final_id.hash()
	_lienzo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_lienzo)
	_lbl_titulo = EstiloUI.etiqueta(str(_datos.get("titulo", "")), 58, _color, true)
	_lbl_titulo.position = Vector2(0.0, 96.0)
	_lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_titulo.size = Vector2(1280.0, 80.0)
	_lbl_titulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	_lienzo.add_child(_lbl_titulo)
	var sub := EstiloUI.etiqueta("SPARTANS II  ·  EPÍLOGO", 16, EstiloUI.COL_TENUE)
	sub.position = Vector2(0.0, 66.0)
	sub.size = Vector2(1280.0, 24.0)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lienzo.add_child(sub)
	_lbl_jefe = EstiloUI.etiqueta("", 22, Color.WHITE, true)
	_lbl_jefe.position = Vector2(240.0, 330.0)
	_lbl_jefe.size = Vector2(800.0, 30.0)
	_lbl_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lienzo.add_child(_lbl_jefe)
	_lbl_texto = EstiloUI.etiqueta("", 26, EstiloUI.COL_TEXTO)
	_lbl_texto.position = Vector2(240.0, 372.0)
	_lbl_texto.size = Vector2(800.0, 200.0)
	_lbl_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.visible_ratio = 0.0
	_lienzo.add_child(_lbl_texto)
	_lbl_pie = EstiloUI.etiqueta("ESPACIO: siguiente   ·   ESC: cerrar", 14, EstiloUI.COL_TENUE)
	_lbl_pie.position = Vector2(0.0, 676.0)
	_lbl_pie.size = Vector2(1280.0, 22.0)
	_lbl_pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lienzo.add_child(_lbl_pie)
	_boton = EstiloUI.boton("VOLVER", 22)
	_boton.position = Vector2(540.0, 600.0)
	_boton.custom_minimum_size = Vector2(200.0, 52.0)
	_boton.visible = false
	_boton.pressed.connect(_cerrar)
	_lienzo.add_child(_boton)


func _preparar_musica() -> void:
	Ajustes.asegurar_buses()
	var tipo := 0 if final_id == "unidos" else (2 if final_id == "dividido" else 1)
	_mus = AudioStreamPlayer.new()
	_mus.bus = Ajustes.BUS_EFECTOS
	_mus.volume_db = -7.0
	add_child(_mus)
	var w := MusicaFinal.obtener(tipo)
	if w != null:
		_mus.stream = w
		_mus.play()
	else:
		_mus_gen = MusicaFinal.new(tipo)


func _siguiente() -> void:
	if _fin:
		return
	_i += 1
	if _i >= _lineas.size():
		_terminar()
		return
	var l: Dictionary = _lineas[_i]
	var j := str(l["j"])
	var inf := Historia.jefe(j)
	_lbl_jefe.text = Historia.titulo(j)
	_lbl_jefe.add_theme_color_override("font_color", inf.get("color", Color.WHITE))
	_lbl_texto.text = "«%s»" % str(l["t"])
	_lbl_texto.visible_ratio = 0.0
	_t = 0.0
	_dur = 2.0 + float(str(l["t"]).length()) * 0.055
	_lienzo.latir(inf.get("color", _color))
	_loc.decir(j, str(l["t"]))


func _terminar() -> void:
	_fin = true
	_lbl_jefe.text = ""
	_lbl_texto.text = str(_datos.get("resumen", ""))
	_lbl_texto.add_theme_color_override("font_color", _color)
	_lbl_texto.visible_ratio = 1.0
	_lbl_pie.text = "Has visto el final «%s». Hay otros dos: cambian con la confianza que tengas con tu equipo." % str(_datos.get("titulo", "")).capitalize()
	_boton.visible = true
	_loc.callar()


func _cerrar() -> void:
	var tw := create_tween()
	tw.tween_property(_lienzo, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	if _mus_gen != null and _mus_gen.avanzar(8000):
		_mus.stream = _mus_gen.resultado
		_mus.play()
		_mus_gen = null
	if _i >= 0 and not _fin:
		_t += delta
		_lbl_texto.visible_ratio = clampf(_t / (_dur * 0.7), 0.0, 1.0)
		if _t >= _dur + 0.8:
			_siguiente()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		if event.keycode == KEY_ESCAPE:
			_cerrar()
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_RIGHT] and _i >= 0:
			_siguiente()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _i >= 0 and not _fin:
		_siguiente()


class Fondo extends Control:
	var color_final: Color = Color.WHITE
	var semilla: int = 0
	var _t: float = 0.0
	var _ondas: Array = []
	var _est: Array = []

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = semilla
		for i in range(140):
			_est.append([Vector2(rng.randf(), rng.randf() * 0.8), rng.randf_range(0.6, 1.8), rng.randf() * TAU, rng.randf_range(0.6, 2.4)])

	func latir(c: Color) -> void:
		_ondas.append([0.0, c])
		if _ondas.size() > 6:
			_ondas.pop_front()

	func _process(delta: float) -> void:
		_t += delta
		for o in _ondas:
			o[0] = float(o[0]) + delta
		while not _ondas.is_empty() and float(_ondas[0][0]) > 4.0:
			_ondas.pop_front()
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.015, 0.03))
		for i in range(10):
			var f := float(i) / 10.0
			draw_rect(Rect2(0, h * f, w, h / 10.0 + 1.0), Color(color_final.r * 0.18, color_final.g * 0.12, color_final.b * 0.2, 0.25 * f))
		for e in _est:
			var p := Vector2((e[0] as Vector2).x * w, (e[0] as Vector2).y * h)
			draw_circle(p, float(e[1]), Color(1, 1, 1, 0.25 + 0.35 * (0.5 + 0.5 * sin(_t * float(e[3]) + float(e[2])))))

		var resp := 1.0 + 0.012 * sin(_t * 0.8)
		var c := Vector2(w * 0.5, h + 520.0)
		draw_circle(c, 640.0 * resp, Color(0.45, 0.16, 0.09, 0.9))
		draw_circle(c, 622.0 * resp, Color(0.66, 0.27, 0.14, 0.9))
		draw_circle(c + Vector2(0, 10), 560.0 * resp, Color(0.55, 0.21, 0.11, 0.55))

		var o_c := Vector2(w * 0.5, h - 110.0)
		for o in _ondas:
			var edad := float(o[0])
			var col: Color = o[1]
			var r := 30.0 + edad * 150.0
			draw_arc(o_c, r, PI * 1.05, PI * 1.95, 48, Color(col.r, col.g, col.b, clampf(0.55 - edad * 0.14, 0.0, 1.0)), 3.0)
		draw_circle(o_c, 7.0 + 2.0 * sin(_t * 5.0), Color(color_final.r, color_final.g, color_final.b, 0.9))
		draw_rect(Rect2(0, 0, w, 4.0), color_final)
