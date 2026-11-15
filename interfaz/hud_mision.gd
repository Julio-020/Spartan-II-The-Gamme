extends CanvasLayer


const CartelEpoca := preload("res://interfaz/cartel_epoca.gd")
const FotoArchivo := preload("res://mision/foto_archivo.gd")
const Cuaderno := preload("res://progreso/cuaderno.gd")
const CuadernoDibujo := preload("res://interfaz/cuaderno_dibujo.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const Historia := preload("res://historia/historia.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const AvatarPiloto := preload("res://interfaz/avatar_piloto.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const RutaMapa := preload("res://interfaz/ruta_mapa.gd")
const HoloFocos := preload("res://dron/holo_focos.gd")

signal volver_pulsado
signal tarjeta_pulsada
signal final_pulsado
signal laboratorio_pulsado
signal cuaderno_pulsado

var _btn_tarjeta: Button
var _btn_final: Button
var _btn_lab: Button
var _btn_detalles: Button
var _det_final: VBoxContainer
var _lbl_final_extra: Label
var _ruta_guardada: Array = []
signal briefing_cerrado
signal briefing_texto

const COL_FOTO := Color(0.78, 0.55, 1.0)

var _raiz: Control
var _avatar: Control
var _lbl_nombre: Label
var _lbl_rango: Label
var _lbl_sol: Label
var _radio_badge: PanelContainer = null
var _radio_tw: Tween = null
var _caja_radar: VBoxContainer = null
var _fila_energia: Control
var _barra_energia: Control
var _lbl_energia: Label
var _lbl_titulo_mision: Label
var _lbl_nave: Label
var _lbl_objetivo: Label
var _filas_mat: Dictionary = {}
var _caja_pips: HBoxContainer
var _lbl_bodega: Label
var _telemetria: Dictionary = {}
var _brujula: Brujula
var _guia: Guia
var _radar: Radar
var _boton_escaner: BotonEscaner
var _lbl_escaner: Label
var _lbl_senal: Label
var _pill_senal: PanelContainer
var _lbl_aviso: Label
var _caja_toasts: VBoxContainer
var _holo: Control
var _banner: Control
var _panel_final: PanelContainer
var _col_izq: Control
var _lbl_final_titulo: Label
var _panel_ruta: PanelContainer
var _ruta_mapa: Control
var _lbl_ruta_info: Label
var _tw_ruta: Tween
var _lbl_datos: Label
var _panel_dato: PanelContainer
var _dato_head: Label
var _dato_tit: Label
var _dato_txt: Label
var _dato_abierto: bool = false
var _tw_dato: Tween
var _brief: Control
var _br_era: Label
var _br_nombre: Label
var _br_piloto: Label
var _br_texto: Label
var _br_cartel: Control
var _br_jefe: Label
var _br_msg: Label
var _br_msg_caja: VBoxContainer
var _tut_panel: PanelContainer = null
var _tut_texto: Label = null
var _tut_paso: Label = null
var _dilema_panel: Control = null
var _br_obj: HFlowContainer
var _br_abierto: bool = false
var _br_fase: int = 0
var _tit: Control
var _tit_veil: ColorRect
var _tit_barras: Array[ColorRect] = []
var _tit_caja: VBoxContainer
var _tit_nombre: Label
var _tit_tw: Tween = null
var _br_arr_caja: VBoxContainer
var _br_arr: Label
var _lbl_final_stats: Label
var _caja_final_mats: VBoxContainer
var _lbl_final_real: Label
var _totales: Dictionary = {}
var _foto_modo: bool = false
var _blancos_nombres: Array[String] = []
var _filas_fotos: Array = []
var _caja_fotos: VBoxContainer
var _caja_ley: VBoxContainer
var _ayuda_br: Label
var _visor: Control
var _visor_dib: VisorDibujo
var _flash: ColorRect
var _ocultables: Array[Control] = []
var _caja_album: HFlowContainer
var _caja_cuaderno: PanelContainer
var _visor_abierto: bool = false
var _capacidad: int = 3


func _ready() -> void:
	layer = 15
	_construir()


func _construir() -> void:
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)


	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.position = Vector2(24.0, 22.0)
	col.custom_minimum_size = Vector2(440.0, 0.0)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(col)

	col.add_child(_tarjeta_piloto())
	col.add_child(_tarjeta_mision())
	col.add_child(_tarjeta_telemetria())
	_ocultables.append(col)
	_col_izq = col


	_brujula = Brujula.new()
	_brujula.fuente = EstiloUI.fuente_titulo()
	_brujula.custom_minimum_size = Vector2(560.0, 44.0)
	_brujula.anchor_left = 0.5
	_brujula.anchor_right = 0.5
	_brujula.offset_left = -280.0
	_brujula.offset_right = 280.0
	_brujula.offset_top = 18.0
	_brujula.offset_bottom = 62.0
	_brujula.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_brujula)


	_guia = Guia.new()
	_guia.fuente = EstiloUI.fuente_titulo()
	_guia.anchor_left = 0.5
	_guia.anchor_right = 0.5
	_guia.offset_left = -150.0
	_guia.offset_right = 150.0
	_guia.offset_top = 110.0
	_guia.offset_bottom = 148.0
	_guia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guia.visible = false
	_raiz.add_child(_guia)


	_pill_senal = PanelContainer.new()
	_pill_senal.add_theme_stylebox_override("panel", EstiloUI.caja(Color(0.03, 0.025, 0.025, 0.72), 14.0))
	_pill_senal.anchor_left = 0.5
	_pill_senal.anchor_right = 0.5
	_pill_senal.offset_left = -190.0
	_pill_senal.offset_right = 190.0
	_pill_senal.offset_top = 72.0
	_pill_senal.offset_bottom = 104.0
	_pill_senal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill_senal.visible = false
	_lbl_senal = EstiloUI.etiqueta("", 18, EstiloUI.COL_AVISO, true)
	_lbl_senal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pill_senal.add_child(_lbl_senal)
	_raiz.add_child(_pill_senal)


	var caja_radar := VBoxContainer.new()
	caja_radar.anchor_left = 1.0
	caja_radar.anchor_right = 1.0
	caja_radar.offset_left = -272.0
	caja_radar.offset_right = -24.0
	caja_radar.offset_top = 22.0
	caja_radar.add_theme_constant_override("separation", 4)
	caja_radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(caja_radar)
	_ocultables.append(caja_radar)
	_radar = Radar.new()
	_radar.fuente = EstiloUI.fuente_titulo()
	_radar.custom_minimum_size = Vector2(248.0, 248.0)
	_radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja_radar.add_child(_radar)
	_lbl_sol = EstiloUI.etiqueta("SOL 1 · 0:00", 18, EstiloUI.COL_TEXTO, true)
	_lbl_sol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja_radar.add_child(_lbl_sol)
	_caja_radar = caja_radar


	var caja_esc := VBoxContainer.new()
	caja_esc.anchor_left = 0.5
	caja_esc.anchor_right = 0.5
	caja_esc.anchor_top = 1.0
	caja_esc.anchor_bottom = 1.0
	caja_esc.offset_left = -170.0
	caja_esc.offset_right = 170.0
	caja_esc.offset_top = -232.0
	caja_esc.offset_bottom = -20.0
	caja_esc.alignment = BoxContainer.ALIGNMENT_END
	caja_esc.add_theme_constant_override("separation", 6)
	caja_esc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(caja_esc)
	_ocultables.append(caja_esc)
	_lbl_aviso = EstiloUI.etiqueta_contorno("", 26, Color.WHITE)
	_lbl_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja_esc.add_child(_lbl_aviso)
	_boton_escaner = BotonEscaner.new()
	_boton_escaner.custom_minimum_size = Vector2(84.0, 84.0)
	_boton_escaner.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_boton_escaner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja_esc.add_child(_boton_escaner)
	_lbl_escaner = EstiloUI.etiqueta_contorno("ESCÁNER · ESPACIO", 15, EstiloUI.COL_TEXTO)
	_lbl_escaner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja_esc.add_child(_lbl_escaner)


	_caja_toasts = VBoxContainer.new()
	_caja_toasts.anchor_top = 1.0
	_caja_toasts.anchor_bottom = 1.0
	_caja_toasts.offset_left = 24.0
	_caja_toasts.offset_right = 520.0
	_caja_toasts.offset_top = -430.0
	_caja_toasts.offset_bottom = -22.0
	_caja_toasts.alignment = BoxContainer.ALIGNMENT_END
	_caja_toasts.add_theme_constant_override("separation", 8)
	_caja_toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_caja_toasts)


	_holo = HoloFocos.new()
	_holo.anchor_left = 1.0
	_holo.anchor_right = 1.0
	_holo.anchor_top = 0.5
	_holo.anchor_bottom = 0.5
	_holo.offset_right = -24.0
	_holo.offset_left = -24.0 - _holo.custom_minimum_size.x
	_holo.offset_top = -20.0
	_holo.offset_bottom = -20.0 + _holo.custom_minimum_size.y
	_raiz.add_child(_holo)


	_caja_ley = _leyenda_controles() as VBoxContainer
	_raiz.add_child(_caja_ley)
	_ocultables.append(_caja_ley)


	_banner = _crear_banner()
	_raiz.add_child(_banner)
	_panel_final = _crear_panel_final()
	_raiz.add_child(_panel_final)
	_panel_ruta = _crear_panel_ruta()
	_raiz.add_child(_panel_ruta)
	_panel_dato = _crear_panel_dato()
	_raiz.add_child(_panel_dato)
	_brief = _crear_briefing()
	_raiz.add_child(_brief)
	_tit = _crear_titulo()
	_raiz.add_child(_tit)
	_visor = _crear_visor()
	_raiz.add_child(_visor)
	_raiz.move_child(_visor, 0)
	_flash = ColorRect.new()
	_flash.color = Color(1.0, 1.0, 1.0, 1.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.modulate.a = 0.0
	_raiz.add_child(_flash)


func _tarjeta_piloto() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 12.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(fila)
	_avatar = AvatarPiloto.new()
	_avatar.custom_minimum_size = Vector2(70.0, 70.0)
	fila.add_child(_avatar)
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 0)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(c)
	_lbl_nombre = EstiloUI.etiqueta("", 28, Color.WHITE, true)
	c.add_child(_lbl_nombre)
	_lbl_rango = EstiloUI.etiqueta("", 14, EstiloUI.COL_ACENTO, true)
	c.add_child(_lbl_rango)
	return p


