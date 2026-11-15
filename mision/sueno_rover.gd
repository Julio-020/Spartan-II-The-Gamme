extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const Historia := preload("res://historia/historia.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")

signal terminado

const JEFES := ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]
const COLORES := {
	"KELLY": Color(0.45, 0.8, 1.0), "JULIO": Color(0.55, 0.95, 0.6), "REYZER": Color(1.0, 0.72, 0.3),
	"GERALD": Color(0.8, 0.65, 1.0), "DAID": Color(1.0, 0.5, 0.65),
}
const MISION_SIMBOLO := 8


const TEMAS := {
	"huecos": ["Sueñas con huecos en el almacén, con la forma exacta de lo que dejaste atrás.", "En el sueño faltan cosas, y las sombras las echan de menos."],
	"gemas": ["Sueñas con gemas que se encienden cuando las miras.", "Algo dorado late bajo la arena, como un corazón pequeño."],
	"marcos": ["Sueñas que el cielo tiene marcos y que cada nube es una foto.", "Todo a tu alrededor está enmarcado, como en un álbum."],
	"cristales": ["Sueñas con cristales que caen hacia arriba.", "En el sueño, el hielo canta bajo las ruedas."],
	"noche": ["Sueñas con una noche larguísima y una sola luz.", "El Sol se esconde y el rover cuenta estrellas."],
	"polvo": ["Sueñas con el viento escribiendo en el polvo.", "El polvo sube en espirales, y cada espiral tiene una voz."],
	"rocas": ["Sueñas con rocas flotando como globos.", "Las piedras susurran sus nombres, una a una."],
}
const ORDEN_TEMAS := ["huecos", "gemas", "marcos", "cristales", "noche", "polvo", "rocas"]

const FRASES_JEFE := {
	"KELLY": ["Cuenta tus pasos antes de darlos, piloto. El suelo tiene memoria.", "No todo lo que se pierde se pierde del todo.",
			"Duerme. Mañana el mapa será otro.", "Tranquilo. Estoy contigo, aunque no me veas."],
	"JULIO": ["Las rocas guardan el tiempo que nosotros no tenemos.", "Cada muestra es una pregunta con forma de piedra.",
			"Hay un patrón. Todavía no sé leerlo.", "Si lo anotas, existe."],
	"REYZER": ["Esa rueda cruje porque te está hablando.", "Una buena máquina sueña con ser reparada.",
			"Todo lo que se rompe enseña algo por dentro.", "Atornilla despacio; el cielo no se va a ir."],
	"GERALD": ["El camino más corto es el que ya conoces. No siempre es el mejor.", "Dibuja la ruta con los ojos cerrados.",
			"Hay un norte, aunque Marte no lo diga.", "Medí tres veces: la distancia es mayor de lo que parece."],
	"DAID": ["No sé por qué, pero hoy el polvo huele a canción.", "¿Y si Marte también sueña con nosotros?",
			"Hay algo allí abajo. No me preguntes cómo lo sé.", "La mejor idea del día fue un error. Guárdalo."],
}

var guion: Dictionary = {}

var _lienzo: Control
var _texto: Label
var _nombre: Label
var _boton: Button
var _fase: int = 0
var _t_fase: float = 0.0
var _cerrando: bool = false


static func temas_de(entrada: Dictionary, datos: Dictionary) -> Array[String]:
	var t: Array[String] = []
	var total := int(entrada.get("total", 0))
	var ent := int(entrada.get("muestras", total))
	if total > 0 and ent < total:
		t.append("huecos")
	if int(entrada.get("hallazgos", 0)) > 0:
		t.append("gemas")
	var tc := int(entrada.get("total_curiosos", 0))
	if str(datos.get("tipo", "")) == "fotos" or (tc > 0 and int(entrada.get("curiosos", 0)) >= tc):
		t.append("marcos")
	var mats: Dictionary = datos.get("muestras", {})
	if mats.has("hielo") or mats.has("perclorato") or mats.has("cristal"):
		t.append("cristales")
	var emin := float(entrada.get("energia_min", -1.0))
	if str(datos.get("condicion", "")) == "noche" or (emin >= 0.0 and emin < 30.0):
		t.append("noche")
	var amb: Dictionary = datos.get("amb", {})
	if str(datos.get("condicion", "")) == "tormenta" or float(amb.get("polvo", 0.0)) >= 0.85:
		t.append("polvo")
	t.append("rocas")
	var res: Array[String] = []
	for k in ORDEN_TEMAS:
		if t.has(k) and res.size() < 3:
			res.append(k)
	return res


