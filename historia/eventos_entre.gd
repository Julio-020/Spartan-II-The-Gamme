extends RefCounted


const Ajustes := preload("res://nucleo/ajustes.gd")
const Historia := preload("res://historia/historia.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const PROBABILIDAD := 0.5
const CLAVE_VISTOS := "eventos_vistos"

const EVENTOS := {
	"tormenta_lejana": {
		"jefe": "DAID", "min": 1, "titulo": "TORMENTA EN EL HORIZONTE",
		"texto": "Piloto, hay una tormenta de polvo creciendo al este. Puedo reforzar las antenas esta noche, o dejar que el viento nos regale unas buenas medidas del polvo.",
		"op": [
			{"txt": "Reforzar las antenas",
			 "res": "DAID pasa la noche subido a la antena. Mañana el escáner llegará más lejos.",
			 "conf": {"DAID": 1},
			 "efecto": {"k": "escaner", "v": 0.10, "txt": "Antenas reforzadas: el escáner llega un 10 % más lejos."}},
			{"txt": "Medir el polvo",
			 "res": "La estación anota cómo se levanta la tormenta. Son datos muy buenos.",
			 "datos": 2},
		]},
	"fuga_almacen": {
		"jefe": "KELLY", "min": 2, "titulo": "FUGA EN EL ALMACÉN", "min_muestras": 2,
		"texto": "Una junta del almacén pierde presión y las muestras se están estropeando. Puedo parar todo y repararla ahora, o salvar lo que se pueda y seguir.",
		"op": [
			{"txt": "Parar y reparar",
			 "res": "Se repara a tiempo. Sales con prisa y el robot tendrá que correr un poco.",
			 "conf": {"KELLY": 1},
			 "efecto": {"k": "consumo", "v": 0.05, "txt": "Salida con prisa: el robot gasta un 5 % más de batería."}},
			{"txt": "Salvar lo que se pueda",
			 "res": "Se pierden algunas muestras, pero no se retrasa nada.",
			 "muestras": -2, "conf": {"KELLY": -1}},
		]},
	"pieza_reyzer": {
		"jefe": "REYZER", "min": 1, "titulo": "UNA PIEZA DE REPUESTO",
		"texto": "He rescatado una pieza de un rover viejo y solo me da para un arreglo. ¿La monto en las ruedas o en el compartimento de la carga?",
		"op": [
			{"txt": "En las ruedas",
			 "res": "El robot rueda con menos esfuerzo en la próxima misión.",
			 "conf": {"REYZER": 1},
			 "efecto": {"k": "consumo", "v": -0.10, "txt": "Ruedas nuevas: el robot gasta un 10 % menos de batería."}},
			{"txt": "En la carga",
			 "res": "Cabe una muestra más en el robot durante la próxima misión.",
			 "conf": {"REYZER": 1},
			 "efecto": {"k": "carga", "v": 1, "txt": "Compartimento ampliado: cabe una muestra más."}},
		]},
	"senal_extrana": {
		"jefe": "GERALD", "min": 2, "titulo": "UNA SEÑAL EXTRAÑA",
		"texto": "Hemos captado una señal rara desde la órbita. Seguramente es ruido, pero estudiarla nos quitaría una noche de descanso.",
		"op": [
			{"txt": "Analizarla",
			 "res": "Era una reflexión del satélite sobre una capa de hielo. Una rareza útil para la ciencia.",
			 "conf": {"GERALD": 1}, "datos": 3},
			{"txt": "Ignorarla y descansar",
			 "res": "El equipo duerme bien. DAID agradece no tener que filtrar más señales.",
			 "conf": {"DAID": 1}},
		]},
	"entrevista": {
		"jefe": "KELLY", "min": 2, "titulo": "UNA ENTREVISTA",
		"texto": "Una televisión quiere hablar con el piloto del robot. Sería buena publicidad para el programa, pero te quitaría tiempo de preparación.",
		"op": [
			{"txt": "Aceptar la entrevista",
			 "res": "Hablas del robot y del programa. Llegan fondos extra para ciencia.",
			 "conf": {"KELLY": 1}, "datos": 2},
			{"txt": "Prepararte para la próxima misión",
			 "res": "Revisas el mapa y los instrumentos con calma. Mañana verás un poco más lejos.",
			 "efecto": {"k": "escaner", "v": 0.05, "txt": "Preparación extra: el escáner llega un 5 % más lejos."}},
		]},
	"kit_julio": {
		"jefe": "JULIO", "min": 2, "titulo": "EL KIT DE JULIO",
		"texto": "He preparado un kit de perforación mejorado. Pesa más, pero permite llevar una muestra extra. ¿Lo llevamos o preferimos ir ligeros?",
		"op": [
			{"txt": "Llevar el kit",
			 "res": "El robot va más cargado: cabe una muestra más, pero gasta algo más.",
			 "conf": {"JULIO": 1},
			 "efecto": {"k": "carga", "v": 1, "txt": "Kit de perforación: cabe una muestra más (y pesa un poco más)."}},
			{"txt": "Ir ligeros",
			 "res": "JULIO guarda el kit sin una queja, aunque pone mala cara.",
			 "conf": {"JULIO": -1},
			 "efecto": {"k": "consumo", "v": -0.05, "txt": "Robot ligero: gasta un 5 % menos de batería."}},
		]},
	"camaras_polvo": {
		"jefe": "GERALD", "min": 3, "titulo": "CÁMARAS CON POLVO",
		"texto": "Las cámaras del robot están llenas de polvo fino. Limpiarlas lleva tiempo, pero se vería todo mucho mejor.",
		"op": [
			{"txt": "Limpiarlas con cuidado",
			 "res": "Las lentes quedan como nuevas. Se ve más lejos.",
			 "efecto": {"k": "escaner", "v": 0.10, "txt": "Cámaras limpias: el escáner llega un 10 % más lejos."}},
			{"txt": "Seguir así",
			 "res": "El polvo en las lentes forma unas imágenes curiosas. Las guardas como datos.",
			 "datos": 1},
		]},
	"archivo_sin_firmar": {
		"jefe": "GERALD", "min": 4, "titulo": "ARCHIVO SIN FIRMAR",
		"texto": "He encontrado un archivo antiguo, sin firma, que habla de una zona con agua. Puede ser un error o una pista de verdad.",
		"op": [
			{"txt": "Estudiarlo",
			 "res": "Hay algo de cierto. JULIO se anima mucho con los datos.",
			 "conf": {"JULIO": 1}, "datos": 3},
			{"txt": "Archivarlo",
			 "res": "KELLY prefiere trabajar con datos firmados. Lo guarda por si acaso.",
			 "conf": {"KELLY": 1}},
		]},
	"cumple_daid": {
		"jefe": "DAID", "min": 2, "titulo": "EL CUMPLEAÑOS DE DAID",
		"texto": "Hoy es mi cumpleaños y el equipo ha preparado una pausa con tarta liofilizada. No es obligatorio venir, piloto, pero me haría ilusión.",
		"op": [
			{"txt": "Unirte a la pausa",
			 "res": "Una tarta que sabe a cartón y una gran noche. DAID no lo olvidará.",
			 "conf": {"DAID": 2}},
			{"txt": "Seguir con los datos",
			 "res": "Avanzas con el trabajo, aunque DAID se queda un poco triste.",
			 "datos": 2, "conf": {"DAID": -1}},
		]},
	"visita_comite": {
		"jefe": "KELLY", "min": 3, "titulo": "VISITA DEL COMITÉ", "min_muestras": 1,
		"texto": "El comité visita la base y quiere ver resultados. Podemos enseñarles una muestra de verdad, o presentar solo el informe.",
		"op": [
			{"txt": "Enseñar una muestra",
			 "res": "La muestra se queda en el comité, pero les impresiona mucho.",
			 "muestras": -1, "conf": {"KELLY": 1}, "datos": 2},
			{"txt": "Presentar solo el informe",
			 "res": "Un informe limpio y serio. GERALD lo agradece.",
			 "conf": {"GERALD": 1}},
		]},
	"noche_fria": {
		"jefe": "JULIO", "min": 1, "titulo": "NOCHE MUY FRÍA",
		"texto": "Esta noche bajaremos de -100 grados. El hielo del almacén puede congelarse del todo si no calentamos la sala.",
		"op": [
			{"txt": "Calentar la sala",
			 "res": "La sala se mantiene a salvo, pero la batería de reserva queda algo baja.",
			 "conf": {"JULIO": 1},
			 "efecto": {"k": "consumo", "v": 0.05, "txt": "Reserva baja: el robot gasta un 5 % más de batería."}},
			{"txt": "Dejar que se congele",
			 "res": "Los cristales de hielo formados son muy bonitos. Los fotografías para el archivo.",
			 "datos": 1},
		]},
}


static func _vistos() -> Array:
	var v: Variant = MetaEstado.extra_get(CLAVE_VISTOS, [])
	return v if v is Array else []


static func posible(id: String) -> bool:
	if not EVENTOS.has(id) or _vistos().has(id):
		return false
	var ev: Dictionary = EVENTOS[id]
	if Ajustes.campana < int(ev.get("min", 0)):
		return false
	if MetaEstado.stock_total() < int(ev.get("min_muestras", 0)):
		return false
	return true


static func sorteo(siempre: bool = false, semilla: int = -1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	if semilla >= 0:
		rng.seed = semilla
	else:
		rng.randomize()
	if not siempre and rng.randf() > PROBABILIDAD:
		return {}
	var candidatos: Array[String] = []
	for id in EVENTOS:
		if posible(str(id)):
			candidatos.append(str(id))
	if candidatos.is_empty():
		return {}
	var id := candidatos[rng.randi() % candidatos.size()]
	var vistos := _vistos().duplicate()
	vistos.append(id)
	MetaEstado.extra_set(CLAVE_VISTOS, vistos)
	var ev: Dictionary = (EVENTOS[id] as Dictionary).duplicate(true)
	ev["id"] = id
	return ev


static func aplicar(ev: Dictionary, i: int) -> Array[String]:
	var l: Array[String] = []
	var ops: Array = ev.get("op", [])
	if i < 0 or i >= ops.size():
		return l
	var o: Dictionary = ops[i]
	var d := int(o.get("datos", 0))
	if d > 0:
		MetaEstado.sumar_datos(d)
		l.append("+%d datos de ciencia" % d)
	var m := int(o.get("muestras", 0))
	if m < 0:
		var q := MetaEstado.perder_muestras(-m)
		if q > 0:
			l.append("-%d muestras del almacén" % q)
	var conf: Dictionary = o.get("conf", {})
	for j in conf:
		var delta := int(conf[j])
		HistoriaEstado.cambiar_conf(str(j), delta)
		l.append("%s: confianza %s%d" % [str(j), "+" if delta > 0 else "", delta])
	var ef: Dictionary = o.get("efecto", {})
	if not ef.is_empty():
		var e := ef.duplicate()
		e["de"] = str(ev.get("id", ""))
		HistoriaEstado.agregar_efecto(e)
		l.append("Próxima misión: %s" % str(ef.get("txt", "")))
	return l


static func crear_tarjeta(ev: Dictionary) -> CanvasLayer:
	var t := Tarjeta.new()
	t.ev = ev
	t.aplicador = aplicar
	return t


class Tarjeta extends CanvasLayer:
	signal cerrada
	var ev: Dictionary = {}
	var aplicador: Callable
	var _caja: VBoxContainer
	var _botones: Array[Button] = []

	func _ready() -> void:
		layer = 60
		process_mode = Node.PROCESS_MODE_ALWAYS
		var fondo := ColorRect.new()
		fondo.color = Color(0, 0, 0, 0.62)
		fondo.mouse_filter = Control.MOUSE_FILTER_STOP
		fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(fondo)
		var centro := CenterContainer.new()
		centro.set_anchors_preset(Control.PRESET_FULL_RECT)
		fondo.add_child(centro)
		var j: Dictionary = Historia.jefe(str(ev.get("jefe", "")))
		var col: Color = j.get("color", EstiloUI.COL_ACENTO)
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", EstiloUI.panel(col, 26.0))
		panel.custom_minimum_size = Vector2(760, 0)
		centro.add_child(panel)
		_caja = VBoxContainer.new()
		_caja.add_theme_constant_override("separation", 12)
		panel.add_child(_caja)
		_pintar_pregunta(col)

	func _limpiar() -> void:
		for c in _caja.get_children():
			c.queue_free()
		_botones.clear()

	func _cabecera(col: Color) -> void:
		var nombre := str(ev.get("jefe", ""))
		var sup := EstiloUI.etiqueta("EVENTO  ·  %s" % Historia.titulo(nombre), 15, col, true)
		_caja.add_child(sup)
		_caja.add_child(EstiloUI.etiqueta(str(ev.get("titulo", "")), 30, EstiloUI.COL_TEXTO, true))
		_caja.add_child(EstiloUI.linea())

	func _parrafo(txt: String, col: Color = EstiloUI.COL_TEXTO, tam: int = 20) -> Label:
		var l := EstiloUI.etiqueta(txt, tam, col)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(700, 0)
		_caja.add_child(l)
		return l

	func _pintar_pregunta(col: Color) -> void:
		_limpiar()
		_cabecera(col)
		_parrafo(str(ev.get("texto", "")))
		var sep := Control.new()
		sep.custom_minimum_size = Vector2(0, 6)
		_caja.add_child(sep)
		var ops: Array = ev.get("op", [])
		for i in ops.size():
			var b := EstiloUI.boton(str((ops[i] as Dictionary).get("txt", "")), 20)
			b.pressed.connect(_elegir.bind(i, col))
			_caja.add_child(b)
			_botones.append(b)
		if not _botones.is_empty():
			_botones[0].call_deferred("grab_focus")

	func _elegir(i: int, col: Color) -> void:
		var lineas: Array = aplicador.call(ev, i)
		var o: Dictionary = (ev.get("op", []) as Array)[i]
		_limpiar()
		_cabecera(col)
		_parrafo(str(o.get("txt", "")).to_upper(), col, 16)
		_parrafo(str(o.get("res", "")))
		for s in lineas:
			_parrafo("·  " + str(s), EstiloUI.COL_OK if not str(s).begins_with("-") else EstiloUI.COL_AVISO, 17)
		var sep := Control.new()
		sep.custom_minimum_size = Vector2(0, 8)
		_caja.add_child(sep)
		var b := EstiloUI.boton("CONTINUAR", 22)
		b.pressed.connect(_cerrar)
		_caja.add_child(b)
		b.call_deferred("grab_focus")

	func _cerrar() -> void:
		cerrada.emit()
		queue_free()

	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey or event is InputEventJoypadButton:
			get_viewport().set_input_as_handled()