func _tarjeta_mision() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 14.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 6)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(c)
	_lbl_titulo_mision = EstiloUI.etiqueta("", 22, EstiloUI.COL_AVISO, true)
	c.add_child(_lbl_titulo_mision)
	_lbl_nave = EstiloUI.etiqueta("", 14, EstiloUI.COL_TENUE, true)
	c.add_child(_lbl_nave)
	c.add_child(EstiloUI.linea())
	_lbl_objetivo = EstiloUI.etiqueta("", 17, EstiloUI.COL_TEXTO)
	_lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_objetivo.custom_minimum_size = Vector2(400.0, 0.0)
	c.add_child(_lbl_objetivo)

	var cont := VBoxContainer.new()
	cont.name = "Materiales"
	cont.add_theme_constant_override("separation", 5)
	cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(cont)

	var fila_b := HBoxContainer.new()
	fila_b.add_theme_constant_override("separation", 10)
	fila_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(fila_b)
	fila_b.add_child(EstiloUI.etiqueta("BODEGA", 14, EstiloUI.COL_TENUE, true))
	_caja_pips = HBoxContainer.new()
	_caja_pips.add_theme_constant_override("separation", 5)
	_caja_pips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_caja_pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila_b.add_child(_caja_pips)
	_lbl_bodega = EstiloUI.etiqueta("0 / 3", 16, EstiloUI.COL_AVISO, true)
	fila_b.add_child(_lbl_bodega)
	_lbl_datos = EstiloUI.etiqueta("DATOS CURIOSOS  0 / 0", 14, EstiloUI.COL_FRIO, true)
	_lbl_datos.visible = false
	c.add_child(_lbl_datos)
	return p


func _tarjeta_telemetria() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_FRIO, 12.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 22)
	g.add_theme_constant_override("v_separation", 4)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja_t := VBoxContainer.new()
	caja_t.add_theme_constant_override("separation", 8)
	caja_t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(caja_t)
	caja_t.add_child(g)

	var fila_e := HBoxContainer.new()
	fila_e.add_theme_constant_override("separation", 10)
	fila_e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila_e.visible = false
	fila_e.add_child(EstiloUI.etiqueta("BATERÍA", 11, EstiloUI.COL_TENUE, true))
	var barra := BarraEnergia.new()
	barra.custom_minimum_size = Vector2(190.0, 12.0)
	barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila_e.add_child(barra)
	var lbl_e := EstiloUI.etiqueta("100 %", 15, EstiloUI.COL_TEXTO, true)
	fila_e.add_child(lbl_e)
	caja_t.add_child(fila_e)
	_fila_energia = fila_e
	_barra_energia = barra
	_lbl_energia = lbl_e
	var campos := [["base", "BASE"], ["vel", "VELOCIDAD"], ["incl", "INCLINACIÓN"],
			["temp", "TEMPERATURA"], ["pres", "PRESIÓN"], ["viento", "VIENTO"]]
	for c in campos:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", -2)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(EstiloUI.etiqueta(c[1], 11, EstiloUI.COL_TENUE, true))
		var l := EstiloUI.etiqueta("—", 17, EstiloUI.COL_TEXTO, true)
		v.add_child(l)
		g.add_child(v)
		_telemetria[c[0]] = l
	return p


func _leyenda_controles() -> Control:
	var caja := VBoxContainer.new()
	caja.anchor_left = 1.0
	caja.anchor_right = 1.0
	caja.anchor_top = 1.0
	caja.anchor_bottom = 1.0
	caja.offset_left = -300.0
	caja.offset_right = -24.0
	caja.offset_top = -330.0
	caja.offset_bottom = -22.0
	caja.alignment = BoxContainer.ALIGNMENT_END
	caja.add_theme_constant_override("separation", 5)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var filas := [["W S", "avanzar / retroceder"], ["A D", "girar"], ["SHIFT", "turbo"],
			["ESPACIO", "escáner"], ["E", "recoger / leer dato"], ["H", "pregunta a FOCOS"], ["RUEDA", "zoom"], ["J", "diario"], ["P", "modo foto"], ["C", "radio a la Tierra"], ["ESC", "pausa"]]
	for f in filas:
		var h := HBoxContainer.new()
		h.alignment = BoxContainer.ALIGNMENT_END
		h.add_theme_constant_override("separation", 8)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var t := EstiloUI.etiqueta_contorno(f[1], 14, EstiloUI.COL_TEXTO, false)
		t.add_theme_constant_override("outline_size", 5)
		h.add_child(t)
		h.add_child(EstiloUI.tecla(f[0]))
		caja.add_child(h)
	return caja


func _crear_banner() -> Control:
	var c := CenterContainer.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.offset_top = -120.0
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.modulate.a = 0.0
	var v := VBoxContainer.new()
	v.name = "Caja"
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(v)
	var era := EstiloUI.etiqueta_contorno("", 24, EstiloUI.COL_ACENTO)
	era.name = "Era"
	era.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(era)
	var nom := EstiloUI.etiqueta_contorno("", 58, Color.WHITE)
	nom.name = "Nombre"
	nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(nom)
	var nave := EstiloUI.etiqueta_contorno("", 22, EstiloUI.COL_TEXTO)
	nave.name = "Nave"
	nave.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(nave)
	var real := EstiloUI.etiqueta_contorno("", 18, Color(1.0, 1.0, 1.0, 0.85), false)
	real.name = "Real"
	real.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	real.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	real.custom_minimum_size = Vector2(700.0, 0.0)
	v.add_child(real)
	return c


func _crear_panel_final() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_OK, 26.0))
	p.set_anchors_preset(Control.PRESET_CENTER)
	p.anchor_left = 0.5
	p.anchor_right = 0.5
	p.anchor_top = 0.5
	p.anchor_bottom = 0.5
	p.offset_left = -480.0
	p.offset_right = 180.0
	p.offset_top = 0.0
	p.offset_bottom = 0.0
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.visible = false
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 10)
	p.add_child(c)
	_lbl_final_titulo = EstiloUI.etiqueta("MISIÓN COMPLETADA", 40, EstiloUI.COL_OK, true)
	c.add_child(_lbl_final_titulo)
	_lbl_final_stats = EstiloUI.etiqueta("", 19, EstiloUI.COL_TEXTO)
	_lbl_final_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.add_child(_lbl_final_stats)
	c.add_child(EstiloUI.linea())
	_caja_final_mats = VBoxContainer.new()
	_caja_final_mats.add_theme_constant_override("separation", 4)
	c.add_child(_caja_final_mats)
	_caja_cuaderno = PanelContainer.new()
	_caja_cuaderno.add_theme_stylebox_override("panel", EstiloUI.caja(Color(0.94, 0.88, 0.7, 0.1), 6.0))
	_caja_cuaderno.visible = false
	c.add_child(_caja_cuaderno)

	_det_final = VBoxContainer.new()
	_det_final.add_theme_constant_override("separation", 10)
	_det_final.visible = false
	c.add_child(_det_final)
	_det_final.add_child(EstiloUI.linea())
	_lbl_final_extra = EstiloUI.etiqueta("", 17, EstiloUI.COL_TEXTO)
	_lbl_final_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_final_extra.custom_minimum_size = Vector2(600.0, 0.0)
	_det_final.add_child(_lbl_final_extra)
	_caja_album = HFlowContainer.new()
	_caja_album.add_theme_constant_override("h_separation", 10)
	_caja_album.add_theme_constant_override("v_separation", 8)
	_caja_album.custom_minimum_size = Vector2(600.0, 0.0)
	_caja_album.visible = false
	_det_final.add_child(_caja_album)
	_det_final.add_child(EstiloUI.linea())
	_det_final.add_child(EstiloUI.etiqueta("POR QUÉ IMPORTA", 14, EstiloUI.COL_FRIO, true))
	_lbl_final_real = EstiloUI.etiqueta("", 17, EstiloUI.COL_TEXTO)
	_lbl_final_real.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_final_real.custom_minimum_size = Vector2(600.0, 0.0)
	_det_final.add_child(_lbl_final_real)
	_btn_tarjeta = EstiloUI.boton("GUARDAR TARJETA", 18)
	_btn_tarjeta.custom_minimum_size = Vector2(190.0, 46.0)
	_btn_tarjeta.pressed.connect(func(): tarjeta_pulsada.emit())
	_det_final.add_child(_btn_tarjeta)

	_btn_final = EstiloUI.boton("VER EL FINAL DE LA HISTORIA", 22)
	_btn_final.visible = false
	_btn_final.pressed.connect(func(): final_pulsado.emit())
	c.add_child(_btn_final)
	var fila_b := HBoxContainer.new()
	fila_b.add_theme_constant_override("separation", 12)
	c.add_child(fila_b)
	_btn_lab = EstiloUI.boton("LABORATORIO", 20)
	_btn_lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_lab.custom_minimum_size = Vector2(190.0, 52.0)
	_btn_lab.visible = false
	_btn_lab.pressed.connect(func(): laboratorio_pulsado.emit())
	fila_b.add_child(_btn_lab)
	_btn_detalles = EstiloUI.boton("VER DETALLES", 20)
	_btn_detalles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_detalles.custom_minimum_size = Vector2(190.0, 52.0)
	_btn_detalles.pressed.connect(_alternar_detalles_final)
	fila_b.add_child(_btn_detalles)
	var b := EstiloUI.boton("VOLVER AL PLANETA", 20)
	b.custom_minimum_size = Vector2(190.0, 52.0)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(func(): volver_pulsado.emit())
	fila_b.add_child(b)
	return p


