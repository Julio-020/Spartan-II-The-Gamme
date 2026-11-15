extends CanvasLayer


signal jugar_pulsado
signal intro_pedida

signal partida_cambiada

signal expedicion_pedida(datos: Dictionary)

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const BotonNasa := preload("res://interfaz/boton_nasa.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const AvatarPiloto := preload("res://interfaz/avatar_piloto.gd")
const MapaRutas := preload("res://interfaz/mapa_rutas.gd")
const PantallaComite := preload("res://interfaz/pantalla_comite.gd")
const PantallaDiario := preload("res://interfaz/pantalla_diario.gd")
const DiarioNovedades := preload("res://progreso/diario_novedades.gd")
const IntroPrograma := preload("res://cinematicas/intro_programa.gd")
const MarcoHUD := preload("res://interfaz/marco_hud.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Partidas := preload("res://nucleo/partidas.gd")
const Expedicion := preload("res://progreso/expedicion.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const Bitacora := preload("res://progreso/bitacora.gd")
const ModoFoto := preload("res://mision/modo_foto.gd")
const ColoniaEstado := preload("res://progreso/colonia_estado.gd")

const COL_ACENTO := Color(0.99, 0.24, 0.13)
const COL_TEXTO := Color(0.94, 0.91, 0.87)
const COL_TENUE := Color(1.0, 1.0, 1.0, 0.72)
const VERSION := "v0.1"


const CREDITOS := [
	["Dirección y diseño", "Julian David Correa Bonilla"],
	["Programación", "Julian Correa"],
	["Psicología", "David Gutiérrez · Alexandra Gutiérrez · Dhannia Riaño · Diego Lara"],
	["Arte 3D (robot, base y módulo de aterrizaje)", "Modelado por código"],
	["Música y sonido", "Generados por código"],
	["Planeta procedural", "Chunked LOD Planet · © 2026 CUBERACT · Licencia MIT"],
	["Motor", "Godot Engine 4"],
]


var _b_diario: Button = null
var audio = null

var sala = null

var _raiz: Control
var _pila: Control
var _vistas: Dictionary = {}
var _controles: Dictionary = {}
var _vista_actual: String = "principal"
var _bloqueado: bool = false
var _midiendo: bool = false
var _tween: Tween


var _perfil_para_jugar: bool = false
var _avatar: Control
var _campo_nombre: LineEdit
var _btns_genero: Array[Button] = []
var _btns_piel: Array[Button] = []
var _btns_pelo: Array[Button] = []
var _lbl_tarjeta_nombre: Label
var _lbl_tarjeta_rango: Label
var _btn_confirmar: Button


var _exp_semilla: int = 1
var _exp_nivel: int = 0
var _exp_campo: LineEdit
var _exp_btns_nivel: Array[Button] = []
var _exp_info: Label
var _exp_top: Label
var _exp_aviso: Label


var _caja_ranuras: VBoxContainer
var _btn_volver_ranuras: Button
var _lbl_partida: Label
var _cred_misiones: RichTextLabel
var _lbl_resumen: Label


func _ready() -> void:
	layer = 20
	_construir()
	_ir(_vista_inicial(), false)
	_raiz.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 1.0, 1.4)


func mostrar() -> void:
	visible = true
	_bloqueado = false
	_ir(_vista_inicial(), false)
	_raiz.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 1.0, 0.5)


func _vista_inicial() -> String:
	return "partidas" if Partidas.slot == 0 else "principal"


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _bloqueado:
		return
	if event.is_action_pressed("ui_cancel") and _vista_actual != "principal" \
			and not (_vista_actual == "partidas" and Partidas.slot == 0):
		get_viewport().set_input_as_handled()
		_volver()


func _construir() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_raiz)


	var grad := Gradient.new()
	grad.set_color(0, Color(0.02, 0.01, 0.01, 0.96))
	grad.set_color(1, Color(0.02, 0.01, 0.01, 0.0))
	grad.add_point(0.6, Color(0.02, 0.01, 0.01, 0.62))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(1.0, 0.0)
	tex.width = 256
	tex.height = 8
	var fondo := TextureRect.new()
	fondo.texture = tex
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.anchor_right = 0.72
	fondo.anchor_bottom = 1.0
	_raiz.add_child(fondo)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 8)
	columna.anchor_bottom = 1.0
	columna.offset_left = 90.0
	columna.offset_top = 40.0
	columna.offset_right = 760.0
	columna.offset_bottom = -64.0
	_raiz.add_child(columna)


	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 24)
	fila.add_child(_label_titulo("SPARTANS", COL_TEXTO, 66))
	fila.add_child(_label_titulo("II", COL_ACENTO, 66))
	columna.add_child(fila)

	var sub := _etiqueta("EXPLORACIÓN Y RECOLECCIÓN EN MARTE", 20, COL_TENUE)
	columna.add_child(sub)

	var linea := ColorRect.new()
	linea.color = COL_ACENTO
	linea.custom_minimum_size = Vector2(300.0, 3.0)
	linea.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	columna.add_child(linea)

	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(0.0, 14.0)
	columna.add_child(espacio)

	_pila = Control.new()
	_pila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_pila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna.add_child(_pila)

	_vista_principal()
	_vista_mas()
	_vista_partidas()
	_vista_expedicion()
	_vista_piloto()
	_vista_ajustes()
	_vista_ayuda()
	_vista_creditos()
	_vista_salir()

	var marco := MarcoHUD.new()
	_raiz.add_child(marco)

	var ver := _etiqueta(VERSION, 16, COL_TENUE)
	ver.anchor_top = 1.0
	ver.anchor_bottom = 1.0
	ver.anchor_left = 1.0
	ver.anchor_right = 1.0
	ver.offset_left = -150.0
	ver.offset_top = -84.0
	ver.offset_right = -40.0
	ver.offset_bottom = -58.0
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_raiz.add_child(ver)


func _nueva_vista(nombre: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 12)
	v.visible = false
	_pila.add_child(v)
	_vistas[nombre] = v
	return v


