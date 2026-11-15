extends CanvasLayer


signal cerrada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const Rutas := preload("res://progreso/rutas.gd")
const Logros := preload("res://progreso/logros.gd")
const Historia := preload("res://historia/historia.gd")
const HistoriaExtra := preload("res://historia/historia_extra.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Comite := preload("res://historia/comite.gd")
const InsigniaMedalla := preload("res://interfaz/insignia_medalla.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const Mejoras := preload("res://progreso/mejoras.gd")
const Colonia := preload("res://progreso/colonia_estado.gd")
const Laboratorio := preload("res://interfaz/laboratorio.gd")
const Hallazgos := preload("res://progreso/hallazgos.gd")
const Bitacora := preload("res://progreso/bitacora.gd")
const CartaFocos := preload("res://interfaz/carta_focos.gd")
const DronVoz := preload("res://dron/dron_voz.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const Recuerdos := preload("res://progreso/recuerdos.gd")
const Cuaderno := preload("res://progreso/cuaderno.gd")
const Novedades := preload("res://progreso/diario_novedades.gd")
const CuadernoDibujo := preload("res://interfaz/cuaderno_dibujo.gd")
const FotoArchivo := preload("res://mision/foto_archivo.gd")
const RelatosMarte := preload("res://datos/relatos_marte.gd")
const HudMision := preload("res://interfaz/hud_mision.gd")


var contexto: Dictionary = {}

var abrir_en: String = ""

var _grupos: Array = []
var _abiertas: Dictionary = {}
var _actual: int = 0
var _botones: Array = []
var _cuerpo: VBoxContainer
var _scroll: ScrollContainer


func _sec(id: String, nombre: String, fn: Callable, abierta: bool = false) -> Dictionary:
	return {"id": id, "nombre": nombre, "fn": fn, "abierta": abierta}


func _ready() -> void:
	layer = 40
	add_to_group("modal")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var en_mision := not contexto.is_empty()
	var hoy: Array = []
	if en_mision:
		hoy.append(_sec("mision", "ESTA MISIÓN", _tab_mision, true))
	hoy.append(_sec("misiones", "MISIONES", _tab_misiones, not en_mision))
	_grupos = [
		{"id": "hoy", "nombre": "HOY", "secs": hoy},
		{"id": "coleccion", "nombre": "COLECCIÓN", "secs": [
			_sec("medallas", "MEDALLAS Y RANGO", _tab_medallas),
			_sec("finales", "FINALES", _tab_finales), _sec("hallazgos", "HALLAZGOS", _tab_coleccion), _sec("cifras", "CIFRAS", _tab_cifras)]},
		{"id": "mejoras", "nombre": "MEJORAS", "secs": [
			_sec("taller", "TALLER Y TIENDA", _tab_taller), _sec("colonia", "COLONIA", _tab_colonia), _sec("equipo", "TU EQUIPO", _tab_equipo)]},
		{"id": "recuerdos", "nombre": "RECUERDOS", "secs": [
			_sec("recuerdos", "ÁLBUM DE MISIONES", _tab_recuerdos), _sec("bitacora", "BITÁCORA", _tab_bitacora)]},
	]
	_construir()
	var inicio := 0
	for i in range(_grupos.size()):
		if str(_grupos[i]["id"]) == abrir_en:
			inicio = i
		for sc: Dictionary in _grupos[i]["secs"]:
			if str(sc["id"]) == abrir_en:
				inicio = i
				_abiertas["%s/%s" % [str(_grupos[i]["id"]), abrir_en]] = true
	_mostrar(inicio)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k: int = event.keycode
	if k in [KEY_ESCAPE, KEY_J, KEY_TAB]:
		get_viewport().set_input_as_handled()
		_cerrar()
	elif k == KEY_RIGHT:
		get_viewport().set_input_as_handled()
		_mostrar((_actual + 1) % _grupos.size())
	elif k == KEY_LEFT:
		get_viewport().set_input_as_handled()
		_mostrar((_actual - 1 + _grupos.size()) % _grupos.size())
	elif k >= KEY_1 and k < KEY_1 + _grupos.size():
		get_viewport().set_input_as_handled()
		_mostrar(k - KEY_1)


func _cerrar() -> void:
	cerrada.emit()
	queue_free()


static func _tiempo(s: float) -> String:
	var t := int(s)
	return "%d:%02d" % [t / 60, t % 60]


func _construir() -> void:
	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(raiz)
	var fondo := ColorRect.new()
	fondo.color = Color(0.03, 0.022, 0.022, 0.96 if not contexto.is_empty() else 0.88)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(fondo)

	var tit := EstiloUI.etiqueta("DIARIO DEL PILOTO", 34, EstiloUI.COL_ACENTO, true)
	tit.position = Vector2(56.0, 18.0)
	raiz.add_child(tit)
	var prog := Logros.progreso(Ajustes.genero)
	var titulo_esp := HistoriaEstado.titulo_final(Ajustes.genero)
	var cab_txt := "%s  %s" % [str(prog["nombre"]), Ajustes.nombre_visible().to_upper()]
	if titulo_esp != "":
		cab_txt += "   ·   «%s»" % titulo_esp
	var cab := EstiloUI.etiqueta(cab_txt, 22, EstiloUI.COL_TEXTO, true)
	cab.position = Vector2(58.0, 62.0)
	raiz.add_child(cab)
	var pts := "%d puntos" % int(prog["puntos"])
	if str(prog["sig_nombre"]) != "":
		pts += "  ·  siguiente rango: %s (%d)" % [str(prog["sig_nombre"]), int(prog["sig_puntos"])]
	else:
		pts += "  ·  rango máximo"
	pts += "   ·   Misiones: %d / %d   ·   Medallas: %d" % [
		HistoriaEstado.num_hechas(), DatosMarte.MISIONES.size(), Logros.total_medallas()]
	var l_pts := EstiloUI.etiqueta(pts, 15, EstiloUI.COL_FRIO)
	l_pts.position = Vector2(58.0, 94.0)
	raiz.add_child(l_pts)


	var barra := HBoxContainer.new()
	barra.position = Vector2(56.0, 122.0)
	barra.add_theme_constant_override("separation", 8)
	barra.custom_minimum_size = Vector2(1168.0, 46.0)
	barra.size = Vector2(1168.0, 46.0)
	raiz.add_child(barra)
	for i in range(_grupos.size()):
		var b := EstiloUI.boton(str(_grupos[i]["nombre"]), 20)
		b.custom_minimum_size = Vector2(0.0, 46.0)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.pressed.connect(_mostrar.bind(i))
		barra.add_child(b)
		_botones.append(b)


	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(56.0, 180.0)
	_scroll.size = Vector2(1168.0, 452.0)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	raiz.add_child(_scroll)
	_cuerpo = VBoxContainer.new()
	_cuerpo.custom_minimum_size = Vector2(1140.0, 0.0)
	_cuerpo.add_theme_constant_override("separation", 8)
	_scroll.add_child(_cuerpo)

	var b := EstiloUI.boton("VOLVER A LA MISIÓN" if not contexto.is_empty() else "VOLVER", 20)
	b.position = Vector2(56.0, 646.0)
	b.custom_minimum_size = Vector2(300.0, 48.0)
	b.pressed.connect(_cerrar)
	raiz.add_child(b)
	var ayuda := EstiloUI.etiqueta("←  →  o  1 - 4  cambiar de sección     ·     J / TAB / ESC  cerrar", 14, EstiloUI.COL_TENUE)
	ayuda.position = Vector2(400.0, 660.0)
	raiz.add_child(ayuda)


func _refrescar() -> void:
	_mostrar(_actual, true)


func _ir(id: String) -> void:
	for i in range(_grupos.size()):
		if str(_grupos[i]["id"]) == id:
			_mostrar(i)
			return


func _grupo_nuevo(g: Dictionary) -> bool:
	for sc: Dictionary in g["secs"]:
		if Novedades.nuevo(str(sc["id"])):
			return true
	return false


func _marcar_botones() -> void:
	for n in range(_botones.size()):
		var b: Button = _botones[n]
		var nuevo := _grupo_nuevo(_grupos[n])
		b.text = ("● " if nuevo else "") + tr(str(_grupos[n]["nombre"]))
		b.modulate = Color(1, 1, 1, 1) if n == _actual else Color(1, 1, 1, 0.6)
		b.add_theme_color_override("font_color", EstiloUI.COL_ACENTO if n == _actual else EstiloUI.COL_TEXTO)
		if nuevo:
			b.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
			b.modulate = Color(1, 1, 1, 1)


func _mostrar(i: int, conservar: bool = false) -> void:
	_actual = i
	var y := _scroll.scroll_vertical
	for c in _cuerpo.get_children():
		c.queue_free()
	var g: Dictionary = _grupos[i]
	if str(g["id"]) == "hoy":
		_tarjeta_ahora()
	for sc: Dictionary in g["secs"]:
		_anadir_seccion(str(g["id"]), sc)
	_marcar_botones()
	_scroll.scroll_vertical = y if conservar else 0


func _resumen(id: String) -> String:
	match id:
		"misiones":
			return "%d / %d" % [HistoriaEstado.num_hechas(), DatosMarte.MISIONES.size()]
		"medallas":
			return tr("%d medallas") % Logros.total_medallas()
		"finales":
			return "%d / 3" % HistoriaEstado.finales_vistos().size()
		"hallazgos":
			return "%d / %d" % [MetaEstado.num_hallazgos(), Hallazgos.total()]
		"taller":
			return tr("%d datos") % MetaEstado.datos()
		"bitacora":
			return tr("%d entradas") % Bitacora.num()
		"recuerdos":
			return tr("%d páginas") % Cuaderno.paginas().size()
	return ""


func _texto_cab(sc: Dictionary, abierta: bool, nuevo: bool) -> String:
	var t := ("−   " if abierta else "+   ") + tr(str(sc["nombre"]))
	if nuevo:
		t += "   ● " + tr("NUEVO")
	var r := _resumen(str(sc["id"]))
	if r != "":
		t += "        " + r
	return t


func _anadir_seccion(gid: String, sc: Dictionary) -> void:
	var sid := str(sc["id"])
	var clave := "%s/%s" % [gid, sid]
	var nuevo := Novedades.nuevo(sid)
	var abierta: bool = _abiertas.get(clave, bool(sc["abierta"]) or nuevo)
	_abiertas[clave] = abierta
	var cab := EstiloUI.boton(_texto_cab(sc, abierta, nuevo), 18)
	cab.custom_minimum_size = Vector2(1140.0, 44.0)
	cab.alignment = HORIZONTAL_ALIGNMENT_LEFT
	cab.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3) if nuevo else EstiloUI.COL_TEXTO)
	var cuerpo := VBoxContainer.new()
	cuerpo.add_theme_constant_override("separation", 8)
	cuerpo.visible = abierta
	var estado := {"hecho": false}
	var llenar := func() -> void:
		if estado["hecho"]:
			return
		estado["hecho"] = true
		var guardado := _cuerpo
		_cuerpo = cuerpo
		(sc["fn"] as Callable).call()
		_cuerpo = guardado
	cab.pressed.connect(func() -> void:
		var ab := not cuerpo.visible
		if ab:
			llenar.call()
			Novedades.visto(sid)
		cuerpo.visible = ab
		_abiertas[clave] = ab
		cab.text = _texto_cab(sc, ab, false)
		cab.add_theme_color_override("font_color", EstiloUI.COL_TEXTO)
		_marcar_botones())
	_cuerpo.add_child(cab)
	_cuerpo.add_child(cuerpo)
	if abierta:
		llenar.call()
		Novedades.visto(sid)


func _tarjeta_ahora() -> void:
	var msg := ""
	var txt_b := "CERRAR"
	var destino := ""
	if not contexto.is_empty():
		var total := int(contexto.get("total", 0))
		msg = "Sigues en misión: %d de %d muestras entregadas." % [int(contexto.get("entregados", 0)), total] if total > 0 else "Sigue la ruta hasta el destino."
		txt_b = "VOLVER A LA MISIÓN"
	elif Novedades.nuevo("recuerdos") or Novedades.nuevo("bitacora"):
		msg = "Tienes un recuerdo nuevo en tu álbum."
		txt_b = "VER RECUERDOS"
		destino = "recuerdos"
	elif Novedades.hay_compra():
		msg = "Tienes datos para mejorar el robot o tu base."
		txt_b = "IR A MEJORAS"
		destino = "mejoras"
	else:
		var est: Array = HistoriaEstado.progreso(DatosMarte.MISIONES, Ajustes.misiones_libres)
		msg = "Elige tu próxima misión en el mapa."
		for n in range(DatosMarte.MISIONES.size()):
			if est[n]["oferta"] and Rutas.obtener(str(DatosMarte.MISIONES[n]["id"])).is_empty():
				msg = "Siguiente misión: %s (%s). Elígela en el mapa." % [str(DatosMarte.MISIONES[n]["nombre"]), str(DatosMarte.MISIONES[n]["era"])]
				break
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 20)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(EstiloUI.etiqueta("QUÉ HAGO AHORA", 14, Color(1.0, 0.8, 0.3), true))
	v.add_child(_texto(msg, 19, EstiloUI.COL_TEXTO, 760.0))
	h.add_child(v)
	var b := EstiloUI.boton(txt_b, 18)
	b.custom_minimum_size = Vector2(300.0, 48.0)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(_cerrar if destino == "" else _ir.bind(destino))
	h.add_child(b)
	_cuerpo.add_child(_tarjeta(h, Color(EstiloUI.COL_ACENTO.r, EstiloUI.COL_ACENTO.g, EstiloUI.COL_ACENTO.b, 0.14)))