func _alternar_detalles_final() -> void:
	var ver := not _det_final.visible
	_det_final.visible = ver
	if _caja_cuaderno != null and _caja_cuaderno.get_child_count() > 0:
		_caja_cuaderno.visible = not ver
	_btn_detalles.text = "OCULTAR DETALLES" if ver else "VER DETALLES"
	if ver and not _ruta_guardada.is_empty():
		_mostrar_ruta(_ruta_guardada[0], bool(_ruta_guardada[1]))
	else:
		_panel_ruta.visible = false


func mostrar_cuaderno(mision: Dictionary, entrada: Dictionary) -> void:
	if _caja_cuaderno == null:
		return
	for h in _caja_cuaderno.get_children():
		h.queue_free()
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	var foto := FotoArchivo.marco(mision, 172.0, false)
	if foto != null:
		fila.add_child(foto)
	else:
		var d := CuadernoDibujo.new()
		d.configurar(mision, entrada)
		d.custom_minimum_size = Vector2(190.0, 104.0)
		fila.add_child(d)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.custom_minimum_size = Vector2(330.0, 0.0)
	v.add_child(EstiloUI.etiqueta("NUEVO RECUERDO", 15, Color(1.0, 0.8, 0.3), true))
	var notas := Cuaderno.notas(entrada)
	for i in range(1, mini(2, notas.size())):
		var l := EstiloUI.etiqueta(notas[i], 14, EstiloUI.COL_TEXTO)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(330.0, 0.0)
		v.add_child(l)
	var b := EstiloUI.boton("VER EN RECUERDOS", 16)
	b.custom_minimum_size = Vector2(0.0, 34.0)
	b.pressed.connect(func(): cuaderno_pulsado.emit())
	v.add_child(b)
	fila.add_child(v)
	_caja_cuaderno.add_child(fila)
	_caja_cuaderno.visible = true


func mostrar_boton_lab(visible_: bool) -> void:
	if _btn_lab != null:
		_btn_lab.visible = visible_


func mostrar_boton_final(visible_: bool) -> void:
	if _btn_final != null:
		_btn_final.visible = visible_


func _color_jefe_hud(jefe: String) -> Color:
	var inf := Historia.jefe(jefe)
	return inf.get("color", EstiloUI.COL_ACENTO)


func tarjeta_guardada(ruta: String) -> void:
	if _btn_tarjeta != null:
		_btn_tarjeta.disabled = ruta != ""
		_btn_tarjeta.text = "TARJETA GUARDADA ✓" if ruta != "" else "GUARDAR TARJETA"
	if ruta != "":
		toast("Tarjeta guardada", "Está en la carpeta de datos del juego: tarjetas/" + ruta.get_file(), EstiloUI.COL_OK, 6.0)
	else:
		toast("No se pudo guardar", "Inténtalo otra vez.", EstiloUI.COL_AVISO, 4.0)


func _crear_panel_ruta() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_FRIO, 18.0))
	p.anchor_left = 0.5
	p.anchor_right = 0.5
	p.anchor_top = 0.5
	p.anchor_bottom = 0.5
	p.offset_left = 262.0
	p.offset_right = 546.0
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.visible = false
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 8)
	p.add_child(c)
	c.add_child(EstiloUI.etiqueta("RUTA RECORRIDA", 22, EstiloUI.COL_FRIO, true))
	_ruta_mapa = RutaMapa.new()
	_ruta_mapa.custom_minimum_size = Vector2(250.0, 220.0)
	c.add_child(_ruta_mapa)
	_lbl_ruta_info = EstiloUI.etiqueta("", 16, EstiloUI.COL_TEXTO)
	_lbl_ruta_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.add_child(_lbl_ruta_info)
	var leyenda := HFlowContainer.new()
	leyenda.add_theme_constant_override("h_separation", 10)
	leyenda.add_theme_constant_override("v_separation", 2)
	for e in [["muestra", "recogida"], ["entrega", "entrega"], ["foto", "foto"], ["dato", "dato"], ["suceso", "suceso"]]:
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 5)
		var punto := ColorRect.new()
		punto.color = RutaMapa.COL_EVENTO[e[0]]
		punto.custom_minimum_size = Vector2(9.0, 9.0)
		punto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		f.add_child(punto)
		f.add_child(EstiloUI.etiqueta(e[1], 13, EstiloUI.COL_TENUE))
		leyenda.add_child(f)
	c.add_child(leyenda)
	return p


func _crear_panel_dato() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_FRIO, 18.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.anchor_left = 0.5
	p.anchor_right = 0.5
	p.anchor_top = 0.0
	p.anchor_bottom = 0.0
	p.offset_left = -160.0
	p.offset_right = 360.0
	p.offset_top = 122.0
	p.offset_bottom = 122.0
	p.grow_horizontal = Control.GROW_DIRECTION_END
	p.grow_vertical = Control.GROW_DIRECTION_END
	p.visible = false
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 6)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(c)
	_dato_head = EstiloUI.etiqueta("DATO CURIOSO", 13, EstiloUI.COL_FRIO, true)
	c.add_child(_dato_head)
	_dato_tit = EstiloUI.etiqueta_sub("", 24, Color.WHITE, true)
	_dato_tit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dato_tit.custom_minimum_size = Vector2(470.0, 0.0)
	c.add_child(_dato_tit)
	c.add_child(EstiloUI.linea())
	_dato_txt = EstiloUI.etiqueta_sub("", 17, EstiloUI.COL_TEXTO)
	_dato_txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dato_txt.custom_minimum_size = Vector2(470.0, 0.0)
	c.add_child(_dato_txt)
	c.add_child(EstiloUI.etiqueta("Pulsa E para cerrar", 13, EstiloUI.COL_TENUE))
	return p


func _crear_titulo() -> Control:
	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.visible = false
	_tit_veil = ColorRect.new()
	_tit_veil.color = Color(0.0, 0.0, 0.0, 0.0)
	_tit_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tit_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(_tit_veil)
	for arriba: bool in [true, false]:
		var b := ColorRect.new()
		b.color = Color.BLACK
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.anchor_left = 0.0
		b.anchor_right = 1.0
		b.anchor_top = 0.0 if arriba else 1.0
		b.anchor_bottom = 0.0 if arriba else 1.0
		capa.add_child(b)
		_tit_barras.append(b)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(centro)
	_tit_caja = VBoxContainer.new()
	_tit_caja.name = "Caja"
	_tit_caja.add_theme_constant_override("separation", 8)
	_tit_caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(_tit_caja)
	var era := EstiloUI.etiqueta_contorno("", 22, EstiloUI.COL_ACENTO)
	era.name = "Era"
	era.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tit_caja.add_child(era)
	var linea := ColorRect.new()
	linea.name = "Linea"
	linea.color = Color(EstiloUI.COL_ACENTO.r, EstiloUI.COL_ACENTO.g, EstiloUI.COL_ACENTO.b, 0.8)
	linea.custom_minimum_size = Vector2(420.0, 2.0)
	linea.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	linea.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tit_caja.add_child(linea)
	_tit_nombre = EstiloUI.etiqueta_contorno("", 62, Color.WHITE)
	_tit_nombre.name = "Nombre"
	_tit_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tit_caja.add_child(_tit_nombre)
	var obj := EstiloUI.etiqueta_contorno("", 22, EstiloUI.COL_TEXTO)
	obj.name = "Objetivo"
	obj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tit_caja.add_child(obj)
	var cond := EstiloUI.etiqueta_contorno("", 18, EstiloUI.COL_AVISO)
	cond.name = "Condicion"
	cond.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tit_caja.add_child(cond)
	var pie := EstiloUI.etiqueta_contorno("ENTER para continuar", 14, EstiloUI.COL_TENUE, false)
	pie.name = "Pie"
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pie.modulate.a = 0.0
	_tit_caja.add_child(pie)
	return capa


