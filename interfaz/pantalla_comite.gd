extends CanvasLayer


signal cerrada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Historia := preload("res://historia/historia.gd")
const Comite := preload("res://historia/comite.gd")
const FinalCinematica := preload("res://cinematicas/final_cinematica.gd")

const COL_APAGADO := Color(1.0, 1.0, 1.0, 0.12)

var _raiz: Control
var _lista: VBoxContainer
var _botones: Dictionary = {}
var _lbl_nombre: Label
var _lbl_sub: Label
var _lbl_nota: Label
var _filas: VBoxContainer
var _lbl_rec: VBoxContainer
var _b_elegir: Button
var _lbl_estado: Label
var _epilogo: Control
var _sel: String = ""


func _ready() -> void:
	layer = 40
	add_to_group("modal")
	_construir()
	var ids := Comite.sitios()
	var previa := Comite.elegida()
	_seleccionar(previa if previa != "" else str(ids[0]))


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _epilogo.visible:
			_epilogo.visible = false
		else:
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

	var tit := EstiloUI.etiqueta("EL COMITÉ", 34, EstiloUI.COL_ACENTO, true)
	tit.position = Vector2(56.0, 22.0)
	_raiz.add_child(tit)
	var sub := EstiloUI.etiqueta("¿Dónde vivirán los primeros humanos en Marte? Cinco jefes, cinco criterios, una decisión.", 17, EstiloUI.COL_TENUE)
	sub.position = Vector2(58.0, 66.0)
	_raiz.add_child(sub)


	_lista = VBoxContainer.new()
	_lista.position = Vector2(56.0, 108.0)
	_lista.size = Vector2(330.0, 480.0)
	_lista.add_theme_constant_override("separation", 5)
	_raiz.add_child(_lista)
	for id in Comite.sitios():
		var m := Comite.mision(str(id))
		var b := EstiloUI.boton("", 17)
		b.custom_minimum_size = Vector2(330.0, 40.0)
		b.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(_seleccionar.bind(str(id)))
		_lista.add_child(b)
		_botones[str(id)] = b
		_actualizar_boton(str(id), m)


	var caja := VBoxContainer.new()
	caja.position = Vector2(420.0, 108.0)
	caja.size = Vector2(810.0, 520.0)
	caja.add_theme_constant_override("separation", 7)
	_raiz.add_child(caja)
	_lbl_nombre = EstiloUI.etiqueta("", 30, EstiloUI.COL_TEXTO, true)
	caja.add_child(_lbl_nombre)
	_lbl_sub = EstiloUI.etiqueta("", 16, EstiloUI.COL_FRIO)
	caja.add_child(_lbl_sub)
	_lbl_nota = EstiloUI.etiqueta("", 16, EstiloUI.COL_TEXTO)
	_lbl_nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_nota.custom_minimum_size = Vector2(800.0, 0.0)
	caja.add_child(_lbl_nota)
	caja.add_child(EstiloUI.linea())
	_filas = VBoxContainer.new()
	_filas.add_theme_constant_override("separation", 6)
	caja.add_child(_filas)
	caja.add_child(EstiloUI.linea())
	caja.add_child(EstiloUI.etiqueta("LO QUE RECOMIENDA CADA JEFE", 14, EstiloUI.COL_FRIO, true))
	_lbl_rec = VBoxContainer.new()
	_lbl_rec.add_theme_constant_override("separation", 3)
	caja.add_child(_lbl_rec)


	var fila := HBoxContainer.new()
	fila.position = Vector2(56.0, 632.0)
	fila.add_theme_constant_override("separation", 14)
	_raiz.add_child(fila)
	_b_elegir = EstiloUI.boton("ELEGIR ESTE SITIO PARA LA BASE", 20)
	_b_elegir.custom_minimum_size = Vector2(430.0, 48.0)
	_b_elegir.pressed.connect(_elegir)
	fila.add_child(_b_elegir)
	var b_volver := EstiloUI.boton("VOLVER", 20)
	b_volver.custom_minimum_size = Vector2(150.0, 48.0)
	b_volver.pressed.connect(func():
		cerrada.emit()
		queue_free())
	fila.add_child(b_volver)
	_lbl_estado = EstiloUI.etiqueta("", 15, EstiloUI.COL_TENUE)
	_lbl_estado.position = Vector2(56.0, 686.0)
	_lbl_estado.size = Vector2(1100.0, 26.0)
	_raiz.add_child(_lbl_estado)

	_epilogo = _crear_epilogo()
	_raiz.add_child(_epilogo)


func _actualizar_boton(id: String, m: Dictionary) -> void:
	var b: Button = _botones[id]
	var marca := "•" if Comite.visitado(id) else "·"
	var elegido := "  ✔" if Comite.elegida() == id else ""
	b.text = " %s  %s · %s%s" % [marca, str(m["nombre"]), str(m["era"]), elegido]