func _vista_principal() -> void:
	var v := _nueva_vista("principal")
	var cab := HBoxContainer.new()
	cab.add_theme_constant_override("separation", 14)
	_lbl_partida = _etiqueta("", 19, COL_TENUE)
	cab.add_child(_lbl_partida)
	var b_cambiar := _boton("CAMBIAR PARTIDA", 16)
	b_cambiar.custom_minimum_size = Vector2(210.0, 30.0)
	b_cambiar.pressed.connect(_ir.bind("partidas"))
	cab.add_child(b_cambiar)
	v.add_child(cab)

	_lbl_resumen = _etiqueta("", 17, COL_TENUE)
	_lbl_resumen.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_resumen.custom_minimum_size = Vector2(420.0, 0.0)
	v.add_child(_lbl_resumen)

	var b_jugar := _boton("JUGAR", 32, "", "01")
	b_jugar.custom_minimum_size = Vector2(420.0, 66.0)
	b_jugar.pressed.connect(_on_jugar)
	v.add_child(b_jugar)
	var b_exp := _boton("EXPEDICIÓN INFINITA", 22, "", "02")
	b_exp.custom_minimum_size = Vector2(420.0, 46.0)
	if USAR_BOTON_NASA:
		b_exp.set("color", EstiloUI.COL_FRIO)
	b_exp.pressed.connect(_ir.bind("expedicion"))
	v.add_child(b_exp)
	var b_diario := _boton("DIARIO", 22, "", "03")
	b_diario.custom_minimum_size = Vector2(420.0, 46.0)
	if USAR_BOTON_NASA:
		b_diario.set("color", EstiloUI.COL_AVISO)
	b_diario.pressed.connect(_abrir_diario)
	v.add_child(b_diario)
	_b_diario = b_diario
	_refrescar_novedades()

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	var b_piloto := _boton("PILOTO", 15)
	b_piloto.pressed.connect(_abrir_piloto.bind(false))
	var b_rutas := _boton("RUTAS", 15)
	b_rutas.pressed.connect(_abrir_rutas)
	var b_comite := _boton("COMITÉ", 15)
	b_comite.pressed.connect(_abrir_comite)
	for b in [b_piloto, b_rutas, b_comite]:
		(b as Button).custom_minimum_size = Vector2(140.0, 40.0)
		(b as Button).alignment = HORIZONTAL_ALIGNMENT_LEFT
		fila.add_child(b)
	v.add_child(fila)
	var b_mas := _boton("MÁS", 18)
	b_mas.custom_minimum_size = Vector2(420.0, 40.0)
	b_mas.pressed.connect(_ir.bind("mas"))
	v.add_child(b_mas)
	var b_salir := _boton("SALIR DEL JUEGO", 16)
	b_salir.custom_minimum_size = Vector2(420.0, 34.0)
	b_salir.pressed.connect(_ir.bind("salir"))
	if not OS.has_feature("web"):
		v.add_child(b_salir)
	v.add_theme_constant_override("separation", 7)


func _vista_mas() -> void:
	var v := _nueva_vista("mas")
	v.add_child(_etiqueta("MÁS", 34, COL_ACENTO))
	for par in [["ÁLBUM DE FOTOS", "album"], ["AYUDA Y CONTROLES", "ayuda"], ["EL PROGRAMA", ""], ["CONFIGURACIONES", "ajustes"], ["CRÉDITOS", "creditos"]]:
		var b := _boton(str(par[0]), 22)
		b.custom_minimum_size = Vector2(420.0, 46.0)
		if str(par[1]) == "":
			b.pressed.connect(_abrir_programa)
		elif str(par[1]) == "album":
			b.pressed.connect(_abrir_album)
		else:
			b.pressed.connect(_ir.bind(str(par[1])))
		v.add_child(b)
	var b_vol := _boton("VOLVER", 22)
	b_vol.custom_minimum_size = Vector2(420.0, 46.0)
	b_vol.pressed.connect(_volver)
	v.add_child(b_vol)
	v.add_theme_constant_override("separation", 8)


func _texto_resumen() -> String:
	var total := DatosMarte.MISIONES.size()
	var lineas: Array[String] = []
	lineas.append("Campaña: %d / %d misiones" % [mini(Ajustes.campana, total), total])
	var ultima := ""
	var es := Bitacora.entradas()
	for i in range(es.size() - 1, -1, -1):
		if not bool((es[i] as Dictionary).get("exp", false)):
			ultima = str((es[i] as Dictionary).get("nombre", ""))
			break
	if ultima != "":
		lineas.append("Última misión: %s" % ultima)
	lineas.append("Almacén: %d muestras · %d datos · Colonia: nivel %d" % [MetaEstado.stock_total(), MetaEstado.datos(), ColoniaEstado.niveles_total()])
	return "\n".join(PackedStringArray(lineas))


func _actualizar_cabecera() -> void:
	if _lbl_partida == null:
		return
	if _lbl_resumen != null:
		_lbl_resumen.text = _texto_resumen() if (Partidas.slot > 0 and Ajustes.perfil_hecho) else ""
		_lbl_resumen.visible = _lbl_resumen.text != ""
	if Partidas.slot <= 0:
		_lbl_partida.text = ""
		return
	var quien := Ajustes.nombre_visible() if Ajustes.perfil_hecho else "campaña nueva"
	_lbl_partida.text = "PARTIDA %d  ·  %s" % [Partidas.slot, quien.to_upper()]


func _vista_partidas() -> void:
	var v := _nueva_vista("partidas")
	v.add_child(_etiqueta("PARTIDAS", 34, COL_ACENTO))
	v.add_child(_etiqueta("Cada ranura es una campaña distinta: piloto, historia, comité, medallas y rutas.", 17, COL_TENUE))
	_caja_ranuras = VBoxContainer.new()
	_caja_ranuras.add_theme_constant_override("separation", 10)
	v.add_child(_caja_ranuras)
	_btn_volver_ranuras = _boton("VOLVER", 22)
	_btn_volver_ranuras.custom_minimum_size = Vector2(200.0, 46.0)
	_btn_volver_ranuras.pressed.connect(_volver)
	v.add_child(_btn_volver_ranuras)


func _vista_expedicion() -> void:
	var v := _nueva_vista("expedicion")
	v.add_theme_constant_override("separation", 8)
	v.add_child(_etiqueta("EXPEDICIÓN INFINITA", 32, COL_ACENTO))
	var sub := _etiqueta("Una misión inventada con un número (la semilla): la misma semilla da siempre la misma. No toca tu campaña.", 16, COL_TENUE)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(600.0, 0.0)
	v.add_child(sub)
	var f1 := HBoxContainer.new()
	f1.add_theme_constant_override("separation", 12)
	var l1 := _etiqueta("SEMILLA", 19, COL_TEXTO)
	l1.custom_minimum_size = Vector2(110.0, 0.0)
	f1.add_child(l1)
	_exp_campo = LineEdit.new()
	_exp_campo.max_length = 6
	_exp_campo.custom_minimum_size = Vector2(150.0, 34.0)
	_exp_campo.add_theme_font_size_override("font_size", 20)
	_exp_campo.text_changed.connect(_on_exp_semilla_texto)
	f1.add_child(_exp_campo)
	var b_azar := _boton("AL AZAR", 17)
	b_azar.custom_minimum_size = Vector2(130.0, 34.0)
	b_azar.pressed.connect(_on_exp_azar)
	f1.add_child(b_azar)
	v.add_child(f1)
	var f2 := HBoxContainer.new()
	f2.add_theme_constant_override("separation", 8)
	var l2 := _etiqueta("NIVEL", 19, COL_TEXTO)
	l2.custom_minimum_size = Vector2(110.0, 0.0)
	f2.add_child(l2)
	for i in range(Expedicion.NIVELES.size()):
		var b := _boton(str(Expedicion.NIVELES[i]), 17)
		b.custom_minimum_size = Vector2(130.0, 34.0)
		b.toggle_mode = true
		b.pressed.connect(_on_exp_nivel.bind(i))
		f2.add_child(b)
		_exp_btns_nivel.append(b)
	v.add_child(f2)
	var cuerpo := HBoxContainer.new()
	cuerpo.add_theme_constant_override("separation", 14)
	v.add_child(cuerpo)
	var c1 := PanelContainer.new()
	c1.add_theme_stylebox_override("panel", _estilo_caja())
	c1.custom_minimum_size = Vector2(340.0, 230.0)
	c1.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_exp_info = _etiqueta("", 16, COL_TEXTO)
	_exp_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_exp_info.custom_minimum_size = Vector2(320.0, 0.0)
	c1.add_child(_exp_info)
	cuerpo.add_child(c1)
	var c2 := PanelContainer.new()
	c2.add_theme_stylebox_override("panel", _estilo_caja())
	c2.custom_minimum_size = Vector2(290.0, 230.0)
	c2.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_exp_top = _etiqueta("", 15, COL_TEXTO)
	c2.add_child(_exp_top)
	cuerpo.add_child(c2)
	_exp_aviso = _etiqueta("", 16, Color(1.0, 0.7, 0.3))
	v.add_child(_exp_aviso)
	var f3 := HBoxContainer.new()
	f3.add_theme_constant_override("separation", 12)
	var b_partir := _boton("PARTIR", 22)
	b_partir.custom_minimum_size = Vector2(200.0, 44.0)
	b_partir.pressed.connect(_on_exp_partir)
	f3.add_child(b_partir)
	var b_vol := _boton("VOLVER", 22)
	b_vol.custom_minimum_size = Vector2(160.0, 44.0)
	b_vol.pressed.connect(_volver)
	f3.add_child(b_vol)
	v.add_child(f3)


