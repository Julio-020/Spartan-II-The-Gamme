extends Node


const MissionSite := preload("res://mision/mission_site.gd")
const INTRO_DIST_INICIAL := 36000.0
const MissionRun := preload("res://mision/mission_run.gd")
const MainMenu := preload("res://interfaz/main_menu.gd")
const SalaControl := preload("res://interfaz/sala_control.gd")
const EscenaComite := preload("res://cinematicas/escena_comite.gd")
const MarcoHUD := preload("res://interfaz/marco_hud.gd")
const Transicion := preload("res://interfaz/transicion.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const CalidadAuto := preload("res://nucleo/calidad_auto.gd")
const AudioJuego := preload("res://sonido/audio_juego.gd")
const IntroCinematica := preload("res://cinematicas/intro_cinematica.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Partidas := preload("res://nucleo/partidas.gd")
const Rutas := preload("res://progreso/rutas.gd")
const Mando := preload("res://nucleo/mando.gd")
const Accesibilidad := preload("res://nucleo/accesibilidad.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const EventosEntre := preload("res://historia/eventos_entre.gd")
const AvisoGuardado := preload("res://nucleo/aviso_guardado.gd")
const SuenoRover := preload("res://mision/sueno_rover.gd")
const Bitacora := preload("res://progreso/bitacora.gd")

var _progreso: Array = []
var _clave_progreso: String = ""

enum Estado { MENU, DESCENSO, MISION, ASCENSO, TITULO, INTRO, COMITE }

@export_group("Referencias de la Escena")
@export var menu_camera: Camera3D
@export var ship_player: PlanetCamera
@export var planet_node: Planet

@export_group("Cámara del menú")
@export var distancia_inicial: float = 8000.0
@export var distancia_min: float = 5200.0
@export var distancia_max: float = 14000.0
@export var giro_automatico: float = 0.03
@export var sensibilidad_giro: float = 0.004

@export_group("Misión")
@export var duracion_descenso: float = 6.0
@export var duracion_ascenso: float = 4.5

@export var escala_robot: float = 0.1


@export_range(0.1, 1.0) var relieve_mision: float = 0.3


var misiones: Array[Dictionary] = []

var estado: Estado = Estado.TITULO
var sitios: Array = []
var _hover: MissionSite = null
var _sitio_actual: MissionSite = null
var _mando: Mando = null
var _datos_ultima: Dictionary = {}
var _evento_pendiente: bool = false
var _sitio_exp: MissionSite = null
var _mision: MissionRun = null

var _planet: Planet
var _relieve_original: float = -1.0
var _audio: AudioJuego
var _menu_titulo: MainMenu
var _trans: Transicion
var _sala: SalaControl
var _lbl_fps: Label
var _acercando: bool = false
var _intro: IntroCinematica = null
var _intro_p: float = 0.0
var _cam: PlanetCamera
var _mat_terreno: ShaderMaterial
var _env: Environment = null


var _cam_rel: Vector3 = Vector3.ZERO
var _cam_basis: Basis = Basis.IDENTITY


var _yaw: float = 0.0
var _pitch: float = 0.0
var _dist: float = 8000.0
var _arrastrando: bool = false


var _v_t: float = 0.0
var _v_dur: float = 1.0
var _v_rel0: Vector3
var _v_rel1: Vector3
var _v_q0: Quaternion
var _v_q1: Quaternion

var _sol_actual: Vector3 = Vector3(0.5, 0.3, 0.8)


var _capa_menu: CanvasLayer
var _lbl_titulo: Label
var _lbl_contador: Label
var _panel_info: PanelContainer
var _lbl_info_era: Label
var _lbl_info_nombre: Label
var _lbl_info_desc: Label
var _lbl_info_real: Label
var _caja_chips: HFlowContainer
var _lbl_info_estado: Label
var _linea_tiempo: Control
var _hover_previo: MissionSite = null


func _ready() -> void:
	if planet_node == null or ship_player == null:
		push_error("GameManager: asigna ship_player (PlanetCamera) y planet_node (Planet).")
		set_process(false)
		set_process_unhandled_input(false)
		return
	_planet = planet_node
	_cam = ship_player
	add_to_group("gestor_juego")
	for d in DatosMarte.MISIONES:
		misiones.append(d)
	EstiloUI.instalar_tema()

	_limpiar_escena_demo()
	_cam.current = true
	_preparar_ambiente()

	var m = _planet.get("_shader_material")
	if m is ShaderMaterial:
		_mat_terreno = m
	else:
		_mat_terreno = load("res://materials/terrain.tres") as ShaderMaterial
	_aplicar_estilo_marte()

	_crear_ui_menu()
	_crear_sitios()

	_dist = clampf(distancia_inicial, distancia_min, distancia_max)
	_yaw = 0.0
	_pitch = 0.0
	_pose_orbita()
	_sol_actual = _sol_objetivo()
	_aplicar_camara(0.0)

	_crear_pantalla_titulo()


func _limpiar_escena_demo() -> void:
	for h in get_parent().get_children():
		var es_demo: bool = h.name == "Example"
		var scr = h.get_script()
		if scr != null and str(scr.resource_path).ends_with("example.gd"):
			es_demo = true
		if es_demo:
			h.process_mode = Node.PROCESS_MODE_DISABLED
			h.queue_free()
	var sol_demo := _cam.get_node_or_null("Sun")
	if sol_demo:
		sol_demo.queue_free()
	if menu_camera and menu_camera != _cam:
		menu_camera.queue_free()
	var viejo := _planet.get_node_or_null("LandingMarker")
	if viejo:
		viejo.queue_free()


func _preparar_ambiente() -> void:
	for h in get_parent().get_children():
		if h is WorldEnvironment and h.environment:
			var env: Environment = h.environment
			_env = env
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			env.ambient_light_color = Color(0.85, 0.6, 0.45)
			env.ambient_light_energy = 0.5


func _aplicar_estilo_marte() -> void:
	if _mat_terreno != null:
		var colores := {
			"color_deep_ocean": Color(0.30, 0.19, 0.14),
			"color_ocean": Color(0.40, 0.25, 0.18),
			"color_shallow_water": Color(0.50, 0.31, 0.21),
			"color_beach": Color(0.68, 0.43, 0.26),
			"color_lowland": Color(0.76, 0.46, 0.26),
			"color_highland": Color(0.70, 0.39, 0.21),
			"color_rock": Color(0.50, 0.38, 0.32),
			"color_high_rock": Color(0.37, 0.29, 0.25),
			"color_snow_line": Color(0.80, 0.62, 0.50),
			"color_snow_peak": Color(0.90, 0.74, 0.62),
		}
		for clave in colores:
			_mat_terreno.set_shader_parameter(clave, colores[clave])
		_mat_terreno.set_shader_parameter("shadow_strength", 1.0)
		_mat_terreno.set_shader_parameter("ambient_light", 0.03)
		_mat_terreno.set_shader_parameter("texture_tint", Color(1.0, 0.62, 0.42))
	var atm = _planet.get("_atm_material")
	if atm is ShaderMaterial:
		atm.set_shader_parameter("wavelength_r", 0.5)
		atm.set_shader_parameter("wavelength_g", 0.55)
		atm.set_shader_parameter("wavelength_b", 0.62)
		atm.set_shader_parameter("km", 0.0035)


func _altura(dir: Vector3) -> float:
	return _planet.terrain_noise.compute_noise(dir) * _planet.terrain_height


func _dir_desde_lat_lon(lat_deg: float, lon_deg: float) -> Vector3:
	var lat := deg_to_rad(lat_deg)
	var lon := deg_to_rad(lon_deg)
	return Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon)).normalized()


func _base_hacia_arriba(arriba: Vector3) -> Basis:
	var ref := Vector3.UP if absf(arriba.y) < 0.999 else Vector3.RIGHT
	var t1 := arriba.cross(ref).normalized()
	return Basis(t1, arriba, t1.cross(arriba))


func _crear_sitios() -> void:
	for d in misiones:
		var s := MissionSite.new()
		s.id = d["id"]
		s.nombre = d["nombre"]
		s.descripcion = d["descripcion"]
		s.datos = d
		var dir := _dir_desde_lat_lon(d["lat"], d["lon"])
		s.position = dir * (_planet.radius + _altura(dir))
		s.basis = _base_hacia_arriba(dir)
		_planet.add_child(s)
		sitios.append(s)


func _aplicar_progreso() -> void:

	var libre: bool = Ajustes.misiones_libres
	var clave := "%d_%s" % [HistoriaEstado.num_hechas(), str(libre)]
	if clave != _clave_progreso or _progreso.size() != sitios.size():
		_clave_progreso = clave
		_progreso = HistoriaEstado.progreso(misiones, libre)
	for i in range(mini(sitios.size(), _progreso.size())):
		var s: MissionSite = sitios[i]
		var p: Dictionary = _progreso[i]
		s.estado_campana(bool(p["hecha"]), bool(p["bloq"]), bool(p["oferta"]))
		s.motivo_bloqueo = str(p["motivo"])


const LOD_UMBRAL := [17.0, 13.0, 10.0]
const LOD_PRESUPUESTO := [4, 6, 8]


func aplicar_lod() -> void:
	if _planet == null:
		return
	var c := clampi(Ajustes.calidad, 0, 2)
	_planet.lod_threshold_deg = LOD_UMBRAL[c]
	_planet.split_budget = LOD_PRESUPUESTO[c]
	_planet._compute_lod_thresholds()


func _crear_pantalla_titulo() -> void:
	Ajustes.cargar()
	Partidas.migrar_legado()
	Ajustes.aplicar(get_viewport())
	add_child(CalidadAuto.new())
	_aplicar_progreso()

	Idioma.aplicar()
	_audio = AudioJuego.new()
	add_child(_audio)
	_audio.iniciar_musica()
	_mando = Mando.new()
	add_child(_mando)
	_mando.giro_planeta.connect(_on_giro_planeta)
	_mando.zoom_planeta.connect(_on_zoom_planeta)
	add_child(Accesibilidad.new())

	var capa_fps := CanvasLayer.new()
	capa_fps.layer = 90
	add_child(capa_fps)
	_lbl_fps = _nueva_label(capa_fps, 16, Color(0.6, 1.0, 0.6))
	_lbl_fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_anclar(_lbl_fps, 1.0, 1.0, 1.0, 1.0, -160.0, -34.0, -14.0, -8.0)

	var capa_sala := CanvasLayer.new()
	capa_sala.layer = 15
	add_child(capa_sala)
	_trans = Transicion.new()
	add_child(_trans)
	_sala = SalaControl.new()
	capa_sala.add_child(_sala)
	_sala.ocultar(true)
	_menu_titulo = MainMenu.new()
	_menu_titulo.sala = _sala
	_menu_titulo.audio = _audio
	_menu_titulo.jugar_pulsado.connect(_on_jugar)
	_menu_titulo.expedicion_pedida.connect(_on_expedicion)
	_menu_titulo.intro_pedida.connect(_iniciar_intro)
	_menu_titulo.partida_cambiada.connect(_on_partida_cambiada)
	add_child(_menu_titulo)
	if Ajustes.ver_intro:
		_iniciar_intro()
	else:
		_entrar_titulo(false)


func _on_partida_cambiada() -> void:
	_clave_progreso = ""
	_aplicar_progreso()


func _entrar_titulo(mostrar_menu: bool) -> void:
	if _hover:
		_hover.set_hover(false)
		_hover = null
	_arrastrando = false
	_acercando = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	for s in sitios:
		s.visible = false
	_capa_menu.visible = false
	estado = Estado.TITULO
	if mostrar_menu:
		if Ajustes.sala_3d:
			_sala.mostrar()
		else:
			_sala.ocultar(true)
		_menu_titulo.mostrar()
	else:
		_sala.ocultar(true)


func _iniciar_intro() -> void:
	_entrar_titulo(false)
	_menu_titulo.visible = false
	_dist = INTRO_DIST_INICIAL
	_yaw = 0.0
	_pitch = 0.45
	_intro_p = 0.0
	_intro = IntroCinematica.new()
	_intro.audio = _audio
	_intro.terminada.connect(_on_intro_terminada)
	add_child(_intro)
	estado = Estado.INTRO


func _on_intro_terminada() -> void:
	_intro = null
	_entrar_titulo(true)


func _proceso_intro(delta: float) -> void:
	if _intro == null or not is_instance_valid(_intro):
		return
	_intro_p = clampf(_intro.t / IntroCinematica.DURACION, 0.0, 1.0)
	var e := 1.0 - pow(1.0 - _intro_p, 1.8)
	var d1 := minf(distancia_max, distancia_inicial * 1.3)
	_dist = INTRO_DIST_INICIAL * pow(d1 / INTRO_DIST_INICIAL, e)
	_yaw += (0.05 + 0.05 * (1.0 - _intro_p)) * delta
	_pitch = lerpf(0.45, 0.0, e)
	_pose_orbita()


func _on_jugar() -> void:
	_sala.ocultar()
	for s in sitios:
		s.visible = true
	_capa_menu.visible = true
	_acercando = true
	estado = Estado.MENU


func _on_expedicion(datos: Dictionary) -> void:
	_sala.ocultar()
	if _sitio_exp != null and is_instance_valid(_sitio_exp):
		_sitio_exp.queue_free()
	var s := MissionSite.new()
	s.id = str(datos["id"])
	s.nombre = str(datos["nombre"])
	s.descripcion = str(datos["descripcion"])
	s.datos = datos
	var dir := _dir_desde_lat_lon(float(datos["lat"]), float(datos["lon"]))
	s.position = dir * (_planet.radius + _altura(dir))
	s.basis = _base_hacia_arriba(dir)
	_planet.add_child(s)
	_sitio_exp = s
	_capa_menu.visible = false
	estado = Estado.MENU
	_empezar_descenso(s)


func _proceso_titulo(delta: float) -> void:
	_yaw += maxf(giro_automatico, 0.03) * 1.3 * delta
	var d_titulo := minf(distancia_max, distancia_inicial * 1.3)
	_dist = lerpf(_dist, d_titulo, 1.0 - exp(-1.5 * delta))
	_pose_orbita()


func _pose_orbita() -> void:
	_cam_rel = Vector3(cos(_pitch) * sin(_yaw), sin(_pitch), cos(_pitch) * cos(_yaw)) * _dist
	_cam_basis = Basis.looking_at(-_cam_rel, Vector3.UP)


func _sol_objetivo() -> Vector3:
	if estado == Estado.DESCENSO or estado == Estado.MISION:
		if _mision != null:
			return _mision.sol_dir
	if estado == Estado.INTRO:

		return (_cam_basis.x * 0.9 + _cam_basis.y * 0.25 \
				+ _cam_basis.z * lerpf(-0.25, 0.75, _intro_p)).normalized()

	return (_cam_basis.x * 0.55 + _cam_basis.y * 0.35 + _cam_basis.z * 0.75).normalized()


func _on_giro_planeta(v: Vector2) -> void:
	if estado != Estado.MENU:
		return
	_yaw -= v.x * 2.4 * Ajustes.sens_giro
	_pitch = clampf(_pitch + v.y * 2.0 * Ajustes.sens_giro, -1.2, 1.2)


func _on_zoom_planeta(z: float) -> void:
	if estado != Estado.MENU:
		return
	_dist = clampf(_dist * (1.0 + z * 1.6), distancia_min, distancia_max)


func _process(delta: float) -> void:
	if _mando != null:
		_mando.modo = "mision" if estado == Estado.MISION else ("planeta" if estado == Estado.MENU else "menu")
	match estado:
		Estado.INTRO:
			_proceso_intro(delta)
		Estado.TITULO:
			_proceso_titulo(delta)
		Estado.MENU:
			_proceso_menu(delta)
		Estado.DESCENSO:
			if _mision:
				_mision.tick(delta)
			_proceso_vuelo(delta)
		Estado.MISION:
			if _mision:
				_mision.tick(delta)
				_cam_rel = _mision.cam_pos
				_cam_basis = _mision.cam_basis
		Estado.ASCENSO:
			_proceso_vuelo(delta)


	var objetivo := _sol_objetivo()
	var mezcla := _sol_actual.lerp(objetivo, 1.0 - exp(-1.5 * delta))
	_sol_actual = mezcla.normalized() if mezcla.length() > 0.01 else objetivo

	_aplicar_camara(delta)

	if estado == Estado.MENU:
		_actualizar_hover()
		_actualizar_ui_menu()

	if _lbl_fps != null:
		_lbl_fps.visible = Ajustes.mostrar_fps
		if Ajustes.mostrar_fps:
			_lbl_fps.text = "%d FPS" % int(Engine.get_frames_per_second())


func _aplicar_camara(delta: float) -> void:
	_planet.sun_direction = _sol_actual

	if _mat_terreno != null:
		var amb_terreno := 0.03
		if _mision != null and (estado == Estado.DESCENSO or estado == Estado.MISION):
			amb_terreno = lerpf(0.03, 0.42, 1.0 - _mision.dia_f)
		_mat_terreno.set_shader_parameter("ambient_light", amb_terreno)
	_cam.global_position = _planet.global_position + _cam_rel
	_cam.global_transform.basis = _cam_basis
	_cam.update(delta)
	_actualizar_tex_origin()
	if _mision:
		_mision.poner_sol(_sol_actual)


func _actualizar_tex_origin() -> void:
	if _mat_terreno == null:
		return
	var local := _planet.to_local(_cam.global_position)
	_mat_terreno.set_shader_parameter("tex_origin", _planet.global_position + local.round())


func _proceso_menu(delta: float) -> void:
	if _acercando:
		_dist = lerpf(_dist, distancia_inicial, 1.0 - exp(-2.5 * delta))
		if absf(_dist - distancia_inicial) < 30.0:
			_acercando = false
	if Ajustes.giro_auto and giro_automatico != 0.0 and _hover == null and not _arrastrando:
		_yaw += giro_automatico * delta
	var giro := float(_tecla(KEY_D, KEY_RIGHT)) - float(_tecla(KEY_A, KEY_LEFT))
	_yaw += giro * delta
	var inclina := float(_tecla(KEY_W, KEY_UP)) - float(_tecla(KEY_S, KEY_DOWN))
	_pitch = clampf(_pitch + inclina * 0.8 * delta, -1.2, 1.2)
	_pose_orbita()


func _tecla(a: Key, b: Key) -> bool:
	return Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)


