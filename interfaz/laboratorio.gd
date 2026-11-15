extends CanvasLayer


signal cerrada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const Colonia := preload("res://progreso/colonia_estado.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")

const TIEMPO_BASE := 20.0
const MAX_COLA := 3
const DATOS_ACIERTO := 2
const DATOS_RAPIDO := 1

enum Fase { ELEGIR, RONDA, RESULTADO, FIN, PRACTICA }

const CLAVE_PRACTICA := "lab_practica"

var _fase: int = Fase.ELEGIR
var _cola: Array[String] = []
var _ronda: int = 0
var _real: String = ""
var _opciones: Array[String] = []
var _tapadas: Array[bool] = []
var _t: float = 0.0
var _t_max: float = TIEMPO_BASE
var _aciertos: int = 0
var _datos_sesion: int = 0
var _jugadas: int = 0
var _rng := RandomNumberGenerator.new()

var _raiz: Control
var _cuerpo: Control
var _espectro_sel: Control = null
var _barra: ProgressBar = null
var _botones_op: Array[Button] = []
var _paso_pr: int = 0
var _guia: Control = null
var _btn_sig: Button = null
var _ok_pr: int = 0


func _ready() -> void:
	layer = 45
	add_to_group("modal")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_raiz)
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.025, 0.035, 0.97)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.add_child(fondo)
	var tit := EstiloUI.etiqueta("LABORATORIO", 34, Color(0.78, 0.58, 1.0), true)
	tit.position = Vector2(56.0, 22.0)
	_raiz.add_child(tit)
	var sub := EstiloUI.etiqueta("Análisis de muestras por espectro", 16, EstiloUI.COL_TENUE)
	sub.position = Vector2(58.0, 68.0)
	_raiz.add_child(sub)
	var b := EstiloUI.boton("CERRAR", 18)
	b.custom_minimum_size = Vector2(160.0, 40.0)
	b.position = Vector2(1064.0, 24.0)
	b.pressed.connect(_cerrar)
	_raiz.add_child(b)
	var bq := EstiloUI.boton("?", 20)
	bq.custom_minimum_size = Vector2(52.0, 40.0)
	bq.position = Vector2(1000.0, 24.0)
	bq.pressed.connect(_fase_practica)
	_raiz.add_child(bq)
	_cuerpo = Control.new()
	_cuerpo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.add_child(_cuerpo)
	if bool(MetaEstado.extra_get(CLAVE_PRACTICA, false)):
		_fase_elegir()
	else:
		_fase_practica()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k: int = event.keycode
	if k == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_cerrar()
	elif _fase == Fase.PRACTICA:
		if k == KEY_ENTER or k == KEY_KP_ENTER or k == KEY_SPACE:
			get_viewport().set_input_as_handled()
			if _paso_pr < 2:
				_practica_sig()
		elif k == KEY_1 + _ok_pr and _paso_pr == 2:
			get_viewport().set_input_as_handled()
			_practica_fin()
	elif _fase == Fase.RONDA and k >= KEY_1 and k <= KEY_3:
		get_viewport().set_input_as_handled()
		_responder(k - KEY_1)
	elif (k == KEY_ENTER or k == KEY_KP_ENTER or k == KEY_SPACE) and _fase == Fase.RESULTADO:
		get_viewport().set_input_as_handled()
		_siguiente()


func _cerrar() -> void:
	cerrada.emit()
	queue_free()


func _process(delta: float) -> void:
	if _fase != Fase.RONDA:
		return
	_t -= delta
	if _barra != null:
		_barra.value = maxf(_t, 0.0)
	if _t <= 0.0:
		_responder(-1)


func _limpiar() -> void:
	for c in _cuerpo.get_children():
		c.queue_free()
	_botones_op.clear()
	_espectro_sel = null
	_barra = null
	_guia = null
	_btn_sig = null