func _refrescar_expedicion() -> void:
	if _exp_campo == null:
		return
	if _exp_campo.text != str(_exp_semilla) and not _exp_campo.has_focus():
		_exp_campo.text = str(_exp_semilla)
	for i in range(_exp_btns_nivel.size()):
		_exp_btns_nivel[i].set_pressed_no_signal(i == _exp_nivel)
	var d := Expedicion.generar(_exp_semilla, _exp_nivel)
	var mats: Array[String] = []
	for m in (d["muestras"] as Dictionary):
		mats.append("%d %s" % [int(d["muestras"][m]), str(DatosMarte.material(str(m))["plural"])])
	var t := "%s\n%s\nBase a %d km  ·  Bodega: %d muestras\nMuestras: %s" % [str(d["nombre"]).to_upper(), str(d["nave"]),
			roundi(float(d["dist"]) / 10.0), int(d["capacidad"]), ", ".join(mats)]
	var amb: Dictionary = d["amb"]
	t += "\nSol a %d°  ·  %d °C  ·  Viento %d %%" % [roundi(float(amb["sol_elev"])), roundi(float(amb["temp"])), roundi(float(amb["viento"]) * 100.0)]
	var cond := DatosMarte.condicion(d)
	if not cond.is_empty():
		t += "\n¡%s!" % str(cond["n"])
	var mult: float = float(Expedicion.MULT_NIVEL[_exp_nivel])
	t += "\nMultiplicador de nivel: ×%s" % str(mult)
	_exp_info.text = t
	var lista := MetaEstado.records_exp(Expedicion.clave(_exp_semilla, _exp_nivel))
	var tt := "TOP 10 · SEMILLA %d" % _exp_semilla
	if lista.is_empty():
		tt += "\n\nAún nadie ha puntuado aquí.\nSé el primero."
	else:
		for i in range(lista.size()):
			var r: Dictionary = lista[i]
			tt += "\n%2d. %s  %d" % [i + 1, str(r["n"]).substr(0, 12), int(r["p"])]
	_exp_top.text = tt
	_exp_aviso.text = "" if Ajustes.perfil_hecho else "Primero crea tu piloto (PILOTO en el menú)."


func _on_exp_semilla_texto(texto: String) -> void:
	var limpio := ""
	for c in texto:
		if c >= "0" and c <= "9":
			limpio += c
	if limpio != texto:
		_exp_campo.text = limpio
		_exp_campo.caret_column = limpio.length()
	_exp_semilla = clampi(int(limpio) if limpio != "" else 1, 1, Expedicion.SEMILLA_MAX)
	_refrescar_expedicion()


func _on_exp_azar() -> void:
	_exp_semilla = Expedicion.semilla_al_azar()
	_exp_campo.text = str(_exp_semilla)
	_refrescar_expedicion()


func _on_exp_nivel(i: int) -> void:
	_exp_nivel = i
	_refrescar_expedicion()


func _on_exp_partir() -> void:
	if _bloqueado:
		return
	if not Ajustes.perfil_hecho:
		_exp_aviso.text = "Primero crea tu piloto (PILOTO en el menú)."
		return
	var d := Expedicion.generar(_exp_semilla, _exp_nivel)
	_bloqueado = true
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		visible = false
		expedicion_pedida.emit(d))