func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.MENU:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_entrar_titulo(true)
		return

	if event is InputEventMouseMotion:
		if _arrastrando:
			_yaw -= event.relative.x * sensibilidad_giro * Ajustes.sens_giro
			_pitch = clampf(_pitch + event.relative.y * sensibilidad_giro * Ajustes.sens_giro, -1.2, 1.2)

	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				_arrastrando = event.pressed
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					_dist = clampf(_dist * 0.92, distancia_min, distancia_max)
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					_dist = clampf(_dist * 1.08, distancia_min, distancia_max)
			MOUSE_BUTTON_LEFT:
				if event.pressed and _hover != null:
					_seleccionar(_hover)


func _interseccion_esfera(origen: Vector3, dir: Vector3, centro: Vector3, radio: float) -> float:
	var oc := origen - centro
	var b := oc.dot(dir)
	var c := oc.dot(oc) - radio * radio
	var disc := b * b - c
	if disc < 0.0:
		return -1.0
	var raiz := sqrt(disc)
	var t := -b - raiz
	if t < 0.0:
		t = -b + raiz
	return t


func _sitio_bajo_cursor(pos: Vector2) -> MissionSite:
	var origen := _cam.project_ray_origin(pos)
	var dir := _cam.project_ray_normal(pos)
	var t_planeta := _interseccion_esfera(origen, dir, _planet.global_position,
			_planet.radius + _planet.terrain_height * 0.4)

	var mejor: MissionSite = null
	var mejor_t := INF
	for s in sitios:
		var centro: Vector3 = s.centro_click()
		var radio: float = s.radio_click()
		var t := _interseccion_esfera(origen, dir, centro, radio)
		if t < 0.0:
			continue
		if t_planeta >= 0.0 and t_planeta < t:
			continue
		if t < mejor_t:
			mejor_t = t
			mejor = s
	return mejor