func _texto(t: String, tam: int = 16, col: Color = EstiloUI.COL_TEXTO, ancho: float = 1100.0) -> Label:
	var l := EstiloUI.etiqueta(t, tam, col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(ancho, 0.0)
	return l


func _tarjeta(contenido: Control, color: Color = Color(1, 1, 1, 0.05)) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.caja(color, 4.0))
	p.add_child(contenido)
	return p


func _seccion(t: String) -> void:
	_cuerpo.add_child(EstiloUI.etiqueta(t, 20, EstiloUI.COL_ACENTO, true))


func _fila_dato(clave: String, valor: String, col: Color = EstiloUI.COL_TEXTO) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	var k := EstiloUI.etiqueta(clave, 15, EstiloUI.COL_TENUE)
	k.custom_minimum_size = Vector2(260.0, 0.0)
	h.add_child(k)
	var v := _texto(valor, 16, col, 820.0)
	h.add_child(v)
	return h


func _tab_mision() -> void:
	var c := contexto
	_seccion(str(c.get("nombre", "")).to_upper())
	var total := int(c.get("total", 0))
	var ent := int(c.get("entregados", 0))
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	var barra := EstiloUI.barra(EstiloUI.COL_OK, 14.0)
	barra.min_value = 0.0
	barra.max_value = maxf(1.0, float(total))
	barra.value = float(ent)
	barra.custom_minimum_size = Vector2(1000.0, 14.0)
	if total > 0:
		caja.add_child(EstiloUI.etiqueta("Muestras entregadas: %d de %d" % [ent, total], 18, EstiloUI.COL_TEXTO, true))
		caja.add_child(barra)
	else:
		caja.add_child(EstiloUI.etiqueta("Esta misión no se mide en muestras: sigue la ruta hasta el destino.", 16, EstiloUI.COL_TEXTO))
	caja.add_child(_fila_dato("En la bodega del robot", str(int(c.get("en_bodega", 0)))))
	caja.add_child(_fila_dato("Tiempo", str(c.get("tiempo", "0:00"))))
	var en := float(c.get("energia", -1.0))
	if en >= 0.0:
		caja.add_child(_fila_dato("Batería", "%d %%" % roundi(en), EstiloUI.COL_OK if en > 35.0 else EstiloUI.COL_AVISO))
	caja.add_child(_fila_dato("Sucesos vividos", str(int(c.get("eventos", 0)))))
	_cuerpo.add_child(_tarjeta(caja))

	_seccion("HISTORIA EN ESTA MISIÓN")
	var h := VBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.add_child(_fila_dato("Misión secundaria por radio", str(c.get("secundaria", ""))))
	h.add_child(_fila_dato("Charla con un jefe", str(c.get("charla", ""))))
	var nr := int(c.get("radio", 0))
	h.add_child(_fila_dato("Mensajes de radio", "%d esperando (tecla R)" % nr if nr > 0 else "Ninguno esperando"))
	var dil := str(c.get("dilema", ""))
	h.add_child(_fila_dato("Decisión tomada", dil if dil != "" else "ninguna todavía"))
	var cons_v: Variant = c.get("consecuencias", "")
	var cons := " ".join(PackedStringArray(cons_v)) if cons_v is Array else str(cons_v)
	if cons != "":
		h.add_child(_fila_dato("Efectos activos", cons, EstiloUI.COL_AVISO))
	_cuerpo.add_child(_tarjeta(h))

	var vent: Array = HistoriaEstado.ventajas()["lista"]
	if not vent.is_empty():
		_seccion("VENTAJAS ACTIVAS")
		var v := VBoxContainer.new()
		for x in vent:
			var inf := Historia.jefe(str(x["j"]))
			v.add_child(_fila_dato(Historia.titulo(str(x["j"])), str(x["txt"]), inf.get("color", Color.WHITE)))
		_cuerpo.add_child(_tarjeta(v))

	var lineas: Array = c.get("hist", [])
	if not lineas.is_empty():
		_seccion("DIARIO DE LA MISIÓN")
		var d := VBoxContainer.new()
		for x in lineas:
			d.add_child(_texto("•  " + str(x), 15))
		_cuerpo.add_child(_tarjeta(d))