func _refrescar_partidas() -> void:
	for c in _caja_ranuras.get_children():
		c.queue_free()
	_btn_volver_ranuras.visible = Partidas.slot > 0
	for n in range(1, Partidas.MAX_RANURAS + 1):
		Partidas.recuperar_ranura(n)
	if Partidas.aviso != "":
		var av := _etiqueta(Partidas.aviso, 16, Color(1.0, 0.8, 0.3))
		av.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		av.custom_minimum_size = Vector2(900.0, 0.0)
		_caja_ranuras.add_child(av)
	var ultima := Partidas.ultima_ranura()
	var foco: Button = null
	for n in range(1, Partidas.MAX_RANURAS + 1):
		var r := Partidas.resumen(n)
		var existe: bool = bool(r["existe"])
		var activa: bool = (n == Partidas.slot)
		var caja := PanelContainer.new()
		var est := _estilo_caja()
		est.content_margin_top = 10.0
		est.content_margin_bottom = 10.0
		if activa or (Partidas.slot == 0 and n == ultima):
			est.border_color = COL_ACENTO
			est.set_border_width_all(2)
		caja.add_theme_stylebox_override("panel", est)
		_caja_ranuras.add_child(caja)
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 16)
		caja.add_child(fila)
		if existe:
			var av := AvatarPiloto.new()
			av.custom_minimum_size = Vector2(78.0, 78.0)
			av.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			av.set("genero", int(r["genero"]))
			av.set("piel", int(r["piel"]))
			av.set("pelo", int(r["pelo"]))
			fila.add_child(av)
		var info := VBoxContainer.new()
		info.add_theme_constant_override("separation", 2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fila.add_child(info)
		if existe:
			var nombre := str(r["nombre"]).strip_edges()
			if nombre.is_empty():
				nombre = "Piloto nuevo"
			var marca := "  ·  ACTIVA" if activa else ("  ·  ÚLTIMA" if n == ultima else "")
			info.add_child(_etiqueta("%d  ·  %s%s" % [n, nombre.to_upper(), marca], 24, Color.WHITE))
			var rango := str(r["rango"])
			info.add_child(_etiqueta("%s  ·  Misiones %d/%d  ·  Historia %d %%" % [rango if not rango.is_empty() else "CADETE",
					int(r["hechas"]), Partidas.TOTAL_MISIONES, int(r["pct"])], 17, COL_TEXTO))
			info.add_child(_etiqueta("Medallas %d   ·   Guardada: %s" % [int(r["medallas"]), Partidas.fecha_texto(int(r["ultima"]))], 15, COL_TENUE))
		else:
			info.add_child(_etiqueta("%d  ·  RANURA VACÍA" % n, 24, COL_TENUE))
			info.add_child(_etiqueta("Empieza una campaña nueva con otro piloto.", 16, COL_TENUE))
		var botones := VBoxContainer.new()
		botones.add_theme_constant_override("separation", 4)
		botones.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fila.add_child(botones)
		var b_main := _boton("CONTINUAR" if existe else "NUEVA CAMPAÑA", 18)
		b_main.custom_minimum_size = Vector2(190.0, 38.0)
		b_main.pressed.connect(_elegir_ranura.bind(n))
		botones.add_child(b_main)
		if foco == null or (Partidas.slot == 0 and n == ultima) or (activa):
			foco = b_main
		if existe:
			var b_borrar := _boton("BORRAR", 15)
			b_borrar.custom_minimum_size = Vector2(190.0, 28.0)
			b_borrar.pressed.connect(_borrar_ranura.bind(n, b_borrar))
			botones.add_child(b_borrar)
			var copia := Partidas.ultima_copia(n)
			if copia != "":
				var b_copia := _boton(tr("COPIA  %s") % Partidas.COPIAS.texto_fecha(copia), 14)
				b_copia.custom_minimum_size = Vector2(190.0, 26.0)
				b_copia.pressed.connect(_restaurar_copia.bind(n, b_copia))
				botones.add_child(b_copia)
	if foco != null:
		foco.grab_focus.call_deferred()


func _elegir_ranura(n: int) -> void:
	if _bloqueado:
		return
	var nueva := not Partidas.existe(n)
	Partidas.aviso = ""
	Partidas.entrar(n)
	partida_cambiada.emit()
	_actualizar_cabecera()
	if nueva or not Ajustes.perfil_hecho:
		_abrir_piloto(true)
	else:
		_ir("principal")


func _borrar_ranura(n: int, b: Button) -> void:
	if bool(b.get_meta("confirmar", false)):
		var era_activa: bool = (n == Partidas.slot)
		Partidas.borrar(n)
		if era_activa:
			partida_cambiada.emit()
			_actualizar_cabecera()
		_refrescar_partidas()
	else:
		b.set_meta("confirmar", true)
		b.text = "¿SEGURO? PULSA DE NUEVO"


func _restaurar_copia(n: int, b: Button) -> void:
	if bool(b.get_meta("confirmar", false)):
		Partidas.restaurar_ultima(n)
		partida_cambiada.emit()
		_actualizar_cabecera()
		_refrescar_partidas()
	else:
		b.set_meta("confirmar", true)
		b.text = "¿VOLVER A ESA COPIA?"


func _abrir_programa() -> void:
	add_child(IntroPrograma.new())


func _abrir_diario() -> void:
	var m := PantallaDiario.new()
	m.cerrada.connect(_refrescar_novedades)
	add_child(m)


func _refrescar_novedades() -> void:
	if _b_diario == null or not is_instance_valid(_b_diario):
		return
	_b_diario.text = "DIARIO  ● NUEVO" if DiarioNovedades.total() > 0 else "DIARIO"


func _abrir_album() -> void:
	if Partidas.slot <= 0:
		return
	add_child(ModoFoto.Album.new())


func _abrir_comite() -> void:
	var m := PantallaComite.new()
	add_child(m)


func _abrir_rutas() -> void:
	var m := MapaRutas.new()
	add_child(m)


func _vista_piloto() -> void:
	var v := _nueva_vista("piloto")
	v.add_child(_etiqueta("PILOTO", 34, COL_ACENTO))
	v.add_child(_etiqueta("Elige cómo te verás en las misiones.", 18, COL_TENUE))

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 34)
	v.add_child(fila)


	var izq := VBoxContainer.new()
	izq.add_theme_constant_override("separation", 6)
	izq.custom_minimum_size = Vector2(190.0, 0.0)
	fila.add_child(izq)
	_avatar = AvatarPiloto.new()
	_avatar.custom_minimum_size = Vector2(170.0, 170.0)
	_avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	izq.add_child(_avatar)
	_lbl_tarjeta_nombre = _etiqueta("", 24, Color.WHITE)
	_lbl_tarjeta_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_tarjeta_nombre.clip_text = true
	izq.add_child(_lbl_tarjeta_nombre)
	_lbl_tarjeta_rango = _etiqueta("", 15, COL_ACENTO)
	_lbl_tarjeta_rango.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	izq.add_child(_lbl_tarjeta_rango)


	var der := VBoxContainer.new()
	der.add_theme_constant_override("separation", 10)
	der.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(der)

	der.add_child(_seccion("GÉNERO Y APARIENCIA"))
	var fila_g := HBoxContainer.new()
	fila_g.add_theme_constant_override("separation", 12)
	der.add_child(fila_g)
	var grupo := ButtonGroup.new()
	var textos := ["MASCULINO", "FEMENINO"]
	for i in range(2):
		var b := _boton(textos[i], 22)
		b.custom_minimum_size = Vector2(200.0, 54.0)
		b.toggle_mode = true
		b.button_group = grupo
		if not USAR_BOTON_NASA:
			b.add_theme_stylebox_override("pressed", _estilo_boton(true))
			b.add_theme_stylebox_override("hover_pressed", _estilo_boton(true))
		b.pressed.connect(_on_genero.bind(i))
		fila_g.add_child(b)
		_btns_genero.append(b)

	if AvatarPiloto.MOSTRAR_ROSTRO:
		var sep0 := Control.new()
		sep0.custom_minimum_size = Vector2(12.0, 1.0)
		fila_g.add_child(sep0)
		var fila_m := fila_g
		var grupo_piel := ButtonGroup.new()
		for i in range(AvatarPiloto.PIELES.size()):
			var bp := _muestra(AvatarPiloto.PIELES[i], grupo_piel)
			bp.tooltip_text = "Tono de piel"
			bp.pressed.connect(_on_piel.bind(i))
			fila_m.add_child(bp)
			_btns_piel.append(bp)
		var sep := Control.new()
		sep.custom_minimum_size = Vector2(14.0, 1.0)
		fila_m.add_child(sep)
		var grupo_pelo := ButtonGroup.new()
		for i in range(AvatarPiloto.PELOS.size()):
			var bc := _muestra(AvatarPiloto.PELOS[i], grupo_pelo)
			bc.tooltip_text = "Cabello"
			bc.pressed.connect(_on_pelo.bind(i))
			fila_m.add_child(bc)
			_btns_pelo.append(bc)

	der.add_child(_seccion("NOMBRE"))
	_campo_nombre = LineEdit.new()
	_campo_nombre.placeholder_text = "Escribe tu nombre"
	_campo_nombre.max_length = Ajustes.NOMBRE_MAX
	_campo_nombre.custom_minimum_size = Vector2(412.0, 54.0)
	_campo_nombre.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_campo_nombre.add_theme_font_size_override("font_size", 24)
	_campo_nombre.add_theme_color_override("font_color", Color.WHITE)
	_campo_nombre.add_theme_color_override("font_placeholder_color", COL_TENUE)
	_campo_nombre.add_theme_color_override("caret_color", COL_ACENTO)
	_campo_nombre.add_theme_stylebox_override("normal", _estilo_boton(false))
	_campo_nombre.add_theme_stylebox_override("focus", _estilo_boton(true))
	_campo_nombre.text_changed.connect(_on_nombre_cambiado)
	_campo_nombre.text_submitted.connect(_on_nombre_enviado)
	der.add_child(_campo_nombre)
	der.add_child(_etiqueta("Hasta %d letras. Si lo dejas vacío serás \"%s\"."
			% [Ajustes.NOMBRE_MAX, Ajustes.NOMBRE_DEFECTO], 15, COL_TENUE))

	var espacio := Control.new()
	espacio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(espacio)

	var pie := HBoxContainer.new()
	pie.add_theme_constant_override("separation", 14)
	_btn_confirmar = _boton("GUARDAR", 22)
	_btn_confirmar.custom_minimum_size = Vector2(300.0, 52.0)
	_btn_confirmar.pressed.connect(_on_confirmar_piloto)
	pie.add_child(_btn_confirmar)
	var b_volver := _boton("VOLVER", 22)
	b_volver.custom_minimum_size = Vector2(200.0, 52.0)
	b_volver.pressed.connect(_volver)
	pie.add_child(b_volver)
	v.add_child(pie)