func _titulo_empezar(datos: Dictionary, objetivo: String, cond: Dictionary) -> void:
	(_tit_caja.get_node("Era") as Label).text = "%s  ·  %s" % [str(datos.get("era", "")), str(datos.get("nave", ""))]
	_tit_nombre.text = str(datos.get("nombre", "")).to_upper()
	_tit_nombre.visible_ratio = 0.0
	(_tit_caja.get_node("Objetivo") as Label).text = objetivo
	var lc := _tit_caja.get_node("Condicion") as Label
	lc.visible = not cond.is_empty()
	if not cond.is_empty():
		lc.text = "%s" % str(cond["n"]).to_upper()
		lc.add_theme_color_override("font_color", cond["c"])
	for n in ["Era", "Linea", "Objetivo", "Condicion"]:
		(_tit_caja.get_node(n) as Control).modulate.a = 0.0
	_tit_veil.color.a = 0.0
	_tit_barras[0].offset_top = 0.0
	_tit_barras[0].offset_bottom = 0.0
	_tit_barras[1].offset_top = 0.0
	_tit_barras[1].offset_bottom = 0.0
	_tit.modulate.a = 1.0
	_tit.visible = true
	if _tit_tw != null:
		_tit_tw.kill()
	var tw := create_tween().set_parallel(true)
	_tit_tw = tw
	tw.tween_property(_tit_veil, "color:a", 0.38, 0.8)
	tw.tween_property(_tit_barras[0], "offset_bottom", 86.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_tit_barras[1], "offset_top", -86.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_tit_caja.get_node("Era"), "modulate:a", 1.0, 0.6).set_delay(0.5)
	tw.tween_property(_tit_caja.get_node("Linea"), "modulate:a", 1.0, 0.5).set_delay(0.8)
	tw.tween_property(_tit_nombre, "visible_ratio", 1.0, 1.1).set_delay(0.9)
	tw.tween_property(_tit_caja.get_node("Objetivo"), "modulate:a", 1.0, 0.6).set_delay(1.5)
	tw.tween_property(_tit_caja.get_node("Condicion"), "modulate:a", 1.0, 0.6).set_delay(1.7)
	tw.tween_property(_tit_caja.get_node("Pie"), "modulate:a", 1.0, 0.6).set_delay(1.9)
	tw.chain().tween_interval(0.8)
	tw.tween_callback(_pasar_a_briefing)


func _pasar_a_briefing() -> void:
	if _br_fase != 1:
		return
	_br_fase = 2
	if _tit_tw != null:
		_tit_tw.kill()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_tit, "modulate:a", 0.0, 0.45)
	tw.chain().tween_callback(func(): _tit.visible = false)
	_brief.visible = true
	_brief.modulate.a = 0.0
	create_tween().tween_property(_brief, "modulate:a", 1.0, 0.55).set_delay(0.2)
	briefing_texto.emit()


func saltar_titulo() -> bool:
	if _br_fase != 1:
		return false
	_pasar_a_briefing()
	return true


func _crear_briefing() -> Control:
	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.visible = false
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.012, 0.015, 0.62)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(centro)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 30.0))
	centro.add_child(p)
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 10)
	p.add_child(c)
	_br_era = EstiloUI.etiqueta("", 17, EstiloUI.COL_ACENTO, true)
	c.add_child(_br_era)
	_br_nombre = EstiloUI.etiqueta("", 38, Color.WHITE, true)
	c.add_child(_br_nombre)
	_br_piloto = EstiloUI.etiqueta("", 14, EstiloUI.COL_TENUE, true)
	c.add_child(_br_piloto)
	c.add_child(EstiloUI.linea())
	_br_cartel = CartelEpoca.new()
	_br_cartel.custom_minimum_size = Vector2(700.0, 150.0)
	c.add_child(_br_cartel)
	_br_texto = EstiloUI.etiqueta_sub("", 17, EstiloUI.COL_TEXTO)
	_br_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_br_texto.custom_minimum_size = Vector2(700.0, 0.0)
	c.add_child(_br_texto)
	_br_msg_caja = VBoxContainer.new()
	_br_msg_caja.add_theme_constant_override("separation", 4)
	_br_msg_caja.add_child(EstiloUI.linea())
	_br_jefe = EstiloUI.etiqueta("", 14, EstiloUI.COL_ACENTO, true)
	_br_msg_caja.add_child(_br_jefe)
	_br_msg = EstiloUI.etiqueta("", 18, Color(0.95, 0.9, 0.82))
	_br_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_br_msg.custom_minimum_size = Vector2(700.0, 0.0)
	_br_msg_caja.add_child(_br_msg)
	c.add_child(_br_msg_caja)
	_br_arr_caja = VBoxContainer.new()
	_br_arr_caja.add_theme_constant_override("separation", 4)
	_br_arr_caja.add_child(EstiloUI.linea())
	_br_arr_caja.add_child(EstiloUI.etiqueta("LO QUE ARRASTRAS", 14, Color(0.62, 0.38, 1.0), true))
	_br_arr = EstiloUI.etiqueta("", 16, EstiloUI.COL_TEXTO)
	_br_arr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_br_arr.custom_minimum_size = Vector2(700.0, 0.0)
	_br_arr_caja.add_child(_br_arr)
	c.add_child(_br_arr_caja)
	c.add_child(EstiloUI.linea())
	c.add_child(EstiloUI.etiqueta("TU OBJETIVO", 14, EstiloUI.COL_FRIO, true))
	_br_obj = HFlowContainer.new()
	_br_obj.add_theme_constant_override("h_separation", 22)
	_br_obj.add_theme_constant_override("v_separation", 4)
	_br_obj.custom_minimum_size = Vector2(700.0, 0.0)
	c.add_child(_br_obj)
	var ayuda := EstiloUI.etiqueta("W A S D conducir  ·  ESPACIO escáner  ·  E recoger  ·  J diario", 14, EstiloUI.COL_TENUE)
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ayuda.custom_minimum_size = Vector2(700.0, 0.0)
	c.add_child(ayuda)
	ayuda.visible = false
	_ayuda_br = ayuda
	var b := EstiloUI.boton("COMENZAR MISIÓN", 22)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func(): briefing_cerrado.emit())
	c.add_child(b)
	var pie := EstiloUI.etiqueta("o pulsa ENTER, ESPACIO o E", 13, EstiloUI.COL_TENUE)
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c.add_child(pie)
	return capa


func configurar(datos: Dictionary, lista: Array[String], capacidad: int) -> void:
	_capacidad = capacidad
	_totales.clear()
	for id in lista:
		_totales[id] = int(_totales.get(id, 0)) + 1
	_lbl_titulo_mision.text = "%s · %s" % [str(datos.get("era", "")), str(datos.get("nombre", "Misión")).to_upper()]
	_lbl_nave.text = str(datos.get("nave", ""))
	var cont: VBoxContainer = _lbl_objetivo.get_parent().get_node("Materiales")
	for h in cont.get_children():
		h.queue_free()
	_filas_mat.clear()
	for id in _totales:
		var info := DatosMarte.material(id)
		var col: Color = info["color"]
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 2)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 8)
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(f)
		var punto := ColorRect.new()
		punto.color = col
		punto.custom_minimum_size = Vector2(10.0, 10.0)
		punto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		punto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		f.add_child(punto)
		var nom := EstiloUI.etiqueta(str(info["nombre"]), 16, EstiloUI.COL_TEXTO, true)
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f.add_child(nom)
		var cnt := EstiloUI.etiqueta("0 / %d" % int(_totales[id]), 16, col, true)
		f.add_child(cnt)
		var barra := EstiloUI.barra(col, 5.0)
		barra.max_value = float(_totales[id])
		v.add_child(barra)
		cont.add_child(v)
		_filas_mat[id] = {"lbl": cnt, "barra": barra}
	_actualizar_pips([])
	var m: Dictionary = datos
	var banner_era: Label = _banner.get_node("Caja/Era")
	banner_era.text = "%s  ·  %s" % [str(m.get("era", "")), str(m.get("nave", ""))]
	(_banner.get_node("Caja/Nombre") as Label).text = str(m.get("nombre", "")).to_upper()
	var nombres: Array[String] = []
	for id in _totales:
		nombres.append(str(DatosMarte.material(id)["nombre"]))
	(_banner.get_node("Caja/Nave") as Label).text = "Objetivo: " + ", ".join(nombres)
	(_banner.get_node("Caja/Real") as Label).text = str(m.get("real", ""))
	_lbl_final_real.text = str(m.get("real", ""))


func actualizar_piloto() -> void:
	_avatar.set("genero", Ajustes.genero)
	_avatar.set("piel", Ajustes.piel)
	_avatar.set("pelo", Ajustes.pelo)
	_lbl_nombre.text = Ajustes.nombre_visible()
	var col: Color = AvatarPiloto.ACENTO[Ajustes.genero]
	_lbl_rango.text = "%s · SPARTANS II" % Ajustes.rango()
	_lbl_rango.add_theme_color_override("font_color", col)


func actualizar_progreso(entregados: Dictionary, bodega: Array, objetivo: String) -> void:
	_lbl_objetivo.text = objetivo
	if _foto_modo:
		return
	for id in _filas_mat:
		var n := int(entregados.get(id, 0))
		var tot := int(_totales.get(id, 0))
		(_filas_mat[id]["lbl"] as Label).text = "%d / %d" % [n, tot]
		(_filas_mat[id]["barra"] as ProgressBar).value = float(n)
	_actualizar_pips(bodega)


func _actualizar_pips(bodega: Array) -> void:
	for h in _caja_pips.get_children():
		h.queue_free()
	for i in range(_capacidad):
		var r := ColorRect.new()
		r.custom_minimum_size = Vector2(22.0, 12.0)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i < bodega.size():
			var info := DatosMarte.material(str(bodega[i]))
			r.color = info["color"]
		else:
			r.color = Color(1.0, 1.0, 1.0, 0.14)
		_caja_pips.add_child(r)
	_lbl_bodega.text = "%d / %d" % [bodega.size(), _capacidad]