func _texto(t: String, tam: int = 16, col: Color = EstiloUI.COL_TEXTO, ancho: float = 1000.0) -> Label:
	var l := EstiloUI.etiqueta(t, tam, col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(ancho, 0.0)
	return l


static func firma(id: String) -> Array:
	var r := RandomNumberGenerator.new()
	r.seed = hash("espectro_" + id)
	var picos: Array = []
	var n := 3 + int(r.randi() % 2)
	var intentos := 0
	while picos.size() < n and intentos < 60:
		intentos += 1
		var x := r.randf_range(0.08, 0.92)
		var ok := true
		for p in picos:
			if absf((p as Vector3).x - x) < 0.13:
				ok = false
		if ok:
			picos.append(Vector3(x, r.randf_range(0.42, 1.0), r.randf_range(0.014, 0.032)))
	return picos


func _fase_elegir() -> void:
	_fase = Fase.ELEGIR
	_limpiar()
	var y := 110.0
	var info := _texto("Elige hasta %d muestras. Cada análisis gasta una. Aciertas = %d datos de ciencia (%d más si respondes rápido) y aprendes lo que esa nave descubrió de verdad." % [MAX_COLA, DATOS_ACIERTO, DATOS_RAPIDO], 16, EstiloUI.COL_FRIO, 1160.0)
	info.position = Vector2(56.0, y)
	_cuerpo.add_child(info)
	var nivel := Colonia.nivel("laboratorio")
	var bono := _texto("Laboratorio de la colonia: nivel %d/3 → +%d s de tiempo y %d candidato%s descartado%s." % [nivel, int(4.0 * nivel), nivel, "" if nivel == 1 else "s", "" if nivel == 1 else "s"], 14, EstiloUI.COL_TENUE, 1160.0)
	bono.position = Vector2(56.0, y + 52.0)
	_cuerpo.add_child(bono)
	var datos_l := EstiloUI.etiqueta("Datos de ciencia: %d      Muestras en el almacén: %d      Análisis hechos: %d" % [MetaEstado.datos(), MetaEstado.stock_total(), MetaEstado.analisis_hechos()], 17, EstiloUI.COL_TEXTO)
	datos_l.position = Vector2(56.0, y + 88.0)
	_cuerpo.add_child(datos_l)

	var cab := EstiloUI.etiqueta("ALMACÉN  (pulsa para añadir a la cola)", 18, EstiloUI.COL_ACENTO, true)
	cab.position = Vector2(56.0, y + 130.0)
	_cuerpo.add_child(cab)
	var flujo := HFlowContainer.new()
	flujo.position = Vector2(56.0, y + 164.0)
	flujo.custom_minimum_size = Vector2(1160.0, 0.0)
	flujo.size = Vector2(1160.0, 220.0)
	flujo.add_theme_constant_override("h_separation", 10)
	flujo.add_theme_constant_override("v_separation", 10)
	_cuerpo.add_child(flujo)
	var st := MetaEstado.stock()
	var hay := false
	for id in st:
		var n_disp := int(st[id]) - _cola.count(str(id))
		if int(st[id]) <= 0 or DatosMarte.material(str(id)).is_empty():
			continue
		hay = true
		var mat := DatosMarte.material(str(id))
		var b := EstiloUI.boton("%s × %d" % [str(mat["nombre"]), maxi(n_disp, 0)], 16)
		b.custom_minimum_size = Vector2(230.0, 42.0)
		b.add_theme_color_override("font_color", mat["color"])
		b.disabled = n_disp <= 0 or _cola.size() >= MAX_COLA
		b.pressed.connect(_anadir.bind(str(id)))
		flujo.add_child(b)
	if not hay:
		flujo.add_child(_texto("No tienes muestras. Entrégalas en la base al terminar las misiones.", 16, EstiloUI.COL_TENUE, 900.0))

	var nombres: Array[String] = []
	for id in _cola:
		nombres.append(str(DatosMarte.material(id)["nombre"]))
	var cola_l := EstiloUI.etiqueta("COLA: " + ("  ·  ".join(nombres) if not nombres.is_empty() else "(vacía)"), 18, EstiloUI.COL_TEXTO)
	cola_l.position = Vector2(56.0, 560.0)
	_cuerpo.add_child(cola_l)
	var b_ana := EstiloUI.boton("ANALIZAR", 22)
	b_ana.custom_minimum_size = Vector2(240.0, 52.0)
	b_ana.position = Vector2(56.0, 610.0)
	b_ana.disabled = _cola.is_empty()
	b_ana.pressed.connect(_empezar)
	_cuerpo.add_child(b_ana)
	var b_vac := EstiloUI.boton("VACIAR COLA", 18)
	b_vac.custom_minimum_size = Vector2(220.0, 52.0)
	b_vac.position = Vector2(312.0, 610.0)
	b_vac.disabled = _cola.is_empty()
	b_vac.pressed.connect(func():
		_cola.clear()
		_fase_elegir())
	_cuerpo.add_child(b_vac)


func _anadir(id: String) -> void:
	if _cola.size() < MAX_COLA:
		_cola.append(id)
	_fase_elegir()


func _empezar() -> void:
	_ronda = 0
	_aciertos = 0
	_datos_sesion = 0
	_jugadas = _cola.size()
	_fase_ronda()


func _fase_ronda() -> void:
	_fase = Fase.RONDA
	_limpiar()
	_real = _cola[_ronda]

	var otros: Array[String] = []
	for id in DatosMarte.MATERIALES:
		if str(id) != _real:
			otros.append(str(id))
	otros.shuffle()
	_opciones = [_real, otros[0], otros[1]]
	_opciones.shuffle()
	var nivel := Colonia.nivel("laboratorio")
	_tapadas = [false, false, false]
	var quitadas := 0
	for i in range(3):
		if quitadas < nivel and _opciones[i] != _real and quitadas < 2:
			_tapadas[i] = true
			quitadas += 1
	_t_max = TIEMPO_BASE + Colonia.bonos()["lab_tiempo"]
	_t = _t_max

	var cab := EstiloUI.etiqueta("MUESTRA %d / %d  ·  ¿De qué material es este espectro?" % [_ronda + 1, _jugadas], 22, EstiloUI.COL_TEXTO, true)
	cab.position = Vector2(56.0, 110.0)
	_cuerpo.add_child(cab)
	var marco := PanelContainer.new()
	marco.add_theme_stylebox_override("panel", EstiloUI.caja(Color(1, 1, 1, 0.05), 6.0))
	marco.position = Vector2(56.0, 156.0)
	_cuerpo.add_child(marco)
	var esp := Espectro.new()
	esp.picos = firma(_real)
	esp.ruido = true
	esp.color = Color(1.0, 0.6, 0.25)
	esp.custom_minimum_size = Vector2(1120.0, 230.0)
	marco.add_child(esp)
	_espectro_sel = esp
	_barra = EstiloUI.barra(Color(0.78, 0.58, 1.0), 12.0)
	_barra.min_value = 0.0
	_barra.max_value = _t_max
	_barra.value = _t_max
	_barra.position = Vector2(56.0, 404.0)
	_barra.custom_minimum_size = Vector2(1120.0, 12.0)
	_cuerpo.add_child(_barra)
	for i in range(3):
		var caja := VBoxContainer.new()
		caja.position = Vector2(56.0 + 380.0 * float(i), 436.0)
		caja.custom_minimum_size = Vector2(360.0, 0.0)
		caja.add_theme_constant_override("separation", 6)
		_cuerpo.add_child(caja)
		var mat := DatosMarte.material(_opciones[i])
		var mini := Espectro.new()
		mini.picos = firma(_opciones[i])
		mini.ruido = false
		mini.color = mat["color"]
		mini.custom_minimum_size = Vector2(360.0, 96.0)
		mini.modulate.a = 0.25 if _tapadas[i] else 1.0
		caja.add_child(mini)
		var b := EstiloUI.boton("%d  ·  %s" % [i + 1, str(mat["nombre"])], 18)
		b.custom_minimum_size = Vector2(360.0, 46.0)
		b.disabled = _tapadas[i]
		b.pressed.connect(_responder.bind(i))
		caja.add_child(b)
		_botones_op.append(b)
	var ayuda := EstiloUI.etiqueta("Teclas 1 · 2 · 3", 14, EstiloUI.COL_TENUE)
	ayuda.position = Vector2(56.0, 690.0)
	_cuerpo.add_child(ayuda)


func _responder(i: int) -> void:
	if _fase != Fase.RONDA:
		return
	var acierto := i >= 0 and _opciones[i] == _real
	var rapido := _t > _t_max * 0.5
	var ganados := 0
	if acierto:
		_aciertos += 1
		ganados = DATOS_ACIERTO + (DATOS_RAPIDO if rapido else 0)
		_datos_sesion += ganados
	MetaEstado.consumir(_real)
	_fase_resultado(i, acierto, ganados, rapido)


func _fase_practica() -> void:
	_fase = Fase.PRACTICA
	_limpiar()
	_paso_pr = 0
	_real = "regolito" if DatosMarte.MATERIALES.has("regolito") else str(DatosMarte.MATERIALES.keys()[0])
	var otros: Array[String] = []
	for id in DatosMarte.MATERIALES:
		if str(id) != _real:
			otros.append(str(id))
	_opciones = [_real, otros[0], otros[otros.size() / 2]]
	_opciones.shuffle()
	_ok_pr = _opciones.find(_real)
	var tag := EstiloUI.etiqueta("PRÁCTICA  ·  gratis", 16, Color(0.78, 0.58, 1.0), true)
	tag.position = Vector2(700.0, 34.0)
	_cuerpo.add_child(tag)
	var marco := PanelContainer.new()
	marco.add_theme_stylebox_override("panel", EstiloUI.caja(Color(1, 1, 1, 0.05), 6.0))
	marco.position = Vector2(56.0, 156.0)
	_cuerpo.add_child(marco)
	var esp := Espectro.new()
	esp.picos = firma(_real)
	esp.ruido = true
	esp.color = Color(1.0, 0.6, 0.25)
	esp.custom_minimum_size = Vector2(1120.0, 230.0)
	marco.add_child(esp)
	for i in range(3):
		var caja := VBoxContainer.new()
		caja.position = Vector2(56.0 + 380.0 * float(i), 436.0)
		caja.custom_minimum_size = Vector2(360.0, 0.0)
		caja.add_theme_constant_override("separation", 6)
		_cuerpo.add_child(caja)
		var mat := DatosMarte.material(_opciones[i])
		var mini := Espectro.new()
		mini.picos = firma(_opciones[i])
		mini.color = mat["color"]
		mini.custom_minimum_size = Vector2(360.0, 96.0)
		caja.add_child(mini)
		var b := EstiloUI.boton("%d  ·  %s" % [i + 1, str(mat["nombre"])], 18)
		b.custom_minimum_size = Vector2(360.0, 46.0)
		b.disabled = true
		b.pressed.connect(_practica_fin)
		caja.add_child(b)
		_botones_op.append(b)
	_guia = Guia.new()
	(_guia as Guia).picos = firma(_real)
	(_guia as Guia).ok = _ok_pr
	_guia.set_anchors_preset(Control.PRESET_FULL_RECT)
	_guia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cuerpo.add_child(_guia)
	var etiquetas := ["1  ·  Mira los picos", "2  ·  Compara: ¿coinciden?", "3  ·  Toca el que coincide"]
	for i in range(3):
		var l := EstiloUI.etiqueta(etiquetas[i], 26, Color(1.0, 0.85, 0.35), true)
		l.position = Vector2(56.0, 112.0)
		l.visible = i == 0
		l.name = "Paso%d" % i
		_cuerpo.add_child(l)
	_btn_sig = EstiloUI.boton("SIGUIENTE", 20)
	_btn_sig.custom_minimum_size = Vector2(240.0, 48.0)
	_btn_sig.position = Vector2(936.0, 640.0)
	_btn_sig.pressed.connect(_practica_sig)
	_cuerpo.add_child(_btn_sig)
	var omitir := EstiloUI.boton("OMITIR", 16)
	omitir.custom_minimum_size = Vector2(140.0, 40.0)
	omitir.position = Vector2(56.0, 644.0)
	omitir.pressed.connect(_practica_hecha_y_elegir)
	_cuerpo.add_child(omitir)


func _practica_sig() -> void:
	if _fase != Fase.PRACTICA or _paso_pr >= 2:
		return
	_paso_pr += 1
	(_guia as Guia).paso = _paso_pr
	for i in range(3):
		var l := _cuerpo.get_node_or_null("Paso%d" % i)
		if l != null:
			l.visible = i == _paso_pr
	if _paso_pr == 2:
		_btn_sig.visible = false
		for i in range(3):
			_botones_op[i].disabled = i != _ok_pr


func _practica_hecha_y_elegir() -> void:
	MetaEstado.extra_set(CLAVE_PRACTICA, true)
	_cola.clear()
	_fase_elegir()


func _practica_fin() -> void:
	if _fase != Fase.PRACTICA or _paso_pr < 2:
		return
	MetaEstado.extra_set(CLAVE_PRACTICA, true)
	_limpiar()
	var cab := EstiloUI.etiqueta("¡ASÍ SE JUEGA!", 40, EstiloUI.COL_OK, true)
	cab.position = Vector2(56.0, 140.0)
	_cuerpo.add_child(cab)
	var esp := Espectro.new()
	esp.picos = firma(_real)
	esp.color = DatosMarte.material(_real)["color"]
	esp.custom_minimum_size = Vector2(1120.0, 150.0)
	esp.position = Vector2(56.0, 214.0)
	_cuerpo.add_child(esp)
	var rec := EstiloUI.etiqueta("Acertar  =  +%d datos de ciencia   ·   rápido  =  +%d" % [DATOS_ACIERTO, DATOS_RAPIDO], 24, EstiloUI.COL_TEXTO)
	rec.position = Vector2(56.0, 400.0)
	_cuerpo.add_child(rec)
	var b := EstiloUI.boton("EMPEZAR", 24)
	b.custom_minimum_size = Vector2(300.0, 56.0)
	b.position = Vector2(56.0, 600.0)
	b.pressed.connect(_practica_hecha_y_elegir)
	_cuerpo.add_child(b)


func _fase_resultado(elegida: int, acierto: bool, ganados: int, rapido: bool) -> void:
	_fase = Fase.RESULTADO
	_limpiar()
	var mat := DatosMarte.material(_real)
	var col_v := EstiloUI.COL_OK if acierto else Color(1.0, 0.45, 0.35)
	var t := "¡CORRECTO!" if acierto else ("TIEMPO AGOTADO" if elegida < 0 else "NO ERA ESE")
	var cab := EstiloUI.etiqueta(t, 36, col_v, true)
	cab.position = Vector2(56.0, 120.0)
	_cuerpo.add_child(cab)
	var que := EstiloUI.etiqueta("Era: %s" % str(mat["nombre"]), 24, mat["color"], true)
	que.position = Vector2(56.0, 176.0)
	_cuerpo.add_child(que)
	var esp := Espectro.new()
	esp.picos = firma(_real)
	esp.ruido = false
	esp.color = mat["color"]
	esp.custom_minimum_size = Vector2(1120.0, 150.0)
	esp.position = Vector2(56.0, 222.0)
	_cuerpo.add_child(esp)
	var dato := _texto(str(mat["dato"]), 18, EstiloUI.COL_TEXTO, 1120.0)
	dato.position = Vector2(56.0, 400.0)
	_cuerpo.add_child(dato)
	var rec := "+%d datos de ciencia" % ganados if acierto else "Sin datos esta vez"
	if acierto and rapido:
		rec += "  (con bono de rapidez)"
	var rec_l := EstiloUI.etiqueta(rec, 20, EstiloUI.COL_OK if acierto else EstiloUI.COL_TENUE)
	rec_l.position = Vector2(56.0, 540.0)
	_cuerpo.add_child(rec_l)
	var b := EstiloUI.boton("CONTINUAR" if _ronda + 1 < _jugadas else "VER RESULTADO", 22)
	b.custom_minimum_size = Vector2(300.0, 52.0)
	b.position = Vector2(56.0, 610.0)
	b.pressed.connect(_siguiente)
	_cuerpo.add_child(b)
	var ayuda := EstiloUI.etiqueta("ENTER o ESPACIO", 14, EstiloUI.COL_TENUE)
	ayuda.position = Vector2(380.0, 626.0)
	_cuerpo.add_child(ayuda)


func _siguiente() -> void:
	_ronda += 1
	if _ronda < _jugadas:
		_fase_ronda()
	else:
		_fase_fin()


func _fase_fin() -> void:
	_fase = Fase.FIN
	_limpiar()
	var perfecto := _jugadas >= 2 and _aciertos == _jugadas
	MetaEstado.sumar_datos(_datos_sesion)
	for i in range(_jugadas):
		MetaEstado.registrar_analisis(perfecto and i == 0)
	var cab := EstiloUI.etiqueta("ANÁLISIS TERMINADO", 36, Color(0.78, 0.58, 1.0), true)
	cab.position = Vector2(56.0, 130.0)
	_cuerpo.add_child(cab)
	var res := EstiloUI.etiqueta("Aciertos: %d / %d      Datos de ciencia ganados: +%d      Total: %d" % [_aciertos, _jugadas, _datos_sesion, MetaEstado.datos()], 22, EstiloUI.COL_TEXTO)
	res.position = Vector2(56.0, 200.0)
	_cuerpo.add_child(res)
	var y := 270.0
	if perfecto:
		var t := _texto("¡Todos los análisis acertados! Análisis perfecto.", 18, Color(0.78, 0.58, 1.0), 1120.0)
		t.position = Vector2(56.0, y)
		_cuerpo.add_child(t)
		y += 60.0
	var nivel_n := Colonia.nivel("laboratorio")
	var falta := Colonia.falta("laboratorio")
	var pie := "Análisis hechos: %d.  " % MetaEstado.analisis_hechos()
	if nivel_n < 3:
		pie += "Faltan %d para subir el Laboratorio de la colonia (más tiempo y menos candidatos)." % falta
	else:
		pie += "El Laboratorio de la colonia está al máximo."
	var pie_l := _texto(pie, 16, EstiloUI.COL_TENUE, 1120.0)
	pie_l.position = Vector2(56.0, y)
	_cuerpo.add_child(pie_l)
	_cola.clear()
	var b1 := EstiloUI.boton("OTRO ANÁLISIS", 22)
	b1.custom_minimum_size = Vector2(280.0, 52.0)
	b1.position = Vector2(56.0, 610.0)
	b1.pressed.connect(_fase_elegir)
	_cuerpo.add_child(b1)
	var b2 := EstiloUI.boton("CERRAR", 22)
	b2.custom_minimum_size = Vector2(200.0, 52.0)
	b2.position = Vector2(352.0, 610.0)
	b2.pressed.connect(_cerrar)
	_cuerpo.add_child(b2)


class Espectro extends Control:
	var picos: Array = []
	var ruido: bool = false
	var color: Color = Color(1.0, 0.6, 0.25)
	var _r: Array[float] = []

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		for i in range(241):
			_r.append(rng.randf_range(-1.0, 1.0))

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.045, 0.9))
		for i in range(1, 8):
			var x := w * float(i) / 8.0
			draw_line(Vector2(x, 0.0), Vector2(x, h), Color(1, 1, 1, 0.06), 1.0)
		for i in range(1, 4):
			var y := h * float(i) / 4.0
			draw_line(Vector2(0.0, y), Vector2(w, y), Color(1, 1, 1, 0.06), 1.0)
		var pts := PackedVector2Array()
		var n := 240
		for i in range(n + 1):
			var xf := float(i) / float(n)
			var v := 0.05
			for p in picos:
				var pv: Vector3 = p
				var d := (xf - pv.x) / pv.z
				v += pv.y * exp(-d * d)
			if ruido and i < _r.size():
				v += 0.03 * _r[i]
			pts.append(Vector2(xf * w, h - 6.0 - clampf(v, 0.0, 1.15) * (h - 14.0) * 0.86))
		draw_polyline(pts, color, 2.0, true)
		draw_rect(Rect2(Vector2.ZERO, size), Color(color.r, color.g, color.b, 0.35), false, 1.0)