func _vista_ajustes() -> void:
	var v := _nueva_vista("ajustes")
	v.add_child(_etiqueta("CONFIGURACIONES", 34, COL_ACENTO))

	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.add_theme_constant_override("separation", 12)
	sc.add_child(caja)

	caja.add_child(_seccion("SONIDO"))
	_fila_slider(caja, "vol_general", "Volumen general", 0.0, 1.0, 0.01, true)
	_fila_slider(caja, "vol_musica", "Música", 0.0, 1.0, 0.01, true)
	_fila_slider(caja, "vol_efectos", "Efectos", 0.0, 1.0, 0.01, true)
	_fila_check(caja, "silencio", "Silenciar todo")
	_fila_check(caja, "musica_dinamica", "Música dinámica durante las misiones (cambia con la situación)")

	caja.add_child(_seccion("VIDEO"))
	_fila_opciones(caja, "calidad", "Calidad general (preajuste)", ["Baja", "Media", "Alta"])
	_fila_check(caja, "pantalla_completa", "Pantalla completa")
	_fila_opciones(caja, "resolucion", "Tamaño de la ventana", ["Sin cambiar", "1280 x 720", "1366 x 768", "1600 x 900", "1920 x 1080", "2560 x 1440"])
	_fila_check(caja, "vsync", "Sincronización vertical (V-Sync)")
	_fila_opciones(caja, "msaa", "Suavizado de bordes", ["Desactivado", "MSAA 2x", "MSAA 4x"])
	_fila_slider(caja, "escala_3d", "Resolución 3D", 0.5, 1.0, 0.05, true)
	_fila_check(caja, "mostrar_fps", "Mostrar FPS")
	_fila_check(caja, "graficos_reales", "Gráficos mejorados (sombras suaves y color de cine)")
	_fila_opciones(caja, "calidad_ambiente", "Efectos de ambiente (niebla, polvo, huellas)", ["Bajo", "Medio", "Alto"])
	_fila_check(caja, "sala_3d", "Sala de control 3D en el menú principal")
	var b_fps := _boton("PRUEBA DE RENDIMIENTO (4 segundos)", 20)
	b_fps.custom_minimum_size = Vector2(360.0, 46.0)
	b_fps.pressed.connect(_prueba_fps.bind(b_fps))
	caja.add_child(b_fps)

	caja.add_child(_seccion("JUEGO"))
	_fila_check(caja, "ver_intro", "Reproducir la introducción al iniciar")
	_fila_check(caja, "misiones_libres", "Desbloquear todas las misiones (sin seguir el orden)")
	_fila_check(caja, "riesgos", "Riesgos: batería del robot y tormentas de polvo")
	_fila_opciones(caja, "dificultad", "Dificultad", ["Fácil", "Normal", "Difícil"])
	var nota_dif := _etiqueta("Fácil: la batería dura más, hay menos tormentas y eventos, y son más cortos. Normal: el equilibrio pensado. Difícil: gastas más batería y hay más tormentas y eventos.", 15, COL_TENUE)
	nota_dif.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota_dif.custom_minimum_size = Vector2(620.0, 0.0)
	caja.add_child(nota_dif)
	_fila_check(caja, "radio", "Radio de los jefes durante la misión")
	_fila_check(caja, "ciclo_dia", "Día y noche durante la misión")
	_fila_check(caja, "eventos", "Eventos aleatorios (meteoritos, remolinos, fallos; con Riesgos)")
	var b_tut := _boton("VER EL TUTORIAL OTRA VEZ", 20)
	b_tut.custom_minimum_size = Vector2(360.0, 46.0)
	b_tut.pressed.connect(func():
		Ajustes.tutorial_hecho = false
		Ajustes.guardar()
		b_tut.text = "EL TUTORIAL SE VERÁ EN LA PRÓXIMA MISIÓN")
	caja.add_child(b_tut)
	var b_camp := _boton("REINICIAR CAMPAÑA (volver a la primera misión)", 20)
	b_camp.custom_minimum_size = Vector2(360.0, 46.0)
	b_camp.pressed.connect(_on_reiniciar_campana.bind(b_camp))
	caja.add_child(b_camp)
	var b_intro := _boton("VER INTRODUCCIÓN AHORA", 20)
	b_intro.custom_minimum_size = Vector2(360.0, 46.0)
	b_intro.pressed.connect(_on_ver_intro)
	caja.add_child(b_intro)

	caja.add_child(_seccion("CONTROLES"))
	_fila_slider(caja, "sens_giro", "Sensibilidad del ratón (y del stick del mando)", 0.3, 2.0, 0.05, false)
	_fila_check(caja, "giro_auto", "Giro automático del planeta")

	caja.add_child(_seccion("ACCESIBILIDAD E IDIOMA"))
	_fila_opciones(caja, "idioma", "Idioma / Language", ["Español", "English"])
	_fila_opciones(caja, "texto_grande", "Tamaño de subtítulos y avisos", ["Normal", "Grande", "Muy grande"])
	_fila_opciones(caja, "daltonismo", "Modo daltónico", ["Desactivado", "Protanopía (rojo)", "Deuteranopía (verde)", "Tritanopía (azul)"])
	_fila_opciones(caja, "guia_objetivo", "Flecha de objetivo", ["Apagada", "Base y señales", "Siempre"])
	_fila_opciones(caja, "consejos", "Consejos de ayuda", ["Apagados", "Activados"])
	_fila_opciones(caja, "pistas", "Pistas si te atascas", ["Apagadas", "Activadas"])
	_fila_opciones(caja, "holograma", "Holograma de FOCOS", ["Ventanita de texto", "Holograma"])
	_fila_opciones(caja, "suenos", "Sueños del rover", ["Apagados", "Activados"])

	var pie := HBoxContainer.new()
	pie.add_theme_constant_override("separation", 14)
	var b_rest := _boton("RESTABLECER", 22)
	b_rest.custom_minimum_size = Vector2(240.0, 48.0)
	b_rest.pressed.connect(_on_restablecer)
	pie.add_child(b_rest)
	var b_volver := _boton("VOLVER", 22)
	b_volver.custom_minimum_size = Vector2(200.0, 48.0)
	b_volver.pressed.connect(_volver)
	pie.add_child(b_volver)
	v.add_child(pie)