func _tab_misiones() -> void:
	var libres: bool = Ajustes.misiones_libres
	var est: Array = HistoriaEstado.progreso(DatosMarte.MISIONES, libres)
	var ofertas := 0
	for e in est:
		if e["oferta"]:
			ofertas += 1
	_cuerpo.add_child(_texto("Campaña: %d de %d misiones. El comité te ofrece %d ahora; las demás se abren al completarlas." % [
		HistoriaEstado.num_hechas(), DatosMarte.MISIONES.size(), ofertas], 15, EstiloUI.COL_FRIO))
	for n in range(DatosMarte.MISIONES.size()):
		_cuerpo.add_child(_fila(DatosMarte.MISIONES[n], est[n]))


func _fila(mis: Dictionary, est: Dictionary = {}) -> Control:
	var id := str(mis["id"])
	var rec := Rutas.obtener(id)
	var log := Logros.obtener(id)
	var jugada := not rec.is_empty()
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.caja(Color(1, 1, 1, 0.05 if jugada else 0.02), 4.0))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 18)
	p.add_child(h)
	var izq := VBoxContainer.new()
	izq.custom_minimum_size = Vector2(300.0, 0.0)
	izq.add_child(EstiloUI.etiqueta(str(mis["nombre"]), 18, EstiloUI.COL_TEXTO if jugada else EstiloUI.COL_TENUE, true))
	izq.add_child(EstiloUI.etiqueta("%s · %s" % [str(mis["era"]), str(mis["nave"])], 13, EstiloUI.COL_FRIO if jugada else EstiloUI.COL_TENUE))
	var etiq := ""
	var col_e := EstiloUI.COL_TENUE
	if not est.is_empty():
		if est["hecha"]:
			etiq = "COMPLETADA"
			col_e = EstiloUI.COL_OK
		elif est["oferta"]:
			etiq = "OFRECIDA POR EL COMITÉ"
			col_e = EstiloUI.COL_ACENTO
		elif est["bloq"]:
			etiq = "BLOQUEADA"
	if etiq != "":
		izq.add_child(EstiloUI.etiqueta(etiq, 12, col_e, true))
	h.add_child(izq)
	var med := HFlowContainer.new()
	med.custom_minimum_size = Vector2(300.0, 0.0)
	med.add_theme_constant_override("h_separation", 8)
	med.add_theme_constant_override("v_separation", 4)
	h.add_child(med)
	if jugada:
		for k in Logros.medallas(id):
			var m: Dictionary = Logros.MEDALLAS.get(str(k), {})
			if m.is_empty():
				continue
			var chip := PanelContainer.new()
			chip.add_theme_stylebox_override("panel", EstiloUI.caja(Color((m["c"] as Color), 0.22), 4.0))
			chip.add_child(EstiloUI.etiqueta(str(m["n"]), 14, m["c"], true))
			med.add_child(chip)
		if Logros.medallas(id).is_empty():
			med.add_child(EstiloUI.etiqueta("sin medallas", 14, EstiloUI.COL_TENUE))
	else:
		med.add_child(EstiloUI.etiqueta("sin jugar", 14, EstiloUI.COL_TENUE))
	var txt := ""
	if jugada:
		var ef := Comite.eficiencia(id)
		txt = "Tiempo %s" % _tiempo(float(rec.get("tiempo", 0.0)))
		if ef >= 0.0:
			txt += "  ·  ruta %d %% directa" % roundi(ef * 100.0)
		var cu: Variant = log.get("curiosos", null)
		if cu is Array and int((cu as Array)[1]) > 0:
			txt += "  ·  datos %d/%d" % [int((cu as Array)[0]), int((cu as Array)[1])]
		var dec := str(log.get("decision", ""))
		if dec != "":
			txt += "\n" + dec
		txt += "\nVeces jugada: %d" % int(rec.get("veces", 1))
		if int(log.get("dif", 1)) >= 2:
			txt += "  ·  completada en Difícil"
	if not jugada and not est.is_empty() and est["bloq"]:
		txt = str(est["motivo"])
	var der := EstiloUI.etiqueta(txt, 14, EstiloUI.COL_TEXTO)
	der.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	der.custom_minimum_size = Vector2(480.0, 0.0)
	h.add_child(der)
	return p