func _seleccionar(id: String) -> void:
	_sel = id
	var m := Comite.mision(id)
	var vis := Comite.visitado(id)
	_lbl_nombre.text = str(m["nombre"])
	_lbl_sub.text = "%s · %s  ·  %s" % [str(m["era"]), str(m["nave"]), "VISITADO" if vis else "SIN VISITAR"]
	_lbl_nota.text = str((Comite.SITIOS[id] as Dictionary)["nota"]) if vis else "Aún no tienes datos de este lugar. Completa su misión para que el comité pueda evaluarlo."
	for h in _filas.get_children():
		h.queue_free()
	for c in Comite.CRITERIOS:
		var inf := Historia.jefe(str(c["j"]))
		var col: Color = inf["color"]
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 14)
		var l1 := EstiloUI.etiqueta(Historia.titulo(str(c["j"])), 17, col, true)
		l1.custom_minimum_size = Vector2(150.0, 0.0)
		f.add_child(l1)
		var l2 := EstiloUI.etiqueta(str(c["n"]), 17, EstiloUI.COL_TEXTO)
		l2.custom_minimum_size = Vector2(170.0, 0.0)
		f.add_child(l2)
		var n := Comite.nota(id, str(c["k"])) if vis else 0
		var barra := HBoxContainer.new()
		barra.add_theme_constant_override("separation", 4)
		barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		for i in range(5):
			var r := ColorRect.new()
			r.custom_minimum_size = Vector2(34.0, 14.0)
			r.color = col if i < n else COL_APAGADO
			barra.add_child(r)
		f.add_child(barra)
		var extra := ""
		if not vis:
			extra = "?"
		else:
			extra = "%d / 5" % n
			var bn := Comite.bono(id)
			if not bn.is_empty() and str(bn.get("crit", "")) == str(c["k"]):
				extra += "   (tu decisión: %s%d)" % ["+" if int(bn["d"]) > 0 else "", int(bn["d"])]
			if str(c["k"]) == "ruta":
				var ef := Comite.eficiencia(id)
				if ef >= 0.0:
					extra += "   (tu ruta: %d %% directa)" % roundi(ef * 100.0)
		f.add_child(EstiloUI.etiqueta(extra, 16, EstiloUI.COL_TENUE))
		_filas.add_child(f)
	if vis:
		var t := EstiloUI.etiqueta("TOTAL: %d / 25" % Comite.total(id), 20, EstiloUI.COL_ACENTO, true)
		_filas.add_child(t)
	_refrescar_recomendaciones()
	var n_vis := Comite.visitados().size()
	_b_elegir.disabled = not (Comite.puede_decidir() and vis)
	if not Comite.puede_decidir():
		_lbl_estado.text = "Para decidir, el comité necesita datos de al menos %d sitios: llevas %d." % [Comite.MINIMO_VISITADOS, n_vis]
	elif not vis:
		_lbl_estado.text = "Elige un sitio ya visitado para poder decidir."
	else:
		_lbl_estado.text = "Sitios visitados: %d / %d" % [n_vis, Comite.sitios().size()]
	var prev := Comite.elegida()
	if prev != "":
		_lbl_estado.text += "   ·   Base elegida: %s" % str(Comite.mision(prev)["nombre"])


func _refrescar_recomendaciones() -> void:
	for h in _lbl_rec.get_children():
		h.queue_free()
	for c in Comite.CRITERIOS:
		var j := str(c["j"])
		var id := Comite.recomendacion(j)
		var col: Color = Historia.jefe(j)["color"]
		var txt := "sin datos todavía" if id == "" else str(Comite.mision(id)["nombre"])
		_lbl_rec.add_child(EstiloUI.etiqueta("%s   →   %s" % [Historia.titulo(j), txt], 16, col if id != "" else EstiloUI.COL_TENUE))


func _crear_epilogo() -> Control:
	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.visible = false
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.012, 0.015, 0.9)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(centro)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 30.0))
	centro.add_child(p)
	var c := VBoxContainer.new()
	c.name = "Caja"
	c.add_theme_constant_override("separation", 9)
	p.add_child(c)
	return capa


func _elegir() -> void:
	if _sel == "" or not Comite.visitado(_sel):
		return
	Comite.elegir(_sel)
	for id in _botones:
		_actualizar_boton(str(id), Comite.mision(str(id)))
	var c: VBoxContainer = _epilogo.find_child("Caja", true, false)
	for h in c.get_children():
		h.queue_free()
	var m := Comite.mision(_sel)
	c.add_child(EstiloUI.etiqueta("DECISIÓN DEL COMITÉ", 18, EstiloUI.COL_ACENTO, true))
	c.add_child(EstiloUI.etiqueta(str(m["nombre"]).to_upper(), 40, Color.WHITE, true))
	c.add_child(EstiloUI.linea())
	var t := EstiloUI.etiqueta(str((Comite.SITIOS[_sel] as Dictionary)["final"]), 19, EstiloUI.COL_TEXTO)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(780.0, 0.0)
	c.add_child(t)
	c.add_child(EstiloUI.linea())
	for cr in Comite.CRITERIOS:
		var j := str(cr["j"])
		var col: Color = Historia.jefe(j)["color"]
		c.add_child(EstiloUI.etiqueta(Historia.titulo(j), 14, col, true))
		var r := EstiloUI.etiqueta("«%s»" % Comite.reaccion(j, _sel), 17, Color(0.95, 0.9, 0.82))
		r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r.custom_minimum_size = Vector2(780.0, 0.0)
		c.add_child(r)
	c.add_child(EstiloUI.linea())
	var k := EstiloUI.etiqueta("KELLY 087 · cierre", 14, Historia.jefe("KELLY")["color"], true)
	c.add_child(k)
	var kt := EstiloUI.etiqueta("«%s»" % Comite.cierre_kelly(_sel), 18, Color.WHITE)
	kt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kt.custom_minimum_size = Vector2(780.0, 0.0)
	c.add_child(kt)
	var b := EstiloUI.boton("CONTINUAR", 22)
	b.pressed.connect(func(): _epilogo.visible = false)
	c.add_child(b)
	_epilogo.visible = false
	_seleccionar(_sel)
	var cin := FinalCinematica.new()
	cin.configurar(_sel)
	cin.terminada.connect(func(): _epilogo.visible = true)
	add_child(cin)