const AYUDA_SECCIONES := [
	["MAPA DE MISIONES", [
		[["CLIC"], "Clic izquierdo en un pin: iniciar la misión"],
		[["CLIC DER."], "Mantén el clic derecho y arrastra para girar el planeta"],
		[["W", "A", "S", "D"], "Girar el planeta con el teclado"],
		[["RUEDA"], "Acercar o alejar"],
		[["ESC"], "Volver al menú principal"],
	]],
	["EN LA MISIÓN", [
		[["W", "S"], "Avanzar y retroceder (también las flechas ↑ ↓)"],
		[["A", "D"], "Girar el robot (también ← →)"],
		[["SHIFT"], "Turbo: gasta más batería"],
		[["ESPACIO"], "Escanear: revela muestras y datos curiosos cerca"],
		[["E"], "Recoger muestra, leer un dato curioso o entregar en la base"],
		[["H"], "Pregunta a FOCOS: su holograma te dice qué hacer ahora (muestra más cercana, base, batería, tormenta)"],
		[["RUEDA"], "Acercar o alejar la cámara"],
		[["J"], "Diario: tu progreso, la confianza con los jefes y tus decisiones (pausa la misión)"],
		[["P"], "Modo foto: pausa, oculta la interfaz y deja orbitar la cámara; ENTER guarda la captura"],
		[["C"], "Radio a la Tierra: consulta a un jefe (1-5). La respuesta llega con retraso y habla de cómo estaba todo al preguntar"],
		[["ESC"], "Volver al planeta"],
	]],
	["HISTORIA POR RADIO", [
		[["1", "2", "3"], "Responder a un jefe cuando te consulta (las decisiones cambian la confianza)"],
		[["RADAR"], "Un punto «!» marca una misión secundaria: llega antes de que se acabe el tiempo"],
	]],
	["EXPEDICIÓN, TALLER Y LABORATORIO", [
		[["MENÚ"], "EXPEDICIÓN INFINITA: una misión nueva por semilla, con puntuación y top 10. No toca tu campaña"],
		[["J"], "Diario → TALLER: mejora el robot con las muestras y datos del almacén (solo fuera de la misión)"],
		[["LAB"], "Al terminar una misión, LABORATORIO convierte muestras en datos de ciencia (minijuego de espectros)"],
		[["*"], "Hallazgos escondidos: no salen en el radar; revélalos con el escáner cerca, con FOCOS o pasando muy cerca"],
	]],
	["MANDO", [
		[["STICK IZQ."], "Mover el robot · en el mapa, mover el cursor · en menús, moverse"],
		[["STICK DER."], "Girar el planeta (mapa) · mirar con el visor de fotos"],
		[["A", "B"], "A: recoger, leer, aceptar o clic · B: volver"],
		[["X", "Y"], "X: escáner · Y: pregunta a FOCOS"],
		[["GATILLOS"], "Derecho: turbo en la misión · en el mapa, acercar y alejar"],
		[["CRUCETA"], "Responder 1 (↑) 2 (→) 3 (↓) a los jefes · ← abre la radio · en menús, moverse"],
		[["LB", "RB"], "Radio / visor de fotos · cambiar de pestaña en el diario"],
		[["SELECT", "START"], "Select: diario · Start: volver"],
	]],
	["MISIONES DE FOTOS", [
		[["F"], "Abrir o cerrar el visor de la cámara"],
		[["RATÓN"], "Apuntar; la rueda cambia el zoom"],
		[["ESPACIO", "CLIC"], "Disparar la foto"],
	]],
	["CONSEJOS", [
		[["!"], "Vigila la batería: las tormentas de polvo tapan el Sol y no recarga"],
		[["!"], "Los sucesos al azar (meteoritos, remolinos, fallos del sensor) solo ocurren con Riesgos activados"],
		[["!"], "Entregar muestras en la base recarga un poco la batería si Julio confía en ti"],
			[["!"], "Al empezar, el robot sale solo del hangar. Si vuelves y te quedas dentro (punto H del radar), la estación de carga recarga la batería"],
	]],
]


func _vista_ayuda() -> void:
	var v := _nueva_vista("ayuda")
	v.add_child(_etiqueta("AYUDA Y CONTROLES", 34, COL_ACENTO))
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.add_theme_constant_override("separation", 10)
	sc.add_child(caja)
	for sec in AYUDA_SECCIONES:
		caja.add_child(_seccion(str(sec[0])))
		for fila in sec[1]:
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 6)
			var teclas := HBoxContainer.new()
			teclas.custom_minimum_size = Vector2(190.0, 0.0)
			teclas.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			teclas.add_theme_constant_override("separation", 4)
			for t in fila[0]:
				teclas.add_child(EstiloUI.tecla(str(t)))
			h.add_child(teclas)
			var l := _etiqueta(str(fila[1]), 17, COL_TEXTO)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size = Vector2(440.0, 0.0)
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(l)
			caja.add_child(h)
	var b := _boton("VOLVER", 22)
	b.custom_minimum_size = Vector2(200.0, 52.0)
	b.pressed.connect(_volver)
	v.add_child(b)


func _vista_creditos() -> void:
	var v := _nueva_vista("creditos")
	v.add_child(_etiqueta("CRÉDITOS", 34, COL_ACENTO))

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _estilo_caja())
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.add_theme_constant_override("separation", 22)
	scroll.add_child(caja)

	var txt := RichTextLabel.new()
	txt.bbcode_enabled = true
	txt.fit_content = true
	txt.scroll_active = false
	txt.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	txt.text = _texto_creditos()
	txt.add_theme_font_size_override("normal_font_size", 20)
	txt.add_theme_font_size_override("bold_font_size", 21)
	txt.add_theme_color_override("default_color", COL_TEXTO)
	caja.add_child(txt)


	_cred_misiones = RichTextLabel.new()
	_cred_misiones.bbcode_enabled = true
	_cred_misiones.fit_content = true
	_cred_misiones.scroll_active = false
	_cred_misiones.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_cred_misiones.add_theme_font_size_override("normal_font_size", 18)
	_cred_misiones.add_theme_font_size_override("bold_font_size", 21)
	_cred_misiones.add_theme_color_override("default_color", COL_TEXTO)
	caja.add_child(_cred_misiones)
	_actualizar_creditos()

	var b := _boton("VOLVER", 22)
	b.custom_minimum_size = Vector2(200.0, 48.0)
	b.pressed.connect(_volver)
	v.add_child(b)


func _texto_creditos() -> String:
	var s := "[center][b]SPARTANS II[/b]\n[color=#9a9a9a]%s[/color]\n\n" % Idioma.t("Exploración y recolección en Marte")
	for par in CREDITOS:
		s += "[b]%s[/b]\n%s\n\n" % [Idioma.t(str(par[0])), Idioma.t(str(par[1]))]
	return s + "[b]%s[/b][/center]" % Idioma.t("Gracias por jugar")


func _actualizar_creditos() -> void:
	if _cred_misiones == null:
		return
	var t := func(x: String) -> String: return Idioma.t(x)
	var reales: Array[String] = []
	var hechas := 0
	for m in DatosMarte.MISIONES:
		var hecha := Partidas.slot > 0 and HistoriaEstado.hecha(str(m["id"]))
		if hecha:
			hechas += 1
		var marca := "[color=#7CFF9A]✓[/color]" if hecha else "[color=#6a6a6a]○[/color]"
		var linea := "%s  %s  ·  %s  ·  [color=#9a9a9a]%s[/color]" % [marca, str(m["era"]), t.call(str(m["nave"])), t.call(str(m["nombre"]))]
		reales.append(linea)
	var s := "[center][b]%s[/b]\n[color=#9a9a9a]%s[/color]\n\n" % [t.call("MISIONES QUE INSPIRARON EL JUEGO"),
			t.call("Los lugares y las naves del juego salen de la exploración real de Marte.")]
	s += "[color=#ff7330]%s[/color]\n%s\n\n" % [t.call("EXPLORACIÓN REAL"), "\n".join(PackedStringArray(reales))]
	s += "[color=#9a9a9a]%s[/color][/center]" % (t.call("Has completado %d de %d misiones.") % [hechas, DatosMarte.MISIONES.size()])
	_cred_misiones.text = s