func _tab_medallas() -> void:
	var prog := Logros.progreso(Ajustes.genero)
	_seccion("RANGO")
	var fila := HFlowContainer.new()
	fila.add_theme_constant_override("h_separation", 10)
	fila.add_theme_constant_override("v_separation", 8)
	var idx := int(prog["idx"])
	for i in range(Logros.RANGOS.size()):
		var r: Dictionary = Logros.RANGOS[i]
		var actual := i == idx
		var conseguido := i <= idx
		var chip := PanelContainer.new()
		var col: Color = EstiloUI.COL_ACENTO if actual else (EstiloUI.COL_OK if conseguido else EstiloUI.COL_TENUE)
		chip.add_theme_stylebox_override("panel", EstiloUI.caja(Color(col.r, col.g, col.b, 0.22 if actual else 0.08), 4.0))
		var v := VBoxContainer.new()
		v.add_child(EstiloUI.etiqueta(str(r["f"] if Ajustes.genero == 1 else r["n"]), 18, col, true))
		v.add_child(EstiloUI.etiqueta("%d puntos" % int(r["p"]), 13, EstiloUI.COL_TENUE))
		chip.add_child(v)
		fila.add_child(chip)
	_cuerpo.add_child(fila)
	var txt := "Tienes %d puntos (10 por misión, 5 por medalla y 5 extra por cada misión en Difícil)." % int(prog["puntos"])
	if str(prog["sig_nombre"]) != "":
		txt += " Te faltan %d para ser %s." % [int(prog["sig_puntos"]) - int(prog["puntos"]), str(prog["sig_nombre"])]
	_cuerpo.add_child(_texto(txt, 15, EstiloUI.COL_FRIO))
	var esp := HistoriaEstado.titulo_final(Ajustes.genero)
	_cuerpo.add_child(_texto("Título especial: " + (esp if esp != "" else "aún sin ganar. Lo da el final de la historia que veas."), 16, EstiloUI.COL_ACENTO if esp != "" else EstiloUI.COL_TENUE))

	_seccion("MEDALLAS  (toca una para ver el detalle)")
	var rejilla := HFlowContainer.new()
	rejilla.add_theme_constant_override("h_separation", 10)
	rejilla.add_theme_constant_override("v_separation", 10)
	_cuerpo.add_child(rejilla)
	var detalle := VBoxContainer.new()
	detalle.add_theme_constant_override("separation", 3)
	var tarj := _tarjeta(detalle)
	_cuerpo.add_child(tarj)
	var ganadas := 0
	var primera := ""
	var infos := {}
	for k in Logros.MEDALLAS:
		var m: Dictionary = Logros.MEDALLAS[k]
		var donde: Array[String] = []
		for mis in DatosMarte.MISIONES:
			if Logros.medallas(str(mis["id"])).has(k):
				donde.append(str(mis["nombre"]))
		infos[str(k)] = donde
		if donde.size() > 0:
			ganadas += 1
			if primera == "":
				primera = str(k)
		var t := Button.new()
		t.custom_minimum_size = Vector2(124.0, 128.0)
		t.flat = false
		t.add_theme_stylebox_override("normal", EstiloUI.caja(Color(m["c"].r, m["c"].g, m["c"].b, 0.12) if donde.size() > 0 else Color(1, 1, 1, 0.03), 6.0))
		t.add_theme_stylebox_override("hover", EstiloUI.caja(Color(m["c"].r, m["c"].g, m["c"].b, 0.28), 6.0))
		t.add_theme_stylebox_override("pressed", EstiloUI.caja(Color(m["c"].r, m["c"].g, m["c"].b, 0.36), 6.0))
		var v := VBoxContainer.new()
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		var ins := InsigniaMedalla.new()
		ins.id = str(k)
		ins.color = m["c"]
		ins.apagada = donde.size() == 0
		ins.tam = 64.0
		ins.custom_minimum_size = Vector2(64.0, 64.0)
		ins.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		ins.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(ins)
		var nm := EstiloUI.etiqueta(str(m["n"]), 13, m["c"] if donde.size() > 0 else EstiloUI.COL_TENUE, true)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nm.custom_minimum_size = Vector2(112.0, 0.0)
		v.add_child(nm)
		t.add_child(v)
		t.pressed.connect(_detalle_medalla.bind(detalle, str(k), donde))
		rejilla.add_child(t)
	_detalle_medalla(detalle, primera if primera != "" else str(Logros.MEDALLAS.keys()[0]), infos[primera if primera != "" else str(Logros.MEDALLAS.keys()[0])])


func _detalle_medalla(caja: VBoxContainer, k: String, donde: Array) -> void:
	for c in caja.get_children():
		c.queue_free()
	var m: Dictionary = Logros.MEDALLAS[k]
	caja.add_child(EstiloUI.etiqueta(str(m["n"]), 22, m["c"] if donde.size() > 0 else EstiloUI.COL_TENUE, true))
	caja.add_child(_texto(str(m["d"]), 15, EstiloUI.COL_TEXTO, 1080.0))
	var d_txt := "Aún no la has ganado." if donde.size() == 0 else "Ganada en %d misión(es): %s" % [donde.size(), ", ".join(donde.slice(0, 6)) + ("…" if donde.size() > 6 else "")]
	caja.add_child(_texto(d_txt, 14, EstiloUI.COL_FRIO if donde.size() > 0 else EstiloUI.COL_TENUE, 1080.0))