func actualizar_vivo(d: Dictionary, delta: float) -> void:
	var blips: Array = d.get("blips", [])
	_brujula.rumbo_deg = float(d.get("rumbo_deg", 0.0))
	_brujula.blips = blips
	_brujula.queue_redraw()
	_guia.poner(d.get("guia", {}))
	_radar.blips = blips
	_radar.alcance = float(d.get("alcance", 70.0))
	_radar.norte_rel = float(d.get("norte_rel", 0.0))
	_radar.pulso = float(d.get("pulso", -1.0))
	_radar.barrido = fposmod(_radar.barrido + delta * 2.2, TAU)
	_radar.queue_redraw()
	_boton_escaner.carga = float(d.get("carga_escaner", 1.0))
	_boton_escaner.queue_redraw()
	_lbl_escaner.text = "ESCÁNER · ESPACIO" if _boton_escaner.carga >= 1.0 else "RECARGANDO…"
	if bool(d.get("escaner_roto", false)):
		_lbl_escaner.text = "AVERIADO · QUIETO 5 s"
	_lbl_aviso.text = str(d.get("aviso", ""))
	var sen := str(d.get("senal", ""))
	_pill_senal.visible = sen != ""
	_lbl_senal.text = sen


	var hora := str(d.get("hora", ""))
	_lbl_sol.text = "SOL %d · %s" % [int(d.get("sol", 1)), hora if hora != "" else str(d.get("tiempo", "0:00"))]
	if int(d.get("tormenta", 0)) == 2:
		_lbl_sol.text += " · TORMENTA"
	elif str(d.get("fase", "")) != "":
		_lbl_sol.text += " · " + str(d["fase"])
	var en := float(d.get("energia", -1.0))
	_fila_energia.visible = en >= 0.0
	if en >= 0.0:
		_barra_energia.set("valor", en / 100.0)
		_barra_energia.set("tormenta", int(d.get("tormenta", 0)) == 2)
		_barra_energia.queue_redraw()
		_lbl_energia.text = "%d %%" % int(round(en))
		_lbl_energia.add_theme_color_override("font_color", BarraEnergia.color_para(en / 100.0))
	(_telemetria["base"] as Label).text = "%.1f km" % float(d.get("dist_base", 0.0))
	(_telemetria["vel"] as Label).text = "%.1f m/s" % float(d.get("vel", 0.0))
	(_telemetria["incl"] as Label).text = "%d°" % int(d.get("incl", 0.0))
	(_telemetria["temp"] as Label).text = "%d °C" % int(d.get("temp", -63.0))
	(_telemetria["pres"] as Label).text = "%.1f mbar" % float(d.get("pres", 6.1))
	(_telemetria["viento"] as Label).text = "%.0f m/s" % float(d.get("viento", 4.0))


func mostrar_dilema(dil: Dictionary, con_coste: bool) -> void:
	ocultar_dilema()
	var inf := Historia.jefe(str(dil["j"]))
	var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(col, 14.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 5)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(c)
	c.add_child(EstiloUI.etiqueta("DECISIÓN  ·  %s" % Historia.titulo(str(dil["j"])), 15, col, true))
	var t := EstiloUI.etiqueta("«%s»" % str(dil["t"]), 17, EstiloUI.COL_TEXTO)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(440.0, 0.0)
	c.add_child(t)
	var n := 1
	for k in ["a", "b"]:
		var op: Dictionary = dil[k]
		var extra := ""
		if con_coste and int(op.get("coste", 0)) > 0:
			extra = "   (−%d %% batería)" % int(op["coste"])
		c.add_child(EstiloUI.etiqueta("[%d]  %s%s" % [n, str(op["txt"]), extra], 18, Color.WHITE, true))
		n += 1
	c.add_child(EstiloUI.etiqueta("Pulsa 1 o 2. Si no respondes, sigues sin decidir.", 13, EstiloUI.COL_TENUE))
	p.position = Vector2(484.0, 112.0)
	p.modulate.a = 0.0
	_raiz.add_child(p)
	_dilema_panel = p
	create_tween().tween_property(p, "modulate:a", 1.0, 0.4)


func mostrar_tutorial(texto: String, paso: int, total: int) -> void:
	if _tut_panel == null or not is_instance_valid(_tut_panel):
		var inf := Historia.jefe("KELLY")
		var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", EstiloUI.panel(col, 14.0))
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var c := VBoxContainer.new()
		c.add_theme_constant_override("separation", 5)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(c)
		_tut_paso = EstiloUI.etiqueta("", 15, col, true)
		c.add_child(_tut_paso)
		_tut_texto = EstiloUI.etiqueta("", 18, EstiloUI.COL_TEXTO)
		_tut_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_tut_texto.custom_minimum_size = Vector2(440.0, 0.0)
		c.add_child(_tut_texto)
		c.add_child(EstiloUI.etiqueta("T = saltar el tutorial", 13, EstiloUI.COL_TENUE))
		p.position = Vector2(484.0, 112.0)
		p.modulate.a = 0.0
		_raiz.add_child(p)
		_tut_panel = p
		create_tween().tween_property(p, "modulate:a", 1.0, 0.4)
	_tut_paso.text = "TUTORIAL  ·  KELLY 087  ·  %d / %d" % [paso, total]
	_tut_texto.text = "«%s»" % texto


func ocultar_tutorial() -> void:
	if _tut_panel != null and is_instance_valid(_tut_panel):
		var p := _tut_panel
		var tw := create_tween()
		tw.tween_property(p, "modulate:a", 0.0, 0.3)
		tw.tween_callback(p.queue_free)
	_tut_panel = null


func ocultar_dilema() -> void:
	if _dilema_panel != null and is_instance_valid(_dilema_panel):
		_dilema_panel.queue_free()
	_dilema_panel = null


func radio_aviso(jefe: String, n: int) -> void:
	radio_aviso_ocultar()
	if _caja_radar == null:
		return
	var col: Color = _color_jefe_hud(jefe)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(col, 8.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var txt := "RADIO  ·  %s  [R]" % jefe
	if n > 1:
		txt += "  (+%d)" % (n - 1)
	var l := EstiloUI.etiqueta(txt, 14, col, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	_caja_radar.add_child(p)
	_radio_badge = p
	_radio_tw = p.create_tween().set_loops()
	_radio_tw.tween_property(p, "modulate:a", 0.45, 0.7)
	_radio_tw.tween_property(p, "modulate:a", 1.0, 0.7)


func radio_aviso_ocultar() -> void:
	if _radio_tw != null:
		_radio_tw.kill()
		_radio_tw = null
	if _radio_badge != null and is_instance_valid(_radio_badge):
		_radio_badge.queue_free()
	_radio_badge = null


func holo_decir(texto: String, color: Color, segundos: float = 5.0) -> bool:
	if _holo == null or int(Ajustes.holograma) == 0:
		return false
	_holo.decir(texto, color, segundos)
	return true


func holo_hablando() -> bool:
	return _holo != null and _holo.esta_hablando()


func toast(titulo: String, texto: String, color: Color, segundos: float = 7.0) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(color, 10.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 1)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(c)
	c.add_child(EstiloUI.etiqueta_sub(titulo, 17, color, true))
	if texto != "":
		var t := EstiloUI.etiqueta_sub(texto, 15, EstiloUI.COL_TEXTO)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.custom_minimum_size = Vector2(440.0 * Ajustes.factor_texto(), 0.0)
		c.add_child(t)
	p.modulate.a = 0.0
	_caja_toasts.add_child(p)
	while _caja_toasts.get_child_count() > 3:
		var viejo := _caja_toasts.get_child(0)
		_caja_toasts.remove_child(viejo)
		viejo.queue_free()
	var tw := p.create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.25)
	tw.tween_interval(segundos)
	tw.tween_property(p, "modulate:a", 0.0, 0.8)
	tw.tween_callback(p.queue_free)


static func corto(t: String, maximo: int = 150) -> String:
	var u := t.strip_edges().replace("\n", " ")
	var corte := -1
	for fin in [". ", "! ", "? ", ".» "]:
		var i := u.find(fin, 40)
		if i != -1 and (corte == -1 or i < corte):
			corte = i
	if corte != -1:
		u = u.substr(0, corte + 1)
	if u.length() > maximo:
		u = u.substr(0, maximo - 1).strip_edges() + "…"
	return u


func mostrar_briefing(datos: Dictionary, relato: Dictionary) -> void:
	_br_era.text = "%s  ·  %s" % [str(datos.get("era", "")), str(datos.get("nave", ""))]
	_br_nombre.text = str(datos.get("nombre", "")).to_upper()
	_br_piloto.text = "%s %s  ·  SPARTANS II" % [Ajustes.rango(), Ajustes.nombre_visible().to_upper()]
	_br_cartel.configurar(datos)
	_br_cartel.visible = int(str(datos.get("era", "0"))) > 0
	_br_texto.text = ""
	var cond := DatosMarte.condicion(datos)
	if not cond.is_empty():
		_br_texto.text = "%s: %s" % [str(cond["n"]), corto(str(cond["d"]), 90)]
	_br_texto.visible = _br_texto.text != ""
	if not _br_cartel.visible:
		var intro := str(relato.get("intro", ""))
		_br_texto.text = corto(intro if intro != "" else str(datos.get("real", "")), 170) + ("\n" + _br_texto.text if _br_texto.text != "" else "")
		_br_texto.visible = true
	var msg: Dictionary = relato.get("jefe", {})
	_br_msg_caja.visible = not msg.is_empty()
	if not msg.is_empty():
		var inf := Historia.jefe(str(msg["j"]))
		var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
		_br_jefe.text = "MENSAJE DE %s  ·  %s" % [Historia.titulo(str(msg["j"])), str(inf.get("rol", "")).to_upper()]
		_br_jefe.add_theme_color_override("font_color", col)
		_br_msg.text = "«%s»" % corto(str(msg["t"]), 140)
	_br_arr_caja.visible = false
	for h in _br_obj.get_children():
		h.queue_free()
	for id in _totales:
		var info := DatosMarte.material(id)
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 8)
		var punto := ColorRect.new()
		punto.color = info["color"]
		punto.custom_minimum_size = Vector2(12.0, 12.0)
		punto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		f.add_child(punto)
		f.add_child(EstiloUI.etiqueta("%s × %d" % [str(info["nombre"]), int(_totales[id])], 19, info["color"], true))
		_br_obj.add_child(f)
	for nom in _blancos_nombres:
		var f2 := HBoxContainer.new()
		f2.add_theme_constant_override("separation", 8)
		var punto2 := ColorRect.new()
		punto2.color = COL_FOTO
		punto2.custom_minimum_size = Vector2(12.0, 12.0)
		punto2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		f2.add_child(punto2)
		f2.add_child(EstiloUI.etiqueta(nom, 19, COL_FOTO, true))
		_br_obj.add_child(f2)
	_br_abierto = true
	var nombres_obj: Array[String] = []
	for id in _totales:
		nombres_obj.append(str(DatosMarte.material(id)["nombre"]))
	for nom2 in _blancos_nombres:
		nombres_obj.append(nom2)
	var txt_obj := "Objetivo: " + ", ".join(nombres_obj) if _blancos_nombres.is_empty() \
			else "Objetivo: %d fotos" % _blancos_nombres.size()
	for c in _ocultables:
		c.modulate.a = 0.0
	_br_fase = 1
	_brief.visible = false
	_titulo_empezar(datos, txt_obj, cond)


