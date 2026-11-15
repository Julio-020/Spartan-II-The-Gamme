extends CanvasLayer


signal cerrada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const Rutas := preload("res://progreso/rutas.gd")
const RutaMapa := preload("res://interfaz/ruta_mapa.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Hallazgos := preload("res://progreso/hallazgos.gd")
const Comite := preload("res://historia/comite.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const COL_DORADO := Color(1.0, 0.82, 0.25)
const COL_COLONIA := Color(0.78, 0.58, 1.0)

const COL_OK := Color(0.35, 1.0, 0.5)
const COL_MAL := Color(1.0, 0.33, 0.33)
const COL_PEND := Color(0.62, 0.6, 0.6)
const COL_ACENTO := Color(0.99, 0.24, 0.13)

var _raiz: Control
var _mapa: Control
var _lbl_nombre: Label
var _lbl_nave: Label
var _lbl_estado: Label
var _lbl_texto: Label
var _ruta: Control
var _lbl_datos: Label
var _lbl_aviso: Label
var _lbl_total: Label
var _sel: int = 0
var _modo_camp: bool = false
var _ley_rutas: Control
var _ley_camp: Control
var _b_modo: Button
var _tw: Tween


func _ready() -> void:
	layer = 40
	add_to_group("modal")
	_construir()
	_seleccionar(0)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			_seleccionar((_sel + 1) % DatosMarte.MISIONES.size())
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT or event.keycode == KEY_A:
			_seleccionar((_sel - 1 + DatosMarte.MISIONES.size()) % DatosMarte.MISIONES.size())
			get_viewport().set_input_as_handled()


func _cerrar() -> void:
	cerrada.emit()
	queue_free()


func _construir() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_raiz)

	var fondo := ColorRect.new()
	fondo.color = Color(0.03, 0.022, 0.022, 0.88)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.add_child(fondo)

	var tit := EstiloUI.etiqueta("MAPA DE RUTAS", 34, COL_ACENTO, true)
	tit.position = Vector2(56.0, 26.0)
	_raiz.add_child(tit)
	var sub := EstiloUI.etiqueta("Las rutas de Marte: las que funcionaron y las que no.", 18, EstiloUI.COL_TENUE)
	sub.position = Vector2(58.0, 72.0)
	_raiz.add_child(sub)
	_lbl_total = EstiloUI.etiqueta("", 18, EstiloUI.COL_TEXTO)
	_lbl_total.position = Vector2(560.0, 40.0)
	_lbl_total.size = Vector2(300.0, 30.0)
	_lbl_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_raiz.add_child(_lbl_total)


	_mapa = MapaMarte.new()
	_mapa.position = Vector2(56.0, 108.0)
	_mapa.size = Vector2(804.0, 402.0)
	_mapa.seleccionada.connect(_seleccionar)
	_raiz.add_child(_mapa)


	var ley := HBoxContainer.new()
	ley.position = Vector2(56.0, 520.0)
	ley.add_theme_constant_override("separation", 22)
	_raiz.add_child(ley)
	_ley_rutas = ley
	_ley_camp = HBoxContainer.new()
	_ley_camp.position = Vector2(56.0, 520.0)
	_ley_camp.add_theme_constant_override("separation", 16)
	_ley_camp.visible = false
	_raiz.add_child(_ley_camp)
	for e in [[COL_OK, "hecha"], [COL_ACENTO, "te la ofrece el comité"], [Color(0.4, 0.4, 0.45), "bloqueada"], [COL_DORADO, "hallazgos"],
			[COL_COLONIA, "base elegida"]]:
		var fc := HBoxContainer.new()
		fc.add_theme_constant_override("separation", 6)
		var pc := ColorRect.new()
		pc.color = e[0]
		pc.custom_minimum_size = Vector2(12.0, 12.0)
		pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fc.add_child(pc)
		fc.add_child(EstiloUI.etiqueta(e[1], 15, EstiloUI.COL_TENUE))
		_ley_camp.add_child(fc)
	for e in [[COL_OK, "ruta recorrida"], [COL_PEND, "sin recorrer"], [COL_MAL, "misión perdida (la investigas)"]]:
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 7)
		var p := ColorRect.new()
		p.color = e[0]
		p.custom_minimum_size = Vector2(12.0, 12.0)
		p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		f.add_child(p)
		f.add_child(EstiloUI.etiqueta(e[1], 16, EstiloUI.COL_TENUE))
		ley.add_child(f)
	var perdidas := EstiloUI.etiqueta("Perdidas en órbita, sin llegar al suelo: Mars Observer (1992) y Mars Climate Orbiter (1998).", 15, EstiloUI.COL_TENUE)
	perdidas.position = Vector2(56.0, 548.0)
	_raiz.add_child(perdidas)
	var nota := EstiloUI.etiqueta("Las rutas del mapa están ampliadas para verse: la real mide unos 30 km. Los lugares son aproximados.", 15, EstiloUI.COL_TENUE)
	nota.position = Vector2(56.0, 572.0)
	_raiz.add_child(nota)


	var caja := VBoxContainer.new()
	caja.position = Vector2(892.0, 108.0)
	caja.size = Vector2(340.0, 580.0)
	caja.add_theme_constant_override("separation", 6)
	_raiz.add_child(caja)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	var b_ant := EstiloUI.boton("◀", 20)
	b_ant.custom_minimum_size = Vector2(52.0, 42.0)
	b_ant.pressed.connect(func(): _seleccionar((_sel - 1 + DatosMarte.MISIONES.size()) % DatosMarte.MISIONES.size()))
	nav.add_child(b_ant)
	var b_sig := EstiloUI.boton("▶", 20)
	b_sig.custom_minimum_size = Vector2(52.0, 42.0)
	b_sig.pressed.connect(func(): _seleccionar((_sel + 1) % DatosMarte.MISIONES.size()))
	nav.add_child(b_sig)
	_lbl_estado = EstiloUI.etiqueta("", 16, COL_OK, true)
	_lbl_estado.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nav.add_child(_lbl_estado)
	caja.add_child(nav)
	_lbl_nombre = EstiloUI.etiqueta("", 26, EstiloUI.COL_TEXTO, true)
	_lbl_nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caja.add_child(_lbl_nombre)
	_lbl_nave = EstiloUI.etiqueta("", 17, EstiloUI.COL_FRIO)
	caja.add_child(_lbl_nave)
	_ruta = RutaMapa.new()
	_ruta.custom_minimum_size = Vector2(340.0, 170.0)
	caja.add_child(_ruta)
	_lbl_datos = EstiloUI.etiqueta("", 15, EstiloUI.COL_TEXTO)
	_lbl_datos.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caja.add_child(_lbl_datos)
	_lbl_texto = EstiloUI.etiqueta("", 14, EstiloUI.COL_TENUE)
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.custom_minimum_size = Vector2(340.0, 0.0)
	caja.add_child(_lbl_texto)


	var fila := HBoxContainer.new()
	fila.position = Vector2(56.0, 614.0)
	fila.add_theme_constant_override("separation", 14)
	_raiz.add_child(fila)
	var b_exp := EstiloUI.boton("EXPORTAR RUTAS", 20)
	b_exp.custom_minimum_size = Vector2(250.0, 48.0)
	b_exp.pressed.connect(_exportar)
	fila.add_child(b_exp)
	var b_carp := EstiloUI.boton("ABRIR CARPETA", 20)
	b_carp.custom_minimum_size = Vector2(230.0, 48.0)
	b_carp.pressed.connect(func(): OS.shell_open(ProjectSettings.globalize_path("user://")))
	fila.add_child(b_carp)
	_b_modo = EstiloUI.boton("VER: CAMPAÑA", 20)
	_b_modo.custom_minimum_size = Vector2(220.0, 48.0)
	_b_modo.pressed.connect(_alternar_modo)
	fila.add_child(_b_modo)
	var b_volver := EstiloUI.boton("VOLVER", 20)
	b_volver.custom_minimum_size = Vector2(150.0, 48.0)
	b_volver.pressed.connect(_cerrar)
	fila.add_child(b_volver)
	_lbl_aviso = EstiloUI.etiqueta("", 15, EstiloUI.COL_OK)
	_lbl_aviso.position = Vector2(56.0, 672.0)
	_lbl_aviso.size = Vector2(800.0, 30.0)
	_raiz.add_child(_lbl_aviso)

	_lbl_total.text = _texto_total()