class Guia extends Control:
	var paso: int = 0
	var picos: Array = []
	var ok: int = 0
	var _t: float = 0.0

	const ESP := Rect2(56.0, 156.0, 1120.0, 230.0)
	const AMARILLO := Color(1.0, 0.85, 0.35)

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _mini(i: int) -> Rect2:
		return Rect2(56.0 + 380.0 * float(i), 436.0, 360.0, 96.0)

	func _boton(i: int) -> Rect2:
		return Rect2(56.0 + 380.0 * float(i), 538.0, 360.0, 46.0)


	func _punta(r: Rect2, p: Vector3) -> Vector2:
		var v := 0.05 + p.y
		return Vector2(r.position.x + p.x * r.size.x, r.position.y + r.size.y - 6.0 - clampf(v, 0.0, 1.15) * (r.size.y - 14.0) * 0.86)

	func _draw() -> void:
		var pulso := 0.5 + 0.5 * sin(_t * 5.0)
		if paso == 0:
			for p in picos:
				var c := _punta(ESP, p)
				draw_arc(c, 12.0 + 5.0 * pulso, 0.0, TAU, 28, AMARILLO, 3.0, true)
				draw_circle(c, 4.0, AMARILLO)
		elif paso == 1:

			for i in range(3):
				var r := _mini(i)
				for p in picos:
					var x := r.position.x + (p as Vector3).x * r.size.x
					var y := r.position.y + 4.0
					while y < r.position.y + r.size.y - 4.0:
						draw_line(Vector2(x, y), Vector2(x, minf(y + 6.0, r.position.y + r.size.y - 4.0)), Color(1.0, 0.85, 0.35, 0.55 + 0.3 * pulso), 2.0)
						y += 11.0
			for p in picos:
				var c := _punta(ESP, p)
				draw_circle(c, 5.0 + 2.0 * pulso, AMARILLO)
		else:
			var rb := _boton(ok)
			var rm := _mini(ok)
			var caja := Rect2(rm.position - Vector2(6, 6), Vector2(rm.size.x + 12.0, rb.end.y - rm.position.y + 12.0))
			draw_rect(caja, Color(0.45, 0.95, 0.55, 0.12 + 0.12 * pulso))
			draw_rect(caja, Color(0.45, 0.95, 0.55, 0.9), false, 3.0 + 2.0 * pulso)

			var cx := caja.position.x + caja.size.x * 0.5
			var y0 := caja.position.y - 14.0 - 8.0 * pulso
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 16.0, y0 - 26.0), Vector2(cx + 16.0, y0 - 26.0), Vector2(cx, y0)]), Color(0.45, 0.95, 0.55))