func _actualizar_hover() -> void:
	var nuevo := _sitio_bajo_cursor(get_viewport().get_mouse_position())
	if nuevo == _hover:
		return
	if _hover:
		_hover.set_hover(false)
	_hover = nuevo
	if _hover:
		_hover.set_hover(true)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _seleccionar(sitio: MissionSite) -> void:
	if estado != Estado.MENU:
		return
	if sitio.bloqueada:
		return
	if _hover:
		_hover.set_hover(false)
		_hover = null
	_arrastrando = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if bool(sitio.datos.get("final", false)) and not Ajustes.misiones_libres:
		_comite_antes(sitio)
		return
	_empezar_descenso(sitio)


func _comite_antes(sitio: MissionSite) -> void:
	estado = Estado.COMITE
	_capa_menu.visible = false
	for s in sitios:
		s.visible = false
	var esc := EscenaComite.new()
	esc.sala = _sala
	esc.terminada.connect(func():
		_sala.ocultar_comite()
		_sala.ocultar()
		estado = Estado.MENU
		_empezar_descenso(sitio))
	add_child(esc)


func _empezar_descenso(sitio: MissionSite) -> void:
	_sitio_actual = sitio


	if _relieve_original < 0.0:
		_relieve_original = _planet.terrain_height
	_planet.terrain_height = maxf(_relieve_original * relieve_mision, 1.0)


	_mision = MissionRun.new()
	_mision.configurar(_planet, sitio.datos, escala_robot, _env)
	_mision.mision_completada.connect(_on_mision_completada)
	_mision.salir_solicitado.connect(_on_salir_mision)
	_planet.add_child(_mision)

	for s in sitios:
		s.visible = false
	sitio.visible = true

	_capa_menu.visible = false
	_audio.atenuar_musica(true)
	_trans.mostrar("DESCENDIENDO A", sitio.nombre, "%s  ·  %s" % [str(sitio.datos.get("era", "")), str(sitio.datos.get("nave", ""))])
	_iniciar_vuelo(_cam_rel, _cam_basis, _mision.cam_pos, _mision.cam_basis, duracion_descenso)
	estado = Estado.DESCENSO