func _tab_equipo() -> void:
	_cuerpo.add_child(_texto("La confianza sube o baja con tus decisiones, las charlas y las misiones secundarias. A partir de %d, el jefe te da su ventaja en cada misión; por debajo de %d se molesta contigo." % [
		HistoriaEstado.CONF_ALTA, HistoriaEstado.CONF_BAJA], 15, EstiloUI.COL_TENUE))
	for j in HistoriaEstado.JEFES:
		var inf := Historia.jefe(j)
		var col: Color = inf.get("color", Color.WHITE)
		var v := HistoriaEstado.conf(j)
		var niv := HistoriaEstado.nivel(j)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 18)
		var izq := VBoxContainer.new()
		izq.custom_minimum_size = Vector2(300.0, 0.0)
		izq.add_child(EstiloUI.etiqueta(Historia.titulo(j), 20, col, true))
		izq.add_child(EstiloUI.etiqueta({"alta": "Confía plenamente", "media": "Neutral", "baja": "Molesto contigo"}[niv] + "  (%+d)" % v, 14, EstiloUI.COL_TEXTO))
		izq.add_child(EstiloUI.etiqueta("Defiende: %s" % Idioma.t(str(inf["defiende"])), 13, col))
		h.add_child(izq)
		var centro := VBoxContainer.new()
		centro.custom_minimum_size = Vector2(300.0, 0.0)
		centro.alignment = BoxContainer.ALIGNMENT_CENTER
		var b := EstiloUI.barra(col if niv != "baja" else Color(1.0, 0.35, 0.3), 12.0)
		b.min_value = float(HistoriaEstado.CONF_MIN)
		b.max_value = float(HistoriaEstado.CONF_MAX)
		b.value = float(v)
		b.custom_minimum_size = Vector2(300.0, 12.0)
		centro.add_child(b)
		h.add_child(centro)
		var ventaja: String = str(HistoriaExtra.VENTAJAS[j]["txt"])
		var activa := niv == "alta"
		var txt := ("VENTAJA ACTIVA\n" if activa else "Ventaja (con confianza %d o más)\n" % HistoriaEstado.CONF_ALTA) + ventaja
		h.add_child(_texto(txt, 14, EstiloUI.COL_OK if activa else EstiloUI.COL_TENUE, 440.0))
		var tarj := VBoxContainer.new()
		tarj.add_theme_constant_override("separation", 6)
		tarj.add_child(h)
		_cuerpo.add_child(_tarjeta(tarj))
	var pend := HistoriaEstado.efectos_pendientes()
	if not pend.is_empty():
		_seccion("CONSECUENCIAS PARA LA PRÓXIMA MISIÓN")
		for e in pend:
			_cuerpo.add_child(_texto("•  " + str((e as Dictionary).get("txt", "")), 15, EstiloUI.COL_AVISO))


func _tab_finales() -> void:
	var vistos := HistoriaEstado.finales_vistos()
	_cuerpo.add_child(_texto("Hay tres finales. Los decide la confianza que tengas con tu equipo al terminar la campaña. Has visto %d de 3." % vistos.size(), 15, EstiloUI.COL_FRIO))
	var pistas_h := {
		"unidos": "Termina la campaña con una confianza media alta con el equipo.",
		"acuerdo": "Termina la campaña con una confianza normal con el equipo.",
		"dividido": "Termina la campaña habiendo perdido la confianza de tu equipo.",
	}
	for id in ["unidos", "acuerdo", "dividido"]:
		var d := HistoriaEstado.final_datos(id)
		var col: Color = d.get("color", Color.WHITE)
		var visto := vistos.has(id)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		if visto:
			v.add_child(EstiloUI.etiqueta(str(d.get("titulo", "")), 20, col, true))
			v.add_child(_texto(str(d.get("resumen", "")), 15))
		else:
			v.add_child(EstiloUI.etiqueta("FINAL SIN DESCUBRIR", 20, EstiloUI.COL_TENUE, true))
			v.add_child(_texto("Pista: " + str(pistas_h[id]), 15, EstiloUI.COL_TENUE))
		_cuerpo.add_child(_tarjeta(v, Color(col.r, col.g, col.b, 0.10) if visto else Color(1, 1, 1, 0.025)))


func _tab_taller() -> void:
	var en_mision := not contexto.is_empty()
	_cuerpo.add_child(_texto("Mejora tu robot con las muestras del almacén y los datos de ciencia. Los consigues entregando muestras en la base, leyendo datos curiosos, encontrando hallazgos y analizando en el laboratorio.", 15, EstiloUI.COL_FRIO))

	_seccion("ALMACÉN")
	var alm := VBoxContainer.new()
	alm.add_theme_constant_override("separation", 6)
	alm.add_child(_texto("Muestras guardadas: %d     ·     Datos de ciencia: %d" % [MetaEstado.stock_total(), MetaEstado.datos()], 18, EstiloUI.COL_TEXTO))
	var st := MetaEstado.stock()
	var fl := HFlowContainer.new()
	fl.custom_minimum_size = Vector2(1080.0, 0.0)
	fl.add_theme_constant_override("h_separation", 12)
	for id in st:
		if int(st[id]) <= 0:
			continue
		var info := DatosMarte.material(str(id))
		if info.is_empty():
			continue
		var chip := EstiloUI.etiqueta("%s × %d" % [str(info["nombre"]), int(st[id])], 14, info["color"])
		fl.add_child(chip)
	if fl.get_child_count() == 0:
		fl.add_child(EstiloUI.etiqueta("Aún no tienes muestras: entrégalas en la base al terminar una misión.", 14, EstiloUI.COL_TENUE))
	alm.add_child(fl)
	_cuerpo.add_child(_tarjeta(alm))
	if en_mision:
		_cuerpo.add_child(_texto("Las mejoras se compran desde el menú principal (DIARIO → TALLER). Esto es lo que llevas instalado:", 14, EstiloUI.COL_AVISO))
	else:
		var b_lab := EstiloUI.boton("ABRIR EL LABORATORIO  (analiza muestras → datos de ciencia)", 17)
		b_lab.custom_minimum_size = Vector2(620.0, 44.0)
		b_lab.pressed.connect(func():
			var lab := Laboratorio.new()
			lab.cerrada.connect(_refrescar)
			add_child(lab))
		_cuerpo.add_child(b_lab)
	for rama in Mejoras.ORDEN:
		_cuerpo.add_child(_tarjeta(_caja_rama(rama, not en_mision), Color(1, 1, 1, 0.05)))
	_seccion("TIENDA DE RECUERDOS")
	_cuerpo.add_child(_texto("Detalles para que el robot y la base sean tuyos. No dan ventaja: solo identidad. Se pagan con datos de ciencia.", 15, EstiloUI.COL_FRIO))
	for cat in Recuerdos.CATEGORIAS:
		_cuerpo.add_child(_tarjeta(_caja_recuerdos(cat, not en_mision), Color(1, 1, 1, 0.05)))