func cerrar_briefing() -> void:
	if not _br_abierto:
		return
	_br_abierto = false
	_br_fase = 0
	if _tit_tw != null:
		_tit_tw.kill()
	if _tit.visible:
		_tit.visible = false
	var tw := create_tween()
	tw.tween_property(_brief, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): _brief.visible = false)


	for i in range(_ocultables.size()):
		var c: Control = _ocultables[i]
		var tw2 := create_tween()
		tw2.tween_interval(0.2 + 0.3 * i)
		tw2.tween_property(c, "modulate:a", 1.0, 0.55)
		if c == _caja_ley:
			tw2.tween_interval(14.0)
			tw2.tween_property(c, "modulate:a", 0.4, 2.5)


func briefing_abierto() -> bool:
	return _br_abierto


func mostrar_dato(d: Dictionary, leidos: int, total: int, cabecera: String = "") -> void:
	if cabecera != "":
		_dato_head.text = cabecera
	else:
		_dato_head.text = "DATO CURIOSO  ·  %s  ·  %d / %d" % [str(d.get("cat", "")).to_upper(), leidos, total]
	_dato_tit.text = str(d.get("t", ""))
	_dato_txt.text = str(d.get("x", ""))
	if _tw_dato != null:
		_tw_dato.kill()
	_dato_abierto = true
	_panel_dato.visible = true
	_panel_dato.modulate.a = 0.0
	_tw_dato = create_tween()
	_tw_dato.tween_property(_panel_dato, "modulate:a", 1.0, 0.3)
	_tw_dato.tween_interval(26.0)
	_tw_dato.tween_property(_panel_dato, "modulate:a", 0.0, 0.7)
	_tw_dato.tween_callback(func():
		_panel_dato.visible = false
		_dato_abierto = false)


func cerrar_dato() -> void:
	if not _dato_abierto:
		return
	_dato_abierto = false
	if _tw_dato != null:
		_tw_dato.kill()
	_tw_dato = create_tween()
	_tw_dato.tween_property(_panel_dato, "modulate:a", 0.0, 0.25)
	_tw_dato.tween_callback(func(): _panel_dato.visible = false)


func dato_abierto() -> bool:
	return _dato_abierto


func actualizar_curiosidades(leidas: int, total: int) -> void:
	_lbl_datos.visible = total > 0
	_lbl_datos.text = "DATOS CURIOSOS  %d / %d" % [leidas, total]


func modo_fotos(nombres: Array, disparos: int) -> void:
	_foto_modo = true
	_capacidad = disparos
	_blancos_nombres.clear()
	for n in nombres:
		_blancos_nombres.append(str(n))
	var cont: VBoxContainer = _lbl_objetivo.get_parent().get_node("Materiales")
	for h in cont.get_children():
		h.queue_free()
	_filas_mat.clear()
	_filas_fotos.clear()
	_caja_fotos = cont
	for n in _blancos_nombres:
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 8)
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var punto := ColorRect.new()
		punto.color = COL_FOTO
		punto.custom_minimum_size = Vector2(10.0, 10.0)
		punto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		punto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		f.add_child(punto)
		var nom := EstiloUI.etiqueta(n, 16, EstiloUI.COL_TEXTO, true)
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f.add_child(nom)
		var est := Estrellas.new()
		est.custom_minimum_size = Vector2(60.0, 18.0)
		est.mouse_filter = Control.MOUSE_FILTER_IGNORE
		f.add_child(est)
		var cnt := EstiloUI.etiqueta("—", 14, EstiloUI.COL_TENUE, true)
		cnt.custom_minimum_size = Vector2(74.0, 0.0)
		cnt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		f.add_child(cnt)
		cont.add_child(f)
		_filas_fotos.append({"nom": nom, "est": est, "lbl": cnt})

	var fila_b := _lbl_bodega.get_parent() as HBoxContainer
	(fila_b.get_child(0) as Label).text = "MEMORIA"
	(_banner.get_node("Caja/Nave") as Label).text = "Objetivo: %d fotos" % _blancos_nombres.size()
	_ayuda_br.visible = true
	_ayuda_br.text = "W A S D conducir  ·  ESPACIO escáner  ·  F abre el visor de la cámara (flechas o ratón orientan, rueda = zoom, ESPACIO o clic = disparar)  ·  E leer un dato curioso (opcional)"
	var fila_f := EstiloUI.etiqueta_contorno("cámara / visor", 14, EstiloUI.COL_TEXTO, false)
	fila_f.add_theme_constant_override("outline_size", 5)
	var h2 := HBoxContainer.new()
	h2.alignment = BoxContainer.ALIGNMENT_END
	h2.add_theme_constant_override("separation", 8)
	h2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h2.add_child(fila_f)
	h2.add_child(EstiloUI.tecla("F"))
	_caja_ley.add_child(h2)
	_caja_ley.move_child(h2, 4)
	_caja_ley.offset_top = -222.0
	actualizar_memoria(0, disparos, [])


func actualizar_fotos(estados: Array) -> void:
	for i in range(mini(estados.size(), _filas_fotos.size())):
		var e: Dictionary = estados[i]
		var fila: Dictionary = _filas_fotos[i]
		var est: int = int(e["estado"])
		(fila["est"] as Estrellas).n = int(e["estrellas"])
		(fila["est"] as Estrellas).queue_redraw()
		var l: Label = fila["lbl"]
		match est:
			2:
				l.text = "enviada"
				l.add_theme_color_override("font_color", EstiloUI.COL_OK)
			1:
				l.text = "en cámara"
				l.add_theme_color_override("font_color", COL_FOTO)
			_:
				l.text = "—"
				l.add_theme_color_override("font_color", EstiloUI.COL_TENUE)


func actualizar_memoria(usada: int, maximo: int, flags: Array) -> void:
	_capacidad = maximo
	for h in _caja_pips.get_children():
		h.queue_free()
	for i in range(maximo):
		var r := ColorRect.new()
		r.custom_minimum_size = Vector2(14.0, 12.0)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i < flags.size():
			r.color = COL_FOTO if bool(flags[i]) else Color(1.0, 1.0, 1.0, 0.4)
		else:
			r.color = Color(1.0, 1.0, 1.0, 0.14)
		_caja_pips.add_child(r)
	_lbl_bodega.text = "%d / %d" % [maximo - usada, maximo]
	if _visor_dib != null:
		_visor_dib.memoria = maximo - usada
		_visor_dib.memoria_max = maximo


func mostrar_visor(abrir: bool) -> void:
	if abrir == _visor_abierto:
		return
	_visor_abierto = abrir
	_visor.visible = abrir
	for c in _ocultables:
		c.visible = not abrir
	_caja_toasts.offset_bottom = -90.0 if abrir else -22.0


func actualizar_visor(d: Dictionary) -> void:
	if not _visor_abierto:
		return
	_visor_dib.zoom = float(d.get("zoom", 1.0))
	_visor_dib.fov = float(d.get("fov", 45.0))
	_visor_dib.rumbo = float(d.get("rumbo", 0.0))
	_visor_dib.elev = float(d.get("elev", 0.0))
	_visor_dib.enfoque = bool(d.get("enfoque", false))
	_visor_dib.queue_redraw()


func ocultar_para_captura(ocultar: bool) -> void:
	_raiz.visible = not ocultar


func flash() -> void:
	_flash.modulate.a = 0.85
	create_tween().tween_property(_flash, "modulate:a", 0.0, 0.45)


func _crear_visor() -> Control:
	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.visible = false
	_visor_dib = VisorDibujo.new()
	_visor_dib.fuente = EstiloUI.fuente_titulo()
	_visor_dib.set_anchors_preset(Control.PRESET_FULL_RECT)
	_visor_dib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(_visor_dib)
	var ayuda := EstiloUI.etiqueta_contorno("ESPACIO o CLIC disparar   ·   flechas / WASD / ratón orientar   ·   RUEDA zoom   ·   F o ESC cerrar visor", 15, EstiloUI.COL_TEXTO, false)
	ayuda.add_theme_constant_override("outline_size", 6)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.anchor_left = 0.0
	ayuda.anchor_right = 1.0
	ayuda.anchor_top = 1.0
	ayuda.anchor_bottom = 1.0
	ayuda.offset_top = -52.0
	ayuda.offset_bottom = -24.0
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(ayuda)
	return capa