static func pista(sig: Dictionary) -> String:
	if sig.is_empty():
		return Idioma.t("Al despertar ya no recuerdas nada. Solo queda silencio, y está bien.")
	var nombre := str(sig.get("nombre", ""))
	var amb: Dictionary = sig.get("amb", {})
	if int(amb.get("cuevas", 0)) > 0:
		return Idioma.t("Al despertar recuerdas una grieta oscura. Siguiente misión: %s. Habrá cuevas.") % nombre
	match str(sig.get("condicion", "")):
		"noche":
			return Idioma.t("Al despertar recuerdas que todo estaba a oscuras. Siguiente misión: %s. Será de noche.") % nombre
		"tormenta":
			return Idioma.t("Al despertar recuerdas un cielo lleno de polvo. Siguiente misión: %s. Empieza con tormenta.") % nombre
	if str(sig.get("tipo", "")) == "fotos":
		return Idioma.t("Al despertar recuerdas marcos por todas partes. Siguiente misión: %s. Te toca fotografiar.") % nombre
	var mats: Dictionary = sig.get("muestras", {})
	var mejor := ""
	var n_max := 0
	for k in mats:
		if int(mats[k]) > n_max:
			n_max = int(mats[k])
			mejor = str(k)
	if mejor != "":
		return Idioma.t("Al despertar recuerdas un brillo: %s. Siguiente misión: %s.") % [str(DatosMarte.material(mejor)["nombre"]), nombre]
	return Idioma.t("Al despertar recuerdas un lugar nuevo. Siguiente misión: %s.") % nombre


static func nitidez_simbolo(n: int) -> float:
	return clampf(float(n - MISION_SIMBOLO + 1) / 10.0, 0.0, 1.0)


static func componer(entrada: Dictionary, datos_prev: Dictionary, sig: Dictionary, n: int) -> Dictionary:
	var temas := temas_de(entrada, datos_prev)
	var frases: Array = TEMAS[temas[0]]
	var jefe: String = JEFES[n % JEFES.size()]
	var lista: Array = FRASES_JEFE[jefe]
	var fases: Array = []
	fases.append({"texto": Idioma.t(str(frases[n % frases.size()])), "color": Color(0.85, 0.9, 1.0), "jefe": "", "dur": 5.5})
	fases.append({"texto": "«%s»" % Idioma.t(str(lista[floori(float(n) / float(JEFES.size())) % lista.size()])), "color": COLORES[jefe], "jefe": jefe, "dur": 6.0})
	var nit := nitidez_simbolo(n)
	if nit > 0.0:
		var txt := "Hay algo en el fondo del sueño: una espiral que casi no se ve."
		if n >= 15:
			txt = "En el fondo del sueño hay un símbolo: una espiral con un ojo en el centro. Ya lo has visto antes."
		fases.append({"texto": Idioma.t(txt), "color": Color(1.0, 0.85, 0.45), "jefe": "", "dur": 5.5})
	fases.append({"texto": pista(sig), "color": Color(1.0, 0.82, 0.25), "jefe": "", "dur": -1.0})
	return {"n": n, "temas": temas, "jefe": jefe, "fases": fases, "simbolo": nit, "semilla": hash(str(entrada.get("id", "")) + str(n))}