func _iniciar_vuelo(rel0: Vector3, b0: Basis, rel1: Vector3, b1: Basis, dur: float) -> void:
	_v_t = 0.0
	_v_dur = maxf(dur, 0.1)
	_v_rel0 = rel0
	_v_rel1 = rel1
	_v_q0 = b0.get_rotation_quaternion()
	_v_q1 = b1.get_rotation_quaternion()


func _proceso_vuelo(delta: float) -> void:
	_v_t += delta / _v_dur
	var t := clampf(_v_t, 0.0, 1.0)
	var te := t * t * (3.0 - 2.0 * t)
	_trans.progreso(t)


	var d0 := _v_rel0.normalized()
	var d1 := _v_rel1.normalized()
	var dir := d0.slerp(d1, te)
	var r := _planet.radius
	var s0 := maxf(_v_rel0.length() - r, 0.05)
	var s1 := maxf(_v_rel1.length() - r, 0.05)
	var s := s0 * pow(s1 / s0, te)
	var largo := r + s

	largo = maxf(largo, r + _altura(dir) + 0.4 + 0.01 * s)

	_cam_rel = dir * largo
	var tr := clampf((t - 0.15) / 0.85, 0.0, 1.0)
	tr = tr * tr * (3.0 - 2.0 * tr)
	_cam_basis = Basis(_v_q0.slerp(_v_q1, tr))


	if estado == Estado.DESCENSO and _sitio_actual and t > 0.45:
		_sitio_actual.visible = false

	if _v_t >= 1.0:
		if estado == Estado.DESCENSO:
			estado = Estado.MISION
			_trans.ocultar()
			_mision.activar()
		else:
			_terminar_ascenso()