func mostrar_final(tiempo_txt: String, resumen: Array, extra: String = "", cierre: String = "", fotos: Array = [], ruta: Dictionary = {}, restos: bool = false) -> void:
	_lbl_final_titulo.text = "INVESTIGACIÓN COMPLETADA" if restos else "MISIÓN COMPLETADA"
	_banner.visible = false
	_br_abierto = false
	_br_fase = 0
	_brief.visible = false
	_tit.visible = false
	for c in _ocultables:
		c.modulate.a = 1.0
	mostrar_visor(false)
	cerrar_dato()
	if cierre != "":
		_lbl_final_real.text = cierre
	_lbl_final_stats.text = "Buen trabajo, %s.\nTiempo de misión: %s" % [Ajustes.nombre_visible(), tiempo_txt]
	_lbl_final_extra.text = extra
	_lbl_final_extra.visible = extra != ""
	_det_final.visible = false
	_btn_detalles.text = "VER DETALLES"
	_ruta_guardada = [ruta, restos]
	for h in _caja_final_mats.get_children():
		h.queue_free()
	for r in resumen:
		var f := HBoxContainer.new()
		f.add_theme_constant_override("separation", 10)
		var punto := ColorRect.new()
		punto.color = r["color"]
		punto.custom_minimum_size = Vector2(12.0, 12.0)
		punto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		f.add_child(punto)
		var n := EstiloUI.etiqueta(str(r["nombre"]), 18, EstiloUI.COL_TEXTO, true)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f.add_child(n)
		f.add_child(EstiloUI.etiqueta("× %d" % int(r["n"]), 18, r["color"], true))
		_caja_final_mats.add_child(f)
	for h in _caja_album.get_children():
		h.queue_free()
	_caja_album.visible = not fotos.is_empty()
	if _caja_cuaderno != null:
		_caja_cuaderno.visible = false
	for ft in fotos:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 3)
		var cuadro := TextureRect.new()
		cuadro.custom_minimum_size = Vector2(176.0, 99.0)
		cuadro.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cuadro.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		if ft["tex"] != null:
			cuadro.texture = ft["tex"]
		v.add_child(cuadro)
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 6)
		var nom_l := EstiloUI.etiqueta(str(ft["nombre"]), 13, EstiloUI.COL_TEXTO, true)
		nom_l.custom_minimum_size = Vector2(110.0, 0.0)
		nom_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fila.add_child(nom_l)
		var est := Estrellas.new()
		est.n = int(ft["estrellas"])
		est.custom_minimum_size = Vector2(60.0, 18.0)
		fila.add_child(est)
		v.add_child(fila)
		_caja_album.add_child(v)
	_panel_final.visible = true
	_panel_final.modulate.a = 0.0
	create_tween().tween_property(_panel_final, "modulate:a", 1.0, 0.6)
	if _col_izq != null:
		create_tween().tween_property(_col_izq, "modulate:a", 0.0, 0.4)
	_panel_ruta.visible = false


func _mostrar_ruta(ruta: Dictionary, restos: bool) -> void:
	if ruta.is_empty():
		_panel_ruta.visible = false
		return
	var directa: float = float(ruta["dist_base"])
	var largo: float = float(ruta["distancia"])
	_ruta_mapa.poner(ruta["ruta"], ruta["eventos"], directa, restos)
	var extra := ""
	if directa > 1.0 and largo > directa:
		extra = "  (+%d %% sobre la línea recta)" % int(round((largo / directa - 1.0) * 100.0))
	_lbl_ruta_info.text = "Recorriste %.1f km. Línea recta A→B: %.1f km.%s" % [largo / 10.0, directa / 10.0, extra]
	_panel_ruta.visible = true
	_panel_ruta.modulate.a = 0.0
	_ruta_mapa.progreso = 0.0
	if _tw_ruta != null:
		_tw_ruta.kill()
	_tw_ruta = create_tween()
	_tw_ruta.tween_property(_panel_ruta, "modulate:a", 1.0, 0.6)
	_tw_ruta.tween_property(_ruta_mapa, "progreso", 1.0, 2.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


class Brujula extends Control:
	var rumbo_deg: float = 0.0
	var blips: Array = []
	var fuente: Font
	const SPAN := 130.0
	const NOMBRES_RUMBO := {0: "N", 45: "NE", 90: "E", 135: "SE", 180: "S", 225: "SO", 270: "O", 315: "NO"}

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0.0, 0.0, w, h), Color(0.03, 0.025, 0.025, 0.55))
		draw_rect(Rect2(0.0, h - 2.0, w, 2.0), Color(1.0, 1.0, 1.0, 0.18))
		var pxdeg := w / SPAN
		var cx := w * 0.5
		var b := int(floor((rumbo_deg - SPAN * 0.5) / 5.0)) * 5
		while float(b) <= rumbo_deg + SPAN * 0.5 + 5.0:
			var x := cx + (float(b) - rumbo_deg) * pxdeg
			if x >= 2.0 and x <= w - 2.0:
				var bn := posmod(b, 360)
				var largo := 7.0
				var a := 0.3
				if bn % 45 == 0:
					largo = 15.0
					a = 0.85
				elif bn % 15 == 0:
					largo = 11.0
					a = 0.55
				draw_line(Vector2(x, h - largo), Vector2(x, h - 2.0), Color(1.0, 1.0, 1.0, a), 1.5)
				if bn % 45 == 0:
					var nombre: String = NOMBRES_RUMBO.get(bn, "")
					var col := Color(0.99, 0.24, 0.13) if bn == 0 else Color(1.0, 1.0, 1.0, 0.9)
					draw_string(fuente, Vector2(x - 14.0, 17.0), nombre, HORIZONTAL_ALIGNMENT_CENTER, 28.0, 15, col)
			b += 5

		for m in blips:
			var t: String = m.get("tipo", "")
			if t == "cueva" or t == "roca":
				continue
			var rel := rad_to_deg(atan2(float(m["x"]), float(m["y"])))
			var col2: Color = m["color"]
			var x2 := cx + clampf(rel, -SPAN * 0.5 + 6.0, SPAN * 0.5 - 6.0) * pxdeg
			var fuera := absf(rel) > SPAN * 0.5 - 6.0
			var alfa := float(m.get("alpha", 1.0)) * (0.55 if fuera else 1.0)
			col2.a = alfa
			var y2 := 28.0
			if t == "muestra":
				draw_colored_polygon(PackedVector2Array([Vector2(x2, y2 - 7.0), Vector2(x2 + 6.0, y2),
						Vector2(x2, y2 + 7.0), Vector2(x2 - 6.0, y2)]), col2)
			else:
				draw_colored_polygon(PackedVector2Array([Vector2(x2 - 6.0, y2 - 6.0), Vector2(x2 + 6.0, y2 - 6.0),
						Vector2(x2, y2 + 6.0)]), col2)
				draw_string(fuente, Vector2(x2 - 8.0, y2 + 20.0), Idioma.t(str(m.get("etq", ""))), HORIZONTAL_ALIGNMENT_CENTER,
						16.0, 12, col2)

		draw_colored_polygon(PackedVector2Array([Vector2(cx - 6.0, 0.0), Vector2(cx + 6.0, 0.0), Vector2(cx, 8.0)]),
				Color(0.99, 0.24, 0.13))
		draw_string(fuente, Vector2(cx - 24.0, h + 14.0), "%03d°" % int(fposmod(rumbo_deg, 360.0)),
				HORIZONTAL_ALIGNMENT_CENTER, 48.0, 13, Color(1.0, 1.0, 1.0, 0.65))


class Guia extends Control:
	var fuente: Font
	var activa: bool = false
	var rel: float = 0.0
	var texto: String = ""
	var dist: String = ""
	var color: Color = Color(0.99, 0.24, 0.13)

	func poner(g: Dictionary) -> void:
		activa = not g.is_empty()
		visible = activa
		if not activa:
			return
		rel = float(g.get("rel", 0.0))
		texto = str(g.get("texto", ""))
		dist = str(g.get("dist", ""))
		color = g.get("color", color)
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0.0, 0.0, w, h), Color(0.03, 0.025, 0.025, 0.62))
		draw_rect(Rect2(0.0, h - 2.0, w, 2.0), Color(color.r, color.g, color.b, 0.7))
		var c := Vector2(24.0, h * 0.5)

		var dir := Vector2(sin(rel), -cos(rel))
		var lado := Vector2(-dir.y, dir.x)
		var punta := c + dir * 13.0
		var cola := c - dir * 9.0
		draw_colored_polygon(PackedVector2Array([punta, cola + lado * 9.0, c - dir * 3.0, cola - lado * 9.0]), color)
		draw_arc(c, 17.0, 0.0, TAU, 24, Color(1.0, 1.0, 1.0, 0.18), 1.5, true)
		draw_string(fuente, Vector2(50.0, 17.0), Idioma.t(texto), HORIZONTAL_ALIGNMENT_LEFT, w - 56.0, 14, Color(1.0, 1.0, 1.0, 0.92))
		draw_string(fuente, Vector2(50.0, 33.0), dist, HORIZONTAL_ALIGNMENT_LEFT, w - 56.0, 13, Color(color.r, color.g, color.b, 0.95))