func _alternar_modo() -> void:
	_modo_camp = not _modo_camp
	_b_modo.text = "VER: RUTAS" if _modo_camp else "VER: CAMPAÑA"
	_ley_rutas.visible = not _modo_camp
	_ley_camp.visible = _modo_camp
	_mapa.set("estados", HistoriaEstado.progreso(DatosMarte.MISIONES, Ajustes.misiones_libres) if _modo_camp else [])
	_mapa.set("modo_campana", _modo_camp)
	_lbl_total.text = _texto_total()
	_seleccionar(_sel)


func _texto_total() -> String:
	if _modo_camp:
		return "%d / %d hechas  ·  ◆ %d / %d" % [HistoriaEstado.num_hechas(), DatosMarte.MISIONES.size(), MetaEstado.num_hallazgos(), Hallazgos.total()]
	var hechas := 0
	for m in DatosMarte.MISIONES:
		if not Rutas.obtener(str(m["id"])).is_empty():
			hechas += 1
	return "%d / %d recorridas" % [hechas, DatosMarte.MISIONES.size()]


func _exportar() -> void:
	var ruta := Rutas.exportar()
	if ruta == "":
		_lbl_aviso.add_theme_color_override("font_color", COL_MAL)
		_lbl_aviso.text = "No se pudo escribir el archivo."
	else:
		_lbl_aviso.add_theme_color_override("font_color", COL_OK)
		_lbl_aviso.text = "Exportado: %s" % ruta