func _on_mision_completada(id_mision: String, tiempo: float) -> void:
	if _sitio_actual and _sitio_actual == _sitio_exp:
		print("¡Expedición completada: ", id_mision, " en ", snappedf(tiempo, 0.1), " s!")
		return
	if _sitio_actual:
		_sitio_actual.marcar_completada()

		if sitios.find(_sitio_actual) == Ajustes.campana:
			Ajustes.campana += 1
			Ajustes.guardar()
			_evento_pendiente = true
			_datos_ultima = _sitio_actual.datos
		_aplicar_progreso()
	print("¡Misión completada: ", id_mision, " en ", snappedf(tiempo, 0.1), " s!")


func _on_salir_mision() -> void:
	if estado != Estado.MISION:
		return
	_mision.desactivar()
	_audio.atenuar_musica(false)


	var dir := _sitio_actual.position.normalized()
	_yaw = atan2(dir.x, dir.z)
	_pitch = asin(clampf(dir.y, -1.0, 1.0))
	var rel1 := Vector3(cos(_pitch) * sin(_yaw), sin(_pitch), cos(_pitch) * cos(_yaw)) * _dist
	var b1 := Basis.looking_at(-rel1, Vector3.UP)

	for s in sitios:
		s.visible = true
	estado = Estado.ASCENSO
	_trans.mostrar("REGRESANDO A ÓRBITA", "Misión de %s" % _sitio_actual.nombre, "Los jefes esperan tu informe en el comité.",
			"CONSEJO  ·  Revisa el diario (menú → DIARIO) para ver medallas y la confianza con tu equipo.")
	_iniciar_vuelo(_cam_rel, _cam_basis, rel1, b1, duracion_ascenso)