class Radar extends Control:
	var blips: Array = []
	var alcance: float = 70.0
	var barrido: float = 0.0
	var pulso: float = -1.0
	var norte_rel: float = 0.0
	var fuente: Font
	const ACENTO := Color(0.99, 0.24, 0.13)

	func _draw() -> void:
		var c := size * 0.5
		var R := minf(size.x, size.y) * 0.5 - 4.0
		draw_circle(c, R, Color(0.03, 0.04, 0.05, 0.62))
		for f in [0.33, 0.66]:
			draw_arc(c, R * float(f), 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.10), 1.0, true)
		draw_line(c + Vector2(-R, 0.0), c + Vector2(R, 0.0), Color(1.0, 1.0, 1.0, 0.08), 1.0)
		draw_line(c + Vector2(0.0, -R), c + Vector2(0.0, R), Color(1.0, 1.0, 1.0, 0.08), 1.0)

		for i in range(16):
			var a := barrido - float(i) * 0.05
			var alfa := (1.0 - float(i) / 16.0) * 0.20
			draw_line(c, c + Vector2(sin(a), -cos(a)) * R, Color(ACENTO.r, ACENTO.g, ACENTO.b, alfa), 3.0)

		if pulso >= 0.0:
			draw_arc(c, R * pulso, 0.0, TAU, 72, Color(ACENTO.r, ACENTO.g, ACENTO.b, (1.0 - pulso) * 0.9), 3.0, true)

		var n := Vector2(sin(norte_rel), -cos(norte_rel))
		draw_string(fuente, c + n * (R - 14.0) + Vector2(-6.0, 6.0), "N", HORIZONTAL_ALIGNMENT_CENTER, 12.0, 14,
				Color(1.0, 0.45, 0.18, 0.95))

		for m in blips:
			var p := Vector2(float(m["x"]), -float(m["y"])) / alcance * R
			var t: String = m.get("tipo", "")
			var col: Color = m["color"]
			col.a = float(m.get("alpha", 1.0))
			var fuera := p.length() > R - 8.0
			if fuera:
				if t == "muestra" or t == "roca":
					continue
				p = p.normalized() * (R - 8.0)
				col.a *= 0.7
			var q := c + p
			match t:
				"muestra":
					draw_colored_polygon(PackedVector2Array([q + Vector2(0.0, -6.0), q + Vector2(5.0, 0.0),
							q + Vector2(0.0, 6.0), q + Vector2(-5.0, 0.0)]), col)
					draw_arc(q, 9.0, 0.0, TAU, 20, Color(col.r, col.g, col.b, col.a * 0.5), 1.5, true)
				"base":
					draw_rect(Rect2(q - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), col)
					draw_string(fuente, q + Vector2(-5.0, -9.0), "B", HORIZONTAL_ALIGNMENT_CENTER, 10.0, 12, col)
				"aterrizaje":
					draw_arc(q, 6.0, 0.0, TAU, 16, col, 2.0, true)
					draw_string(fuente, q + Vector2(-5.0, -9.0), "A", HORIZONTAL_ALIGNMENT_CENTER, 10.0, 12, col)
				"cueva":
					draw_colored_polygon(PackedVector2Array([q + Vector2(-6.0, 5.0), q + Vector2(6.0, 5.0),
							q + Vector2(0.0, -6.0)]), Color(col.r, col.g, col.b, col.a * 0.9))

		draw_colored_polygon(PackedVector2Array([c + Vector2(0.0, -9.0), c + Vector2(6.0, 7.0), c + Vector2(0.0, 3.0),
				c + Vector2(-6.0, 7.0)]), Color.WHITE)
		draw_arc(c, R, 0.0, TAU, 72, Color(ACENTO.r, ACENTO.g, ACENTO.b, 0.85), 2.0, true)


class BotonEscaner extends Control:
	var carga: float = 1.0

	func _draw() -> void:
		var c := size * 0.5
		var R := minf(size.x, size.y) * 0.5 - 3.0
		var listo := carga >= 1.0
		var col := Color(0.45, 0.95, 0.55) if listo else Color(1.0, 0.78, 0.3)
		draw_circle(c, R, Color(0.03, 0.04, 0.05, 0.7))
		draw_arc(c, R - 2.0, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.15), 3.0, true)
		draw_arc(c, R - 2.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(carga, 0.0, 1.0), 48, col, 4.0, true)

		draw_circle(c + Vector2(0.0, 8.0), 4.0, col)
		for i in range(3):
			var r := 11.0 + float(i) * 8.0
			draw_arc(c + Vector2(0.0, 8.0), r, -PI * 0.78, -PI * 0.22, 14,
					Color(col.r, col.g, col.b, 1.0 - float(i) * 0.25), 2.5, true)


class BarraEnergia extends Control:
	var valor: float = 1.0
	var tormenta: bool = false

	static func color_para(v: float) -> Color:
		if v < 0.18:
			return Color(1.0, 0.36, 0.33)
		if v < 0.4:
			return Color(1.0, 0.72, 0.25)
		return Color(0.35, 1.0, 0.5)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0.0, 0.0, w, h), Color(1.0, 1.0, 1.0, 0.10))
		var col := color_para(valor)
		draw_rect(Rect2(0.0, 0.0, w * clampf(valor, 0.0, 1.0), h), col)
		draw_rect(Rect2(0.0, 0.0, w, h), Color(1.0, 1.0, 1.0, 0.25), false, 1.0)
		if tormenta:
			var x := -h
			while x < w:
				draw_line(Vector2(x, h), Vector2(x + h, 0.0), Color(0.0, 0.0, 0.0, 0.35), 2.0)
				x += 7.0


class Estrellas extends Control:
	var n: int = 0

	func _draw() -> void:
		for i in range(3):
			var c := Vector2(9.0 + float(i) * 20.0, size.y * 0.5)
			var pts := PackedVector2Array()
			for j in range(10):
				var a := -PI * 0.5 + TAU * float(j) / 10.0
				var r := 8.5 if j % 2 == 0 else 3.6
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			var col := Color(1.0, 0.78, 0.3) if i < n else Color(1.0, 1.0, 1.0, 0.16)
			draw_colored_polygon(pts, col)


class VisorDibujo extends Control:
	var fuente: Font
	var zoom: float = 1.0
	var fov: float = 45.0
	var rumbo: float = 0.0
	var elev: float = 0.0
	var enfoque: bool = false
	var memoria: int = 0
	var memoria_max: int = 0

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var col := Color(0.55, 1.0, 0.6, 0.95) if enfoque else Color(1.0, 1.0, 1.0, 0.85)
		var sombra := Color(0.0, 0.0, 0.0, 0.5)

		for i in range(5):
			var g := 14.0 * float(i)
			draw_rect(Rect2(0.0, 0.0, w, g), Color(0.0, 0.0, 0.0, 0.06))
			draw_rect(Rect2(0.0, h - g, w, g), Color(0.0, 0.0, 0.0, 0.06))

		var mx := w * 0.07
		var my := h * 0.09
		var L := 46.0
		for sx in [0.0, 1.0]:
			for sy in [0.0, 1.0]:
				var x := mx if sx == 0.0 else w - mx
				var y := my if sy == 0.0 else h - my
				var dx := L if sx == 0.0 else -L
				var dy := L if sy == 0.0 else -L
				draw_line(Vector2(x, y) + Vector2(1.5, 1.5), Vector2(x + dx, y) + Vector2(1.5, 1.5), sombra, 4.0)
				draw_line(Vector2(x, y) + Vector2(1.5, 1.5), Vector2(x, y + dy) + Vector2(1.5, 1.5), sombra, 4.0)
				draw_line(Vector2(x, y), Vector2(x + dx, y), col, 3.0)
				draw_line(Vector2(x, y), Vector2(x, y + dy), col, 3.0)

		var c := size * 0.5
		var gap := 10.0
		var largo := 26.0
		for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			draw_line(c + dir * gap, c + dir * (gap + largo), col, 2.0)
		draw_arc(c, 62.0, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.28), 1.5, true)
		draw_circle(c, 2.5, col)

		var tam := 20
		draw_string(fuente, Vector2(mx + 8.0, my + 34.0), Idioma.t("PANCAM  ·  PANORÁMICA"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, col)
		draw_string(fuente, Vector2(w - mx - 260.0, my + 34.0), Idioma.t("ZOOM ×%.1f" % zoom), HORIZONTAL_ALIGNMENT_RIGHT, 252.0, tam, col)
		draw_string(fuente, Vector2(w - mx - 260.0, my + 60.0), Idioma.t("CAMPO %d°" % int(round(fov))), HORIZONTAL_ALIGNMENT_RIGHT, 252.0, 16,
				Color(1.0, 1.0, 1.0, 0.7))
		draw_string(fuente, Vector2(mx + 8.0, h - my - 18.0), Idioma.t("RUMBO %03d°   ELEV %+d°" % [int(fposmod(rumbo, 360.0)), int(round(elev))]),
				HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, col)
		draw_string(fuente, Vector2(w - mx - 260.0, h - my - 18.0), Idioma.t("DISPAROS  %d / %d" % [memoria, memoria_max]),
				HORIZONTAL_ALIGNMENT_RIGHT, 252.0, tam, col)
		if enfoque:
			draw_string(fuente, Vector2(c.x - 150.0, c.y + 100.0), Idioma.t("BLANCO EN ENCUADRE"), HORIZONTAL_ALIGNMENT_CENTER, 300.0, 20, col)