func _caja_rama(rama: String, comprable: bool) -> Control:
	var d: Dictionary = Mejoras.RAMAS[rama]
	var col: Color = d["c"]
	var n := Mejoras.nivel(rama)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 18)
	var izq := VBoxContainer.new()
	izq.custom_minimum_size = Vector2(300.0, 0.0)
	izq.add_theme_constant_override("separation", 4)
	izq.add_child(EstiloUI.etiqueta("%s  ·  nivel %d/3" % [str(d["n"]), n], 20, col, true))
	izq.add_child(_texto(str(d["d"]), 14, EstiloUI.COL_TENUE, 290.0))
	var pips := HBoxContainer.new()
	pips.add_theme_constant_override("separation", 6)
	for i in range(3):
		var r := ColorRect.new()
		r.custom_minimum_size = Vector2(46.0, 10.0)
		r.color = col if i < n else Color(1, 1, 1, 0.14)
		pips.add_child(r)
	izq.add_child(pips)
	h.add_child(izq)
	var der := VBoxContainer.new()
	der.add_theme_constant_override("separation", 4)
	var sig := Mejoras.siguiente(rama)
	if sig.is_empty():
		der.add_child(_texto("Todas las mejoras instaladas.", 16, EstiloUI.COL_OK, 520.0))
	else:
		der.add_child(_texto("Siguiente: " + str(sig["t"]), 16, EstiloUI.COL_TEXTO, 520.0))
		var coste := "Coste: %d muestras" % int(sig["m"])
		if int(sig["d"]) > 0:
			coste += " + %d datos" % int(sig["d"])
		var ok := Mejoras.puede_comprar(rama)
		der.add_child(EstiloUI.etiqueta(coste, 15, EstiloUI.COL_OK if ok else EstiloUI.COL_TENUE))
	h.add_child(der)
	if comprable and not sig.is_empty():
		var b := EstiloUI.boton("INSTALAR", 16)
		b.custom_minimum_size = Vector2(140.0, 40.0)
		b.disabled = not Mejoras.puede_comprar(rama)
		b.pressed.connect(func():
			if Mejoras.comprar(rama):
				Ajustes.guardar()
				_refrescar())
		h.add_child(b)
	return h


func _caja_recuerdos(cat: String, comprable: bool) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.add_child(EstiloUI.etiqueta(str(Recuerdos.NOMBRES[cat]), 19, EstiloUI.COL_ACENTO, true))
	v.add_child(_texto(str(Recuerdos.DESCRIPCIONES[cat]), 14, EstiloUI.COL_TENUE, 1000.0))
	var puesto := Recuerdos.puesto(cat)
	for it: Dictionary in Recuerdos.items(cat):
		var id := str(it["id"])
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		var mu := ColorRect.new()
		mu.custom_minimum_size = Vector2(20.0, 20.0)
		mu.color = it["col"]
		h.add_child(mu)
		var tx := VBoxContainer.new()
		tx.custom_minimum_size = Vector2(620.0, 0.0)
		tx.add_child(EstiloUI.etiqueta(str(it["n"]), 16, EstiloUI.COL_TEXTO))
		tx.add_child(_texto(str(it["t"]), 13, EstiloUI.COL_TENUE, 600.0))
		h.add_child(tx)
		var tengo := Recuerdos.tiene(id)
		var coste := int(it["c"])
		if id == puesto:
			h.add_child(EstiloUI.etiqueta("PUESTO", 15, EstiloUI.COL_OK, true))
		elif comprable:
			var b: Button
			if tengo:
				b = EstiloUI.boton("PONER", 15)
			else:
				b = EstiloUI.boton("COMPRAR · %d datos" % coste, 15)
				b.disabled = MetaEstado.datos() < coste
			b.custom_minimum_size = Vector2(190.0, 36.0)
			b.pressed.connect(func():
				var ok := Recuerdos.poner(cat, id) if tengo else Recuerdos.comprar(id)
				if ok:
					Ajustes.guardar()
					_refrescar())
			h.add_child(b)
		elif not tengo:
			h.add_child(EstiloUI.etiqueta("%d datos" % coste, 14, EstiloUI.COL_TENUE))
		v.add_child(h)
	return v


func _tab_coleccion() -> void:
	var dorado := Color(1.0, 0.82, 0.25)
	var n := MetaEstado.num_hallazgos()
	var tot := Hallazgos.total()
	_cuerpo.add_child(_texto("Cada misión de la campaña esconde objetos raros lejos de la ruta. No salen en el radar: los revela el escáner (ESPACIO) de cerca, FOCOS o pasar muy cerca. Se recogen con E y dan datos de ciencia.", 15, EstiloUI.COL_FRIO))
	var cab := VBoxContainer.new()
	cab.add_theme_constant_override("separation", 4)
	cab.add_child(EstiloUI.etiqueta("Encontrados: %d / %d%s" % [n, tot, "   ·   ¡COLECCIONISTA!" if n >= tot else ""], 22, dorado if n > 0 else EstiloUI.COL_TENUE, true))
	var barra := EstiloUI.barra(dorado, 10.0)
	barra.min_value = 0.0
	barra.max_value = float(tot)
	barra.value = float(n)
	barra.custom_minimum_size = Vector2(500.0, 10.0)
	cab.add_child(barra)
	if n >= tot:
		cab.add_child(_texto("Medalla de coleccionista: encontraste todo lo que Marte guardaba.", 15, EstiloUI.COL_OK))
	_cuerpo.add_child(_tarjeta(cab, Color(dorado.r, dorado.g, dorado.b, 0.08)))
	for m in DatosMarte.MISIONES:
		var lista := Hallazgos.de_mision(str(m["id"]))
		if lista.is_empty():
			continue
		var pr := Hallazgos.progreso_mision(str(m["id"]))
		_cuerpo.add_child(EstiloUI.etiqueta("%s · %s   (%d/%d)" % [str(m["era"]), str(m["nombre"]), pr.x, pr.y], 17,
				EstiloUI.COL_ACENTO if pr.x < pr.y else EstiloUI.COL_OK, true))
		for h in lista:
			var hecho := MetaEstado.hallazgo_hecho(str(h["id"]))
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 2)
			if hecho:
				v.add_child(EstiloUI.etiqueta("%s   ·   +%d datos" % [str(h["n"]), int(h["d"])], 17, dorado, true))
				v.add_child(_texto(str(h["t"]), 14, EstiloUI.COL_TEXTO, 1040.0))
			else:
				v.add_child(EstiloUI.etiqueta("???   ·   escondido en esta misión", 16, EstiloUI.COL_TENUE))
			_cuerpo.add_child(_tarjeta(v, Color(dorado.r, dorado.g, dorado.b, 0.06) if hecho else Color(1, 1, 1, 0.025)))