func _terminar_ascenso() -> void:
	if _sitio_exp != null and is_instance_valid(_sitio_exp):
		if _sitio_actual == _sitio_exp:
			_sitio_actual = null
		_sitio_exp.queue_free()
	_sitio_exp = null
	if _mision:
		_mision.queue_free()
		_mision = null
	if _relieve_original > 0.0:
		_planet.terrain_height = _relieve_original
		_relieve_original = -1.0
	_pose_orbita()
	_trans.ocultar()
	_capa_menu.visible = true
	estado = Estado.MENU
	_actualizar_ui_menu()
	_mostrar_evento_entre()


func _mostrar_evento_entre() -> void:
	if not _evento_pendiente:
		return
	_evento_pendiente = false
	var ev := EventosEntre.sorteo()
	if ev.is_empty():
		_mostrar_sueno()
		return
	var tarjeta := EventosEntre.crear_tarjeta(ev)
	add_child(tarjeta)
	tarjeta.cerrada.connect(_actualizar_ui_menu)
	tarjeta.cerrada.connect(AvisoGuardado.mostrar)
	tarjeta.cerrada.connect(_mostrar_sueno)


func _mostrar_sueno() -> void:
	if Ajustes.suenos == 0 or _datos_ultima.is_empty():
		return
	var entradas := Bitacora.entradas()
	var ent: Dictionary = entradas.back() if not entradas.is_empty() else {}
	var sig: Dictionary = {}
	if Ajustes.campana < sitios.size():
		sig = (sitios[Ajustes.campana] as MissionSite).datos
	var s := SuenoRover.new()
	s.guion = SuenoRover.componer(ent, _datos_ultima, sig, Ajustes.campana)
	add_child(s)


func _anclar(c: Control, izq: float, arr: float, der: float, aba: float,
		o_izq: float, o_arr: float, o_der: float, o_aba: float) -> void:
	c.anchor_left = izq
	c.anchor_top = arr
	c.anchor_right = der
	c.anchor_bottom = aba
	c.offset_left = o_izq
	c.offset_top = o_arr
	c.offset_right = o_der
	c.offset_bottom = o_aba