func _vista_salir() -> void:
	var v := _nueva_vista("salir")
	v.add_child(_etiqueta("¿SALIR DEL JUEGO?", 34, COL_ACENTO))
	var b_si := _boton("SÍ, SALIR")
	b_si.pressed.connect(func(): get_tree().quit())
	v.add_child(b_si)
	var b_no := _boton("CANCELAR")
	b_no.pressed.connect(_volver)
	v.add_child(b_no)


func _ir(nombre: String, animar: bool = true) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	for k in _vistas:
		_vistas[k].visible = (k == nombre)
	_vista_actual = nombre
	if sala != null and is_instance_valid(sala):
		sala.ir_a(nombre)
	var v: Control = _vistas[nombre]
	_actualizar_cabecera()
	if nombre == "ajustes":
		_sincronizar()
	elif nombre == "creditos":
		_actualizar_creditos()
	elif nombre == "piloto":
		_sincronizar_piloto()
	elif nombre == "partidas":
		_refrescar_partidas()
	elif nombre == "expedicion":
		if _exp_semilla <= 1:
			_exp_semilla = Expedicion.semilla_al_azar()
		_refrescar_expedicion()
	else:
		_campo_nombre.release_focus()
	if animar:
		v.modulate.a = 0.0
		_tween = create_tween()
		_tween.tween_property(v, "modulate:a", 1.0, 0.25)
	else:
		v.modulate.a = 1.0


func _volver() -> void:
	if Partidas.slot == 0:
		_ir("partidas")
		return
	if _vista_actual == "ajustes" or _vista_actual == "piloto":
		Ajustes.guardar()
	_ir("principal")


func _on_jugar() -> void:
	if _bloqueado:
		return
	if not Ajustes.perfil_hecho:
		_abrir_piloto(true)
		return
	_comenzar()


func _abrir_piloto(para_jugar: bool) -> void:
	_perfil_para_jugar = para_jugar
	_ir("piloto")


func _sincronizar_piloto() -> void:
	_campo_nombre.text = Ajustes.nombre
	_campo_nombre.caret_column = _campo_nombre.text.length()
	for i in range(_btns_genero.size()):
		_btns_genero[i].set_pressed_no_signal(i == Ajustes.genero)
	for i in range(_btns_piel.size()):
		_btns_piel[i].set_pressed_no_signal(i == Ajustes.piel)
	for i in range(_btns_pelo.size()):
		_btns_pelo[i].set_pressed_no_signal(i == Ajustes.pelo)
	_btn_confirmar.text = "CONFIRMAR Y JUGAR" if _perfil_para_jugar else "GUARDAR"
	_actualizar_tarjeta()
	_campo_nombre.grab_focus.call_deferred()


func _actualizar_tarjeta() -> void:
	_avatar.set("genero", Ajustes.genero)
	_avatar.set("piel", Ajustes.piel)
	_avatar.set("pelo", Ajustes.pelo)
	_lbl_tarjeta_nombre.text = Ajustes.nombre_visible()
	_lbl_tarjeta_rango.text = Ajustes.rango()