func _tab_bitacora() -> void:
	var azul := EstiloUI.COL_FRIO
	_cuerpo.add_child(_texto("Se escribe sola cada vez que terminas una misión o una expedición. Puedes guardarla como archivo de texto.", 15, azul))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	var b_exp := EstiloUI.boton("EXPORTAR A TEXTO", 16)
	b_exp.custom_minimum_size = Vector2(260.0, 40.0)
	var l_res := _texto("", 14, EstiloUI.COL_OK, 760.0)
	b_exp.pressed.connect(func():
		var r := Bitacora.exportar_txt()
		l_res.text = (tr("Guardada en: %s") % r) if r != "" else "No se pudo guardar el archivo.")
	b_exp.disabled = Bitacora.num() == 0
	fila.add_child(b_exp)
	fila.add_child(l_res)
	_cuerpo.add_child(fila)
	var lista := Bitacora.entradas()
	if lista.is_empty():
		_cuerpo.add_child(_texto("Todavía no hay entradas. Termina una misión y aparecerá aquí.", 17, EstiloUI.COL_TENUE))
		return
	var total_e := 0
	for e0 in lista:
		if (e0 as Dictionary).has("carta"):
			total_e += 1
	lista.reverse()
	var idx_e := 0
	for e in lista:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 3)
		v.add_child(EstiloUI.etiqueta(Bitacora.titulo_entrada(e), 18, EstiloUI.COL_ACENTO, true))
		var ls := Bitacora.lineas_entrada(e)
		for i in range(ls.size()):
			var ult := i == ls.size() - 1
			v.add_child(_texto(ls[i], 15, EstiloUI.COL_TENUE if ult else EstiloUI.COL_TEXTO, 1060.0))
		var carta := CartaFocos.componer(e, total_e - idx_e)
		if not carta.is_empty():
			v.add_child(_carta_focos(carta, idx_e == 0))
			idx_e += 1
		_cuerpo.add_child(_tarjeta(v, Color(1, 1, 1, 0.045)))


func _carta_focos(parrafos: Array[String], abierta: bool = false) -> Control:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	var b := Button.new()
	b.text = "✉  " + Idioma.t("Carta de FOCOS a la Tierra") + "  ▾"
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.flat = true
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", DronVoz.COLOR)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	caja.add_child(b)
	var papel := VBoxContainer.new()
	papel.add_theme_constant_override("separation", 7)
	papel.visible = false
	for i in range(parrafos.size()):
		var firma := i == parrafos.size() - 2
		var l := _texto(parrafos[i], 15, DronVoz.COLOR.lightened(0.35) if firma else Color(0.95, 0.93, 0.85), 1000.0)
		if firma:
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		papel.add_child(l)
	var marco := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.94, 0.9, 0.78, 0.08)
	sb.border_color = DronVoz.COLOR
	sb.border_width_left = 3
	sb.content_margin_left = 16.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	marco.add_theme_stylebox_override("panel", sb)
	marco.add_child(papel)
	marco.visible = false
	caja.add_child(marco)
	b.pressed.connect(func():
		papel.visible = not papel.visible
		marco.visible = papel.visible
		b.text = "✉  " + Idioma.t("Carta de FOCOS a la Tierra") + ("  ▴" if papel.visible else "  ▾"))
	if abierta:
		papel.visible = true
		marco.visible = true
		b.text = "✉  " + Idioma.t("Carta de FOCOS a la Tierra") + "  ▴"
	return caja


func _tab_recuerdos() -> void:
	var tinta := Color(0.22, 0.3, 0.62).lightened(0.45)
	var pag := Cuaderno.paginas()
	pag.reverse()
	_cuerpo.add_child(_texto("Tu historia en Marte, como álbum: cada misión que terminas deja un recuerdo. Pulsa RELEER para volver a vivirlo.", 15, EstiloUI.COL_FRIO))
	_cuerpo.add_child(EstiloUI.etiqueta("Recuerdos: %d / %d" % [pag.size(), DatosMarte.MISIONES.size()], 18, EstiloUI.COL_ACENTO, true))
	if pag.is_empty():
		_cuerpo.add_child(_texto("Todavía no hay recuerdos. Termina una misión de la campaña y aparecerá aquí.", 17, EstiloUI.COL_TENUE))
	for p: Dictionary in pag:
		_cuerpo.add_child(_tarjeta(_caja_recuerdo(p["mision"], p["entrada"], tinta), Color(0.94, 0.91, 0.82, 0.06)))
	_equipo_recuerdos()


func _caja_recuerdo(m: Dictionary, e: Dictionary, tinta: Color) -> Control:
	var id := str(m["id"])
	var raiz := VBoxContainer.new()
	raiz.add_theme_constant_override("separation", 8)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 22)
	raiz.add_child(h)
	var foto := FotoArchivo.marco(m, 300.0)
	if foto != null:
		h.add_child(foto)
	else:
		var d := CuadernoDibujo.new()
		d.configurar(m, e)
		h.add_child(d)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	h.add_child(v)
	v.add_child(EstiloUI.etiqueta("%s · %s" % [str(m["era"]), str(m["nombre"])], 19, EstiloUI.COL_ACENTO, true))

	var des: Dictionary = Historia.mensaje(id, "despues")
	if not des.is_empty():
		var inf := Historia.jefe(str(des["j"]))
		var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
		v.add_child(EstiloUI.etiqueta(Historia.titulo(str(des["j"])), 13, col, true))
		v.add_child(_texto("«%s»" % HudMision.corto(str(des["t"]), 150), 15, Color(0.95, 0.9, 0.82), 640.0))
	else:
		var cierre := str(RelatosMarte.relato(id).get("cierre", ""))
		if cierre != "":
			v.add_child(_texto(HudMision.corto(cierre, 150), 15, Color(0.95, 0.9, 0.82), 640.0))
	var ns := Cuaderno.notas(e)
	if ns.size() > 1:
		v.add_child(_texto(ns[1], 14, tinta, 640.0))
	var dec := str(e.get("decision", ""))
	if dec != "":
		v.add_child(_texto("Por radio decidí: %s" % dec, 14, tinta, 640.0))
	var ch := HistoriaEstado.charla_de(id)
	if not ch.is_empty():
		v.add_child(EstiloUI.etiqueta("Hablaste con %s por radio." % str(ch.get("j", "")), 13, EstiloUI.COL_TENUE))

	var det := VBoxContainer.new()
	det.add_theme_constant_override("separation", 6)
	det.visible = false
	var rel: Dictionary = RelatosMarte.relato(id)
	if str(rel.get("intro", "")) != "":
		det.add_child(EstiloUI.etiqueta("LA HISTORIA", 12, EstiloUI.COL_FRIO, true))
		det.add_child(_texto(str(rel["intro"]), 14, EstiloUI.COL_TEXTO, 1060.0))
	var ant: Dictionary = Historia.mensaje(id, "antes")
	if not ant.is_empty():
		det.add_child(EstiloUI.etiqueta("ANTES DE SALIR · %s" % Historia.titulo(str(ant["j"])), 12, EstiloUI.COL_ACENTO, true))
		det.add_child(_texto("«%s»" % str(ant["t"]), 14, Color(0.95, 0.9, 0.82), 1060.0))
	if not des.is_empty():
		det.add_child(EstiloUI.etiqueta("AL VOLVER · %s" % Historia.titulo(str(des["j"])), 12, EstiloUI.COL_ACENTO, true))
		det.add_child(_texto("«%s»" % str(des["t"]), 14, Color(0.95, 0.9, 0.82), 1060.0))
	if str(rel.get("cierre", "")) != "":
		det.add_child(EstiloUI.etiqueta("POR QUÉ IMPORTA", 12, EstiloUI.COL_FRIO, true))
		det.add_child(_texto(str(rel["cierre"]), 14, EstiloUI.COL_TEXTO, 1060.0))
	if str(m.get("real", "")) != "":
		det.add_child(EstiloUI.etiqueta("DATO REAL", 12, EstiloUI.COL_TENUE))
		det.add_child(_texto(str(m["real"]), 13, EstiloUI.COL_FRIO, 1060.0))
	det.add_child(_texto(Cuaderno.posdata(id), 13, EstiloUI.COL_TENUE, 1060.0))
	var b := EstiloUI.boton("RELEER", 15)
	b.custom_minimum_size = Vector2(150.0, 34.0)
	b.pressed.connect(func():
		det.visible = not det.visible
		b.text = "CERRAR" if det.visible else "RELEER")
	v.add_child(b)
	raiz.add_child(det)
	return raiz