func _ready() -> void:
	layer = 62
	add_to_group("modal")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.modulate.a = 0.0
	add_child(raiz)
	_lienzo = Lienzo.new()
	_lienzo.set("guion", guion)
	_lienzo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_lienzo)

	var cab := EstiloUI.etiqueta_contorno("EL ROVER DUERME  ·  SUEÑO %d" % int(guion.get("n", 1)), 18, Color(0.7, 0.8, 1.0, 0.8), true)
	cab.set_anchors_preset(Control.PRESET_CENTER_TOP)
	cab.anchor_left = 0.0
	cab.anchor_right = 1.0
	cab.offset_top = 34.0
	cab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(cab)

	_nombre = EstiloUI.etiqueta_contorno("", 16, Color.WHITE, true)
	_nombre.anchor_left = 0.0
	_nombre.anchor_right = 1.0
	_nombre.anchor_top = 1.0
	_nombre.anchor_bottom = 1.0
	_nombre.offset_top = -230.0
	_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_nombre)

	_texto = EstiloUI.etiqueta_contorno("", 24, Color.WHITE, false)
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.anchor_left = 0.5
	_texto.anchor_right = 0.5
	_texto.anchor_top = 1.0
	_texto.anchor_bottom = 1.0
	_texto.offset_left = -400.0
	_texto.offset_right = 400.0
	_texto.offset_top = -200.0
	_texto.offset_bottom = -90.0
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_texto)

	_boton = EstiloUI.boton("DESPERTAR", 20)
	_boton.anchor_left = 0.5
	_boton.anchor_right = 0.5
	_boton.anchor_top = 1.0
	_boton.anchor_bottom = 1.0
	_boton.offset_left = -110.0
	_boton.offset_right = 110.0
	_boton.offset_top = -78.0
	_boton.offset_bottom = -30.0
	_boton.visible = false
	_boton.pressed.connect(_cerrar)
	raiz.add_child(_boton)

	var pie := EstiloUI.etiqueta_contorno("ENTER: seguir  ·  ESC: saltar el sueño", 13, Color(0.7, 0.75, 0.9, 0.6), false)
	pie.anchor_left = 0.0
	pie.anchor_right = 1.0
	pie.anchor_top = 1.0
	pie.anchor_bottom = 1.0
	pie.offset_top = -24.0
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(pie)

	var tw := create_tween()
	tw.tween_property(raiz, "modulate:a", 1.0, 1.4)
	_poner_fase(0)


func _fases() -> Array:
	return guion.get("fases", [])


func _poner_fase(i: int) -> void:
	_fase = i
	_t_fase = 0.0
	var f: Dictionary = _fases()[i]
	_texto.text = str(f["texto"])
	_texto.add_theme_color_override("font_color", f["color"])
	_texto.modulate.a = 0.0
	var j := str(f["jefe"])
	_nombre.text = j
	_nombre.add_theme_color_override("font_color", COLORES.get(j, Color.WHITE))
	_lienzo.set("jefe_activo", j)
	var ultima := float(f["dur"]) < 0.0
	_boton.visible = ultima
	if ultima:
		_boton.call_deferred("grab_focus")


func _process(delta: float) -> void:
	if _cerrando or _fases().is_empty():
		return
	_t_fase += delta
	_texto.modulate.a = clampf(_t_fase / 1.2, 0.0, 1.0)
	var dur := float(_fases()[_fase]["dur"])
	if dur > 0.0 and _t_fase >= dur:
		_siguiente()


func _siguiente() -> void:
	if _fase < _fases().size() - 1:
		_poner_fase(_fase + 1)


func _cerrar() -> void:
	if _cerrando:
		return
	_cerrando = true
	MetaEstado.extra_set("suenos", int(MetaEstado.extra_get("suenos", 0)) + 1)
	if float(guion.get("simbolo", 0.0)) > 0.0:
		MetaEstado.extra_set("simbolos", int(MetaEstado.extra_get("simbolos", 0)) + 1)
	var tw := create_tween()
	tw.tween_property(get_child(0), "modulate:a", 0.0, 0.9)
	tw.tween_callback(func():
		terminado.emit()
		queue_free())


func _input(event: InputEvent) -> void:
	if _cerrando:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				_cerrar()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				get_viewport().set_input_as_handled()
				if _fase >= _fases().size() - 1:
					_cerrar()
				else:
					_siguiente()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _fase < _fases().size() - 1:
			_siguiente()