func _muestra(color: Color, grupo: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = grupo
	b.custom_minimum_size = Vector2(44.0, 54.0)
	for estado in ["normal", "hover", "pressed", "hover_pressed"]:
		var st := StyleBoxFlat.new()
		st.bg_color = color.lightened(0.12) if estado == "hover" else color
		st.set_corner_radius_all(10)
		var sel: bool = estado.contains("pressed")
		st.set_border_width_all(4 if sel else 2)
		st.border_color = Color.WHITE if sel else Color(0.0, 0.0, 0.0, 0.55)
		b.add_theme_stylebox_override(estado, st)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b


func _on_piel(i: int) -> void:
	Ajustes.escribir("piel", i)
	_actualizar_tarjeta()


func _on_pelo(i: int) -> void:
	Ajustes.escribir("pelo", i)
	_actualizar_tarjeta()


func _on_genero(genero: int) -> void:
	Ajustes.escribir("genero", genero)
	_actualizar_tarjeta()


func _on_nombre_cambiado(texto: String) -> void:
	Ajustes.escribir("nombre", texto)
	_actualizar_tarjeta()


func _on_nombre_enviado(_texto: String) -> void:
	_on_confirmar_piloto()


func _on_confirmar_piloto() -> void:
	Ajustes.escribir("nombre", _campo_nombre.text)
	Ajustes.escribir("perfil_hecho", true)
	Ajustes.guardar()
	if _perfil_para_jugar:
		_comenzar()
	else:
		_ir("principal")


func _comenzar() -> void:
	if _bloqueado:
		return
	if not Ajustes.programa_visto:

		Ajustes.programa_visto = true
		Ajustes.guardar()
		var ip := IntroPrograma.new()
		ip.cerrada.connect(_comenzar)
		add_child(ip)
		return
	_bloqueado = true
	var tw := create_tween()
	tw.tween_property(_raiz, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		visible = false
		jugar_pulsado.emit())


func _on_ver_intro() -> void:
	if _bloqueado:
		return
	Ajustes.guardar()
	_bloqueado = true
	visible = false
	intro_pedida.emit()


func _on_reiniciar_campana(b: Button) -> void:

	if bool(b.get_meta("confirmar", false)):
		Ajustes.reiniciar_campana()
		Ajustes.guardar()
		HistoriaEstado.reiniciar()
		MetaEstado.extra_set("eventos_vistos", [])
		b.set_meta("confirmar", false)
		b.text = "CAMPAÑA REINICIADA"
	else:
		b.set_meta("confirmar", true)
		b.text = "¿SEGURO? PULSA DE NUEVO"


func _on_restablecer() -> void:
	Ajustes.restablecer()
	Ajustes.aplicar(get_viewport())
	Ajustes.guardar()
	_sincronizar()


func _fila_slider(padre: Control, clave: String, texto: String, minimo: float,
		maximo: float, paso: float, pct: bool) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	var l := _etiqueta(texto, 19, COL_TEXTO)
	l.custom_minimum_size = Vector2(250.0, 0.0)
	fila.add_child(l)

	var s := HSlider.new()
	s.min_value = minimo
	s.max_value = maximo
	s.step = paso
	s.custom_minimum_size = Vector2(220.0, 26.0)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_estilo_slider(s)
	fila.add_child(s)

	var val := _etiqueta("", 19, COL_ACENTO)
	val.custom_minimum_size = Vector2(72.0, 0.0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fila.add_child(val)

	s.value_changed.connect(_on_slider.bind(clave, val, pct))
	s.drag_ended.connect(_on_slider_fin.bind(clave))
	padre.add_child(fila)
	_controles[clave] = {"tipo": "slider", "nodo": s, "etiqueta": val, "pct": pct}


func _fila_check(padre: Control, clave: String, texto: String) -> void:
	var c := CheckButton.new()
	c.text = texto
	c.add_theme_font_size_override("font_size", 19)
	c.add_theme_color_override("font_color", COL_TEXTO)
	c.add_theme_color_override("font_hover_color", Color.WHITE)
	c.add_theme_color_override("font_pressed_color", COL_TEXTO)
	c.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	c.toggled.connect(_on_check.bind(clave))
	padre.add_child(c)
	_controles[clave] = {"tipo": "check", "nodo": c}


func _fila_opciones(padre: Control, clave: String, texto: String, opciones: Array) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	var l := _etiqueta(texto, 19, COL_TEXTO)
	l.custom_minimum_size = Vector2(250.0, 0.0)
	fila.add_child(l)
	var o := OptionButton.new()
	o.add_theme_font_size_override("font_size", 19)
	for t in opciones:
		o.add_item(str(t))
	o.custom_minimum_size = Vector2(200.0, 0.0)
	o.item_selected.connect(_on_opcion.bind(clave))
	fila.add_child(o)
	padre.add_child(fila)
	_controles[clave] = {"tipo": "opcion", "nodo": o}


func _sincronizar() -> void:
	for clave in _controles:
		var d: Dictionary = _controles[clave]
		var valor: Variant = Ajustes.leer(clave)
		match d["tipo"]:
			"slider":
				var s: HSlider = d["nodo"]
				s.set_value_no_signal(float(valor))
				_texto_valor(d["etiqueta"], float(valor), d["pct"])
			"check":
				var c: CheckButton = d["nodo"]
				c.set_pressed_no_signal(bool(valor))
			"opcion":
				var o: OptionButton = d["nodo"]
				o.select(int(valor))


func _texto_valor(lbl: Label, v: float, pct: bool) -> void:
	lbl.text = ("%d %%" % roundi(v * 100.0)) if pct else ("%.2f ×" % v)


func _on_slider(v: float, clave: String, lbl: Label, pct: bool) -> void:
	Ajustes.escribir(clave, v)
	_texto_valor(lbl, v, pct)
	Ajustes.aplicar(get_viewport())


func _on_slider_fin(cambiado: bool, clave: String) -> void:
	Ajustes.guardar()
	if cambiado and clave == "vol_efectos" and audio != null:
		audio.clic()


func _on_check(activo: bool, clave: String) -> void:
	Ajustes.escribir(clave, activo)
	Ajustes.aplicar(get_viewport())
	Ajustes.guardar()
	if clave == "sala_3d" and sala != null and is_instance_valid(sala):
		if activo:
			sala.mostrar()
		else:
			sala.ocultar()


func _on_opcion(indice: int, clave: String) -> void:
	if clave == "calidad":
		Ajustes.aplicar_calidad(indice)
		_sincronizar()
	else:
		Ajustes.escribir(clave, indice)
	Ajustes.aplicar(get_viewport())
	Ajustes.guardar()
	if clave == "idioma":
		Idioma.aplicar()
	elif clave == "daltonismo":
		get_tree().call_group("accesibilidad", "aplicar")
	if sala != null and is_instance_valid(sala):
		sala.ajustar_calidad()


func _prueba_fps(b: Button) -> void:
	if _midiendo:
		return
	_midiendo = true
	var duracion := 4.0
	var t := 0.0
	var cuadros := 0
	while t < duracion + 0.5:
		await get_tree().process_frame
		var d := get_process_delta_time()
		t += d
		if t > 0.5:
			cuadros += 1
		b.text = "MIDIENDO…  %d s" % ceili(maxf(duracion + 0.5 - t, 0.0))
	var fps := float(cuadros) / duracion
	var rec := Ajustes.calidad_para_fps(fps)
	Ajustes.aplicar_calidad(rec)
	Ajustes.aplicar(get_viewport())
	Ajustes.guardar()
	_sincronizar()
	if sala != null and is_instance_valid(sala):
		sala.ajustar_calidad()
	b.text = "%d FPS · calidad %s aplicada" % [roundi(fps), ["BAJA", "MEDIA", "ALTA"][rec]]
	_midiendo = false


func _etiqueta(texto: String, tam: int, color: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", maxi(tam, 14))
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.4))
	l.add_theme_constant_override("shadow_offset_y", 1)
	return l


func _seccion(texto: String) -> Label:
	var l := _etiqueta("—  " + texto, 20, COL_TENUE)
	return l


func _label_titulo(texto: String, color: Color, tam: int) -> Label:
	var fv := FontVariation.new()
	fv.base_font = EstiloUI.fuente_titulo()
	fv.spacing_glyph = 8
	var ls := LabelSettings.new()
	ls.font = fv
	ls.font_size = tam
	ls.font_color = color
	ls.outline_size = 8
	ls.outline_color = Color(0.0, 0.0, 0.0, 0.9)
	ls.shadow_size = 12
	ls.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	ls.shadow_offset = Vector2(4.0, 6.0)
	var l := Label.new()
	l.text = texto
	l.label_settings = ls
	return l


func _estilo_boton(activo: bool) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	if activo:
		e.bg_color = Color(COL_ACENTO.r, COL_ACENTO.g, COL_ACENTO.b, 0.25)
		e.border_color = COL_ACENTO
		e.border_width_left = 6
	else:
		e.bg_color = Color(0.05, 0.04, 0.04, 0.55)
		e.border_color = Color(1.0, 1.0, 1.0, 0.14)
		e.border_width_left = 2
	e.set_corner_radius_all(4)
	e.content_margin_left = 24.0
	e.content_margin_right = 24.0
	return e


func _estilo_caja() -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = Color(0.04, 0.03, 0.03, 0.6)
	e.border_color = Color(1.0, 1.0, 1.0, 0.12)
	e.set_border_width_all(1)
	e.set_corner_radius_all(6)
	e.content_margin_left = 20.0
	e.content_margin_right = 20.0
	e.content_margin_top = 16.0
	e.content_margin_bottom = 16.0
	return e


const USAR_BOTON_NASA := true


func _boton(texto: String, tam: int = 28, icono: String = "", numero: String = "") -> Button:
	var b = BotonNasa.new() if USAR_BOTON_NASA else Button.new()
	b.text = texto
	if USAR_BOTON_NASA:
		b.icono = icono
		b.numero = numero
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(400.0, 56.0)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.add_theme_font_size_override("font_size", tam)
	b.add_theme_color_override("font_color", COL_TEXTO)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE if USAR_BOTON_NASA else COL_ACENTO)
	if USAR_BOTON_NASA:
		b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
		b.focus_entered.connect(_sonido_hover)
	else:
		b.add_theme_stylebox_override("normal", _estilo_boton(false))
		b.add_theme_stylebox_override("hover", _estilo_boton(true))
		b.add_theme_stylebox_override("pressed", _estilo_boton(true))
		b.add_theme_stylebox_override("focus", _estilo_boton(true))
	b.mouse_entered.connect(_sonido_hover)
	if texto.strip_edges().to_upper() in ["VOLVER", "CANCELAR"]:
		b.pressed.connect(_sonido_atras)
	else:
		b.pressed.connect(_sonido_clic)
	return b


func _estilo_slider(s: HSlider) -> void:
	var pista := StyleBoxFlat.new()
	pista.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	pista.set_corner_radius_all(3)
	pista.content_margin_top = 3.0
	pista.content_margin_bottom = 3.0
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = COL_ACENTO
	relleno.set_corner_radius_all(3)
	relleno.content_margin_top = 3.0
	relleno.content_margin_bottom = 3.0
	s.add_theme_stylebox_override("slider", pista)
	s.add_theme_stylebox_override("grabber_area", relleno)
	s.add_theme_stylebox_override("grabber_area_highlight", relleno)


func _sonido_clic() -> void:
	if audio != null:
		audio.clic()


func _sonido_atras() -> void:
	if audio != null and audio.has_method("atras"):
		audio.atras()


func _sonido_hover() -> void:
	if audio != null:
		audio.hover()