func _equipo_recuerdos() -> void:
	_seccion("TU EQUIPO")
	for j in ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]:
		var inf := Historia.jefe(j)
		var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 14)
		var n := EstiloUI.etiqueta(Historia.titulo(j), 15, col, true)
		n.custom_minimum_size = Vector2(190.0, 0.0)
		h.add_child(n)
		var t := tr("Confianza %d") % HistoriaEstado.conf(j)
		h.add_child(_texto(t, 14, EstiloUI.COL_TEXTO, 860.0))
		_cuerpo.add_child(_tarjeta(h, Color(1, 1, 1, 0.04)))


func _tab_cifras() -> void:
	var c := Bitacora.cifras()
	_cuerpo.add_child(_texto("Totales de tu campaña. Cuentan las misiones terminadas desde que existe la bitácora.", 15, EstiloUI.COL_FRIO))
	var seg := int(float(c["tiempo"]))
	var horas := seg / 3600
	var tiempo := ("%d h %02d min" % [horas, (seg % 3600) / 60]) if horas > 0 else ("%d min %02d s" % [seg / 60, seg % 60])
	var datos: Array = [
		["Misiones terminadas", str(int(c["misiones"])), EstiloUI.COL_OK],
		["Expediciones jugadas", str(int(c["expediciones"])), EstiloUI.COL_FRIO],
		["Tiempo en misión", tiempo, EstiloUI.COL_TEXTO],
		["Distancia recorrida", "%.1f km" % float(c["km"]), EstiloUI.COL_TEXTO],
		["Muestras entregadas", str(int(c["muestras"])), EstiloUI.COL_ACENTO],
		["Datos curiosos leídos", str(int(c["curiosos"])), EstiloUI.COL_FRIO],
		["Hallazgos escondidos", "%d  (colección: %d / %d)" % [int(c["hallazgos"]), MetaEstado.num_hallazgos(), Hallazgos.total()], Color(1.0, 0.82, 0.25)],
		["Decisiones por radio", str(int(c["decisiones"])), EstiloUI.COL_TEXTO],
		["Sustos en el camino", str(int(c["sustos"])), EstiloUI.COL_AVISO],
		["Medallas ganadas", str(Logros.total_medallas()), EstiloUI.COL_AVISO],
		["Análisis de laboratorio", str(MetaEstado.analisis_hechos()), EstiloUI.COL_TEXTO],
		["Datos de ciencia", str(MetaEstado.datos()), EstiloUI.COL_FRIO],
	]
	if float(c["mas_rapida"]) > 0.0:
		var t := int(float(c["mas_rapida"]))
		datos.append(["Misión más rápida", "%d:%02d" % [t / 60, t % 60], EstiloUI.COL_OK])
	if int(c["mejor_exp"]) > 0:
		datos.append(["Mejor puntuación de expedición", str(int(c["mejor_exp"])), EstiloUI.COL_ACENTO])
	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 12)
	rejilla.add_theme_constant_override("v_separation", 10)
	for d in datos:
		var v := VBoxContainer.new()
		v.custom_minimum_size = Vector2(540.0, 0.0)
		v.add_theme_constant_override("separation", 0)
		v.add_child(EstiloUI.etiqueta(str(d[0]), 14, EstiloUI.COL_TENUE))
		v.add_child(EstiloUI.etiqueta(str(d[1]), 26, d[2], true))
		rejilla.add_child(_tarjeta(v, Color(1, 1, 1, 0.045)))
	_cuerpo.add_child(rejilla)


func _tab_colonia() -> void:
	_cuerpo.add_child(_texto("La colonia crece sola con lo que haces en la campaña (no se paga). Los módulos se ven junto al hangar de cada misión y dan pequeñas ventajas.", 15, EstiloUI.COL_FRIO))
	_cuerpo.add_child(_texto("Lugar de la base: " + Colonia.lugar(), 17, EstiloUI.COL_TEXTO))
	for id in Colonia.ORDEN:
		var d: Dictionary = Colonia.MODULOS[id]
		var col: Color = d["c"]
		var n := Colonia.nivel(id)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		v.add_child(EstiloUI.etiqueta("%s  ·  nivel %d/3" % [str(d["n"]), n], 20, col if n > 0 else EstiloUI.COL_TENUE, true))
		var u: Array = d["u"]
		var prog := Colonia.progreso_de(id)
		var meta_n := int(u[mini(n, 2)])
		var barra := EstiloUI.barra(col, 10.0)
		barra.min_value = 0.0
		barra.max_value = float(meta_n)
		barra.value = float(mini(prog, meta_n))
		barra.custom_minimum_size = Vector2(500.0, 10.0)
		v.add_child(barra)
		if n >= 3:
			v.add_child(_texto("Nivel máximo. %d %s." % [prog, str(d["txt"])], 14, EstiloUI.COL_OK))
		else:
			v.add_child(_texto("%d / %d %s para el nivel %d." % [prog, meta_n, str(d["txt"]), n + 1], 14, EstiloUI.COL_TENUE))
		v.add_child(_texto("Ventaja: " + str(d["bono"]), 14, EstiloUI.COL_TEXTO))
		_cuerpo.add_child(_tarjeta(v, Color(col.r, col.g, col.b, 0.07) if n > 0 else Color(1, 1, 1, 0.025)))
