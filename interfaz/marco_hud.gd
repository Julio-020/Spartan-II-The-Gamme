extends Control


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")

const COL := Color(1.0, 0.5, 0.2)
const FRIO := Color(0.45, 0.85, 1.0)
const TELEMETRIA := "ENLACE CON MARTE ESTABLE   ·   KELLY · JULIO · REYZER · GERALD · DAID: COMITÉ EN LÍNEA   ·   TORMENTAS DE POLVO: VIGILANCIA ACTIVA   ·   "

var titulo: String = "CENTRO DE CONTROL  ·  SPARTANS II"
var ticker: bool = true
var margen: float = 22.0

var _t: float = 0.0
var _fuente: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fuente = EstiloUI.fuente_texto()
	if ticker:
		var tk := Ticker.new()
		tk.anchor_top = 1.0
		tk.anchor_bottom = 1.0
		tk.anchor_right = 1.0
		tk.offset_left = margen + 58.0
		tk.offset_right = -(margen + 58.0)
		tk.offset_top = -50.0
		tk.offset_bottom = -22.0
		add_child(tk)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var m := margen
	var l := 34.0
	var c := Color(COL.r, COL.g, COL.b, 0.75)
	for e in [[Vector2(m, m), 1.0, 1.0], [Vector2(w - m, m), -1.0, 1.0], [Vector2(m, h - m), 1.0, -1.0], [Vector2(w - m, h - m), -1.0, -1.0]]:
		var p: Vector2 = e[0]
		draw_line(p, p + Vector2(l * float(e[1]), 0.0), c, 3.0)
		draw_line(p, p + Vector2(0.0, l * float(e[2])), c, 3.0)
	draw_string(_fuente, Vector2(m + 14.0, m + 22.0), Idioma.t(titulo), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(1, 1, 1, 0.5))
	var s := int(_t) + 4321
	var reloj := "T+ %02d:%02d:%02d" % [s / 3600, (s / 60) % 60, s % 60]
	draw_string(_fuente, Vector2(w - m - 150.0, m + 22.0), reloj, HORIZONTAL_ALIGNMENT_RIGHT, 136.0, 14, FRIO)
	var a := 0.5 + 0.5 * sin(_t * 3.0)
	draw_circle(Vector2(w - m - 168.0, m + 17.0), 4.0, Color(0.4, 1.0, 0.5, 0.35 + 0.65 * a))


class Ticker extends Control:
	var _t: float = 0.0
	var _fuente: Font

	func _ready() -> void:
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fuente = load("res://interfaz/estilo_ui.gd").fuente_texto()

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		draw_line(Vector2(0, 0), Vector2(size.x, 0), Color(1.0, 0.5, 0.2, 0.25), 1.0)
		var ancho := _fuente.get_string_size(Idioma.t(TELEMETRIA), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13).x
		var x0 := -fmod(_t * 36.0, ancho)
		for k in range(4):
			var x := x0 + float(k) * ancho
			if x > size.x:
				break
			draw_string(_fuente, Vector2(x, 20.0), Idioma.t(TELEMETRIA), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(1, 1, 1, 0.38))