class Lienzo extends Control:
	var guion: Dictionary = {}
	var jefe_activo: String = ""
	var _t: float = 0.0
	var _estrellas: Array = []
	var _objetos: Array = []
	var _rng := RandomNumberGenerator.new()
	var _fuente: Font

	func _ready() -> void:
		_rng.seed = int(guion.get("semilla", 1))
		_fuente = EstiloUI.fuente_texto()
		for i in range(110):
			_estrellas.append(Vector3(_rng.randf(), _rng.randf(), _rng.randf_range(0.3, 1.0)))
		var orden: Array = (guion.get("temas", []) as Array).duplicate()
		if orden.has("noche"):
			orden.erase("noche")
			orden.push_front("noche")
		for tema in orden:
			for i in range(12 if tema != "noche" else 1):
				_objetos.append({"tema": tema, "x": _rng.randf(), "y": _rng.randf(), "v": _rng.randf_range(0.01, 0.035),
						"s": _rng.randf_range(0.6, 1.5), "f": _rng.randf() * TAU, "r": _rng.randf_range(-0.6, 0.6),
						"pol": _poligono(7)})

	func _poligono(n: int) -> PackedFloat32Array:
		var p := PackedFloat32Array()
		for i in range(n):
			p.append(_rng.randf_range(0.65, 1.15))
		return p

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var tam := size

		var arriba := Color(0.03, 0.03, 0.10)
		var abajo := Color(0.14, 0.06, 0.12)
		draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(tam.x, 0.0), tam, Vector2(0.0, tam.y)]),
				PackedColorArray([arriba, arriba, abajo, abajo]))
		for e in _estrellas:
			var a := 0.35 + 0.65 * (0.5 + 0.5 * sin(_t * (0.8 + e.z * 1.6) + e.x * 40.0))
			draw_circle(Vector2(e.x * tam.x, e.y * tam.y), 0.8 + e.z * 1.4, Color(0.85, 0.9, 1.0, a * 0.7))
		var nit := float(guion.get("simbolo", 0.0))
		if nit > 0.0:
			_simbolo(Vector2(tam.x * 0.80, tam.y * 0.30), 70.0 + 30.0 * nit, nit)
		for o in _objetos:
			_objeto(o, tam)
		_constelacion(tam)

	func _objeto(o: Dictionary, tam: Vector2) -> void:
		var x: float = fposmod(float(o["x"]) + sin(_t * 0.2 + float(o["f"])) * 0.02, 1.0) * tam.x
		var tema := str(o["tema"])
		var s: float = float(o["s"])
		match tema:
			"cristales":
				var y: float = fposmod(float(o["y"]) - _t * float(o["v"]), 1.0) * tam.y
				_hexagono(Vector2(x, y), 14.0 * s, _t * float(o["r"]) + float(o["f"]), Color(0.6, 0.85, 1.0, 0.55))
			"marcos":
				var y: float = fposmod(float(o["y"]) + sin(_t * 0.3 + float(o["f"])) * 0.03, 1.0) * tam.y
				draw_set_transform(Vector2(x, y), _t * 0.15 * float(o["r"]) + float(o["f"]) * 0.1, Vector2.ONE)
				draw_rect(Rect2(Vector2(-26.0, -18.0) * s, Vector2(52.0, 36.0) * s), Color(1.0, 0.95, 0.8, 0.5), false, 2.0)
				draw_rect(Rect2(Vector2(-20.0, -12.0) * s, Vector2(40.0, 24.0) * s), Color(1.0, 0.95, 0.8, 0.12), true)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"huecos":
				var ciclo: float = fposmod(_t * float(o["v"]) * 3.0 + float(o["f"]), 1.0)
				draw_arc(Vector2(x, float(o["y"]) * tam.y), 8.0 + ciclo * 60.0 * s, 0.0, TAU, 36, Color(0.9, 0.5, 0.6, 0.5 * (1.0 - ciclo)), 2.0)
			"gemas":
				var y: float = (float(o["y"]) + sin(_t * 0.5 + float(o["f"])) * 0.03) * tam.y
				var p := 0.6 + 0.4 * sin(_t * 2.0 + float(o["f"]))
				var c := Color(1.0, 0.82, 0.25, 0.35 + 0.4 * p)
				var h := 12.0 * s
				draw_circle(Vector2(x, y), h * 1.8, Color(1.0, 0.82, 0.25, 0.08 * p))
				draw_polygon(PackedVector2Array([Vector2(x, y - h * 1.3), Vector2(x + h * 0.8, y), Vector2(x, y + h * 1.3), Vector2(x - h * 0.8, y)]),
						PackedColorArray([c, c, c, c]))
			"polvo":
				var y: float = float(o["y"]) * tam.y
				var xx: float = fposmod(float(o["x"]) + _t * float(o["v"]) * 3.0, 1.0) * tam.x
				draw_line(Vector2(xx, y), Vector2(xx + 70.0 * s, y + sin(_t + float(o["f"])) * 8.0), Color(0.95, 0.65, 0.4, 0.3), 2.0)
			"noche":
				var c := Vector2(tam.x * 0.22, tam.y * 0.32)
				draw_circle(c, 46.0, Color(0.9, 0.92, 1.0, 0.85))
				draw_circle(c + Vector2(18.0, -6.0), 42.0, Color(0.05, 0.04, 0.12, 1.0))
			_:
				var y: float = fposmod(float(o["y"]) + sin(_t * 0.25 + float(o["f"])) * 0.04 - _t * float(o["v"]) * 0.4, 1.0) * tam.y
				var pol: PackedFloat32Array = o["pol"]
				var pts := PackedVector2Array()
				for i in range(pol.size()):
					var a := TAU * float(i) / float(pol.size()) + _t * 0.1 * float(o["r"])
					pts.append(Vector2(x, y) + Vector2(cos(a), sin(a)) * pol[i] * 16.0 * s)
				draw_colored_polygon(pts, Color(0.75, 0.38, 0.22, 0.55))

	func _hexagono(c: Vector2, r: float, rot: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in range(6):
			var a := rot + TAU * float(i) / 6.0
			pts.append(c + Vector2(cos(a), sin(a)) * r)
		draw_colored_polygon(pts, col)
		pts.append(pts[0])
		draw_polyline(pts, Color(0.9, 0.97, 1.0, 0.7), 1.5)


	func _simbolo(c: Vector2, r: float, nit: float) -> void:
		var col := Color(1.0, 0.85, 0.45, 0.10 + 0.5 * nit)
		var pts := PackedVector2Array()
		for i in range(90):
			var f := float(i) / 89.0
			var a := f * TAU * 2.6 + _t * 0.25
			pts.append(c + Vector2(cos(a), sin(a)) * r * f)
		draw_polyline(pts, col, 2.0)
		draw_arc(c, r * 0.16, 0.0, TAU, 24, col, 2.0)
		draw_circle(c, r * 0.07 * (0.8 + 0.2 * sin(_t * 1.5)), Color(col.r, col.g, col.b, col.a + 0.2))


	func _constelacion(tam: Vector2) -> void:
		var base := [Vector2(0.38, 0.30), Vector2(0.50, 0.20), Vector2(0.62, 0.30), Vector2(0.56, 0.44), Vector2(0.44, 0.44)]
		var pos: Array[Vector2] = []
		for i in range(5):
			var b: Vector2 = base[i]
			pos.append(Vector2((b.x + sin(_t * 0.3 + float(i) * 1.7) * 0.01) * tam.x, (b.y + cos(_t * 0.25 + float(i) * 2.3) * 0.012) * tam.y))
		for i in range(5):
			draw_line(pos[i], pos[(i + 1) % 5], Color(0.8, 0.9, 1.0, 0.18), 1.5)
		draw_line(pos[0], pos[2], Color(0.8, 0.9, 1.0, 0.08), 1.0)
		draw_line(pos[1], pos[3], Color(0.8, 0.9, 1.0, 0.08), 1.0)
		for i in range(5):
			var j: String = JEFES[i]
			var col: Color = COLORES[j]
			var activo := j == jefe_activo
			var p := 0.5 + 0.5 * sin(_t * 3.0)
			var r := 5.0 + (5.0 + 3.0 * p if activo else 0.0)
			draw_circle(pos[i], r * 3.2, Color(col.r, col.g, col.b, (0.22 + 0.15 * p) if activo else 0.07))
			draw_circle(pos[i], r, Color(col.r, col.g, col.b, 1.0 if activo else 0.7))
			if activo:
				draw_string(_fuente, pos[i] + Vector2(-40.0, 34.0), j, HORIZONTAL_ALIGNMENT_CENTER, 80.0, 15, col)
