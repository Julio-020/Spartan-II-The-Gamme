extends SubViewport


signal guardada(ruta: String)

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const RutaMapa := preload("res://interfaz/ruta_mapa.gd")

const ANCHO := 1200
const ALTO := 630
const Partidas := preload("res://nucleo/partidas.gd")

var datos: Dictionary = {}


func configurar(d: Dictionary) -> void:
	datos = d


func _ready() -> void:
	size = Vector2i(ANCHO, ALTO)
	transparent_bg = false
	render_target_update_mode = SubViewport.UPDATE_ONCE
	_construir()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(Partidas.subcarpeta("tarjetas")))
	var f := Time.get_datetime_dict_from_system()
	var ruta := "%s/%s_%04d%02d%02d_%02d%02d%02d.png" % [Partidas.subcarpeta("tarjetas"), str(datos.get("id", "mision")),
			f["year"], f["month"], f["day"], f["hour"], f["minute"], f["second"]]
	var ok := img.save_png(ruta)
	guardada.emit(ruta if ok == OK else "")
	queue_free()


func _poner(texto: String, pos: Vector2, tam: int, color: Color = EstiloUI.COL_TEXTO, titulo: bool = true, ancho: float = 0.0) -> Label:
	var l := EstiloUI.etiqueta(texto, tam, color, titulo)
	l.position = pos
	if ancho > 0.0:
		l.custom_minimum_size = Vector2(ancho, 0.0)
		l.size = Vector2(ancho, 0.0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$Raiz.add_child(l)
	return l


func _construir() -> void:
	var raiz := Control.new()
	raiz.name = "Raiz"
	raiz.size = Vector2(ANCHO, ALTO)
	add_child(raiz)
	var fondo := Fondo.new()
	fondo.size = Vector2(ANCHO, ALTO)
	fondo.semilla = str(datos.get("id", "")).hash()
	raiz.add_child(fondo)


	_poner("SPARTANS II  ·  PROGRAMA DE EXPLORACIÓN DE MARTE", Vector2(40.0, 26.0), 16, EstiloUI.COL_TENUE)
	_poner(str(datos.get("nombre", "MARTE")).to_upper(), Vector2(40.0, 50.0), 52, EstiloUI.COL_ACENTO)
	var sub := "%s  ·  %s" % [str(datos.get("era", "")), str(datos.get("nave", ""))]
	_poner(sub, Vector2(40.0, 116.0), 26, EstiloUI.COL_TEXTO)
	var titulo_fin := "INVESTIGACIÓN COMPLETADA" if bool(datos.get("restos", false)) else "MISIÓN COMPLETADA"
	_poner(titulo_fin, Vector2(ANCHO - 440.0, 30.0), 22, EstiloUI.COL_OK).size = Vector2(400.0, 30.0)


	var marco := PanelContainer.new()
	marco.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_FRIO, 10.0))
	marco.position = Vector2(40.0, 170.0)
	marco.size = Vector2(560.0, 400.0)
	raiz.add_child(marco)
	var mapa := RutaMapa.new()
	mapa.custom_minimum_size = Vector2(540.0, 380.0)
	marco.add_child(mapa)
	mapa.poner(datos.get("ruta", []), datos.get("eventos_ruta", []), float(datos.get("dist_base", 300.0)), bool(datos.get("restos", false)))
	mapa.progreso = 1.0


	var x := 650.0
	_poner("PILOTO", Vector2(x, 160.0), 14, EstiloUI.COL_FRIO)
	_poner(str(datos.get("piloto", "Piloto")), Vector2(x, 178.0), 36, EstiloUI.COL_TEXTO)
	_poner(str(datos.get("rango", "")), Vector2(x, 224.0), 24 if str(datos.get("rango", "")).length() <= 24 else 17, EstiloUI.COL_ACENTO)
	var dif: String = ["FÁCIL", "NORMAL", "DIFÍCIL"][clampi(int(datos.get("dificultad", 1)), 0, 2)]
	_poner("DIFICULTAD  " + dif, Vector2(x + 300.0, 230.0), 16, EstiloUI.COL_TENUE)


	var ef := float(datos.get("eficiencia", 0.0))
	var bat := float(datos.get("energia_min", -1.0))
	var cifras := [
		["TIEMPO", str(datos.get("tiempo", "0:00"))],
		["RECORRIDO", "%.1f km" % float(datos.get("km", 0.0))],
		["RUTA DIRECTA", "%d %%" % int(round(ef * 100.0))],
		["MUESTRAS", str(int(datos.get("muestras", 0)))],
		["BATERÍA MÍNIMA", ("%d %%" % int(round(bat))) if bat >= 0.0 else "—"],
		["SUCESOS", str(int(datos.get("eventos", 0)))],
	]
	for i in range(cifras.size()):
		var cx := x + float(i % 3) * 180.0
		var cy := 275.0 + float(i / 3) * 78.0
		_poner(str(cifras[i][0]), Vector2(cx, cy), 13, EstiloUI.COL_TENUE)
		_poner(str(cifras[i][1]), Vector2(cx, cy + 18.0), 32, EstiloUI.COL_TEXTO)


	_poner("MEDALLAS", Vector2(x, 435.0), 14, EstiloUI.COL_FRIO)
	var meds: Array = datos.get("medallas", [])
	if meds.is_empty():
		_poner("Sin medallas esta vez. ¡Prueba otra vez!", Vector2(x, 458.0), 20, EstiloUI.COL_TENUE, false)
	else:
		var flujo := HFlowContainer.new()
		flujo.position = Vector2(x, 458.0)
		flujo.size = Vector2(510.0, 70.0)
		flujo.add_theme_constant_override("h_separation", 8)
		flujo.add_theme_constant_override("v_separation", 8)
		raiz.add_child(flujo)
		for m in meds:
			var c := PanelContainer.new()
			var sb := EstiloUI.panel(m["c"], 6.0)
			c.add_theme_stylebox_override("panel", sb)
			c.add_child(EstiloUI.etiqueta(str(m["n"]), 18, m["c"], true))
			flujo.add_child(c)


	var com := str(datos.get("comite", ""))
	if com != "":
		_poner(com, Vector2(x, 542.0), 15, EstiloUI.COL_TEXTO, false, 510.0)
	if datos.has("pistas"):
		_poner("PISTAS %d / %d   ·   CONFIANZA CON EL EQUIPO %+.1f" % [int(datos["pistas"]), int(datos.get("pistas_total", 8)), float(datos.get("confianza", 0.0))],
				Vector2(x, 596.0), 15, EstiloUI.COL_FRIO, false, 560.0)
	var f := Time.get_date_dict_from_system()
	_poner("%02d/%02d/%04d" % [f["day"], f["month"], f["year"]], Vector2(40.0, 590.0), 16, EstiloUI.COL_TENUE)
	_poner("SPARTANS II", Vector2(ANCHO - 200.0, 584.0), 24, EstiloUI.COL_ACENTO)


class Fondo extends Control:
	var semilla: int = 0

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0, 0, w, h), Color(0.045, 0.032, 0.035))
		for i in range(8):
			var f := float(i) / 8.0
			draw_rect(Rect2(0, h * f, w, h / 8.0 + 1.0), Color(0.16, 0.06, 0.04, 0.35 * f))
		var rng := RandomNumberGenerator.new()
		rng.seed = semilla
		for i in range(90):
			var p := Vector2(rng.randf() * w, rng.randf() * h * 0.7)
			draw_circle(p, rng.randf_range(0.6, 1.6), Color(1, 1, 1, rng.randf_range(0.15, 0.6)))
		draw_circle(Vector2(w - 60.0, h + 220.0), 420.0, Color(0.55, 0.2, 0.1, 0.55))
		draw_circle(Vector2(w - 60.0, h + 220.0), 400.0, Color(0.72, 0.3, 0.16, 0.5))
		draw_rect(Rect2(0, 0, w, 6.0), Color(0.99, 0.24, 0.13))