func _seleccionar(i: int) -> void:
	_sel = clampi(i, 0, DatosMarte.MISIONES.size() - 1)
	var m: Dictionary = DatosMarte.MISIONES[_sel]
	var id := str(m["id"])
	var rec := Rutas.obtener(id)
	var fallida := Rutas.es_fallida(m)
	_mapa.set("seleccion", _sel)
	_lbl_nombre.text = str(m["nombre"])
	_lbl_nave.text = "%s · %s" % [str(m["era"]), str(m["nave"])]
	if rec.is_empty():
		_lbl_estado.text = "SIN RECORRER"
		_lbl_estado.add_theme_color_override("font_color", COL_PEND)
		_ruta.call("poner", [], [], float(m.get("dist", 300.0)), fallida)
		_lbl_datos.text = "Aún no has recorrido esta ruta. Desde el planeta, elige la misión y llega a la base B."
	else:
		_lbl_estado.text = "INVESTIGADA" if fallida else "COMPLETADA"
		_lbl_estado.add_theme_color_override("font_color", COL_OK)
		_ruta.call("poner", rec["ruta"], rec["eventos"], float(rec["directa"]), fallida)
		var seg: float = float(rec["tiempo"])
		_lbl_datos.text = "Recorriste %.1f km (línea recta: %.1f km)\nTiempo: %d:%02d  ·  Veces: %d" % [
				float(rec["distancia"]) / 10.0, float(rec["directa"]) / 10.0, int(seg) / 60, int(seg) % 60, int(rec.get("veces", 1))]
	if _modo_camp:
		_lbl_datos.text += "\n" + _linea_campana(m)
	if fallida:
		_lbl_texto.text = "Misión perdida. " + str(m.get("real", ""))
	else:
		_lbl_texto.text = str(m.get("real", ""))
	if _tw != null:
		_tw.kill()
	_ruta.set("progreso", 0.0)
	_tw = create_tween()
	_tw.tween_property(_ruta, "progreso", 1.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _linea_campana(m: Dictionary) -> String:
	var id := str(m["id"])
	var partes: Array[String] = []
	var est: Array = _mapa.get("estados")
	if _sel < est.size():
		var e: Dictionary = est[_sel]
		if bool(e["hecha"]):
			partes.append("Estado: hecha")
		elif bool(e["oferta"]):
			partes.append("Estado: el comité te la ofrece")
		else:
			partes.append("Estado: bloqueada · " + str(e.get("motivo", "")))
	var pr := Hallazgos.progreso_mision(id)
	if pr.y > 0:
		partes.append("Hallazgos escondidos: %d / %d" % [pr.x, pr.y])
	if id == Comite.elegida():
		partes.append("Aquí aterrizarán los primeros humanos.")
	return "\n".join(partes)


class MapaMarte extends Control:
	signal seleccionada(i: int)
	var seleccion: int = 0:
		set(v):
			seleccion = v
			queue_redraw()
	var modo_campana: bool = false:
		set(v):
			modo_campana = v
			queue_redraw()
	var estados: Array = []
	var _pos: Array[Vector2] = []
	var _real: Array[Vector2] = []
	var _hover: int = -1
	var _fuente: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		_fuente = EstiloUI.fuente_titulo()

	func _punto(lat: float, lon: float) -> Vector2:
		return Vector2((lon + 180.0) / 360.0 * size.x, (90.0 - lat) / 180.0 * size.y)

	func _calcular() -> void:
		_pos.clear()
		_real.clear()
		for m in DatosMarte.MISIONES:
			var ll := Rutas.lat_lon(m)
			var p := _punto(ll.x, ll.y)
			_real.append(p)

			var q := p
			for intento in range(6):
				var choca := false
				for o in _pos:
					if q.distance_to(o) < 17.0:
						choca = true
						q = o + Vector2(17.0, -9.0 if intento % 2 == 0 else 13.0)
						break
				if not choca:
					break
			_pos.append(q)

	func _gui_input(event: InputEvent) -> void:
		if _pos.size() != DatosMarte.MISIONES.size():
			_calcular()
		if event is InputEventMouseMotion:
			var h := _cercano((event as InputEventMouseMotion).position)
			if h != _hover:
				_hover = h
				queue_redraw()
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
				and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			var c := _cercano((event as InputEventMouseButton).position)
			if c >= 0:
				seleccionada.emit(c)

	func _cercano(p: Vector2) -> int:
		var mejor := -1
		var d_min := 16.0
		for i in range(_pos.size()):
			var d := p.distance_to(_pos[i])
			if d < d_min:
				d_min = d
				mejor = i
		return mejor

	func _elipse(c: Vector2, rx: float, ry: float, col: Color, rot: float = 0.0) -> void:
		var pts := PackedVector2Array()
		for i in range(33):
			var a := TAU * float(i) / 32.0
			var v := Vector2(cos(a) * rx, sin(a) * ry).rotated(rot)
			pts.append(c + v)
		draw_colored_polygon(pts, col)

	func _draw() -> void:
		if _pos.size() != DatosMarte.MISIONES.size():
			_calcular()
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0.0, 0.0, w, h), Color(0.11, 0.06, 0.05))

		draw_rect(Rect2(0.0, 0.0, w, h * 0.06), Color(0.91, 0.86, 0.82, 0.16))
		draw_rect(Rect2(0.0, h * 0.94, w, h * 0.06), Color(0.91, 0.86, 0.82, 0.16))
		_elipse(_punto(5.0, -105.0), w * 0.15, h * 0.25, Color(0.69, 0.38, 0.23, 0.30))
		_elipse(_punto(18.6, -133.8), w * 0.026, h * 0.05, Color(0.85, 0.54, 0.36, 0.38))
		_elipse(_punto(-42.4, 70.5), w * 0.052, h * 0.10, Color(0.1, 0.05, 0.04, 0.6))
		_elipse(_punto(-8.0, -60.0), w * 0.12, h * 0.022, Color(0.08, 0.04, 0.035, 0.7), 0.07)

		for lo in range(-180, 181, 30):
			var x := (float(lo) + 180.0) / 360.0 * w
			draw_line(Vector2(x, 0.0), Vector2(x, h), Color(1.0, 0.9, 0.8, 0.07), 1.0)
		for la in range(-90, 91, 30):
			var y := (90.0 - float(la)) / 180.0 * h
			draw_line(Vector2(0.0, y), Vector2(w, y), Color(1.0, 0.9, 0.8, 0.07), 1.0)
		draw_rect(Rect2(0.0, 0.0, w, h), Color(1.0, 1.0, 1.0, 0.16), false, 1.0)
		for t in [["OLYMPUS MONS", 38.0, -133.8], ["VALLES MARINERIS", -22.0, -62.0], ["HELLAS", -60.0, 70.5], ["THARSIS", 30.0, -95.0]]:
			var pt := _punto(t[1], t[2])
			draw_string(_fuente, pt + Vector2(-60.0, 0.0), t[0], HORIZONTAL_ALIGNMENT_CENTER, 120.0, 11, Color(1.0, 0.9, 0.8, 0.32))


		for i in range(_pos.size()):
			var m: Dictionary = DatosMarte.MISIONES[i]
			var rec := Rutas.obtener(str(m["id"]))
			var fallida := Rutas.es_fallida(m)
			var p := _pos[i]
			if p.distance_to(_real[i]) > 2.0:
				draw_line(_real[i], p, Color(1.0, 1.0, 1.0, 0.35), 1.0)
				draw_circle(_real[i], 2.0, Color(1.0, 1.0, 1.0, 0.6))
			if modo_campana and i < estados.size():
				_pin_campana(i, m, p, estados[i])
				if i == seleccion:
					draw_arc(p, 13.5, 0.0, TAU, 28, Color.WHITE, 2.0, true)
				_etiqueta_pin(i, m, p)
				continue
			var col := COL_OK if not fallida else Color(1.0, 0.72, 0.25)
			if rec.is_empty():
				col = COL_PEND

			if not rec.is_empty():
				var r: Array = rec["ruta"]
				if r.size() >= 2:
					var mx := 1.0
					for q in r:
						mx = maxf(mx, maxf(absf(float(q[0])), absf(float(q[1]))))
					var esc := 34.0 / mx
					var lado := -1.0 if p.x > w - 52.0 else 1.0
					var pts := PackedVector2Array()
					for q in r:
						pts.append(p + Vector2(float(q[0]) * lado, float(q[1])) * Vector2(esc, esc))
					draw_polyline(pts, Color(0.0, 0.0, 0.0, 0.5), 4.0, true)
					draw_polyline(pts, col, 2.0, true)
			if fallida:
				var cx := COL_MAL
				draw_line(p + Vector2(-6.0, -6.0), p + Vector2(6.0, 6.0), Color(0, 0, 0, 0.6), 6.0, true)
				draw_line(p + Vector2(-6.0, 6.0), p + Vector2(6.0, -6.0), Color(0, 0, 0, 0.6), 6.0, true)
				draw_line(p + Vector2(-6.0, -6.0), p + Vector2(6.0, 6.0), cx, 3.2, true)
				draw_line(p + Vector2(-6.0, 6.0), p + Vector2(6.0, -6.0), cx, 3.2, true)
				if not rec.is_empty():
					draw_arc(p, 10.5, 0.0, TAU, 20, COL_OK, 2.0, true)
			else:
				draw_circle(p, 7.0, Color(0.0, 0.0, 0.0, 0.6))
				draw_arc(p, 5.2, 0.0, TAU, 20, col, 3.0, true)
				if not rec.is_empty():
					draw_circle(p, 2.4, col)
			if i == seleccion:
				draw_arc(p, 13.5, 0.0, TAU, 28, Color.WHITE, 2.0, true)
			_etiqueta_pin(i, m, p)

	func _etiqueta_pin(i: int, m: Dictionary, p: Vector2) -> void:
		var w := size.x
		if i == seleccion or i == _hover:
			var txt := "%s %s" % [str(m["nombre"]), Idioma.t(str(m["era"]))]
			var ancho := _fuente.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13).x + 14.0
			var x0 := clampf(p.x - ancho * 0.5, 2.0, w - ancho - 2.0)
			var y0 := p.y - 36.0 if p.y > 40.0 else p.y + 16.0
			draw_rect(Rect2(x0, y0, ancho, 22.0), Color(0.04, 0.03, 0.03, 0.9))
			draw_rect(Rect2(x0, y0, ancho, 22.0), Color(1.0, 1.0, 1.0, 0.3), false, 1.0)
			draw_string(_fuente, Vector2(x0 + 7.0, y0 + 16.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color.WHITE)
		else:
			draw_string(_fuente, p + Vector2(-20.0, -12.0), Idioma.t(str(m["era"])), HORIZONTAL_ALIGNMENT_CENTER, 40.0, 10, Color(1.0, 0.95, 0.9, 0.6))


	func _pin_campana(_i: int, m: Dictionary, p: Vector2, e: Dictionary) -> void:
		var id := str(m["id"])
		var hecha := bool(e["hecha"])
		var oferta := bool(e["oferta"])
		var c := COL_OK if hecha else (COL_ACENTO if oferta else Color(0.42, 0.42, 0.48))
		draw_circle(p, 8.0, Color(0.0, 0.0, 0.0, 0.65))
		draw_arc(p, 5.6, 0.0, TAU, 20, c, 3.0, true)
		if hecha:
			draw_circle(p, 2.6, c)
		elif oferta:
			draw_arc(p, 11.0, 0.0, TAU, 24, c, 2.0, true)
		var pr := Hallazgos.progreso_mision(id)
		if pr.y > 0:
			var q := p + Vector2(10.0, -10.0)
			var rombo := PackedVector2Array([q + Vector2(0, -5), q + Vector2(5, 0), q + Vector2(0, 5), q + Vector2(-5, 0)])
			if pr.x >= pr.y:
				draw_colored_polygon(rombo, COL_DORADO)
			else:
				rombo.append(rombo[0])
				draw_polyline(rombo, COL_DORADO, 1.6, true)
				if pr.x > 0:
					draw_circle(q, 1.8, COL_DORADO)
		if id == Comite.elegida():
			var r := Rect2(p + Vector2(-6.0, 11.0), Vector2(12.0, 11.0))
			draw_rect(r, COL_COLONIA)
			draw_string(_fuente, p + Vector2(-4.0, 20.5), "C", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(0.1, 0.05, 0.15))