func _nueva_label(padre: Node, tam: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(l)
	return l


func _crear_ui_menu() -> void:
	_capa_menu = CanvasLayer.new()
	add_child(_capa_menu)

	var marco := MarcoHUD.new()
	marco.titulo = "MAPA DE MISIONES  ·  SPARTANS II"
	marco.ticker = false
	_capa_menu.add_child(marco)

	_lbl_titulo = EstiloUI.etiqueta_contorno("", 36, EstiloUI.COL_TEXTO, true)
	_lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa_menu.add_child(_lbl_titulo)
	_anclar(_lbl_titulo, 0.0, 0.0, 1.0, 0.0, 0.0, 20.0, 0.0, 80.0)

	_linea_tiempo = LineaTiempo.new()
	_linea_tiempo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa_menu.add_child(_linea_tiempo)
	_anclar(_linea_tiempo, 0.5, 0.0, 0.5, 0.0, -460.0, 84.0, 460.0, 150.0)

	_lbl_contador = EstiloUI.etiqueta_contorno("", 20, EstiloUI.COL_OK, true)
	_lbl_contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_contador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa_menu.add_child(_lbl_contador)
	_anclar(_lbl_contador, 1.0, 0.0, 1.0, 0.0, -420.0, 54.0, -40.0, 90.0)

	var ayuda := EstiloUI.etiqueta("Click izquierdo en un pin: iniciar misión\nClick derecho + arrastrar (o A/D/W/S): girar el planeta\nRueda del ratón: zoom · Esc: menú principal",
			16, EstiloUI.COL_TENUE)
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa_menu.add_child(ayuda)
	_anclar(ayuda, 0.0, 1.0, 0.0, 1.0, 50.0, -116.0, 590.0, -44.0)

	_panel_info = PanelContainer.new()
	_panel_info.add_theme_stylebox_override("panel", EstiloUI.panel(EstiloUI.COL_ACENTO, 20.0))
	_panel_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_info.visible = false
	_capa_menu.add_child(_panel_info)
	_anclar(_panel_info, 0.5, 1.0, 0.5, 1.0, -330.0, -30.0, 330.0, -30.0)
	_panel_info.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_info.add_child(caja)

	_lbl_info_era = EstiloUI.etiqueta("", 18, EstiloUI.COL_ACENTO, true)
	caja.add_child(_lbl_info_era)
	_lbl_info_nombre = EstiloUI.etiqueta("", 30, EstiloUI.COL_TEXTO, true)
	caja.add_child(_lbl_info_nombre)
	_lbl_info_desc = EstiloUI.etiqueta("", 17, EstiloUI.COL_TEXTO)
	_lbl_info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_info_desc.custom_minimum_size = Vector2(620.0, 0.0)
	caja.add_child(_lbl_info_desc)
	caja.add_child(EstiloUI.linea())
	_lbl_info_real = EstiloUI.etiqueta("", 15, EstiloUI.COL_TENUE)
	_lbl_info_real.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_info_real.custom_minimum_size = Vector2(620.0, 0.0)
	caja.add_child(_lbl_info_real)
	_caja_chips = HFlowContainer.new()
	_caja_chips.add_theme_constant_override("h_separation", 8)
	_caja_chips.add_theme_constant_override("v_separation", 6)
	_caja_chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(_caja_chips)
	_lbl_info_estado = EstiloUI.etiqueta("", 16, EstiloUI.COL_FRIO, true)
	caja.add_child(_lbl_info_estado)


func _llenar_chips(datos: Dictionary) -> void:
	for h in _caja_chips.get_children():
		h.queue_free()
	var cond := DatosMarte.condicion(datos)
	if not cond.is_empty():
		var col_c: Color = cond["c"]
		var chip_c := PanelContainer.new()
		chip_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb_c := EstiloUI.caja(Color(col_c.r, col_c.g, col_c.b, 0.2), 5.0)
		sb_c.content_margin_left = 10.0
		sb_c.content_margin_right = 10.0
		sb_c.content_margin_top = 3.0
		sb_c.content_margin_bottom = 3.0
		sb_c.border_color = col_c
		sb_c.set_border_width_all(1)
		chip_c.add_theme_stylebox_override("panel", sb_c)
		chip_c.add_child(EstiloUI.etiqueta(str(cond["n"]), 15, col_c.lightened(0.3), true))
		_caja_chips.add_child(chip_c)
	if str(datos.get("tipo", "")) == "fotos":
		var col_f := Color(0.78, 0.55, 1.0)
		var chip_f := PanelContainer.new()
		chip_f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb_f := EstiloUI.caja(Color(col_f.r, col_f.g, col_f.b, 0.16), 5.0)
		sb_f.content_margin_left = 10.0
		sb_f.content_margin_right = 10.0
		sb_f.content_margin_top = 3.0
		sb_f.content_margin_bottom = 3.0
		sb_f.border_color = Color(col_f.r, col_f.g, col_f.b, 0.7)
		sb_f.set_border_width_all(1)
		chip_f.add_theme_stylebox_override("panel", sb_f)
		chip_f.add_child(EstiloUI.etiqueta("Misión de fotos × %d" % (datos.get("blancos", []) as Array).size(), 15, col_f.lightened(0.25), true))
		_caja_chips.add_child(chip_f)
		return
	var cuentas := {}
	for id in DatosMarte.lista_muestras(datos):
		cuentas[id] = int(cuentas.get(id, 0)) + 1
	for id in cuentas:
		var info := DatosMarte.material(id)
		var col: Color = info["color"]
		var chip := PanelContainer.new()
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := EstiloUI.caja(Color(col.r, col.g, col.b, 0.16), 5.0)
		sb.content_margin_left = 10.0
		sb.content_margin_right = 10.0
		sb.content_margin_top = 3.0
		sb.content_margin_bottom = 3.0
		sb.border_color = Color(col.r, col.g, col.b, 0.7)
		sb.set_border_width_all(1)
		chip.add_theme_stylebox_override("panel", sb)
		var l := EstiloUI.etiqueta("%s × %d" % [str(info["nombre"]), int(cuentas[id])], 15, col.lightened(0.25), true)
		chip.add_child(l)
		_caja_chips.add_child(chip)


func _actualizar_ui_menu() -> void:
	_aplicar_progreso()
	var total := sitios.size()
	var hechas := 0
	var estados: Array = []
	var bloqueadas: Array = []
	var anios: Array = []
	var hover_i := -1
	var sig_i := -1
	for i in range(total):
		var s: MissionSite = sitios[i]
		if s.completada:
			hechas += 1
		estados.append(s.completada)
		bloqueadas.append(s.bloqueada)
		anios.append(str(s.datos.get("era", "")))
		if s.siguiente:
			sig_i = i
		if s == _hover:
			hover_i = i
	_lbl_contador.text = "Misiones completadas: %d / %d" % [hechas, total]
	(_linea_tiempo as LineaTiempo).poner(anios, estados, hover_i, bloqueadas, sig_i)

	var sig: MissionSite = sitios[sig_i] if sig_i >= 0 else null
	var ofertas: Array[String] = []
	for s in sitios:
		if (s as MissionSite).siguiente:
			ofertas.append("%s · %s" % [str((s as MissionSite).datos.get("era", "")), (s as MissionSite).nombre])
	if total > 0 and hechas >= total:
		_lbl_titulo.text = "¡Campaña completada: de %s a %s!" % [str(anios[0]), str(anios[anios.size() - 1])]
	elif ofertas.size() > 1 and not Ajustes.misiones_libres:
		_lbl_titulo.text = "Elige tu próximo destino  (%d ofrecidos)" % ofertas.size()
	elif sig != null and not Ajustes.misiones_libres:
		_lbl_titulo.text = "Siguiente misión:  %s  ·  %s" % [str(sig.datos.get("era", "")), sig.nombre]
	else:
		_lbl_titulo.text = "Selecciona un sitio de misión"

	if _hover != null and estado == Estado.MENU:
		_panel_info.visible = true
		var d: Dictionary = _hover.datos
		_lbl_info_era.text = "%s  ·  %s" % [str(d.get("era", "")), str(d.get("nave", ""))]
		_lbl_info_nombre.text = _hover.nombre
		_lbl_info_desc.text = _hover.descripcion
		_lbl_info_real.text = "EN LA VIDA REAL  ·  " + str(d.get("real", ""))
		if _hover != _hover_previo:
			_hover_previo = _hover
			_llenar_chips(d)
		var col_estado: Color = EstiloUI.COL_FRIO
		if _hover.bloqueada:
			col_estado = EstiloUI.COL_ACENTO
			var falta: String = "las misiones que ofrece el comité"
			if not ofertas.is_empty():
				falta = " / ".join(ofertas)
			_lbl_info_estado.text = "BLOQUEADA · " + (_hover.motivo_bloqueo if _hover.motivo_bloqueo != "" else "completa antes: " + falta)
		elif _hover.completada:
			col_estado = EstiloUI.COL_OK
			_lbl_info_estado.text = "Misión completada · click para repetirla"
		elif _hover.siguiente:
			col_estado = EstiloUI.COL_ACENTO
			_lbl_info_estado.text = "El comité te la ofrece · click para enviar al robot"
		else:
			_lbl_info_estado.text = "Click para enviar al robot recolector"
		_lbl_info_estado.add_theme_color_override("font_color", col_estado)
	else:
		_panel_info.visible = false
		_hover_previo = null


class LineaTiempo extends Control:
	const EstiloUI := preload("res://interfaz/estilo_ui.gd")
	var anios: Array = []
	var hechas: Array = []
	var activa: int = -1
	var bloq: Array = []
	var sig: int = -1

	func poner(a: Array, h: Array, i: int, b: Array = [], s: int = -1) -> void:
		if a != anios or h != hechas or i != activa or b != bloq or s != sig:
			anios = a
			hechas = h
			activa = i
			bloq = b
			sig = s
			queue_redraw()

	func _draw() -> void:
		var n := anios.size()
		if n == 0:
			return
		var fuente := EstiloUI.fuente_titulo()
		var y := 22.0
		var x0 := 40.0
		var x1 := size.x - 40.0
		draw_line(Vector2(x0, y), Vector2(x1, y), Color(1.0, 1.0, 1.0, 0.22), 2.0)
		for i in range(n):
			var x := lerpf(x0, x1, float(i) / float(maxi(n - 1, 1)))
			var bloqueada: bool = i < bloq.size() and bool(bloq[i])
			var col := EstiloUI.COL_OK if hechas[i] else (Color(0.5, 0.5, 0.56) if bloqueada else EstiloUI.COL_ACENTO)
			var r := 5.0
			if i == sig:
				draw_arc(Vector2(x, y), 11.0, 0.0, TAU, 28, Color(col.r, col.g, col.b, 0.9), 2.0)
			if i == activa:
				r = 8.0
				draw_circle(Vector2(x, y), 13.0, Color(col.r, col.g, col.b, 0.22))
			draw_circle(Vector2(x, y), r, col)


			var cabe: bool = (x1 - x0) / float(maxi(n - 1, 1)) >= 56.0
			if cabe or i % 2 == 0 or i == activa or i == sig:
				draw_string(fuente, Vector2(x - 26.0, y + 28.0), str(anios[i]), HORIZONTAL_ALIGNMENT_CENTER, 52.0, 14,
						Color(1, 1, 1, 0.95 if (i == activa or i == sig) else (0.35 if bloqueada else 0.6)))
