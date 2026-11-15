extends Node3D


signal mision_completada(id: String, tiempo: float)
signal salir_solicitado

const Ajustes := preload("res://nucleo/ajustes.gd")
const AvisoGuardado := preload("res://nucleo/aviso_guardado.gd")
const AyudaContextual := preload("res://nucleo/ayuda_contextual.gd")
const ModoFoto := preload("res://mision/modo_foto.gd")
const PausaMision := preload("res://interfaz/pausa_mision.gd")
const ConsultaRadio := preload("res://mision/consulta_radio.gd")
const Recuerdos := preload("res://progreso/recuerdos.gd")
const RecuerdosModelo := preload("res://modelos/recuerdos_modelo.gd")
const ClimaPantalla := preload("res://mision/clima_pantalla.gd")
const DronVoz := preload("res://dron/dron_voz.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const RelatosMarte := preload("res://datos/relatos_marte.gd")
const Historia := preload("res://historia/historia.gd")
const Comite := preload("res://historia/comite.gd")
const Logros := preload("res://progreso/logros.gd")
const Muestras := preload("res://mision/muestras.gd")
const Rutas := preload("res://progreso/rutas.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Realismo := preload("res://nucleo/realismo.gd")
const HudMision := preload("res://interfaz/hud_mision.gd")
const AudioMision := preload("res://sonido/audio_mision.gd")
const CicloDia := preload("res://mision/ciclo_dia.gd")
const EventosAzar := preload("res://mision/eventos_azar.gd")
const TarjetaResultados := preload("res://interfaz/tarjeta_resultados.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const HistoriaExtra := preload("res://historia/historia_extra.gd")
const PantallaDiario := preload("res://interfaz/pantalla_diario.gd")
const Epilogo := preload("res://cinematicas/epilogo.gd")
const RadioPanel := preload("res://mision/radio_panel.gd")
const EscanerFx := preload("res://mision/escaner_fx.gd")
const CieloNocturno := preload("res://mision/cielo_nocturno.gd")
const EclipseFobos := preload("res://mision/eclipse_fobos.gd")
const AmbienteMision := preload("res://mision/ambiente_mision.gd")
const SueloMision := preload("res://mision/suelo_mision.gd")
const CuevaMision := preload("res://mision/cueva_mision.gd")
const FotoMision := preload("res://mision/foto_mision.gd")
const BaseSalida := preload("res://mision/base_salida.gd")
const Mejoras := preload("res://progreso/mejoras.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")
const Bitacora := preload("res://progreso/bitacora.gd")
const CartaFocos := preload("res://interfaz/carta_focos.gd")
const Dron := preload("res://dron/dron.gd")
const Laboratorio := preload("res://interfaz/laboratorio.gd")
const Expedicion := preload("res://progreso/expedicion.gd")
const Hallazgos := preload("res://progreso/hallazgos.gd")
const MusicaDinamica := preload("res://sonido/musica_dinamica.gd")
const CineHistoria := preload("res://cinematicas/cine_historia.gd")
const EcoHistoria := preload("res://historia/eco_historia.gd")
const FotoArchivo := preload("res://mision/foto_archivo.gd")


var planet: Planet
var datos: Dictionary = {}
var amb: Dictionary = {}
var env: Environment = null
var id_mision: String = ""
var nombre: String = "Misión"
var descripcion: String = ""
var total_objetos: int = 4
var capacidad: int = 3
var semilla: int = 1
var rumbo_deg: float = 0.0
var dist_base: float = 300.0
var lista: Array[String] = []
var site_up: Vector3 = Vector3.UP
var k: float = 0.1
var calidad: int = 2


var cam_pos: Vector3 = Vector3.ZERO
var cam_basis: Basis = Basis.IDENTITY
var sol_dir: Vector3 = Vector3.UP
var activo: bool = false


const RADIO_BASE := 15.5
const VEL := 6.0
const VEL_ATRAS := 3.5
const TURBO := 2.2
const ACEL := 24.0
const VEL_GIRO := 1.9
const RADIO_RECOGIDA := 3.4
const RADIO_DATO := 4.0
const COLOR_DATO := Color(0.35, 0.85, 1.0)
const TIEMPO_ENTREGA := 0.4
const PENDIENTE_MAX := 1.2
const PENDIENTE_MUESTRA := 30.0
const ALCANCE_ESCANER := 70.0
const RECARGA_ESCANER := 7.0
const DURACION_SENAL := 8.0
const DURACION_PULSO := 1.7
const NUM_ROCAS := 100


const ENERGIA_POR_GM := 0.06
const COSTE_TURBO := 2.4
const COSTE_PENDIENTE := 1.6
const COSTE_ESCANER := 2.0
const RECARGA_QUIETO := 0.7
const RECARGA_BASE := 5.0
const RECARGA_HANGAR := 3.0
const ENERGIA_ARRANQUE := 8.0
const ENERGIA_BAJA := 18.0

const COLOR_A := Color(0.2, 0.8, 1.0)
const COLOR_B := Color(0.3, 1.0, 0.4)
const COLOR_CUEVA := Color(1.0, 0.62, 0.25)
const COLOR_FOTO := Color(0.78, 0.55, 1.0)
const FOV_VISOR := 50.0
const FOV_MIN := 5.0
const ALTURA_MASTIL := 1.9


var _rng := RandomNumberGenerator.new()

var _f0: Vector3 = Vector3.FORWARD
var _perp: Vector3 = Vector3.RIGHT

var _up: Vector3 = Vector3.UP
var _fwd: Vector3 = Vector3.FORWARD
var _h: float = 0.0
var _pos_robot: Vector3 = Vector3.ZERO
var _vel: float = 0.0
var _vel_prev: float = 0.0
var _rover_pivote: Node3D = null
var _radar_rot: Node3D = null
var _luces_taller: Array[Node3D] = []
var _ruedas: Array[Node3D] = []
var _cabeza_mastil: Node3D = null
var _antena_dish: Node3D = null
var _t_anim: float = 0.0
var _t_polvo: float = 0.0
var _pitch_r: float = 0.0
var _roll_r: float = 0.0
var _yaw_mastil: float = 0.0
var _normal: Vector3 = Vector3.UP


var _ruta: Array[Vector2] = []
var _ruta_eventos: Array = []
var _ruta_ult: Vector2 = Vector2(1.0e9, 1.0e9)
var _ruta_dist: float = 0.0


var _riesgos: bool = false

var control_auto: Vector2 = Vector2.ZERO

var _modo_captura: bool = false
var _cap_yaw: float = 0.0
var _cap_pitch: float = 33.0
var _cap_zoom: float = 1.0
var _pausa: CanvasLayer = null
var _consulta: CanvasLayer = null
var _cons_pend: Array = []
var _cons_cd: Dictionary = {}
var _balizas: Array = []
var _cons_acum: float = 0.0
var _cons_consejo: bool = false
var _consultas_n: int = 0
var _dron_cd: float = 0.0
var _dron_idle: float = 70.0
var _dron_storm_prev: int = 0
var _dron_hall: Array = []
var _dron_n: float = 0.0
var _cap_capa: CanvasLayer
var _cap_filtro: CanvasLayer
var _cap_ayuda: Label
var _cap_msg: Label
var _cap_flash: ColorRect
var _tormenta_cond: bool = false
var _energia: float = 100.0
var _sin_energia: bool = false
var _tormenta_estado: int = 0
var _tormenta_t: float = 0.0
var _tormenta_prox: float = 150.0
var _tormenta_f: float = 0.0
var _aviso_bateria: int = 0


var _dilema_hecho: bool = false
var _dilema_activo: bool = false
var _dilema_t: float = 0.0
var _dilema: Dictionary = {}
var _dilema_resp: String = ""
var _energia_min: float = 100.0


var _dif: int = 1
var _tarjeta_datos: Dictionary = {}
var _guardando_tarjeta: bool = false


var _ventajas: Dictionary = {}
var _mej: Dictionary = {"consumo": 1.0, "recarga": 1.0, "vel": 1.0, "pendiente": 1.0, "capacidad": 0, "recogida": 1.0,
		"alcance": 1.0, "escaner_cd": 1.0, "datos_mision": 0}
var _mult_consumo: float = 1.0
var _alcance_esc: float = ALCANCE_ESCANER
var _consec_txt: Array[String] = []
var _elec: Dictionary = {}
var _radio_cola: Array = []
var _radio_msg: Dictionary = {}
var _radio_panel: Node = null
var _radio_quieto: float = 0.0
var _radio_mov: float = 0.0
var _hist_cd: float = 25.0
var _charla_hecha: bool = false
var _sec_ofrecida: bool = false
var _sec: Dictionary = {}
var _hist_lineas: Array[String] = []
var _diario: Node = null
var _final_hist: String = ""
var _radio_cd: float = 0.0
var _radio_n: int = 0
var _quieto_t: float = 0.0
var _radio_cueva: bool = false
var _radio_mitad: bool = false
var _tut_activo: bool = false
var _pista_t: float = 0.0
var _pista_n: int = 0
var _pista_huella: Vector3 = Vector3(-999.0, 0.0, 0.0)
var _tut_paso: int = 0
var _tut_escaneo: bool = false
var _tut_fin_t: float = 0.0


var _env_previo: Dictionary = {}
var _sombra_robot: MeshInstance3D = null

var _cam_fwd: Vector3 = Vector3.FORWARD
var _cam_pos_s: Vector3 = Vector3.ZERO
var _cam_h_terreno: float = 0.0
var _zoom: float = 1.0
var _cine: RefCounted = null
var _eco: Node3D = null
var _rel_br: Dictionary = {}
var _intro_k: float = 1.0
var _n_frame: int = 0

var _up_a: Vector3
var _up_b: Vector3
var _up_h: Vector3
var _hangar: Node3D = null
var _dron: Node3D = null
var _guia_dir_ult: Vector3 = Vector3.ZERO
var _focos_guia_t: float = 0.0
var _focos_bat_dicho: bool = false
var _focos_ask_cd: float = 0.0
var _focos_holo_consejo: bool = false
var _focos_n: int = 0
var _salida: int = 0
var _salida_t: float = 0.0

var _robot: Node3D
var _carga: Node3D
var _flecha: Node3D
var _mat_flecha: StandardMaterial3D
var _luz: DirectionalLight3D
var _mat_baliza_b: StandardMaterial3D
var _raiz_base: Node3D
var _faro: SpotLight3D

var _objetos: Array[Node3D] = []
var _items_carga: Array[Node3D] = []
var _rocas_dir: Array[Vector3] = []
var _rocas_r: Array[float] = []
var _cuevas: Array[Node3D] = []

var _bodega: Array[String] = []
var _entregados_por: Dictionary = {}
var _datos_mostrados: Dictionary = {}
var _curiosidades: Array[Node3D] = []
var _curiosidades_leidas: int = 0
var _dato_actual: Node3D = null
var _en_briefing: bool = false




var _modo_fotos: bool = false
var _foto: Node3D = null
var _visor: bool = false
var _vis_yaw: float = 0.0
var _vis_pitch: float = 0.0
var _vis_fov: float = FOV_VISOR
var _fov_previo: float = 75.0
var _mem_max: int = 14
var _mem_usada: int = 0
var _mem_flags: Array[bool] = []
var _disparando: bool = false
var _timer_tx: float = 0.0
var _enfoque: bool = false
var _entregados: int = 0
var _tiempo: float = 0.0
var _musica: Node = null
var _exp: bool = false
var _exp_puntos: int = 0
var _hallazgos: Array[Node3D] = []
var _datos_hallazgos: int = 0
var _consejo_cueva: bool = false
var _hallazgos_mision: int = 0
var _datos_extra: int = 0
var _terminada: bool = false
var _timer_entrega: float = 0.0
var _dentro: float = 0.0
var _arranque_hecho: bool = false
var _luz_energia_base: float = 1.7
var _luz_color_dia: Color = Color(1.0, 0.93, 0.84)


var dia_f: float = 1.0
var _ciclo: CicloDia
var _h0_sol: Vector3 = Vector3.FORWARD
var _luna: Vector3 = Vector3.UP
var _es_noche: bool = false


var _eventos: EventosAzar
var _escaner_roto: float = 0.0
var _reinicio_t: float = 0.0
var _capa_noche: CanvasLayer
var _velo_noche: ColorRect

const ECLIPSE_S := 32.0
var _ecl_nodo: Node3D = null
var _ecl_estado: int = 0
var _ecl_inicio: float = 1.0e9
var _ecl_p: float = 0.0
var _ecl_f: float = 0.0
var _ecl_quieto: float = 0.0
var _ecl_visto: bool = false

var _c_tormenta: bool = false
var _sol_real: Vector3 = Vector3.UP


var _escaner_cd: float = 0.0
var _senal_t: float = 0.0
var _pulso_t: float = -1.0
var _senal_lista: Array[Node3D] = []
var _guia_conocidas: Array[Node3D] = []
var _senal_texto: String = ""
var _cuevas_detectadas: Array[Node3D] = []


var _hud: CanvasLayer
var _audio: Node
var _fx: Node3D
var _ambiente: Node3D
var _clima: CanvasLayer
var _rn_suelo: FastNoiseLite = null
var _suelo_pes: Vector3 = Vector3(1.0, 0.0, 0.0)
var _suelo_t: float = 0.0
var _suelo: Node3D


func configurar(p: Planet, d: Dictionary, escala: float, entorno: Environment = null) -> void:
	planet = p
	k = escala
	env = entorno
	datos = d
	amb = d.get("amb", {})
	id_mision = d.get("id", "")
	nombre = d.get("nombre", "Misión")
	descripcion = d.get("descripcion", "")
	capacidad = clampi(int(d.get("capacidad", 3)), 1, 6)
	semilla = int(d.get("semilla", 1))
	rumbo_deg = float(d.get("rumbo", 0.0))
	dist_base = float(d.get("dist", 300.0))
	lista = DatosMarte.lista_muestras(d)
	total_objetos = lista.size()
	_modo_fotos = str(d.get("tipo", "")) == "fotos"
	_exp = Expedicion.es_expedicion(d)
	_tut_activo = not Ajustes.tutorial_hecho and not _modo_fotos and not _exp
	_mem_max = int(d.get("disparos", 14))
	site_up = _dir_lat_lon(float(d["lat"]), float(d["lon"]))


func _ready() -> void:
	_rng.seed = semilla
	_riesgos = Ajustes.riesgos and bool(datos.get("riesgos", true))
	_dif = clampi(Ajustes.dificultad, 0, 2)
	_aplicar_historia()
	_tormenta_prox = (150.0 + float(semilla % 90)) * [1.6, 1.0, 0.7][_dif]
	calidad = Ajustes.calidad_ambiente

	var ang := deg_to_rad(rumbo_deg)
	var t1 := _t1(site_up)
	var t2 := site_up.cross(t1)
	_f0 = (t1 * cos(ang) + t2 * sin(ang)).normalized()
	_perp = site_up.cross(_f0).normalized()

	_up_a = site_up
	_up_b = _mover(site_up, _f0, dist_base * k)
	_up = _crear_base_salida()
	_fwd = (_f0 - _up * _f0.dot(_up)).normalized()
	_cam_fwd = _fwd
	_h = _altura(_up)
	_normal = _up


	var el := deg_to_rad(float(amb.get("sol_elev", 55.0)))
	sol_dir = (site_up * sin(el) + _f0.rotated(site_up, deg_to_rad(150.0)) * cos(el)).normalized()
	_sol_real = sol_dir
	_h0_sol = _f0.rotated(site_up, deg_to_rad(150.0))
	_ciclo = CicloDia.new(float(amb.get("sol_elev", 55.0)), _dif, str(datos.get("condicion", "")))
	_aplicar_condicion()

	if Ajustes.graficos_reales and env != null:
		_env_previo = Realismo.gradar_entorno(env)
	_crear_luz()
	_crear_capa_noche()
	var cielo_n := CieloNocturno.new()
	add_child(cielo_n)
	cielo_n.configurar(self)
	_ecl_nodo = EclipseFobos.new()
	add_child(_ecl_nodo)
	_ecl_nodo.configurar(self)
	var rec := RandomNumberGenerator.new()
	rec.seed = semilla * 13 + 7
	var cond := str(datos.get("condicion", ""))
	if rec.randf() < 0.8 and cond != "noche" and cond != "tormenta":
		_ecl_inicio = rec.randf_range(70.0, 220.0)
	_crear_modulo_aterrizaje()
	_crear_base()
	_crear_cuevas()
	_crear_rocas()
	_crear_horizonte()
	_crear_muestras()
	if _modo_fotos:
		_crear_blancos_foto()
	_crear_curiosidades()
	_crear_hallazgos()
	_crear_robot()
	_crear_eco()
	_estimar_normal(1.0)
	_colocar_robot()
	_crear_modulos()
	_cam_h_terreno = _altura(_pos_robot.normalized())
	_actualizar_camara(0.0, true)


func _exit_tree() -> void:
	Realismo.restaurar_entorno(env, _env_previo)


func _sol_en(n: Node3D) -> Vector3:
	return n.transform.basis.orthonormalized().inverse() * _sol_real


func _crear_modulos() -> void:
	_crear_faro()
	_hud = HudMision.new()
	add_child(_hud)
	_clima = ClimaPantalla.new()
	add_child(_clima)
	_clima.configurar(datos)
	_hud.configurar(datos, lista, capacidad)
	if _modo_fotos:
		var nombres: Array[String] = []
		for b in _foto.blancos:
			nombres.append(str(b["nombre"]))
		_hud.modo_fotos(nombres, _mem_max)
	_hud.volver_pulsado.connect(_pedir_salida)
	_hud.tarjeta_pulsada.connect(_guardar_tarjeta)
	_hud.final_pulsado.connect(_ver_final)
	_hud.laboratorio_pulsado.connect(_abrir_laboratorio)
	_hud.cuaderno_pulsado.connect(_abrir_cuaderno)
	_hud.briefing_cerrado.connect(_cerrar_briefing)
	_hud.briefing_texto.connect(_briefing_habla)
	_hud.visible = false
	_hud.actualizar_curiosidades(0, _curiosidades.size())
	_refrescar_hud()

	_audio = AudioMision.new()
	add_child(_audio)
	_musica = MusicaDinamica.new()
	_musica.configurar(datos)
	add_child(_musica)

	var fx := EscanerFx.new()
	fx.k = k
	fx.radio_planeta = planet.radius
	_fx = fx
	add_child(_fx)

	var amb_n := AmbienteMision.new()
	amb_n.configurar(self, env, k, amb, calidad, semilla)
	_ambiente = amb_n
	add_child(_ambiente)

	_eventos = EventosAzar.new()
	_eventos.configurar(self, k, semilla, _dif)
	_eventos.aviso.connect(_ev_aviso)
	_eventos.golpe.connect(_ev_golpe)
	_eventos.bonus.connect(_ev_bonus)
	_eventos.datos.connect(_ev_datos)
	_eventos.sensor_averiado.connect(_ev_sensor)
	_eventos.sonido.connect(func(nombre: String, dist: float): _audio.boom(dist))
	_eventos.hito.connect(func(): _hito_ruta("suceso"))
	add_child(_eventos)


	_dron = Dron.new()
	add_child(_dron)
	_dron.configurar(self)
	_dron.vision = 0.6 * _alcance_esc
	_dron.marcados_nuevos.connect(func(n: int):
		if not _dron_marca(n):
			_hud.toast(DronVoz.NOMBRE, "+%d marcado%s en el radar" % [n, "s" if n > 1 else ""], DronVoz.COLOR, 3.0))
	_dron.estado_cambiado.connect(_on_dron_estado)

	var suelo_n := SueloMision.new()
	suelo_n.configurar(self, k, calidad, semilla)
	suelo_n.sombras = Ajustes.graficos_reales
	suelo_n.sol_dir = _sol_real
	_suelo = suelo_n
	add_child(_suelo)


func planeta_radio() -> float:
	return planet.radius


func altura_en(dir: Vector3) -> float:
	return _altura(dir)


func punto_suelo(dir: Vector3) -> Vector3:
	return _pos(dir)


func base_en(dir: Vector3) -> Basis:
	return _base_up(dir)


func pos_robot_local() -> Vector3:
	return _pos_robot


func fwd_robot() -> Vector3:
	return _fwd


func eje_f0() -> Vector3:
	return _f0


func eje_perp() -> Vector3:
	return _perp


func dir_a() -> Vector3:
	return _up_a


func dir_b() -> Vector3:
	return _up_b


func dir_uv(u: float, v: float) -> Vector3:
	return _desplazar(site_up, _f0, _perp, u * k, v * k)


func distancia_entre(a: Vector3, b: Vector3) -> float:
	return _arco(a, b) / k


func distancia_gm(a: Vector3, b: Vector3) -> float:
	return _arco(a, b) / k


func dir_lejana(dist_gm: float, ang: float) -> Vector3:
	var t := _t1(_up).rotated(_up, ang)
	return _mover(_up, t, dist_gm * k)


func tangente_en(dir: Vector3, rumbo: float) -> Vector3:
	return _t1(dir).rotated(dir, rumbo)


func mover_dir(dir: Vector3, tang: Vector3, dist: float) -> Vector3:
	return _mover(dir, tang, dist)


func registrar_obstaculo(dir: Vector3, radio_km: float) -> void:
	_rocas_dir.append(dir)
	_rocas_r.append(radio_km)


func normal_aprox(dir: Vector3) -> Vector3:
	var a1 := _t1(dir)
	var a2 := dir.cross(a1)
	var e := 0.8 * k
	var h0 := _altura(dir)
	var d1 := _altura(_mover(dir, a1, e)) - h0
	var d2 := _altura(_mover(dir, a2, e)) - h0
	return (dir - a1 * (d1 / e) - a2 * (d2 / e)).normalized()


func _dir_lat_lon(lat_deg: float, lon_deg: float) -> Vector3:
	var lat := deg_to_rad(lat_deg)
	var lon := deg_to_rad(lon_deg)
	return Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon)).normalized()


func _t1(up: Vector3) -> Vector3:
	var ref := Vector3.UP if absf(up.y) < 0.999 else Vector3.RIGHT
	return up.cross(ref).normalized()


func _base_up(up: Vector3) -> Basis:
	var t1 := _t1(up)
	return Basis(t1, up, t1.cross(up))


func _altura(dir: Vector3) -> float:
	return planet.terrain_noise.compute_noise(dir) * planet.terrain_height


func _pos(dir: Vector3) -> Vector3:
	return dir * (planet.radius + _altura(dir))


func _mover(up: Vector3, fwd: Vector3, dist: float) -> Vector3:
	var th := dist / planet.radius
	return (up * cos(th) + fwd * sin(th)).normalized()


func _desplazar(dir: Vector3, f: Vector3, p: Vector3, u: float, v: float) -> Vector3:
	return (dir + (f * u + p * v) / planet.radius).normalized()


func _offset_dir(up: Vector3, ox: float, oz: float) -> Vector3:
	var t1 := _t1(up)
	var t2 := up.cross(t1)
	return (up + (t1 * ox + t2 * oz) / planet.radius).normalized()


func _arco(a: Vector3, b: Vector3) -> float:
	return (a - b).length() * planet.radius


func _altura_max(dir: Vector3, radio_gm: float) -> float:
	var h := _altura(dir)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		h = maxf(h, _altura(_offset_dir(dir, cos(a) * radio_gm * k, sin(a) * radio_gm * k)))
	return h


func _evaluar(dir: Vector3) -> Vector2:
	var e0 := planet.terrain_noise.compute_noise(dir)
	var h0 := e0 * planet.terrain_height
	var t1 := _t1(dir)
	var t2 := dir.cross(t1)
	var d := 0.6 * k
	var d1 := (dir + t1 * d / planet.radius).normalized()
	var d2 := (dir + t2 * d / planet.radius).normalized()
	var s1 := absf(planet.terrain_noise.compute_noise(d1) * planet.terrain_height - h0) / d
	var s2 := absf(planet.terrain_noise.compute_noise(d2) * planet.terrain_height - h0) / d
	return Vector2(e0, rad_to_deg(atan(maxf(s1, s2))))


func _mat(color: Color, emisivo: bool = false, energia: float = 1.5) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.75
	if emisivo:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = energia
	return m


func _mat_pbr(color: Color, metal: float, rough: float, emision: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metal
	m.roughness = rough
	if emision > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emision
	return m


func _caja(padre: Node3D, tam: Vector3, pos: Vector3, mat: Material, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = tam
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	padre.add_child(mi)
	return mi


func _cil(padre: Node3D, r_sup: float, r_inf: float, alto: float, pos: Vector3,
		mat: Material, rot_deg: Vector3 = Vector3.ZERO, segs: int = 20) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r_sup
	cm.bottom_radius = r_inf
	cm.height = alto
	cm.radial_segments = segs
	cm.rings = 1
	mi.mesh = cm
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	padre.add_child(mi)
	return mi


func _esfera(padre: Node3D, radio: float, pos: Vector3, mat: Material, segs: int = 14) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radio
	sm.height = radio * 2.0
	sm.radial_segments = segs
	sm.rings = maxi(segs / 2, 4)
	mi.mesh = sm
	mi.material_override = mat
	mi.position = pos
	padre.add_child(mi)
	return mi


func _crear_luz() -> void:
	_luz = DirectionalLight3D.new()
	_luz_energia_base = 1.7
	_luz.light_energy = _luz_energia_base

	_luz_color_dia = Color(1.0, 0.93, 0.84).lerp(Color(1.0, 0.78, 0.6), clampf(float(amb.get("polvo", 0.5)), 0.0, 1.0))
	_luz.light_color = _luz_color_dia
	_luz.shadow_enabled = false
	add_child(_luz)
	poner_sol(sol_dir)


func _crear_capa_noche() -> void:
	_capa_noche = CanvasLayer.new()
	_capa_noche.layer = 1
	_velo_noche = ColorRect.new()
	_velo_noche.set_anchors_preset(Control.PRESET_FULL_RECT)
	_velo_noche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_velo_noche.color = Color.WHITE
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_velo_noche.material = m
	_capa_noche.add_child(_velo_noche)
	_capa_noche.visible = false
	add_child(_capa_noche)


func _actualizar_dia(delta: float) -> void:
	if _ciclo == null:
		return
	var vivo := activo and not _terminada and not _en_briefing and not _tut_activo
	if Ajustes.ciclo_dia and vivo:
		_ciclo.avanzar(delta)
	dia_f = _ciclo.luz() if Ajustes.ciclo_dia else 1.0
	if Ajustes.ciclo_dia:
		_sol_real = _ciclo.dir_sol(site_up, _h0_sol)
		_luna = _ciclo.dir_luna(site_up, _h0_sol)
		if _suelo != null:
			_suelo.sol_dir = _sol_real.lerp(_luna, 1.0 - dia_f).normalized()
	if _ambiente != null:
		_ambiente.luz_f = dia_f * (1.0 - 0.3 * _ecl_f)

	if _luz != null:
		var s := sin(_ciclo.elevacion())
		var calido := 1.0 - smoothstep(0.02, 0.45, s)
		_luz.light_color = _luz_color_dia.lerp(Color(1.0, 0.55, 0.35), calido * 0.8).lerp(Color(0.55, 0.68, 1.0), 1.0 - dia_f)
	_actualizar_eclipse(delta, vivo)
	var noche := 1.0 - dia_f
	if _velo_noche != null:
		_velo_noche.color = Color.WHITE.lerp(Color(0.72, 0.83, 1.0), noche).lerp(Color(0.78, 0.68, 0.95), _ecl_f * 0.5)
		_capa_noche.visible = activo and (noche > 0.02 or _ecl_f > 0.02)
	if not vivo:
		return
	if not _es_noche and dia_f < 0.4:
		_es_noche = true
		_hud.toast("Anochece", "Sin Sol los paneles no cargan. Los faros se encienden: ve despacio y vigila la batería.",
				Color(0.55, 0.7, 1.0), 6.0)
		_audio.aviso()
		_radio("anochecer", true)
	elif _es_noche and dia_f > 0.65:
		_es_noche = false
		_hud.toast("Amanece", "Sale el Sol: los paneles vuelven a cargar.", Color(1.0, 0.8, 0.45), 5.0)
		_audio.paso()
		_radio("amanecer", true)


func _actualizar_eclipse(delta: float, vivo: bool) -> void:
	if _ecl_nodo == null or _ecl_estado == 2:
		return
	if _ecl_estado == 0:
		if vivo and Ajustes.ciclo_dia and Ajustes.eventos and _tiempo >= _ecl_inicio and dia_f > 0.95 \
				and _ciclo.elevacion() > 0.45 and _dentro < 0.3 and _tormenta_estado == 0:
			_ecl_estado = 1
			_ecl_p = 0.0
			_ecl_quieto = 0.0
			_hud.toast(Idioma.t("Tránsito de Fobos"), Idioma.t("La luna Fobos va a cruzar por delante del Sol. Párate a mirarla: los paneles rendirán menos unos segundos."),
					Color(0.75, 0.55, 1.0), 7.0)
			_audio.aviso()
			_radio("eclipse", true)
			focos_comenta("eclipse")
		return
	if vivo:
		_ecl_p += delta / ECLIPSE_S
	_ecl_f = _ecl_nodo.mover(clampf(_ecl_p, 0.0, 1.0), _sol_real, site_up)
	if vivo and _ecl_f > 0.75 and absf(_vel) / k < 0.3 and _dentro < 0.3:
		_ecl_quieto += delta
		if _ecl_quieto >= 5.0 and not _ecl_visto:
			_ecl_visto = true
			_datos_extra += 1
			_hito_ruta("dato")
			_audio.bueno()
			_hud.toast(Idioma.t("Lo viste entero"), Idioma.t("Fobos tapa el Sol y el halo late como un pulso. Lo anotas: +1 dato de ciencia."),
					Color(0.75, 0.55, 1.0), 6.0)
	if _ecl_p >= 1.0:
		_ecl_estado = 2
		_ecl_f = 0.0
		_ecl_nodo.apagar()


func poner_sol(dir: Vector3) -> void:
	if _luz == null:
		return

	dir = dir.lerp(_sol_real, clampf(_dentro, 0.0, 1.0)).normalized()
	if dia_f < 0.999:
		dir = dir.lerp(_luna, 1.0 - dia_f).normalized()
	var up_ref := Vector3.UP if absf(dir.y) < 0.99 else Vector3.RIGHT
	_luz.global_transform = Transform3D(Basis.looking_at(-dir, up_ref), _luz.global_transform.origin)


func _etiqueta(texto: String, color: Color, pos: Vector3) -> Label3D:
	var l := Label3D.new()
	l.text = texto
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.fixed_size = true
	l.pixel_size = 0.0011
	l.font_size = 40
	l.outline_size = 10
	l.modulate = color
	l.no_depth_test = true
	l.position = pos
	return l


func _columna_luz(raiz: Node3D, color: Color, alto: float) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, 0.28)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var c := _cil(raiz, 0.35, 0.35, alto, Vector3(0.0, alto * 0.5, 0.0), m)
	c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _anclar_en(dir: Vector3) -> Node3D:
	var n := Node3D.new()
	n.transform = Transform3D(_base_up(dir) * Basis.from_scale(Vector3.ONE * k), _pos(dir))
	add_child(n)
	return n


func _rango_altura(d: Vector3) -> float:
	var lo := 1.0e9
	var hi := -1.0e9
	for z in [-6.0, 0.0, 6.0, 13.0]:
		for x in [-5.0, 0.0, 5.0]:
			var h := _altura(_desplazar(d, _f0, _perp, z * k, x * k))
			lo = minf(lo, h)
			hi = maxf(hi, h)
	return hi - lo


func _crear_base_salida() -> Vector3:
	var mejor := _desplazar(_up_a, _f0, _perp, 3.0 * k, 16.0 * k)
	var mejor_r := 1.0e9
	for u in [-6.0, 0.0, 6.0, 12.0]:
		for v in [-14.0, 14.0, -19.0, 19.0, -25.0, 25.0]:
			var d := _desplazar(_up_a, _f0, _perp, u * k, v * k)
			var r := _rango_altura(d) + 0.002 * absf(v)
			if r < mejor_r:
				mejor_r = r
				mejor = d
	_up_h = mejor
	var f := (_f0 - _up_h * _f0.dot(_up_h)).normalized()
	var h_suelo := -1.0e9
	for zz in [-5.0, -2.0, 2.0, 5.0]:
		for xx in [-4.0, 0.0, 4.0]:
			h_suelo = maxf(h_suelo, _altura(_desplazar(_up_h, f, _perp, zz * k, xx * k)))
	var h_fin := _altura(_mover(_up_h, f, (BaseSalida.LARGO * 0.5 + BaseSalida.PUERTA_ALTO) * k))
	_hangar = BaseSalida.new()
	add_child(_hangar)
	_hangar.configurar(_up_h, f, h_suelo, h_fin, planet.radius, k, BaseSalida.estilo_de(datos), str(datos.get("nave", "")))
	_hangar.puerta_abierta.connect(_on_puerta_abierta)
	for c: Array in _hangar.colisiones():
		_rocas_dir.append(c[0])
		_rocas_r.append(float(c[1]) * k)
	return _hangar.punto_arranque()


func _salida_iniciar() -> void:
	if _hangar == null:
		return
	_salida = 1
	_salida_t = 0.0
	_hangar.iniciar_salida()
	_audio.aviso()
	_hud.toast("Salida de la base", "La puerta del hangar se abre. El robot saldrá solo.", COLOR_DATO, 3.5)


func _on_puerta_abierta() -> void:
	if _salida == 1:
		_salida = 2
		_salida_t = 0.0
		_audio.paso()


func _actualizar_salida(delta: float) -> void:
	if _salida == 0 or _hangar == null:
		return
	_salida_t += delta
	var fuera: bool = _hangar.z_de(_pos_robot) > BaseSalida.Z_SALIDA
	if _salida == 2 and (fuera or _salida_t > 12.0):
		_salida = 0
		_vel = 0.0
		_hud.toast("Fuera de la base", "Tienes el control. Puedes volver al hangar para recargar la batería.", COLOR_DATO, 4.5)
		_audio.bueno()
	elif _salida == 1 and _salida_t > 8.0:
		_on_puerta_abierta()


func _crear_modulo_aterrizaje() -> void:
	var raiz := Node3D.new()
	raiz.transform = Transform3D(_base_up(_up_a) * Basis.from_scale(Vector3.ONE * k),
			_up_a * (planet.radius + _altura_max(_up_a, 3.5)))
	add_child(raiz)
	_acc_ini()
	var gris := _mat_sucio(Color(0.42, 0.42, 0.46), 0.2, 0.8, 0.25)
	var gris_c := _mat_pbr(Color(0.5, 0.51, 0.55), 0.3, 0.45)
	var tubo := _mat_sucio(Color(0.82, 0.82, 0.86), 0.3, 0.42, 0.3)
	var dorado := _mat_sucio(Color(0.98, 0.78, 0.36), 0.3, 0.4, 0.4)
	var blanco := _mat_pbr(Color(0.9, 0.9, 0.92), 0.0, 0.55)
	var negro := _mat_pbr(Color(0.08, 0.08, 0.09), 0.1, 0.7)
	var vidrio := _mat_pbr(Color(0.03, 0.05, 0.09), 0.3, 0.08, 0.05)
	var m_panel := _mat_pbr(Color(0.08, 0.14, 0.34), 0.4, 0.3, 0.12)
	var plata := _mat_pbr(Color(0.7, 0.72, 0.78), 0.3, 0.4)


	_a_cil(3.8, 3.8, 8.0, Vector3(0.0, -3.6, 0.0), gris, Vector3.ZERO, 32)
	_a_cil(3.3, 3.3, 0.05, Vector3(0.0, 0.42, 0.0), _mat_pbr(Color(0.24, 0.23, 0.24), 0.1, 0.8), Vector3.ZERO, 32)


	for i in range(4):
		var a := TAU * float(i) / 4.0 + PI * 0.25
		var d := Vector3(cos(a), 0.0, sin(a))
		var sup := d * 1.5 + Vector3(0.0, 4.0, 0.0)
		var pie := d * 3.0 + Vector3(0.0, 0.62, 0.0)
		var tir_a := d * 1.1 + Vector3(0.0, 3.0, 0.0)
		var tir_b := sup.lerp(pie, 0.62)
		_a_tubo(sup, pie, 0.14, tubo, 10)
		_a_tubo(tir_a, tir_b, 0.09, tubo, 8)
		_a_esf(0.2, sup, gris_c, 10)
		_a_esf(0.14, tir_b, gris_c, 8)
		_a_cil(0.3, 0.7, 0.28, d * 3.0 + Vector3(0.0, 0.56, 0.0), gris, Vector3.ZERO, 16)
		_a_cil(0.7, 0.7, 0.06, d * 3.0 + Vector3(0.0, 0.45, 0.0), negro, Vector3.ZERO, 16)


	_a_cil(1.85, 1.85, 2.2, Vector3(0.0, 4.3, 0.0), dorado, Vector3.ZERO, 12)
	_a_cil(1.9, 1.9, 0.22, Vector3(0.0, 3.3, 0.0), gris_c, Vector3.ZERO, 12)
	_a_cil(1.9, 1.9, 0.22, Vector3(0.0, 5.35, 0.0), gris_c, Vector3.ZERO, 12)

	for i in range(4):
		var a2 := TAU * float(i) / 4.0
		var d2 := Vector3(cos(a2), 0.0, sin(a2))
		var rot_y := rad_to_deg(PI * 0.5 - a2)
		if i == 3:
			_a_chaf(Vector3(2.1, 0.8, 0.3), d2 * 1.98 + Vector3(0.0, 4.25, 0.0), blanco, 0.05, Vector3(0, rot_y, 0))
			continue
		_a_chaf(Vector3(1.0, 0.8, 0.3), d2 * 1.98 + Vector3(0.0, 4.25, 0.0), blanco, 0.05, Vector3(0, rot_y, 0))
		_a_chaf(Vector3(0.7, 0.5, 0.05), d2 * 2.16 + Vector3(0.0, 4.25, 0.0), negro, 0.02, Vector3(0, rot_y, 0))

	_a_cil(0.7, 1.0, 0.9, Vector3(0.0, 2.55, 0.0), gris_c, Vector3.ZERO, 20)
	_a_cil(0.5, 0.8, 0.7, Vector3(0.0, 2.2, 0.0), negro, Vector3.ZERO, 20)
	for i in range(4):
		var a3 := TAU * float(i) / 4.0 + PI * 0.25
		_a_cil(0.2, 0.46, 0.7, Vector3(cos(a3) * 1.15, 2.75, sin(a3) * 1.15), negro, Vector3.ZERO, 12)


	_a_cil(1.25, 1.8, 0.75, Vector3(0.0, 5.85, 0.0), blanco, Vector3.ZERO, 12)
	_a_cil(1.25, 1.25, 0.1, Vector3(0.0, 6.27, 0.0), negro, Vector3.ZERO, 12)


	_a_tubo(Vector3(0.55, 6.3, 0.45), Vector3(0.55, 7.4, 0.45), 0.06, tubo, 8)
	_a_chaf(Vector3(0.62, 0.22, 0.26), Vector3(0.55, 7.5, 0.45), blanco, 0.03)
	for lado in [-1.0, 1.0]:
		_a_cil(0.06, 0.06, 0.12, Vector3(0.55 + lado * 0.15, 7.5, 0.3), negro, Vector3(90, 0, 0), 12)
		_a_cil(0.04, 0.04, 0.02, Vector3(0.55 + lado * 0.15, 7.5, 0.235), vidrio, Vector3(90, 0, 0), 12)


	_a_tubo(Vector3(-0.6, 6.3, -0.3), Vector3(-0.6, 7.5, -0.3), 0.05, tubo, 8)
	_a_cil(0.65, 0.12, 0.22, Vector3(-0.6, 7.7, -0.3), blanco, Vector3(-22, 0, 0), 20)
	_a_tubo(Vector3(-0.6, 7.7, -0.3), Vector3(-0.6, 8.25, -0.45), 0.02, gris_c, 6)

	_a_tubo(Vector3(0.0, 6.3, -0.7), Vector3(0.0, 8.3, -0.7), 0.025, gris_c, 6)


	for lado in [-1.0, 1.0]:
		var centro := Vector3(lado * 3.9, 5.9, 0.0)
		var bas := Basis.from_euler(Vector3(0.0, 0.0, deg_to_rad(-lado * 12.0)))
		var xf := Transform3D(bas, centro)
		_a_tubo(Vector3(lado * 1.7, 5.0, 0.0), centro + Vector3(-lado * 1.4, -0.1, 0.0), 0.1, tubo, 8)
		_a_tubo(Vector3(lado * 1.7, 5.6, 0.0), centro + Vector3(-lado * 1.4, 0.0, 0.0), 0.07, tubo, 8)
		_a_cil_t(1.6, 1.6, 0.1, xf, m_panel, 28)
		_a_cil_t(1.66, 1.66, 0.07, xf * Transform3D(Basis.IDENTITY, Vector3(0, -0.02, 0)), gris_c, 28)
		for j in range(4):
			var gj := Basis.from_euler(Vector3(0.0, PI * float(j) / 4.0, 0.0))
			_a_caja_t(Vector3(3.2, 0.02, 0.05), xf * Transform3D(gj, Vector3(0, 0.06, 0)), plata)
		_a_cil_t(0.45, 0.45, 0.14, xf * Transform3D(Basis.IDENTITY, Vector3(0, 0.07, 0)), gris_c, 16)

	var mi := _acc_fin(raiz)
	mi.name = "Modulo"
	var et := Label3D.new()
	et.text = "SPARTANS II"
	et.font_size = 64
	et.pixel_size = 0.0042
	et.modulate = Color(0.12, 0.13, 0.18)
	et.outline_size = 0
	et.double_sided = false
	et.position = Vector3(0.0, 4.25, -2.15)
	et.rotation_degrees = Vector3(0, 180, 0)
	raiz.add_child(et)

	_columna_luz(raiz, COLOR_A, 22.0)
	raiz.add_child(_etiqueta("A · ATERRIZAJE", COLOR_A, Vector3(0.0, 12.0, 0.0)))

	_rocas_dir.append(_up_a)
	_rocas_r.append(3.8 * k)


func _crear_base() -> void:
	var h_max := _altura_max(_up_b, 11.0)
	var fb := (_f0 - _up_b * _f0.dot(_up_b)).normalized()
	var zl := -fb
	var xl := _up_b.cross(zl).normalized()
	var raiz := Node3D.new()
	raiz.transform = Transform3D(Basis(xl, _up_b, zl) * Basis.from_scale(Vector3.ONE * k),
			_up_b * (planet.radius + h_max))
	add_child(raiz)
	_raiz_base = raiz

	var m_hormigon := _mat_pbr(Color(0.4, 0.38, 0.36), 0.0, 0.95)
	var m_blanco := _mat_pbr(Color(0.9, 0.9, 0.92), 0.0, 0.55)
	var m_gris := _mat_pbr(Color(0.36, 0.37, 0.4), 0.2, 0.6)
	var m_negro := _mat_pbr(Color(0.08, 0.08, 0.09), 0.1, 0.7)
	var m_naranja := _mat_pbr(Color(0.9, 0.42, 0.1), 0.0, 0.6)
	var m_azul := _mat_pbr(Color(0.07, 0.11, 0.24), 0.3, 0.3)
	var m_tanque := _mat_pbr(Color(0.78, 0.8, 0.83), 0.3, 0.4)
	var m_amarillo := _mat_pbr(Color(0.85, 0.72, 0.15), 0.0, 0.6)
	var m_contenedor1 := _mat_pbr(Color(0.75, 0.3, 0.12), 0.0, 0.7)
	var m_contenedor2 := _mat_pbr(Color(0.82, 0.83, 0.85), 0.0, 0.7)
	var m_ventana := _mat_pbr(Color(1.0, 0.85, 0.55), 0.0, 0.3, 0.9)

	_cil(raiz, 12, 12, 14.5, Vector3(0, -6.75, 0), m_hormigon, Vector3(0, 0, 0), 40)
	_cil(raiz, 6.3, 6.3, 0.03, Vector3(0, 0.51, 9), m_amarillo, Vector3(0, 0, 0), 40)
	_cil(raiz, 5.95, 5.95, 0.05, Vector3(0, 0.52, 9), m_hormigon, Vector3(0, 0, 0), 40)
	_cil(raiz, 2.4, 2.4, 9, Vector3(-1, 3.1, -3), m_blanco, Vector3(0, 0, 90), 28)
	_esfera(raiz, 2.4, Vector3(-5.5, 3.1, -3), m_blanco, 20).scale = Vector3(0.55, 1, 1)
	_cil(raiz, 2.44, 2.44, 0.12, Vector3(-4.5, 3.1, -3), m_gris, Vector3(0, 0, 90), 28)
	_cil(raiz, 2.44, 2.44, 0.12, Vector3(-2.2, 3.1, -3), m_gris, Vector3(0, 0, 90), 28)
	_cil(raiz, 2.44, 2.44, 0.12, Vector3(0.2, 3.1, -3), m_gris, Vector3(0, 0, 90), 28)
	_cil(raiz, 2.44, 2.44, 0.12, Vector3(2, 3.1, -3), m_gris, Vector3(0, 0, 90), 28)
	_caja(raiz, Vector3(0.7, 0.45, 0.08), Vector3(-4.2, 3.55, -0.6), m_ventana)
	_caja(raiz, Vector3(0.7, 0.45, 0.08), Vector3(-2.6, 3.55, -0.6), m_ventana)
	_caja(raiz, Vector3(0.7, 0.45, 0.08), Vector3(-1, 3.55, -0.6), m_ventana)
	_caja(raiz, Vector3(0.7, 0.45, 0.08), Vector3(0.6, 3.55, -0.6), m_ventana)
	_cil(raiz, 2.6, 2.6, 4.6, Vector3(3.5, 2.8, -3), m_blanco, Vector3(0, 0, 0), 28)
	_cil(raiz, 2.64, 2.64, 0.15, Vector3(3.5, 4.9, -3), m_gris, Vector3(0, 0, 0), 28)
	_cil(raiz, 2, 2, 9, Vector3(3.5, 2.7, 0.5), m_blanco, Vector3(90, 0, 0), 28)
	_esfera(raiz, 2, Vector3(3.5, 2.7, 5), m_blanco, 20).scale = Vector3(1, 1, 0.55)
	_cil(raiz, 2.04, 2.04, 0.12, Vector3(3.5, 2.7, -0.5), m_gris, Vector3(90, 0, 0), 28)
	_cil(raiz, 2.04, 2.04, 0.12, Vector3(3.5, 2.7, 1.8), m_gris, Vector3(90, 0, 0), 28)
	_cil(raiz, 2.04, 2.04, 0.12, Vector3(3.5, 2.7, 4), m_gris, Vector3(90, 0, 0), 28)
	_cil(raiz, 1, 1, 2.4, Vector3(3.5, 2.5, 6.6), m_gris, Vector3(90, 0, 0), 16)
	_cil(raiz, 0.85, 0.85, 0.12, Vector3(3.5, 2.5, 7.85), m_naranja, Vector3(90, 0, 0), 16)
	_caja(raiz, Vector3(5.5, 3.8, 4.5), Vector3(-6.5, 2.4, 4), m_blanco)
	_caja(raiz, Vector3(5.9, 0.25, 4.9), Vector3(-6.5, 4.4, 4), m_blanco)
	_caja(raiz, Vector3(4, 3, 0.12), Vector3(-6.5, 2, 6.3), m_gris)
	_caja(raiz, Vector3(4, 0.1, 0.14), Vector3(-6.5, 1.3, 6.34), m_negro)
	_caja(raiz, Vector3(4, 0.1, 0.14), Vector3(-6.5, 2, 6.34), m_negro)
	_caja(raiz, Vector3(4, 0.1, 0.14), Vector3(-6.5, 2.7, 6.34), m_negro)
	_caja(raiz, Vector3(0.25, 3, 0.14), Vector3(-4.35, 2, 6.3), m_naranja)
	_cil(raiz, 1.1, 1.1, 5, Vector3(-6.5, 2.2, -8.5), m_tanque, Vector3(0, 0, 90), 20)
	_esfera(raiz, 1.1, Vector3(-9, 2.2, -8.5), m_tanque, 14).scale = Vector3(0.5, 1, 1)
	_esfera(raiz, 1.1, Vector3(-4, 2.2, -8.5), m_tanque, 14).scale = Vector3(0.5, 1, 1)
	_caja(raiz, Vector3(0.4, 1, 1.8), Vector3(-8, 1, -8.5), m_negro)
	_caja(raiz, Vector3(0.4, 1, 1.8), Vector3(-5, 1, -8.5), m_negro)
	_cil(raiz, 1.1, 1.1, 5, Vector3(-0.5, 2.2, -8.5), m_tanque, Vector3(0, 0, 90), 20)
	_esfera(raiz, 1.1, Vector3(-3, 2.2, -8.5), m_tanque, 14).scale = Vector3(0.5, 1, 1)
	_esfera(raiz, 1.1, Vector3(2, 2.2, -8.5), m_tanque, 14).scale = Vector3(0.5, 1, 1)
	_caja(raiz, Vector3(0.4, 1, 1.8), Vector3(-2, 1, -8.5), m_negro)
	_caja(raiz, Vector3(0.4, 1, 1.8), Vector3(1, 1, -8.5), m_negro)
	_caja(raiz, Vector3(4.8, 2.2, 2.2), Vector3(5.2, 1.6, -9.2), m_contenedor1)
	_caja(raiz, Vector3(4.8, 2.2, 2.2), Vector3(5.2, 3.8, -9.2), m_contenedor2)
	_caja(raiz, Vector3(2.2, 2.2, 4.8), Vector3(9.5, 1.6, -5), m_contenedor2)
	_caja(raiz, Vector3(4.2, 0.1, 3.4), Vector3(8.8, 2.6, -3), m_azul).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(4.3, 0.06, 3.5), Vector3(8.8, 2.55, -3), m_gris).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(0.15, 1.6, 0.15), Vector3(9.4, 1.4, -3), m_gris)
	_caja(raiz, Vector3(4.2, 0.1, 3.4), Vector3(8.8, 2.6, 1.5), m_azul).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(4.3, 0.06, 3.5), Vector3(8.8, 2.55, 1.5), m_gris).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(0.15, 1.6, 0.15), Vector3(9.4, 1.4, 1.5), m_gris)
	_caja(raiz, Vector3(4.2, 0.1, 3.4), Vector3(8.8, 2.6, 6), m_azul).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(4.3, 0.06, 3.5), Vector3(8.8, 2.55, 6), m_gris).rotation_degrees = Vector3(0, 0, -22)
	_caja(raiz, Vector3(0.15, 1.6, 0.15), Vector3(9.4, 1.4, 6), m_gris)
	_cil(raiz, 0.22, 0.3, 15, Vector3(-9.3, 8, -5), m_gris, Vector3(0, 0, 0), 10)
	var plato := _esfera(raiz, 2.2, Vector3(-9.3, 13.7, -5), m_blanco, 20)
	plato.scale = Vector3(1, 0.22, 1)
	_cil(raiz, 0.06, 0.06, 1.8, Vector3(-9.3, 14.5, -5), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.28, Vector3(-9.3, 15.5, -5), m_negro, 8)
	_caja(raiz, Vector3(6, 0.25, 6), Vector3(0, 0.65, 9.5), m_gris)
	_cil(raiz, 0.08, 0.1, 3.2, Vector3(11.3, 2.1, 0), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.22, Vector3(11.3, 3.8, 0), m_ventana, 8)
	_cil(raiz, 0.08, 0.1, 3.2, Vector3(7.263, 2.1, 8.656), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.22, Vector3(7.263, 3.8, 8.656), m_ventana, 8)
	_cil(raiz, 0.08, 0.1, 3.2, Vector3(-3.865, 2.1, 10.619), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.22, Vector3(-3.865, 3.8, 10.619), m_ventana, 8)
	_cil(raiz, 0.08, 0.1, 3.2, Vector3(-11.128, 2.1, 1.962), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.22, Vector3(-11.128, 3.8, 1.962), m_ventana, 8)
	_cil(raiz, 0.08, 0.1, 3.2, Vector3(3.865, 2.1, -10.619), m_gris, Vector3(0, 0, 0), 8)
	_esfera(raiz, 0.22, Vector3(3.865, 3.8, -10.619), m_ventana, 8)

	_mat_baliza_b = _mat(COLOR_B, true, 2.0)
	_cil(raiz, 0.5, 0.5, 1.0, Vector3(3.5, 5.6, -3.0), _mat_baliza_b, Vector3.ZERO, 12)
	_columna_luz(raiz, COLOR_B, 60.0)
	raiz.add_child(_etiqueta("B · BASE", COLOR_B, Vector3(0.0, 18.0, 0.0)))

	_rocas_dir.append(_up_b)
	_rocas_r.append(12.4 * k)


func _poner_baliza(f: float) -> void:
	if _mat_baliza_b == null:
		return
	var c := Color(1.0, 0.25, 0.18).lerp(COLOR_B, clampf(f, 0.0, 1.0))
	_mat_baliza_b.albedo_color = c
	_mat_baliza_b.emission = c


func _crear_rocas() -> void:

	var campos: Array = []
	var n_campos := 8
	for _i in n_campos:
		campos.append([_rng.randf_range(0.0, 1.0) * dist_base,
				_rng.randf_range(-0.42, 0.42) * dist_base,
				_rng.randf_range(14.0, 38.0)])
	var n := 0
	var gigantes := 0
	var intentos := 0
	while n < NUM_ROCAS and intentos < 1500:
		intentos += 1
		var u: float
		var v: float
		if _rng.randf() < 0.78:
			var c: Array = campos[_rng.randi() % n_campos]
			u = float(c[0]) + _rng.randfn(0.0, float(c[2]))
			v = float(c[1]) + _rng.randfn(0.0, float(c[2]))
		else:
			u = _rng.randf_range(-0.15, 1.05) * dist_base
			v = _rng.randf_range(-0.5, 0.5) * dist_base
		var r := lerpf(0.9, 4.2, pow(_rng.randf(), 2.2))
		var gigante := false
		if gigantes < 4 and _rng.randf() < 0.025:
			r = _rng.randf_range(8.0, 13.0)
			gigante = true
		elif _rng.randf() < 0.07:
			r *= 2.0
		var d := _desplazar(site_up, _f0, _perp, u * k, v * k)
		if _arco(d, _up_a) < (r + 12.0) * k or _arco(d, _up_h) < (r + 20.0) * k:
			continue
		if _arco(d, _up_b) < (r + 16.0) * k:
			continue
		var en_cueva := false
		for c in _cuevas:
			if distancia_entre(d, c.dir_centro) < r + 26.0 * c.escala:
				en_cueva = true
				break
		if en_cueva:
			continue
		var muy_junto := false
		for j in _rocas_dir.size():
			if _arco(d, _rocas_dir[j]) < (r * k + float(_rocas_r[j])) * 0.7:
				muy_junto = true
				break
		if muy_junto:
			continue
		var roca := Muestras.roca_escenario(_rng, r)
		var esc := roca.scale
		var b := _base_up(d).rotated(d, _rng.randf() * TAU)
		b = b * Basis.from_scale(esc * k)
		roca.transform = Transform3D(b, _pos(d) + d * (r * k * 0.2))
		add_child(roca)
		if Ajustes.graficos_reales:
			var anc := _anclar_en(d)
			Realismo.sombra(anc, r * 1.08, 0.7, _sol_en(anc), 0.14)
		_rocas_dir.append(d)
		_rocas_r.append(r * k)
		if gigante:
			gigantes += 1
		n += 1


func _crear_horizonte() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla * 7 + 31
	var centro := ((_up_a + _up_b) * 0.5).normalized()
	var f := (_f0 - centro * _f0.dot(centro)).normalized()
	var p := centro.cross(f).normalized()
	var n_mac := 26
	var col_base := Color(0.30, 0.16, 0.11).lerp(Color(0.50, 0.30, 0.21), clampf(float(amb.get("polvo", 0.5)), 0.0, 1.0) * 0.6)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in n_mac:
		var ang := (float(i) + rng.randf_range(-0.3, 0.3)) / float(n_mac) * TAU
		var dist_gm := rng.randf_range(2300.0, 3300.0)
		var d := _desplazar(centro, f, p, cos(ang) * dist_gm * k, sin(ang) * dist_gm * k)
		var mesh := _malla_macizo(rng, col_base)
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var b := _base_up(d).rotated(d, rng.randf() * TAU)
		b = b * Basis.from_scale(Vector3.ONE * k)
		mi.transform = Transform3D(b, _pos(d) - d * (35.0 * k))
		add_child(mi)


func _malla_macizo(rng: RandomNumberGenerator, col: Color) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var picos := rng.randi_range(3, 5)
	var ancho_total := rng.randf_range(260.0, 520.0)
	for pk in picos:
		var cx := (float(pk) / float(picos - 1) - 0.5) * ancho_total + rng.randf_range(-25.0, 25.0)
		var cz := rng.randf_range(-40.0, 40.0)
		var alto := rng.randf_range(130.0, 380.0) * (1.0 - absf(float(pk) / float(picos - 1) - 0.5) * 0.7)
		var w := alto * rng.randf_range(1.0, 1.7)
		var seg := 11
		var base_pts: Array[Vector3] = []
		var mid_pts: Array[Vector3] = []
		for j in seg:
			var a := float(j) / float(seg) * TAU
			var rb := w * rng.randf_range(0.85, 1.15)
			var rm := w * rng.randf_range(0.4, 0.8)
			base_pts.append(Vector3(cx + cos(a) * rb, 0.0, cz + sin(a) * rb * 0.75))
			mid_pts.append(Vector3(cx + cos(a) * rm, alto * rng.randf_range(0.5, 0.8), cz + sin(a) * rm * 0.75))
		var cima := Vector3(cx + rng.randf_range(-0.12, 0.12) * w, alto, cz + rng.randf_range(-0.1, 0.1) * w)
		var c_baja := col.darkened(0.18)
		var c_med := col
		var c_alta := col.lightened(0.08)
		for j in seg:
			var j2 := (j + 1) % seg
			_tri_color(st, base_pts[j], c_baja, mid_pts[j], c_med, base_pts[j2], c_baja)
			_tri_color(st, base_pts[j2], c_baja, mid_pts[j], c_med, mid_pts[j2], c_med)
			_tri_color(st, mid_pts[j], c_med, cima, c_alta, mid_pts[j2], c_med)
	st.generate_normals()
	return st.commit()


func _tri_color(st: SurfaceTool, a: Vector3, ca: Color, b: Vector3, cb: Color, c: Vector3, cc: Color) -> void:
	st.set_color(ca)
	st.add_vertex(a)
	st.set_color(cb)
	st.add_vertex(b)
	st.set_color(cc)
	st.add_vertex(c)


func _sitio_cueva_valido(d: Vector3, grande: bool, previas: Array[Node3D]) -> bool:
	var esc := 1.6 if grande else 1.0
	if distancia_entre(d, _up_a) < 60.0 * esc or distancia_entre(d, _up_b) < 60.0 * esc or distancia_entre(d, _up_h) < 60.0 * esc:
		return false
	for c in previas:
		if distancia_entre(d, c.dir_centro) < 70.0:
			return false
	if _evaluar(d).y > 11.0:
		return false
	var h0 := _altura(d)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var p := _offset_dir(d, cos(a) * CuevaMision.ANCHO * 0.8 * esc * k, sin(a) * CuevaMision.LARGO * 0.8 * esc * k)
		if absf(_altura(p) - h0) / k > 2.3:
			return false
	return true


func _crear_cuevas() -> void:
	var n := int(amb.get("cuevas", 0))
	if n <= 0:
		return
	var grande := bool(amb.get("cueva_grande", false))
	var mineral := str(amb.get("cueva_mat", ""))
	var col := Color(0.7, 0.85, 1.0)
	if mineral != "":
		col = DatosMarte.material(mineral)["color"]
	var crng := RandomNumberGenerator.new()
	crng.seed = semilla * 7 + 3
	var intentos := 0
	while _cuevas.size() < n and intentos < 400:
		intentos += 1
		var i := _cuevas.size()
		var u := dist_base * (float(i + 1) / float(n + 1)) + crng.randf_range(-0.1, 0.1) * dist_base
		var lado := -1.0 if crng.randi() % 2 == 0 else 1.0
		var v := lado * crng.randf_range(34.0, 56.0) * (1.4 if grande else 1.0)
		var d := dir_uv(u, v)
		if not _sitio_cueva_valido(d, grande, _cuevas):
			continue

		var d_ruta := dir_uv(u, 0.0)
		var hacia := d_ruta - d * d_ruta.dot(d)
		var c := CuevaMision.new()
		add_child(c)
		c.construir(self, d, hacia, grande, semilla * 13 + i, mineral, col)
		_cuevas.append(c)


func _sitio_muestra_valido(d: Vector3, colocados: Array[Vector3]) -> bool:
	if _arco(d, _up_a) < 30.0 * k or _arco(d, _up_b) < 35.0 * k or _arco(d, _up_h) < 30.0 * k:
		return false
	for q in colocados:
		if _arco(d, q) < 25.0 * k:
			return false
	for c in _cuevas:
		if distancia_entre(d, c.dir_centro) < 30.0 * c.escala:
			return false
	for i in range(_rocas_dir.size()):
		if _arco(d, _rocas_dir[i]) < _rocas_r[i] + 2.6 * k:
			return false
	return true


func _crear_muestras() -> void:
	var pendientes: Array[String] = lista.duplicate()
	var puestas: Array[String] = []
	var colocados: Array[Vector3] = []


	var cueva_mat := str(amb.get("cueva_mat", ""))
	var cueva_n := int(amb.get("cueva_n", 0))
	if not _cuevas.is_empty() and cueva_mat != "" and cueva_n > 0:
		var restantes := cueva_n
		var por_cueva := ceili(float(cueva_n) / float(_cuevas.size()))
		for c in _cuevas:
			var pts: Array[Vector3] = c.puntos_interior(mini(por_cueva, restantes), _rng)
			for d in pts:
				var idx := pendientes.find(cueva_mat)
				if idx == -1:
					break
				pendientes.remove_at(idx)
				_crear_muestra_en(d, cueva_mat)
				puestas.append(cueva_mat)
				colocados.append(d)
				restantes -= 1


	for id in pendientes:
		var puesto := false
		var intentos := 0
		while not puesto and intentos < 600:
			intentos += 1
			var u := _rng.randf() * dist_base
			var v := _rng.randf_range(-0.42, 0.42) * dist_base
			var d := dir_uv(u, v)
			if not _sitio_muestra_valido(d, colocados):
				continue
			var ev := _evaluar(d)
			if ev.y > PENDIENTE_MUESTRA:
				continue
			var umbral := maxf(DatosMarte.afinidad(id, ev.x, ev.y), 0.1) if intentos < 350 else 1.0
			if _rng.randf() > umbral:
				continue
			_crear_muestra_en(d, id)
			puestas.append(id)
			colocados.append(d)
			puesto = true
	lista = puestas
	total_objetos = maxi(puestas.size(), 1)


func _crear_muestra_en(dir: Vector3, id: String) -> void:
	var raiz := Node3D.new()
	var b := _base_up(dir).rotated(dir, _rng.randf() * TAU) * Basis.from_scale(Vector3.ONE * k)
	raiz.transform = Transform3D(b, _pos(dir))
	raiz.set_meta("dir", dir)
	raiz.set_meta("mat", id)
	var r := RandomNumberGenerator.new()
	r.seed = semilla * 131 + _objetos.size() * 7 + 1
	Muestras.construir(raiz, id, 1.0, r)
	add_child(raiz)
	_objetos.append(raiz)


var _acc: Dictionary = {}
var _cache_chaflan: Dictionary = {}
var _tex_sucio_c: Texture2D = null


func _acc_ini() -> void:
	_acc = {}


func _acc_fin(padre: Node3D) -> MeshInstance3D:
	var am := ArrayMesh.new()
	for mat in _acc:
		var st: SurfaceTool = _acc[mat]
		st.set_material(mat)
		st.commit(am)
	var mi := MeshInstance3D.new()
	mi.mesh = am
	padre.add_child(mi)
	_acc = {}
	return mi


func _acc_aparte() -> Dictionary:
	var guardado := _acc
	_acc = {}
	return guardado


func _acc_grupo(guardado: Dictionary, raiz: Node3D, pivote: Vector3) -> Node3D:
	var nodo := Node3D.new()
	nodo.position = pivote
	raiz.add_child(nodo)
	var mi := _acc_fin(nodo)
	mi.position = -pivote
	_acc = guardado
	return nodo


func _acc_mesh(mesh: Mesh, xf: Transform3D, mat: Material) -> void:
	var st: SurfaceTool = _acc.get(mat)
	if st == null:
		st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_acc[mat] = st
	st.append_from(mesh, 0, xf)


func _xf(pos: Vector3, rot_deg: Vector3) -> Transform3D:
	return Transform3D(Basis.from_euler(rot_deg * (PI / 180.0)), pos)


func _a_caja_t(tam: Vector3, xf: Transform3D, mat: Material) -> void:
	var bm := BoxMesh.new()
	bm.size = tam
	_acc_mesh(bm, xf, mat)


func _a_caja(tam: Vector3, pos: Vector3, mat: Material, rot_deg: Vector3 = Vector3.ZERO) -> void:
	_a_caja_t(tam, _xf(pos, rot_deg), mat)


func _a_chaf_t(tam: Vector3, xf: Transform3D, mat: Material, c: float = 0.04) -> void:
	_acc_mesh(_malla_chaflan(tam, c), xf, mat)


func _a_chaf(tam: Vector3, pos: Vector3, mat: Material, c: float = 0.04,
		rot_deg: Vector3 = Vector3.ZERO) -> void:
	_a_chaf_t(tam, _xf(pos, rot_deg), mat, c)


func _a_cil_t(r_sup: float, r_inf: float, alto: float, xf: Transform3D, mat: Material,
		segs: int = 16) -> void:
	var cm := CylinderMesh.new()
	cm.top_radius = r_sup
	cm.bottom_radius = r_inf
	cm.height = alto
	cm.radial_segments = segs
	cm.rings = 1
	_acc_mesh(cm, xf, mat)


func _a_cil(r_sup: float, r_inf: float, alto: float, pos: Vector3, mat: Material,
		rot_deg: Vector3 = Vector3.ZERO, segs: int = 16) -> void:
	_a_cil_t(r_sup, r_inf, alto, _xf(pos, rot_deg), mat, segs)


func _a_esf(radio: float, pos: Vector3, mat: Material, segs: int = 12) -> void:
	var sm := SphereMesh.new()
	sm.radius = radio
	sm.height = radio * 2.0
	sm.radial_segments = segs
	sm.rings = maxi(segs / 2, 4)
	_acc_mesh(sm, Transform3D(Basis.IDENTITY, pos), mat)


func _a_tubo(a: Vector3, b: Vector3, r: float, mat: Material, segs: int = 8) -> void:
	var d := b - a
	var l := d.length()
	if l < 0.0001:
		return
	var dn := d / l
	var bas: Basis
	if dn.y < -0.9999:
		bas = Basis(Vector3.RIGHT, PI)
	else:
		bas = Basis(Quaternion(Vector3.UP, dn))
	_a_cil_t(r, r, l, Transform3D(bas, (a + b) * 0.5), mat, segs)


func _tri_ext(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var nrm := (b - a).cross(c - a)
	var cen := (a + b + c) / 3.0
	if nrm.dot(cen) > 0.0:
		var t := b
		b = c
		c = t
	for p: Vector3 in [a, b, c]:
		st.set_uv(Vector2(p.x + p.z * 0.5, p.y + p.z * 0.3))
		st.add_vertex(p)


func _quad_ext(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_tri_ext(st, a, b, c)
	_tri_ext(st, a, c, d)


func _malla_chaflan(tam: Vector3, c: float) -> ArrayMesh:
	var clave := "%.3f_%.3f_%.3f_%.3f" % [tam.x, tam.y, tam.z, c]
	if _cache_chaflan.has(clave):
		return _cache_chaflan[clave]
	var h := tam * 0.5
	var ci := minf(c, minf(h.x, minf(h.y, h.z)) * 0.9)
	var n := Vector3(h.x - ci, h.y - ci, h.z - ci)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var orden: Array[Vector2] = [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1)]
	var signos: Array[float] = [-1.0, 1.0]

	for a in range(3):
		var b := (a + 1) % 3
		var d := (a + 2) % 3
		for s in signos:
			var q: Array[Vector3] = []
			for o in orden:
				var p := Vector3.ZERO
				p[a] = s * h[a]
				p[b] = o.x * n[b]
				p[d] = o.y * n[d]
				q.append(p)
			_quad_ext(st, q[0], q[1], q[2], q[3])

	for a in range(3):
		var b := (a + 1) % 3
		var d := (a + 2) % 3
		for sa in signos:
			for sb in signos:
				var q: Array[Vector3] = []
				for t in signos:
					var p := Vector3.ZERO
					p[a] = sa * h[a]
					p[b] = sb * n[b]
					p[d] = t * n[d]
					q.append(p)
				for t in [1.0, -1.0]:
					var p2 := Vector3.ZERO
					p2[a] = sa * n[a]
					p2[b] = sb * h[b]
					p2[d] = t * n[d]
					q.append(p2)
				_quad_ext(st, q[0], q[1], q[2], q[3])

	for sx in signos:
		for sy in signos:
			for sz in signos:
				_tri_ext(st, Vector3(sx * h.x, sy * n.y, sz * n.z),
						Vector3(sx * n.x, sy * h.y, sz * n.z),
						Vector3(sx * n.x, sy * n.y, sz * h.z))
	st.generate_normals()
	st.generate_tangents()
	st.index()
	var mesh := st.commit()
	_cache_chaflan[clave] = mesh
	return mesh


func _tex_sucio() -> Texture2D:
	if _tex_sucio_c != null:
		return _tex_sucio_c
	var fn := FastNoiseLite.new()
	fn.seed = 11
	fn.frequency = 0.035
	fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fn.fractal_type = FastNoiseLite.FRACTAL_FBM
	fn.fractal_octaves = 5
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(0.6, 0.53, 0.46), Color(1.0, 1.0, 1.0)])
	var t := NoiseTexture2D.new()
	t.width = 256
	t.height = 256
	t.seamless = true
	t.noise = fn
	t.color_ramp = g
	_tex_sucio_c = t
	return t


func _mat_sucio(color: Color, metal: float, rough: float, escala: float = 0.6) -> StandardMaterial3D:
	var m := _mat_pbr(color, metal, rough)
	m.albedo_texture = _tex_sucio()
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * escala
	return m


func _modelar_rover(raiz: Node3D) -> void:
	_acc_ini()
	var m_blanco := _mat_pbr(Recuerdos.color_pintura(), 0.0, 0.5)
	var m_crema := _mat_sucio(Color(1.0, 0.97, 0.92), 0.0, 0.6, 0.7)
	var m_gris := _mat_pbr(Color(0.5, 0.51, 0.55), 0.3, 0.45)
	var m_tubo := _mat_sucio(Color(0.82, 0.82, 0.86), 0.3, 0.42, 0.8)
	var m_negro := _mat_pbr(Color(0.07, 0.07, 0.08), 0.1, 0.7)
	var m_llanta := _mat_sucio(Color(0.86, 0.82, 0.78), 0.3, 0.5, 0.7)
	var m_cara := _mat_pbr(Color(0.44, 0.44, 0.48), 0.3, 0.55)
	var m_radio := _mat_sucio(Color(0.82, 0.82, 0.86), 0.3, 0.4, 0.9)
	var m_taco := _mat_pbr(Color(0.34, 0.33, 0.35), 0.3, 0.55)
	var m_naranja := _mat_pbr(Color(0.9, 0.42, 0.1), 0.0, 0.6)
	var m_vidrio := _mat_pbr(Color(0.03, 0.05, 0.09), 0.3, 0.08, 0.05)
	var m_rtg := _mat_pbr(Color(0.14, 0.14, 0.15), 0.3, 0.5)
	var m_oro := _mat_pbr(Color(0.8, 0.62, 0.26), 0.3, 0.35)


	_a_chaf(Vector3(1.5, 0.55, 2.0), Vector3(0, 0.95, 0.05), m_blanco, 0.07)
	_a_chaf(Vector3(1.53, 0.13, 2.03), Vector3(0, 0.77, 0.05), m_crema, 0.03)
	_a_chaf(Vector3(1.0, 0.14, 1.5), Vector3(0, 0.6, 0.05), m_negro, 0.03)
	_a_caja(Vector3(0.02, 0.1, 1.5), Vector3(-0.765, 1.03, 0.05), m_naranja)
	_a_caja(Vector3(0.02, 0.1, 1.5), Vector3(0.765, 1.03, 0.05), m_naranja)
	_a_chaf(Vector3(1.52, 0.05, 2.02), Vector3(0, 1.245, 0.05), m_negro, 0.02)

	for lado in [-1.0, 1.0]:
		for z in [-0.55, 0.0, 0.55]:
			_a_caja(Vector3(0.012, 0.22, 0.4), Vector3(lado * 0.757, 0.93, z + 0.05), m_gris)

	_a_chaf(Vector3(1.1, 0.28, 0.9), Vector3(0, 1.4, -0.35), m_blanco, 0.05)
	for i in range(5):
		_a_caja(Vector3(0.96, 0.015, 0.05), Vector3(0, 1.545, -0.7 + float(i) * 0.14), m_negro)
	for i in range(4):
		_a_caja(Vector3(0.22, 0.14, 0.012), Vector3(-0.36 + float(i) * 0.24, 1.4, -0.806), m_negro)

	_a_chaf(Vector3(0.16, 0.08, 0.5), Vector3(-0.66, 1.3, 0.0), m_gris, 0.02)
	_a_chaf(Vector3(0.16, 0.08, 0.5), Vector3(0.66, 1.3, 0.0), m_gris, 0.02)

	_a_caja(Vector3(1.2, 0.05, 0.9), Vector3(0, 1.29, 0.55), m_negro)
	_a_caja(Vector3(0.04, 0.14, 0.9), Vector3(-0.6, 1.35, 0.55), m_gris)
	_a_caja(Vector3(0.04, 0.14, 0.9), Vector3(0.6, 1.35, 0.55), m_gris)

	_a_caja(Vector3(1.2, 0.34, 0.05), Vector3(0, 0.98, -0.975), m_gris)
	for lado in [-1.0, 1.0]:
		_a_chaf(Vector3(0.2, 0.12, 0.07), Vector3(lado * 0.5, 0.98, -1.03), m_negro, 0.02)
		_a_cil(0.032, 0.032, 0.03, Vector3(lado * 0.55, 0.98, -1.08), m_vidrio, Vector3(90, 0, 0), 10)
		_a_cil(0.032, 0.032, 0.03, Vector3(lado * 0.45, 0.98, -1.08), m_vidrio, Vector3(90, 0, 0), 10)
		_a_chaf(Vector3(0.2, 0.12, 0.07), Vector3(lado * 0.5, 1.02, 1.1), m_negro, 0.02)


	for lado in [-1.0, 1.0]:
		var x: float = lado * 0.8
		var p_dif := Vector3(x, 0.98, 0.05)
		var p_bog := Vector3(x, 0.78, 0.48)
		var t_del := Vector3(x, 0.72, -0.95)
		var t_med := Vector3(x, 0.62, 0.0)
		var t_tra := Vector3(x, 0.62, 0.95)
		_a_tubo(p_dif, t_del, 0.038, m_tubo, 10)
		_a_tubo(p_dif, p_bog, 0.038, m_tubo, 10)
		_a_tubo(p_bog, t_med, 0.034, m_tubo, 10)
		_a_tubo(p_bog, t_tra, 0.034, m_tubo, 10)
		_a_cil(0.075, 0.075, 0.16, p_dif, m_gris, Vector3(0, 0, 90), 12)
		_a_cil(0.065, 0.065, 0.14, p_bog, m_gris, Vector3(0, 0, 90), 12)
		for z in [-0.95, 0.0, 0.95]:
			var top := Vector3(x, 0.72 if z < -0.5 else 0.62, z)
			_a_tubo(Vector3(x, 0.38, z), top, 0.034, m_tubo, 8)
			_a_cil(0.045, 0.045, 0.26, Vector3(lado * 0.9, 0.38, z), m_gris, Vector3(0, 0, 90), 10)
			_a_esf(0.055, top, m_gris, 8)
			if absf(z) > 0.5:
				_a_cil(0.07, 0.07, 0.1, top + Vector3(0, 0.06, 0), m_negro, Vector3.ZERO, 10)
			var pz := Vector3(lado * 1.0, 0.38, z)
			var g_r := _acc_aparte()
			_a_rueda(pz, lado, m_llanta, m_cara, m_radio, m_taco)
			var rueda := _acc_grupo(g_r, raiz, pz)
			rueda.set_meta("lado", lado)
			if raiz == _rover_pivote:
				_ruedas.append(rueda)


	_a_chaf(Vector3(0.5, 0.1, 0.3), Vector3(0, 0.98, 1.1), m_gris, 0.02)
	_a_cil(0.2, 0.2, 0.95, Vector3(0, 1.12, 1.3), m_rtg, Vector3(90, 0, 0), 20)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		_a_caja(Vector3(0.025, 0.14, 0.88), Vector3(cos(a) * 0.27, 1.12 + sin(a) * 0.27, 1.3), m_rtg,
				Vector3(0, 0, rad_to_deg(a) - 90.0))
	_a_cil(0.215, 0.215, 0.1, Vector3(0, 1.12, 1.3), m_oro, Vector3(90, 0, 0), 20)
	_a_cil(0.24, 0.24, 0.04, Vector3(0, 1.12, 1.79), m_gris, Vector3(90, 0, 0), 20)
	_a_cil(0.24, 0.24, 0.04, Vector3(0, 1.12, 0.83), m_gris, Vector3(90, 0, 0), 20)
	_a_tubo(Vector3(-0.15, 1.0, 0.95), Vector3(-0.12, 1.08, 1.7), 0.02, m_gris, 6)
	_a_tubo(Vector3(0.15, 1.0, 0.95), Vector3(0.12, 1.08, 1.7), 0.02, m_gris, 6)


	var mx := 0.5
	var mz := -0.7
	_a_cil(0.08, 0.1, 0.08, Vector3(mx, 1.58, mz), m_gris, Vector3.ZERO, 12)
	_a_tubo(Vector3(mx, 1.6, mz), Vector3(mx, 2.3, mz), 0.042, m_tubo, 10)
	var g_m := _acc_aparte()
	_a_cil(0.09, 0.09, 0.07, Vector3(mx, 2.32, mz), m_negro, Vector3.ZERO, 12)
	_a_chaf(Vector3(0.66, 0.2, 0.24), Vector3(mx, 2.44, mz), m_blanco, 0.03)
	for lado in [-1.0, 1.0]:
		_a_cil(0.062, 0.062, 0.12, Vector3(mx + lado * 0.14, 2.44, mz - 0.14), m_negro, Vector3(90, 0, 0), 14)
		_a_cil(0.045, 0.045, 0.02, Vector3(mx + lado * 0.14, 2.44, mz - 0.205), m_vidrio, Vector3(90, 0, 0), 14)
		_a_chaf(Vector3(0.12, 0.12, 0.12), Vector3(mx + lado * 0.26, 2.58, mz), m_negro, 0.02)
		_a_cil(0.03, 0.03, 0.03, Vector3(mx + lado * 0.26, 2.58, mz - 0.075), m_vidrio, Vector3(90, 0, 0), 10)
	_a_cil(0.06, 0.06, 0.3, Vector3(mx, 2.62, mz - 0.04), m_negro, Vector3(90, 0, 0), 14)
	_a_cil(0.075, 0.075, 0.03, Vector3(mx, 2.62, mz - 0.2), m_gris, Vector3(90, 0, 0), 14)
	_a_cil(0.045, 0.045, 0.02, Vector3(mx, 2.62, mz - 0.22), m_vidrio, Vector3(90, 0, 0), 14)
	var cabeza := _acc_grupo(g_m, raiz, Vector3(mx, 2.32, mz))
	if raiz == _rover_pivote:
		_cabeza_mastil = cabeza


	var ax := -0.62
	_a_tubo(Vector3(ax, 1.55, -0.15), Vector3(ax, 1.8, -0.15), 0.03, m_gris, 8)
	_a_esf(0.065, Vector3(ax, 1.86, -0.15), m_gris, 10)
	var rot_ant := Vector3(-35, 0, 0)
	var nrm_ant: Vector3 = Basis.from_euler(rot_ant * (PI / 180.0)) * Vector3.UP
	var c_ant := Vector3(ax, 1.98, -0.17)
	var g_a := _acc_aparte()
	_a_cil(0.3, 0.3, 0.03, c_ant, m_blanco, rot_ant, 6)
	_a_cil(0.23, 0.23, 0.012, c_ant + nrm_ant * 0.018, m_cara, rot_ant, 6)
	_a_tubo(c_ant + nrm_ant * 0.02, c_ant + nrm_ant * 0.22, 0.012, m_gris, 6)
	_a_esf(0.028, c_ant + nrm_ant * 0.23, m_gris, 8)
	var dish := _acc_grupo(g_a, raiz, Vector3(ax, 1.86, -0.15))
	if raiz == _rover_pivote:
		_antena_dish = dish
	_a_cil(0.05, 0.06, 0.06, Vector3(0.62, 1.57, 0.9), m_gris, Vector3.ZERO, 10)
	_a_tubo(Vector3(0.62, 1.6, 0.9), Vector3(0.62, 2.0, 0.9), 0.015, m_gris, 6)


	var bx := -0.45
	_a_chaf(Vector3(0.26, 0.26, 0.14), Vector3(bx, 0.9, -1.06), m_gris, 0.03)
	_a_cil(0.1, 0.1, 0.22, Vector3(bx, 0.9, -1.15), m_gris, Vector3(0, 0, 90), 14)
	_a_tubo(Vector3(bx, 0.9, -1.15), Vector3(bx, 0.93, -1.8), 0.05, m_blanco, 10)
	_a_cil(0.078, 0.078, 0.16, Vector3(bx, 0.93, -1.8), m_gris, Vector3(0, 0, 90), 14)
	_a_tubo(Vector3(bx, 0.93, -1.8), Vector3(bx, 0.68, -2.28), 0.045, m_blanco, 10)
	_a_cil(0.07, 0.07, 0.14, Vector3(bx, 0.68, -2.28), m_gris, Vector3(0, 0, 90), 14)
	_a_cil(0.16, 0.16, 0.22, Vector3(bx, 0.66, -2.4), m_oro, Vector3(90, 0, 0), 16)
	_a_cil(0.15, 0.15, 0.025, Vector3(bx, 0.66, -2.52), m_negro, Vector3(90, 0, 0), 16)
	for off: Vector2 in [Vector2(-0.075, -0.045), Vector2(0.075, -0.045), Vector2(0.0, 0.085)]:
		_a_cil(0.04, 0.04, 0.2, Vector3(bx + off.x, 0.66 + off.y, -2.62), m_negro, Vector3(90, 0, 0), 8)
	_a_cil(0.012, 0.045, 0.3, Vector3(bx, 0.66, -2.68), m_gris, Vector3(-90, 0, 0), 10)
	_a_chaf(Vector3(0.07, 0.07, 0.1), Vector3(bx + 0.13, 0.76, -2.5), m_negro, 0.015)

	var mi := _acc_fin(raiz)
	mi.name = "Rover"


	for lado in [-1.0, 1.0]:
		var et := Label3D.new()
		et.text = "SPARTANS II"
		et.font_size = 64
		et.pixel_size = 0.0027
		et.modulate = Color(0.12, 0.13, 0.18)
		et.outline_size = 0
		et.double_sided = false
		et.position = Vector3(lado * 0.757, 1.14, 0.25)
		et.rotation_degrees = Vector3(0, 90.0 * lado, 0)
		raiz.add_child(et)


func _a_rueda(c: Vector3, lado: float, m_llanta: Material, m_cara: Material, m_radio: Material,
		m_taco: Material) -> void:
	var eje := Vector3(0, 0, 90)
	_a_cil(0.38, 0.38, 0.3, c, m_llanta, eje, 28)
	var xo: float = lado * 0.152
	_a_cil(0.31, 0.31, 0.02, c + Vector3(xo, 0, 0), m_cara, eje, 24)
	for i in range(5):
		var a := TAU * float(i) / 5.0
		var rad := Vector3(0.0, cos(a), sin(a))
		_a_caja(Vector3(0.03, 0.27, 0.05), c + Vector3(xo + lado * 0.012, 0, 0) + rad * 0.17, m_radio,
				Vector3(rad_to_deg(a), 0, 0))
	_a_cil(0.1, 0.1, 0.05, c + Vector3(lado * 0.17, 0, 0), m_radio, eje, 12)
	_a_cil(0.07, 0.07, 0.3, c + Vector3(-lado * 0.1, 0, 0), m_cara, eje, 10)
	for i in range(24):
		var a2 := TAU * float(i) / 24.0
		_a_caja(Vector3(0.31, 0.05, 0.055), c + Vector3(0.0, cos(a2), sin(a2)) * 0.385, m_taco,
				Vector3(rad_to_deg(a2), 0, 0))


func _crear_robot() -> void:
	_robot = Node3D.new()
	add_child(_robot)
	_rover_pivote = Node3D.new()
	_robot.add_child(_rover_pivote)
	_modelar_rover(_rover_pivote)
	_aplicar_mejoras_visuales()
	RecuerdosModelo.bandera(_robot, Recuerdos.puesto("bandera"))
	if Ajustes.graficos_reales:
		_sombra_robot = Realismo.sombra(_robot, 2.1, 0.75, Vector3.UP, 0.06)


	_carga = Node3D.new()
	_carga.position = Vector3(0.0, 1.34, 0.55)
	_robot.add_child(_carga)


	_flecha = Node3D.new()
	_flecha.position = Vector3(0.0, 3.5, 0.0)
	var cono := MeshInstance3D.new()
	var fm := CylinderMesh.new()
	fm.top_radius = 0.0
	fm.bottom_radius = 0.3
	fm.height = 0.9
	cono.mesh = fm
	_mat_flecha = _mat(COLOR_B, true, 2.0)
	cono.material_override = _mat_flecha
	cono.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	_flecha.add_child(cono)
	_robot.add_child(_flecha)


	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(0.0, 0.0, 0.0, 0.6), Color(0.0, 0.0, 0.0, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	var mat_s := StandardMaterial3D.new()
	mat_s.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_s.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_s.albedo_texture = tex
	mat_s.cull_mode = BaseMaterial3D.CULL_DISABLED
	var blob := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(3.4, 5.2)
	blob.mesh = pm
	blob.material_override = mat_s
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	blob.position = Vector3(0.0, 0.06, -0.2)
	_robot.add_child(blob)


func _crear_faro() -> void:
	_faro = SpotLight3D.new()
	_faro.spot_range = 44.0 * k
	_faro.spot_angle = 40.0
	_faro.spot_attenuation = 0.9
	_faro.light_color = Color(1.0, 0.95, 0.85)
	_faro.light_energy = 0.0
	_faro.shadow_enabled = false
	add_child(_faro)


func _actualizar_faro() -> void:
	if _faro == null:
		return
	var f := (_fwd - _up * _fwd.dot(_up)).normalized()
	var mira := (f * 0.93 - _up * 0.30).normalized()
	_faro.global_transform = Transform3D(Basis.looking_at(mira, _up),
			to_global(_pos_robot + _up * (1.6 * k) + f * (0.9 * k)))
	_faro.light_energy = 0.5 + 6.0 * _dentro + 4.5 * (1.0 - dia_f)


func _refrescar_hud() -> void:
	_hud.actualizar_progreso(_entregados_por, _bodega, _texto_objetivo())
	if _modo_fotos and _foto != null:
		_hud.actualizar_fotos(_foto.estados())
		_hud.actualizar_memoria(_mem_usada, _mem_max, _mem_flags)


func _material_pendiente() -> String:
	var por_id := {}
	for id in lista:
		por_id[id] = int(por_id.get(id, 0)) + 1
	for id in _entregados_por:
		por_id[id] = int(por_id.get(id, 0)) - int(_entregados_por[id])
	for id in _bodega:
		por_id[id] = int(por_id.get(id, 0)) - 1
	var mejor := ""
	var n := 0
	for id in por_id:
		if int(por_id[id]) > n:
			n = int(por_id[id])
			mejor = id
	return mejor


func _texto_fotos() -> String:
	if _terminada or _entregados >= total_objetos:
		return "¡Todas las fotos transmitidas a la Tierra!"
	if _foto.por_transmitir() > 0 and _foto.hechos() >= _foto.total():
		return "Tienes los %d blancos: lleva la cámara a la base (B) para transmitir las fotos." % _foto.total()
	if _mem_usada >= _mem_max:
		return "Memoria llena: lleva las fotos a la base (B) para transmitirlas y liberar espacio."
	var p: Dictionary = _foto.primer_pendiente()
	if p.is_empty():
		return "Lleva las fotos a la base (B) para transmitirlas."
	return "Fotos %d / %d.  %s" % [_foto.hechos(), _foto.total(), str(p["pista"])]


func _texto_objetivo() -> String:
	if _modo_fotos and _foto != null:
		return _texto_fotos()
	if _terminada:
		return "¡Todo el cargamento entregado en la base!"
	if _bodega.size() >= capacidad or (_objetos.is_empty() and not _bodega.is_empty()):
		return "Bodega llena: lleva la carga a la base (B)."
	if not _bodega.is_empty():
		return "Sigue explorando o vuelve a la base con lo que llevas."
	var id := _material_pendiente()
	if id == "":
		return "Explora el terreno y usa el escáner (Espacio)."
	var info := DatosMarte.material(id)
	return "Busca %s: %s." % [str(info["plural"]), str(info["pista"])]


func _rel(dir: Vector3) -> Vector2:
	var v := (dir - _up) * planet.radius / k
	var f := (_fwd - _up * _fwd.dot(_up)).normalized()
	var derecha := f.cross(_up).normalized()
	return Vector2(v.dot(derecha), v.dot(f))


func _hay_blanco_cerca() -> bool:
	return not _foto.contactos_suelo(_pos_robot, 60.0).is_empty()


func _texto_distancia(km: float) -> String:
	return "%d m" % int(km * 1000.0) if km < 1.0 else "%.1f km" % km


func _actualizar_eventos(delta: float) -> void:
	if _eventos == null:
		return
	var permitido := Ajustes.eventos and _riesgos and activo and not _terminada and not _en_briefing \
			and not _tut_activo and not _dilema_activo and not _visor and _dentro < 0.3 \
			and _tormenta_estado == 0 and not _sin_energia and _escaner_roto <= 0.0 and dia_f > 0.5
	_eventos.actualizar(delta, _tiempo, _up, permitido)
	if _escaner_roto > 0.0 and activo and not _terminada:
		_escaner_roto = maxf(_escaner_roto - delta, 0.0)
		if absf(_vel) / k < 0.05:
			_reinicio_t += delta
		else:
			_reinicio_t = 0.0
		if _reinicio_t >= 5.0 or _escaner_roto <= 0.0:
			_escaner_roto = 0.0
			_reinicio_t = 0.0
			_hud.toast("Escáner reiniciado", "El sensor vuelve a funcionar.", Color(0.35, 1.0, 0.5), 4.0)
			_audio.bueno()


func _ev_aviso(titulo: String, texto: String, color: Color, radio: String) -> void:
	_hud.toast(titulo, texto, color, 7.0)
	_audio.aviso()
	if radio != "":
		_radio(radio, true)


func _ev_golpe(energia: float) -> void:
	if _riesgos:
		_energia = maxf(_energia - energia * float(_ventajas.get("golpe", 1.0)), 0.5)


func _ev_bonus(energia: float) -> void:
	if _riesgos:
		_energia = minf(_energia + energia, 100.0)
	_audio.bueno()


func _ev_datos(n: int) -> void:
	_datos_extra += n
	_hito_ruta("dato")
	_audio.bueno()


func tormenta_repentina() -> bool:
	if not _riesgos or _tormenta_estado != 0 or _tormenta_cond:
		return false
	_tormenta_estado = 1
	_tormenta_t = 6.0
	_audio.aviso()
	return true


func _ev_sensor(segundos: float) -> void:
	_escaner_roto = segundos
	_reinicio_t = 0.0
	_senal_t = 0.0
	_pulso_t = -1.0


func _fase_corta() -> String:
	if _ciclo == null or not Ajustes.ciclo_dia:
		return ""
	match _ciclo.nombre():
		"ATARDECER": return "TARDE"
		"AMANECER": return "ALBA"
	return _ciclo.nombre()


func _actualizar_hud_vivo(delta: float) -> void:
	if _escaner_cd > 0.0:
		_escaner_cd = maxf(_escaner_cd - delta, 0.0)
	if _senal_t > 0.0:
		_senal_t = maxf(_senal_t - delta, 0.0)
	if _pulso_t >= 0.0:
		_pulso_t += delta
		if _pulso_t > DURACION_PULSO:
			_pulso_t = -1.0

	var blips: Array = []
	var ra := _rel(_up_a)
	blips.append({"tipo": "aterrizaje", "x": ra.x, "y": ra.y, "color": COLOR_A, "alpha": 1.0, "etq": "A"})
	var rb := _rel(_up_b)
	blips.append({"tipo": "base", "x": rb.x, "y": rb.y, "color": COLOR_B, "alpha": 1.0, "etq": "B"})
	var rh := _rel(_up_h)
	blips.append({"tipo": "aterrizaje", "x": rh.x, "y": rh.y, "color": Color(1.0, 0.75, 0.2), "alpha": 1.0, "etq": "H"})
	if _eventos != null and _eventos.poi_dir != Vector3.ZERO:
		var rp := _rel(_eventos.poi_dir)
		var es_sos: bool = _eventos.poi_tipo == "rescate"
		blips.append({"tipo": "muestra", "x": rp.x, "y": rp.y, "color": Color(1.0, 0.4, 0.3) if es_sos else Color(0.5, 0.95, 1.0), "alpha": 1.0,
				"etq": "SOS" if es_sos else "?"})
	for c in (_cuevas_detectadas if _escaner_roto <= 0.0 else []):
		var rc := _rel(c.dir_entrada())
		blips.append({"tipo": "cueva", "x": rc.x, "y": rc.y, "color": COLOR_CUEVA, "alpha": 1.0, "etq": "Cueva"})
	if not _sec.is_empty() and int(_sec.get("estado", 0)) == 1:
		var rs := _rel(_sec["dir"])
		blips.append({"tipo": "muestra", "x": rs.x, "y": rs.y, "color": _color_jefe(str(_sec["j"])), "alpha": 1.0, "etq": "!"})
	for hz in _hallazgos:
		if _hallazgo_revelado(hz):
			var rhz := _rel(hz.get_meta("dir"))
			blips.append({"tipo": "muestra", "x": rhz.x, "y": rhz.y, "color": Color(1.0, 0.82, 0.25), "alpha": 1.0, "etq": "*"})
	if _dron != null:
		for o in _dron.marcados:
			if not is_instance_valid(o):
				continue
			if _objetos.has(o):
				var rm2 := _rel(o.get_meta("dir"))
				blips.append({"tipo": "muestra", "x": rm2.x, "y": rm2.y, "color": DatosMarte.material(str(o.get_meta("mat")))["color"], "alpha": 1.0, "etq": ""})
			elif _cuevas.has(o):
				var rc2 := _rel(o.get_meta("dir_dron"))
				blips.append({"tipo": "cueva", "x": rc2.x, "y": rc2.y, "color": COLOR_CUEVA, "alpha": 1.0, "etq": "Cueva"})
			elif _curiosidades.has(o) and not bool(o.get_meta("leido")):
				var rd2 := _rel(o.get_meta("dir"))
				blips.append({"tipo": "muestra", "x": rd2.x, "y": rd2.y, "color": COLOR_DATO, "alpha": 1.0, "etq": "?"})
	var senal := ""
	if _modo_fotos and _senal_t > 0.0:
		for c in _foto.contactos_suelo(_pos_robot, ALCANCE_ESCANER * 1.4):
			var rf := _rel(c["dir"])
			blips.append({"tipo": "muestra", "x": rf.x, "y": rf.y, "color": COLOR_FOTO,
					"alpha": clampf(_senal_t / 2.0, 0.0, 1.0), "etq": ""})
	if _senal_t > 0.0:
		var alfa := clampf(_senal_t / 2.0, 0.0, 1.0)
		for o in _senal_lista:
			if is_instance_valid(o) and _objetos.has(o):
				var rm := _rel(o.get_meta("dir"))
				var info := DatosMarte.material(str(o.get_meta("mat")))
				blips.append({"tipo": "muestra", "x": rm.x, "y": rm.y, "color": info["color"],
						"alpha": alfa, "etq": ""})
		senal = _senal_texto


	var norte := (Vector3.UP - _up * _up.y)
	var f := (_fwd - _up * _fwd.dot(_up)).normalized()
	var derecha := f.cross(_up).normalized()
	var rumbo := 0.0
	var norte_rel := 0.0
	if norte.length() > 0.0001:
		norte = norte.normalized()
		var este := norte.cross(_up).normalized()
		rumbo = fposmod(rad_to_deg(atan2(f.dot(este), f.dot(norte))), 360.0)
		norte_rel = atan2(norte.dot(derecha), norte.dot(f))

	var aviso := ""
	if aviso == "" and not _terminada and activo:
		var o := _muestra_cercana()
		if _eventos != null and _eventos.rescate_cerca:
			aviso = "[E] Compartir batería (-12 %)"
		elif o != null:
			if _bodega.size() < capacidad:
				aviso = "[E] Recoger %s" % str(DatosMarte.material(str(o.get_meta("mat")))["nombre"]).to_lower()
			else:
				aviso = "Bodega llena: llévala a la base"
		elif _modo_fotos and _foto.por_transmitir() > 0 and _arco(_up, _up_b) < RADIO_BASE * k:
			aviso = "Transmitiendo fotos…"
		elif _curiosidad_cercana() != null:
			aviso = "[E] Leer dato curioso"
		elif _modo_fotos and not _visor and _hay_blanco_cerca():
			aviso = "[F] Abrir la cámara"
		elif not _bodega.is_empty() and _arco(_up, _up_b) < RADIO_BASE * k:
			aviso = "Entregando muestras…"
		elif _dentro > 0.6:
			aviso = "Dentro de una cueva"

	if aviso == "" and not _terminada and activo and not _sec.is_empty() and int(_sec.get("estado", 0)) == 1:
		aviso = "Secundaria de %s: %d m  ·  %d s" % [str(_sec["j"]), int(distancia_gm(_up, _sec["dir"])), int(float(_sec["t"]))]

	if aviso == "" and _riesgos and not _terminada and activo:
		if _sin_energia:
			aviso = "Sin batería: esperando al Sol…" if _tormenta_estado != 2 else "Sin batería · tormenta"
		elif _tormenta_estado == 2:
			aviso = "Tormenta: sin recarga solar"
		elif dia_f < 0.25:
			aviso = "Noche: sin recarga solar"

	var viento_ms: float = (_ambiente.viento_actual if _ambiente != null else 0.4) * 18.0
	_hud.actualizar_vivo({
		"rumbo_deg": rumbo,
		"norte_rel": norte_rel,
		"blips": blips,
		"alcance": _alcance_esc,
		"vel": absf(_vel) / k,
		"incl": rad_to_deg(acos(clampf(_normal.dot(_up), -1.0, 1.0))),
		"temp": float(amb.get("temp", -63.0)) + 3.0 * sin(_tiempo * 0.05) + 6.0 * (sol_dir.dot(_up) - 0.8) - 38.0 * (1.0 - dia_f),
		"pres": 6.1 + 0.15 * sin(_tiempo * 0.03),
		"viento": viento_ms,
		"dist_base": _arco(_up, _up_b),
		"carga_escaner": 0.0 if _escaner_roto > 0.0 else 1.0 - _escaner_cd / (RECARGA_ESCANER * float(_mej["escaner_cd"])),
		"escaner_roto": _escaner_roto > 0.0,
		"pulso": (_pulso_t / DURACION_PULSO) if _pulso_t >= 0.0 else -1.0,
		"senal": senal,
		"sol": int(datos.get("sol", 1)),
		"tiempo": _formato_tiempo(_tiempo),
		"hora": _ciclo.hora_texto() if _ciclo != null else "",
		"fase": _fase_corta(),
		"aviso": aviso,
		"energia": _energia if _riesgos else -1.0,
		"tormenta": _tormenta_estado,
		"guia": _guia_objetivo(),
	}, delta)


func _guia_objetivo() -> Dictionary:
	_guia_dir_ult = Vector3.ZERO
	var modo := int(Ajustes.guia_objetivo)
	if modo <= 0 or _terminada or not activo or _visor or _en_briefing or _modo_fotos:
		return {}
	var dir := Vector3.ZERO
	var texto := ""
	var col: Color = COLOR_B
	var quedan := not _objetos.is_empty()
	if not _bodega.is_empty() and (_bodega.size() >= capacidad or not quedan):
		dir = _up_b
		texto = "BASE · entregar"
	else:
		var lista: Array = []
		if modo >= 2:
			lista = _objetos
		else:
			lista = _guia_conocidas.duplicate()
			if _dron != null:
				for o in _dron.marcados:
					if not lista.has(o):
						lista.append(o)
		var mejor: Node3D = null
		var d_min := INF
		for o in lista:
			if not is_instance_valid(o) or not _objetos.has(o):
				continue
			var d := _arco(_up, o.get_meta("dir"))
			if d < d_min:
				d_min = d
				mejor = o
		if mejor != null:
			dir = mejor.get_meta("dir")
			var info := DatosMarte.material(str(mejor.get_meta("mat")))
			texto = str(info["nombre"])
			col = info["color"]
		elif not _bodega.is_empty():
			dir = _up_b
			texto = "BASE"
		else:
			return {}
	var r := _rel(dir)
	var km := _arco(_up, dir)
	_guia_dir_ult = dir
	return {"rel": atan2(r.x, r.y), "texto": texto, "dist": ("%.2f km" % km) if km < 1.0 else ("%.1f km" % km), "color": col}


func activar() -> void:
	activo = true
	_hud.actualizar_piloto()
	_hud.visible = true
	if not _arranque_hecho:
		_arranque_hecho = true
		_en_briefing = true
		var rel_b: Dictionary = RelatosMarte.relato(id_mision).duplicate()
		rel_b["jefe"] = Historia.mensaje(id_mision, "antes")
		rel_b["arrastra"] = _lineas_arrastra()
		_intro_k = 1.9
		_rel_br = rel_b
		if not _iniciar_cine():
			_hud.mostrar_briefing(datos, rel_b)


func _iniciar_cine() -> bool:
	if _exp or _modo_fotos:
		return false
	_cine = CineHistoria.new()
	if not _cine.iniciar(self, datos, not Rutas.obtener(id_mision).is_empty()):
		_cine = null
		return false
	_hud.visible = false
	_cine.terminada.connect(_cine_terminada)
	return true


func _cine_terminada() -> void:
	_cine = null
	if is_instance_valid(_hud):
		_hud.visible = true
		_hud.mostrar_briefing(datos, _rel_br)


func _foto_archivo() -> void:
	var c := _cine
	if c == null:
		return
	c.ocultar_ui(true)
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if c != null:
		c.ocultar_ui(false)
	FotoArchivo.guardar(id_mision, img)


func _crear_eco() -> void:
	if _exp or _modo_fotos or _eco != null:
		return
	var e := EcoHistoria.new()
	if e.iniciar(self, datos):
		_eco = e
		e.descubierto.connect(_eco_descubierto)


func _eco_descubierto(primera: bool) -> void:
	if not is_instance_valid(_hud):
		return
	var txt := "%s · %s" % [str(datos.get("era", "")), str(datos.get("nave", ""))]
	if primera:
		txt += "   ·   " + Idioma.t("+1 dato de ciencia")
	_hud.toast("Eco del pasado", txt, COLOR_DATO, 5.5)
	if _audio != null:
		_audio.aviso()


func desactivar() -> void:
	activo = false
	_cerrar_visor()
	_hud.visible = false
	if _audio != null:
		_audio.detener()
	if _musica != null:
		_musica.detener()
	if _ambiente != null:
		_ambiente.restaurar_entorno()


func _unhandled_input(event: InputEvent) -> void:
	if not activo:
		return
	if _pausa != null and is_instance_valid(_pausa):
		return
	if _cine != null and _cine.activa:
		if (event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed):
			_cine.saltar()
		return
	if _en_briefing:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E:
					if not _hud.saltar_titulo():
						_cerrar_briefing()
				KEY_ESCAPE:
					salir_solicitado.emit()
		return
	if _modo_captura:
		_entrada_captura(event)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P and not _visor and not _terminada and (_diario == null or not is_instance_valid(_diario)) \
				and _elec.is_empty() and not _dilema_activo:
			_alternar_captura()
			return
		if _tut_activo and event.keycode == KEY_T:
			_terminar_tutorial()
			return
		if _diario != null and is_instance_valid(_diario):
			if event.keycode == KEY_J or event.keycode == KEY_ESCAPE or event.keycode == KEY_TAB:
				_alternar_diario()
			return
		if event.keycode == KEY_J or event.keycode == KEY_TAB:
			_alternar_diario()
			return
		if _dilema_activo and (event.keycode == KEY_1 or event.keycode == KEY_KP_1 or event.keycode == KEY_2 or event.keycode == KEY_KP_2):
			_resolver_dilema(0 if (event.keycode == KEY_1 or event.keycode == KEY_KP_1) else 1)
			return
		if event.keycode == KEY_C and _puede_consultar():
			_alternar_consulta()
			return
		if event.keycode == KEY_R and not _terminada and not _visor and not _dilema_activo:
			if _radio_panel != null:
				_radio_guardar()
				return
			if not _radio_cola.is_empty():
				_radio_abrir()
				return
		if not _elec.is_empty():
			var n_op := -1
			match event.keycode:
				KEY_1, KEY_KP_1: n_op = 0
				KEY_2, KEY_KP_2: n_op = 1
				KEY_3, KEY_KP_3: n_op = 2
			if n_op >= 0 and n_op < int(_elec["n"]):
				if _radio_panel != null and is_instance_valid(_radio_panel):
					_radio_panel.intentar(n_op)
				else:
					_resolver_eleccion(n_op)
				return
		if _modo_fotos and event.keycode == KEY_F:
			_alternar_visor()
			return
		if _visor:
			match event.keycode:
				KEY_ESCAPE:
					_cerrar_visor()
				KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
					_disparar()
			return
		match event.keycode:
			KEY_ESCAPE:
				_pedir_salida()
			KEY_E:
				_accion_e()
			KEY_SPACE:
				_escanear()
			KEY_H:
				_preguntar_focos()
	elif event is InputEventMouseMotion and _visor:
		var sens := 0.0022 * (_vis_fov / FOV_VISOR)
		_vis_yaw -= event.relative.x * sens
		_vis_pitch = clampf(_vis_pitch - event.relative.y * sens, deg_to_rad(-20.0), deg_to_rad(80.0))
	elif event is InputEventMouseButton and event.pressed and _visor:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_visor(0.88)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_visor(1.14)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_disparar()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom = clampf(_zoom * 0.9, 0.5, 2.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom = clampf(_zoom * 1.1, 0.5, 2.5)


func tick(delta: float) -> void:
	_n_frame += 1
	if _diario != null and is_instance_valid(_diario):
		return
	if _pausa != null and is_instance_valid(_pausa):
		return
	if _modo_captura:
		_actualizar_captura(delta)
		return

	var adelante := 0.0
	var giro := 0.0
	var turbo := false
	if activo and not _terminada and not _en_briefing and _salida == 0:
		_tiempo += delta
		if _visor:
			_actualizar_visor(delta)
	if activo and not _terminada and not _en_briefing and not _visor:
		adelante = float(_tecla(KEY_W, KEY_UP)) - float(_tecla(KEY_S, KEY_DOWN))
		giro = float(_tecla(KEY_A, KEY_LEFT)) - float(_tecla(KEY_D, KEY_RIGHT))
		turbo = Input.is_physical_key_pressed(KEY_SHIFT)
		if control_auto != Vector2.ZERO:
			adelante = control_auto.x
			giro = control_auto.y
		if _sin_energia:
			adelante = 0.0
			turbo = false
		if _salida > 0:
			giro = 0.0
			turbo = false
			adelante = 0.55 if _salida == 2 else 0.0

	if giro != 0.0:
		_fwd = _fwd.rotated(_up, giro * VEL_GIRO * delta)

	var vmax := (VEL if adelante >= 0.0 else VEL_ATRAS) * k * float(_mej["vel"])
	if turbo and adelante > 0.0:
		vmax *= TURBO
	if _eventos != null:
		vmax *= 1.0 - 0.5 * _eventos.lento
	if _riesgos and _energia < ENERGIA_BAJA:
		vmax *= lerpf(0.55, 1.0, clampf(_energia / ENERGIA_BAJA, 0.0, 1.0))
	_vel = move_toward(_vel, adelante * vmax, ACEL * k * delta)

	var se_movio := false
	if absf(_vel) > 0.0001:
		se_movio = _avanzar(_vel * delta)

	if se_movio or giro != 0.0:
		_fwd = (_fwd - _up * _fwd.dot(_up)).normalized()
		if _n_frame % 3 == 0:
			_estimar_normal(1.0 - exp(-8.0 * delta * 3.0))

	_colocar_robot()
	_animar_rover(delta, giro, adelante)
	if _dron != null:
		_alimentar_dron()
		_dron.actualizar(delta, _up)
		if _n_frame % 10 == 0:
			_dron.limpiar()
	_actualizar_energia(delta, turbo)
	_actualizar_salida(delta)
	if activo and not _terminada and not _en_briefing and _salida == 0:
		_grabar_ruta()
	_actualizar_tutorial(delta)
	_actualizar_pistas(delta)
	_actualizar_radio(delta)
	_actualizar_consultas(delta)
	_actualizar_dron_voz(delta)
	_actualizar_dilema(delta)
	_actualizar_historia(delta)
	_actualizar_dia(delta)
	_actualizar_eventos(delta)
	_actualizar_cuevas(delta)
	_actualizar_curiosidades(delta)
	_actualizar_hallazgos(delta)
	if _foto != null:
		_foto.actualizar(delta, _pos_robot)
	if _visor and _terminada:
		_cerrar_visor()
	if activo and not _terminada and not _en_briefing and _salida == 0:
		_logica(delta)
	_actualizar_flecha()
	if _cine != null and _cine.activa:
		_cine.actualizar(delta)
		if _cine != null and _cine.foto_pendiente:
			_cine.foto_pendiente = false
			_foto_archivo()
	if _eco != null:
		_eco.actualizar(delta, _pos_robot)
	_actualizar_camara(delta, false)
	_actualizar_modulos(delta, turbo)
	_actualizar_hud_vivo(delta)


func _tecla(a: Key, b: Key) -> bool:
	return Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)


func _actualizar_cuevas(delta: float) -> void:
	var objetivo := 0.0
	for c in _cuevas:
		var f: float = c.factor_dentro(_up)
		c.actualizar(f)
		objetivo = maxf(objetivo, f)
	_dentro = lerpf(_dentro, objetivo, 1.0 - exp(-4.0 * delta))
	if _dentro > 0.6 and not _consejo_cueva:
		_consejo_cueva = true
		_consejo("cueva")


	sol_dir = _sol_real.slerp(-_up, clampf(_dentro, 0.0, 1.0) * 0.92)
	if _luz != null:
		_luz.light_energy = _luz_energia_base * lerpf(1.0, 0.22, _dentro) * (1.0 - 0.4 * _tormenta_f) * (1.0 - 0.55 * _ecl_f) * lerpf(0.32, 1.0, dia_f)


func _suelo_pesos(delta: float) -> Vector3:
	if _rn_suelo == null:
		_rn_suelo = FastNoiseLite.new()
		_rn_suelo.seed = semilla * 5 + 1
		_rn_suelo.frequency = 0.012
	_suelo_t -= delta
	if _suelo_t > 0.0:
		return _suelo_pes
	_suelo_t = 0.12
	var p := _up * (planet.radius / k)
	var a := _rn_suelo.get_noise_3dv(p)
	var b := _rn_suelo.get_noise_3dv(p + Vector3(931.0, 47.0, 211.0))
	var arena := smoothstep(-0.05, 0.3, a)
	var roca := smoothstep(0.1, 0.45, b) * (1.0 - arena)
	for i in range(_rocas_dir.size()):
		if _arco(_up, _rocas_dir[i]) - _rocas_r[i] < 2.5 * k:
			roca = maxf(roca, 0.85)
			break
	roca = maxf(roca, clampf(_dentro, 0.0, 1.0))
	arena *= 1.0 - clampf(_dentro, 0.0, 1.0)
	arena *= 1.0 - roca * 0.6
	var grava := maxf(1.0 - arena - roca, 0.12)
	var objetivo := Vector3(grava, arena, roca) / (grava + arena + roca)
	_suelo_pes = _suelo_pes.lerp(objetivo, 0.35)
	return _suelo_pes


func _actualizar_modulos(delta: float, turbo: bool) -> void:
	if _hangar != null:
		_hangar.actualizar(delta, _pos_robot)
	var alt_cam := _cam_pos_s.length() - (planet.radius + _cam_h_terreno)
	_ambiente.actualizar(delta, _pos_robot, _up, _vel / (VEL * k), alt_cam, _dentro)
	if _clima != null:
		_clima.actualizar(delta, _tormenta_f, _dentro, dia_f, _ambiente.viento_actual)
	_suelo.actualizar(delta, _up, _pos_robot, _up, _fwd, _vel)
	_fx.actualizar(delta, _pos_robot)
	_actualizar_faro()
	if activo:
		var prox := 0.0
		if _senal_t > 0.0:
			var o := _muestra_mas_cercana()
			if o != null:
				var d := _arco(_up, o.get_meta("dir")) / k
				if d < 14.0:
					prox = 1.0 - d / 14.0
		_audio.actualizar(delta, clampf(_vel / (VEL * k), -1.0, 1.0), turbo, _dentro,
				_ambiente.viento_actual, prox, _suelo_pesos(delta), _ambiente.remolino_prox)
		if _musica != null:
			_musica.actualizar(delta, {"energia": (_energia / 100.0) if _riesgos else 1.0,
					"noche": 1.0 - _ciclo.luz() if _ciclo != null else 0.0, "tormenta": _tormenta_f,
					"cueva": _dentro, "final": _terminada})


func _actualizar_energia(delta: float, turbo: bool) -> void:
	if not _riesgos or _terminada or _en_briefing or not activo:
		return
	_actualizar_tormenta(delta)
	var en_base := _arco(_up, _up_b) < RADIO_BASE * k
	var mov := absf(_vel) / k
	if mov > 0.05:
		var coste: float = mov * delta * ENERGIA_POR_GM * [0.6, 1.0, 1.5][_dif]
		if turbo and _vel > 0.0:
			coste *= COSTE_TURBO
		var incl := acos(clampf(_normal.dot(_up), -1.0, 1.0))
		coste *= 1.0 + COSTE_PENDIENTE * float(_mej["pendiente"]) * clampf(tan(incl), 0.0, 1.0)
		coste *= 1.0 + 0.5 * _tormenta_f
		coste *= 1.0 + 0.15 * (1.0 - dia_f)
		coste *= _mult_consumo
		_energia -= coste
	var tasa := 0.0
	if en_base:
		tasa = RECARGA_BASE
	elif _hangar != null and _salida == 0 and mov < 0.3 and _hangar.en_recarga(_pos_robot):
		tasa = RECARGA_HANGAR
	elif mov < 0.3:
		tasa = RECARGA_QUIETO * (1.0 - _tormenta_f) * (1.0 - clampf(_dentro, 0.0, 1.0)) * dia_f * (1.0 - 0.6 * _ecl_f)
	tasa *= [1.4, 1.0, 0.8][_dif] * float(_mej["recarga"])
	_energia = clampf(_energia + tasa * delta, 0.0, 100.0)
	_energia_min = minf(_energia_min, _energia)

	if not _sin_energia and _energia <= 0.0:
		_sin_energia = true
		_hud.toast("Batería agotada", "El robot se detiene. Espera a que el Sol (o la base) la recargue; con tormenta no se puede.",
				Color(1.0, 0.4, 0.35), 7.0)
		_audio.agotada()
	elif _sin_energia and _energia >= ENERGIA_ARRANQUE:
		_sin_energia = false
		_hud.toast("Batería recuperada", "El robot puede moverse otra vez.", Color(0.35, 1.0, 0.5), 4.0)
		_audio.bueno()
	if _energia > ENERGIA_BAJA + 5.0:
		_aviso_bateria = 0
	elif _energia < ENERGIA_BAJA and _aviso_bateria == 0:
		_aviso_bateria = 1
		_hud.toast("Batería baja", "Modo ahorro: el robot va más lento. Evita el turbo y las cuestas, o párate a recargar.",
				Color(1.0, 0.72, 0.25), 6.0)
		_audio.aviso()
		_radio("bateria_baja", true)


func _radio(evento: String, forzar: bool = false) -> void:
	if not Ajustes.radio or _tut_activo or _terminada or _en_briefing:
		return
	if _radio_cd > 0.0 and not forzar:
		return
	var m := Historia.radio(evento, _radio_n)
	if m.is_empty():
		return
	_radio_n += 1
	var inf := Historia.jefe(str(m["j"]))
	_hud.toast("RADIO  ·  %s" % Historia.titulo(str(m["j"])), "«%s»" % str(m["t"]),
			inf.get("color", Color.WHITE), 5.0)
	_hablar(str(m["j"]), str(m["t"]))
	_radio_cd = 25.0


func _puede_consultar() -> bool:
	return activo and not _terminada and not _en_briefing and not _tut_activo and not _visor and not _modo_captura \
			and not _dilema_activo and _elec.is_empty() and _salida == 0 \
			and (_pausa == null or not is_instance_valid(_pausa))


func _crear_consulta() -> void:
	if _consulta != null and is_instance_valid(_consulta):
		return
	var r := ConsultaRadio.retraso_de(id_mision)
	_consulta = ConsultaRadio.new()
	_consulta.retraso = float(r["seg"])
	_consulta.min_luz = float(r["min_luz"])
	add_child(_consulta)
	_consulta.preguntar.connect(_preguntar_jefe)


func _alternar_consulta() -> void:
	_crear_consulta()
	if _consulta.abierta():
		_consulta.cerrar()
		return
	_consulta.refrescar(_estados_consulta())
	_consulta.abrir()


func _estados_consulta() -> Dictionary:
	var e := {}
	for j in ConsultaRadio.JEFES:
		e[j] = {"pend": -1.0, "cd": float(_cons_cd.get(j, 0.0))}
	for p in _cons_pend:
		e[str(p["j"])]["pend"] = float(p["resta"])
	return e


func _objeto_cercano() -> Dictionary:
	var mejor: Node3D = null
	var d_min := INF
	for o in _objetos:
		if not is_instance_valid(o):
			continue
		var d := _arco(_up, o.get_meta("dir"))
		if d < d_min:
			d_min = d
			mejor = o
	if mejor == null:
		return {}
	var info := DatosMarte.material(str(mejor.get_meta("mat")))
	var r := _rel(mejor.get_meta("dir"))
	return {"obj": mejor, "dir": mejor.get_meta("dir"), "nombre": str(info["nombre"]),
			"pista": str(info.get("pista", "")), "dist": d_min / k, "ang": atan2(r.x, r.y)}


func _foto_consulta() -> Dictionary:
	var s := {"energia": _energia, "storm": _tormenta_estado, "bodega": _bodega.size(), "cap": capacidad}
	var o := _objeto_cercano()
	if not o.is_empty():
		s["obj"] = o["obj"]
		s["obj_dir"] = o["dir"]
		s["obj_nombre"] = o["nombre"]
		s["obj_pista"] = o["pista"]
		s["obj_dist"] = o["dist"]
		s["obj_ang"] = o["ang"]
	var rb := _rel(_up_b)
	s["base_dist"] = distancia_gm(_up, _up_b)
	s["base_ang"] = atan2(rb.x, rb.y)
	var d_min := INF
	for h in _hallazgos:
		if not is_instance_valid(h) or h.visible or bool(h.get_meta("recogido")):
			continue
		var d := _arco(_up, h.get_meta("dir"))
		if d < d_min:
			d_min = d
			var rh := _rel(h.get_meta("dir"))
			s["hall_dir"] = h.get_meta("dir")
			s["hall_dist"] = d / k
			s["hall_ang"] = atan2(rh.x, rh.y)
	return s


func _preguntar_jefe(j: String) -> void:
	if _cons_pend.size() >= ConsultaRadio.MAX_PENDIENTES:
		_hud.toast("Radio ocupada", "Espera a que lleguen las respuestas que ya vienen en camino.", Color(1.0, 0.72, 0.25), 4.0)
		return
	for p in _cons_pend:
		if str(p["j"]) == j:
			return
	if float(_cons_cd.get(j, 0.0)) > 0.0:
		return
	_cons_pend.append({"j": j, "resta": _consulta.retraso, "snap": _foto_consulta()})
	_consultas_n += 1
	MetaEstado.extra_set("consultas", int(MetaEstado.extra_get("consultas", 0)) + 1)
	_hud.toast("RADIO  ·  consulta a %s" % Historia.titulo(j), "Enviada. La respuesta tardará unos %d s en volver." % int(round(_consulta.retraso)),
			_color_jefe(j), 4.0)
	_consulta.refrescar(_estados_consulta())


func _responder_consulta(p: Dictionary) -> void:
	var j := str(p["j"])
	var s: Dictionary = p["snap"]
	var ahora := _foto_consulta()
	var a := {"energia": _energia, "storm": _tormenta_estado, "bodega": _bodega.size(), "cap": capacidad,
			"sin_energia": _sin_energia, "escaner_roto": _escaner_roto, "base_dir": _up_b}
	if _riesgos and _tormenta_estado == 0 and _tormenta_prox < 5000.0:
		a["storm_en"] = _tormenta_prox - _tiempo
	a["obj_vivo"] = s.has("obj") and is_instance_valid(s["obj"]) and _objetos.has(s["obj"])
	if ahora.has("obj_dir"):
		a["obj2_dir"] = ahora["obj_dir"]
		a["obj2_nombre"] = ahora["obj_nombre"]
		a["obj2_dist"] = ahora["obj_dist"]
	var r := ConsultaRadio.respuesta(j, s, a, _n_frame + int(_tiempo * 10.0))
	_hud.toast("RADIO  ·  %s" % Historia.titulo(j), "«%s»" % str(r["texto"]), _color_jefe(j), 10.0)
	_hablar(j, str(r["texto"]))
	_audio.bueno()
	if r["dir"] != Vector3.ZERO:
		_luz_de_radio(r["dir"], r["color"], float(r["seg"]))
	_cons_cd[j] = ConsultaRadio.ENFRIAMIENTO


func _luz_de_radio(dir: Vector3, color: Color, seg: float) -> void:
	while _balizas.size() >= 3:
		var viejo: Dictionary = _balizas.pop_front()
		if is_instance_valid(viejo["nodo"]):
			(viejo["nodo"] as Node3D).queue_free()
	_balizas.append({"nodo": _crear_marca_sec(dir, color), "t": seg})


func _actualizar_consultas(delta: float) -> void:
	if not _balizas.is_empty():
		for b in _balizas.duplicate():
			var nodo: Node3D = b["nodo"]
			b["t"] = float(b["t"]) - delta
			if not is_instance_valid(nodo) or float(b["t"]) <= 0.0:
				if is_instance_valid(nodo):
					nodo.queue_free()
				_balizas.erase(b)
				continue
			var g: MeshInstance3D = nodo.get_meta("gema")
			g.rotation.y += delta * 1.6
			g.position.y = 2.8 + 0.25 * sin(_tiempo * 3.0)
	if not activo or _terminada:
		return
	if not _cons_consejo and _tiempo > 90.0 and not _en_briefing:
		_cons_consejo = true
		_consejo("radio")
	if _consulta == null or not is_instance_valid(_consulta):
		return
	for j in _cons_cd.keys():
		_cons_cd[j] = maxf(float(_cons_cd[j]) - delta, 0.0)
	for p in _cons_pend.duplicate():
		p["resta"] = float(p["resta"]) - delta
		if float(p["resta"]) <= 0.0:
			_cons_pend.erase(p)
			_responder_consulta(p)
	if _consulta.abierta() and not _puede_consultar():
		_consulta.cerrar()
	_cons_acum += delta
	if _cons_acum >= 0.25 and (_consulta.abierta() or not _cons_pend.is_empty()):
		_cons_acum = 0.0
		_consulta.refrescar(_estados_consulta())


func _actualizar_radio(delta: float) -> void:
	if not activo or _terminada or _en_briefing:
		return
	_radio_cd = maxf(_radio_cd - delta, 0.0)
	if absf(_vel) / k < 0.05 and not _visor and _dentro < 0.3:
		_quieto_t += delta
		if _quieto_t > 55.0:
			_quieto_t = -50.0
			_radio("quieto")
	else:
		_quieto_t = minf(_quieto_t, 0.0) if _quieto_t < 0.0 else 0.0
	if _dentro > 0.6 and not _radio_cueva:
		_radio_cueva = true
		_radio("cueva")
	if not _radio_mitad and total_objetos >= 4 and _entregados * 2 >= total_objetos:
		_radio_mitad = true
		_radio("mitad")


func _texto_rumbo(dir: Vector3) -> String:
	var d := _arco(_up, dir) / k
	var t := (dir - _up * dir.dot(_up)).normalized()
	var ang := rad_to_deg(atan2(t.dot(_up.cross(_fwd)), t.dot(_fwd)))
	var lado := Idioma.t("delante")
	if absf(ang) > 145.0:
		lado = Idioma.t("detrás")
	elif absf(ang) > 35.0:
		lado = Idioma.t("a tu izquierda") if ang > 0.0 else Idioma.t("a tu derecha")
	var m := int(round(d / 10.0) * 10.0) if d < 1000.0 else int(round(d / 100.0) * 100.0)
	return Idioma.t("a unos %d m, %s" % [m, lado])


func _actualizar_pistas(delta: float) -> void:
	if int(Ajustes.pistas) <= 0 or not activo or _terminada or _en_briefing or _tut_activo or _visor or _dilema_activo or _modo_fotos:
		return
	var huella := Vector3(_ruta_dist, float(_bodega.size()) + float(_entregados) * 7.0, _senal_t)
	if absf(huella.x - _pista_huella.x) > 20.0 or huella.y != _pista_huella.y or (huella.z > 0.0 and _pista_huella.z <= 0.0):
		_pista_huella = huella
		_pista_t = 0.0
		return
	_pista_t += delta
	if _pista_t < 60.0:
		return
	_pista_t = 25.0
	var txt := ""
	if _entregados >= total_objetos:
		return
	if not _bodega.is_empty() and _entregados + _bodega.size() >= total_objetos or _bodega.size() >= capacidad:
		txt = Idioma.t("Llevas muestras: la base B está %s. Entra en su zona para entregarlas.") % _texto_rumbo(_up_b)
	elif _pista_n % 2 == 0 or _objetos.is_empty():
		txt = Idioma.t("Pulsa ESPACIO para escanear: las muestras cercanas se revelan con un destello.")
	else:
		var o := _muestra_mas_cercana()
		if o != null:
			txt = Idioma.t("Pista: la muestra más cercana está %s.") % _texto_rumbo(o.get_meta("dir"))
	if _riesgos and _energia < 30.0 and _tormenta_estado != 2:
		txt = Idioma.t("Batería baja: vuelve a la base o espera al Sol para recargarla.")
	_pista_n += 1
	if txt != "":
		_hud.toast(Idioma.t("Pista"), txt, Color(0.55, 0.85, 1.0), 9.0)


func _actualizar_tutorial(delta: float) -> void:
	if not _tut_activo or not activo or _terminada or _en_briefing or _salida > 0:
		return
	if _tut_fin_t > 0.0:
		_tut_fin_t -= delta
		if _tut_fin_t <= 0.0:
			_terminar_tutorial()
		return
	var n := Historia.TUTORIAL.size()
	var hecho := false
	match _tut_paso:
		0: hecho = _ruta_dist >= 4.0
		1: hecho = _tut_escaneo
		2: hecho = _entregados > 0
	_hud.mostrar_tutorial(str(Historia.TUTORIAL[_tut_paso]), _tut_paso + 1, n)
	if hecho:
		_audio.paso()
		_tut_paso += 1
		if _tut_paso >= n - 1:
			_tut_paso = n - 1
			_hud.mostrar_tutorial(str(Historia.TUTORIAL[_tut_paso]), n, n)
			_tut_fin_t = 7.0


func _terminar_tutorial() -> void:
	_tut_activo = false
	_tut_fin_t = 0.0
	_hud.ocultar_tutorial()
	Ajustes.tutorial_hecho = true
	Ajustes.guardar()


func _actualizar_dilema(delta: float) -> void:
	if _dilema_hecho or _terminada or _en_briefing or _visor or not activo or _tut_activo:
		return
	if not Comite.SITIOS.has(id_mision):
		_dilema_hecho = true
		return
	if _dilema_activo:
		_dilema_t -= delta
		if _dilema_t <= 0.0:
			_dilema_activo = false
			_dilema_hecho = true
			_hud.ocultar_dilema()
			_hud.toast("Sin respuesta", "El tiempo se acabó y seguiste adelante sin decidir.", Color(0.8, 0.8, 0.8), 5.0)
		return
	if _tiempo > 40.0 and _ruta_dist > 15.0 and _dentro < 0.3 and not _hud.briefing_abierto() and _elec.is_empty():
		_dilema = Historia.dilema(id_mision)
		_dilema_activo = true
		_dilema_t = [45.0, 30.0, 20.0][_dif]
		_hud.mostrar_dilema(_dilema, _riesgos)
		_audio.decision()
		_hablar(str(_dilema["j"]), str(_dilema["t"]))


func _resolver_dilema(i: int) -> void:
	var op: Dictionary = _dilema["a" if i == 0 else "b"]
	_dilema_activo = false
	_dilema_hecho = true
	_hud.ocultar_dilema()
	var coste := float(op.get("coste", 0))
	if _riesgos and coste > 0.0:
		_energia = maxf(_energia - coste, 1.0)
	Comite.bono_fijar(id_mision, str(op.get("crit", "")), int(op.get("d", 0)))
	_dilema_resp = "%s: %s" % [Historia.titulo(str(_dilema["j"])), str(op.get("txt", ""))]
	_hist_cd = 20.0
	_cambiar_conf(str(_dilema["j"]), int(op.get("conf", 0)))
	var ef: Variant = op.get("ef", null)
	if ef is Dictionary:
		var e: Dictionary = (ef as Dictionary).duplicate()
		e["de"] = id_mision
		HistoriaEstado.agregar_efecto(e)
		_hist_lineas.append("Consecuencia para la próxima misión: %s" % str(e.get("txt", "")))
	var inf := Historia.jefe(str(_dilema["j"]))
	_hud.toast("Decisión de %s" % Historia.titulo(str(_dilema["j"])), str(op.get("res", "")),
			inf.get("color", Color.WHITE), 7.0)
	_audio.decision_resultado(int(op.get("d", 0)))


func _hash_id() -> int:
	var h := 0
	for i in range(id_mision.length()):
		h = (h * 31 + id_mision.unicode_at(i)) % 100003
	return h


func _color_jefe(j: String) -> Color:
	var inf := Historia.jefe(j)
	return inf.get("color", Color.WHITE)


func _aplicar_historia() -> void:
	_ventajas = HistoriaEstado.ventajas()
	capacidad = clampi(capacidad + int(_ventajas["carga"]), 1, 6)
	_alcance_esc = ALCANCE_ESCANER * (1.0 + float(_ventajas["escaner"]))
	_mult_consumo = 1.0 + float(_ventajas["consumo"])
	_mej = Mejoras.efectos()
	capacidad = clampi(capacidad + int(_mej["capacidad"]), 1, 6)
	_alcance_esc *= float(_mej["alcance"])
	_mult_consumo *= float(_mej["consumo"])
	if _tut_activo or _exp:
		return
	for e in HistoriaEstado.tomar_efectos():
		var v := float((e as Dictionary).get("v", 0.0))
		match str((e as Dictionary).get("k", "")):
			"escaner": _alcance_esc *= 1.0 + v
			"consumo": _mult_consumo *= 1.0 + v
			"carga": capacidad = clampi(capacidad + int(v), 1, 6)
		_consec_txt.append(str((e as Dictionary).get("txt", "")))


func _lineas_arrastra() -> Array[String]:
	var lineas: Array[String] = []
	for t in _consec_txt:
		lineas.append("· " + t)
	var vent: Array[String] = []
	for v in (_ventajas.get("lista", []) as Array):
		vent.append("%s: %s" % [str(v["j"]), str(v["txt"]).to_lower()])
	if not vent.is_empty():
		lineas.append(Idioma.t("· Confían en ti  —  %s") % "  ·  ".join(vent))
	var taller := Mejoras.resumen()
	if taller != "":
		lineas.append("· Taller: " + taller)
	return lineas


func _cambiar_conf(jefe: String, d: int) -> void:
	if d == 0:
		return
	var antes := HistoriaEstado.nivel(jefe)
	HistoriaEstado.cambiar_conf(jefe, d)
	_hist_lineas.append("Confianza con %s: %s%d" % [jefe, "+" if d > 0 else "", d])
	var despues := HistoriaEstado.nivel(jefe)
	var col := _color_jefe(jefe)
	if antes != "alta" and despues == "alta":
		var v: Dictionary = HistoriaExtra.VENTAJAS[jefe]
		_hist_lineas.append("¡%s confía plenamente en ti! Ventaja desde la próxima misión: %s" % [jefe, str(v["txt"]).to_lower()])
		get_tree().create_timer(2.6).timeout.connect(func():
			if is_instance_valid(_hud):
				_hud.toast("¡%s confía plenamente en ti!" % jefe, "Desde la próxima misión: %s." % str(v["txt"]).to_lower(), col, 9.0)
				_audio.medalla())
	elif antes != "baja" and despues == "baja":
		_hist_lineas.append("%s está molesto contigo." % jefe)
		get_tree().create_timer(2.6).timeout.connect(func():
			if is_instance_valid(_hud):
				_hud.toast("%s está molesto contigo" % jefe, "Pierde confianza en tu criterio. Cuida lo que le contestas.", col, 7.0))


func _actualizar_historia(delta: float) -> void:
	if _terminada:
		_radio_limpiar()
		return
	if _en_briefing or not activo or _tut_activo or _visor or _exp:
		return
	_radio_actualizar(delta)
	if not _elec.is_empty():
		return
	_hist_cd = maxf(_hist_cd - delta, 0.0)
	_actualizar_sec(delta)
	if not _radio_cola.is_empty() or _dilema_activo or _hist_cd > 0.0 or _dentro > 0.3 or _hud.briefing_abierto() or _tormenta_estado == 2:
		return
	if not _sec_ofrecida and _tiempo > 70.0 and _ruta_dist > 25.0 and (_dilema_hecho or not Comite.SITIOS.has(id_mision)) \
			and str(datos.get("tipo", "")) != "fotos":
		_ofrecer_secundaria()
	elif not _charla_hecha and _tiempo > 130.0 and _ruta_dist > 40.0:
		_ofrecer_charla()


var _elec_tipo_prev: String = ""


func _radio_encolar(tipo: String, titulo: String, jefe: String, texto: String, ops: Array, pie: String) -> void:
	_radio_cola.append({"tipo": tipo, "titulo": titulo, "j": jefe, "texto": texto, "ops": ops, "pie": pie})
	_audio.decision()
	_radio_actualizar_aviso()


func _radio_actualizar_aviso() -> void:
	if _radio_cola.is_empty() or _radio_panel != null:
		_hud.radio_aviso_ocultar()
		return
	var m: Dictionary = _radio_cola[0]
	_hud.radio_aviso(str(m["j"]), _radio_cola.size())


func _radio_abrir() -> void:
	if _radio_cola.is_empty() or _radio_panel != null:
		return
	var m: Dictionary = _radio_cola[0]
	_radio_cola.remove_at(0)
	_radio_msg = m
	_elec = {"tipo": str(m["tipo"]), "j": str(m["j"]), "n": (m["ops"] as Array).size()}
	var pn := RadioPanel.new()
	pn.configurar(str(m["j"]), str(m["titulo"]), str(m["texto"]), m["ops"], str(m["pie"]))
	pn.elegida.connect(_resolver_eleccion)
	pn.guardada.connect(_radio_guardar)
	add_child(pn)
	_radio_panel = pn
	_radio_quieto = 0.0
	_radio_mov = 0.0
	_hud.radio_aviso_ocultar()
	_hablar(str(m["j"]), str(m["texto"]))


func _radio_guardar() -> void:
	if _radio_panel == null:
		return
	if is_instance_valid(_radio_panel):
		_radio_panel.cerrar()
	_radio_panel = null
	if not _radio_msg.is_empty():
		_radio_cola.push_front(_radio_msg)
	_radio_msg = {}
	_elec = {}
	_radio_quieto = -2.0
	_radio_actualizar_aviso()


func _radio_actualizar(delta: float) -> void:
	var rapido := absf(_vel) / k > 1.0
	if _radio_panel != null:
		if is_instance_valid(_radio_panel):
			_radio_mov = _radio_mov + delta if rapido else 0.0
			if _radio_mov > 2.5:
				_radio_guardar()
		return
	if _radio_cola.is_empty():
		return
	if absf(_vel) / k < 0.15 and _dentro < 0.3 and not _dilema_activo:
		_radio_quieto += delta
	else:
		_radio_quieto = minf(_radio_quieto, 0.0)
	if _radio_quieto > 1.2:
		_radio_abrir()


func _radio_limpiar() -> void:
	if _radio_panel != null and is_instance_valid(_radio_panel):
		_radio_panel.cerrar()
	_radio_panel = null
	_radio_cola.clear()
	_radio_msg = {}
	_elec = {}
	_hud.radio_aviso_ocultar()


func _cerrar_eleccion() -> void:
	_elec_tipo_prev = str(_elec.get("tipo", ""))
	_elec = {}
	if _radio_panel != null and is_instance_valid(_radio_panel):
		_radio_panel.cerrar()
	_radio_panel = null
	_radio_msg = {}
	_hud.ocultar_dilema()
	_hist_cd = 20.0
	_radio_actualizar_aviso()


func _ofrecer_secundaria() -> void:
	_sec_ofrecida = true
	var j: String = HistoriaEstado.JEFES[(_hash_id() + 2) % HistoriaEstado.JEFES.size()]
	var dist := _rng.randf_range(55.0, 95.0)
	var d := dir_lejana(dist, _rng.randf_range(0.0, TAU))
	_sec = {"j": j, "dir": d, "t": float(HistoriaExtra.SEC_TIEMPO[_dif]), "estado": 0, "dist": dist}
	var texto := str((HistoriaExtra.SECUNDARIAS[j] as Dictionary)["pedido"]) % int(dist)
	_radio_encolar("sec", "MISIÓN SECUNDARIA", j, texto,
			["Ir al punto marcado en el radar", "Ahora no"], "Pulsa 1 o 2  ·  R: guardar para luego. Cumplirla sube la confianza de %s." % j)


func _ofrecer_charla() -> void:
	_charla_hecha = true
	var n := _hash_id()
	var ch := HistoriaExtra.charla(n)
	if str(ch["j"]) == str(_dilema.get("j", "")):
		ch = HistoriaExtra.charla(n + 2)
	_radio_encolar("charla", "CHARLA POR RADIO", str(ch["j"]), str(ch["t"]),
			["(Serio)  " + str(ch["serio"]), "(Bromista)  " + str(ch["bromista"]), "(Técnico)  " + str(ch["tecnico"])],
			"Pulsa 1, 2 o 3  ·  R: guardar para luego. Cada jefe prefiere un tono distinto.")


func _resolver_eleccion(i: int) -> void:
	var tipo := str(_elec.get("tipo", ""))
	var j := str(_elec.get("j", ""))
	_cerrar_eleccion()
	if tipo == "sec":
		if i == 0:
			_sec["estado"] = 1
			_sec["nodo"] = _crear_marca_sec(_sec["dir"], _color_jefe(j))
			_hud.toast("Punto marcado", "Mira el radar: llega a menos de %d m antes de que se acabe el tiempo." % int(HistoriaExtra.SEC_ALCANCE),
					_color_jefe(j), 6.0)
			_audio.paso()
		else:
			HistoriaEstado.sec_fijar(id_mision, "no")
			_sec = {}
			_hud.toast("Petición rechazada", "%s lo entiende. Quizá otra vez." % j, Color(0.8, 0.8, 0.8), 4.0)
	elif tipo == "charla":
		var tono: String = ["serio", "bromista", "tecnico"][i]
		var delta := HistoriaExtra.preferencia(j, tono)
		var rep := HistoriaExtra.replica(j, tono)
		HistoriaEstado.charla_fijar(id_mision, j, tono)
		_cambiar_conf(j, delta)
		var signo := "+" if delta > 0 else ""
		_hud.toast("%s  ·  confianza %s%d" % [Historia.titulo(j), signo, delta], "«%s»" % rep, _color_jefe(j), 7.0)
		_hablar(j, rep)
		if delta > 0:
			_audio.bueno()
		elif delta < 0:
			_audio.malo_corto()


func _actualizar_sec(delta: float) -> void:
	if _sec.is_empty() or int(_sec.get("estado", 0)) != 1:
		return
	var nodo: Node3D = _sec.get("nodo", null)
	if nodo != null and is_instance_valid(nodo):
		var g: MeshInstance3D = nodo.get_meta("gema")
		g.rotation.y += delta * 1.6
		g.position.y = 2.8 + 0.25 * sin(_tiempo * 3.0)
	_sec["t"] = float(_sec["t"]) - delta
	if distancia_gm(_up, _sec["dir"]) <= HistoriaExtra.SEC_ALCANCE:
		_cumplir_sec()
	elif float(_sec["t"]) <= 0.0:
		_quitar_marca_sec()
		_sec["estado"] = 3
		HistoriaEstado.sec_fijar(id_mision, "tarde")
		_hud.toast("Se acabó el tiempo", "No llegaste al punto. %s lo deja para otra ocasión." % str(_sec["j"]), Color(1.0, 0.72, 0.25), 6.0)
		_audio.malo_corto()


func _cumplir_sec() -> void:
	var j := str(_sec["j"])
	_sec["estado"] = 2
	_quitar_marca_sec()
	var ok := str((HistoriaExtra.SECUNDARIAS[j] as Dictionary)["ok"])
	HistoriaEstado.sec_fijar(id_mision, "ok")
	_cambiar_conf(j, HistoriaExtra.SEC_CONF)
	if _riesgos:
		_energia = minf(_energia + HistoriaExtra.SEC_BATERIA, 100.0)
	_hito_ruta("suceso")
	_hist_lineas.append("Misión secundaria cumplida (%s)" % j)
	var col := _color_jefe(j)
	_hud.toast("Misión secundaria cumplida", "«%s»  (+%d de confianza)" % [ok, HistoriaExtra.SEC_CONF], col, 8.0)
	_audio.bueno()
	_hablar(j, ok)


func _quitar_marca_sec() -> void:
	var nodo: Node3D = _sec.get("nodo", null)
	if nodo != null and is_instance_valid(nodo):
		nodo.queue_free()
	_sec["nodo"] = null


func _crear_marca_sec(dir: Vector3, color: Color) -> Node3D:
	var raiz := _anclar_en(dir)
	var sm := SphereMesh.new()
	sm.radial_segments = 4
	sm.rings = 2
	sm.radius = 0.6
	sm.height = 1.2
	var gema := MeshInstance3D.new()
	gema.mesh = sm
	gema.material_override = _mat(color, true, 2.6)
	gema.scale = Vector3(0.9, 1.5, 0.9)
	gema.position = Vector3(0.0, 2.8, 0.0)
	gema.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(gema)
	var aro := TorusMesh.new()
	aro.inner_radius = HistoriaExtra.SEC_ALCANCE - 0.2
	aro.outer_radius = HistoriaExtra.SEC_ALCANCE
	aro.rings = 40
	aro.ring_segments = 6
	var mi_aro := MeshInstance3D.new()
	mi_aro.mesh = aro
	mi_aro.material_override = _mat(color, true, 1.4)
	mi_aro.position = Vector3(0.0, 0.1, 0.0)
	mi_aro.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(mi_aro)
	_columna_luz(raiz, color, 18.0)
	raiz.set_meta("gema", gema)
	return raiz


func _alternar_diario() -> void:
	if _diario != null and is_instance_valid(_diario):
		_diario.queue_free()
		_diario = null
		return
	var d := PantallaDiario.new()
	d.contexto = _contexto_diario()
	d.cerrada.connect(func(): _diario = null)
	add_child(d)
	_diario = d


func _contexto_diario() -> Dictionary:
	var s := "Sin pedir"
	if not _sec.is_empty():
		s = ["Pedida", "En curso: %d m" % int(distancia_gm(_up, _sec["dir"])), "Cumplida", "Fuera de tiempo"][clampi(int(_sec.get("estado", 0)), 0, 3)]
	elif _sec_ofrecida:
		s = "Rechazada"
	return {
		"id": id_mision, "nombre": nombre, "entregados": _entregados, "total": total_objetos, "en_bodega": _bodega.size(),
		"tiempo": _formato_tiempo(_tiempo), "energia": _energia if _riesgos else -1.0,
		"secundaria": s, "charla": "Hecha" if _charla_hecha else "Pendiente", "radio": _radio_cola.size() + (1 if _radio_panel != null else 0),
		"dilema": _dilema_resp, "eventos": _eventos.vividos if _eventos != null else 0,
		"consecuencias": _consec_txt, "hist": _hist_lineas,
	}


func _aplicar_condicion() -> void:
	if str(datos.get("condicion", "")) == "tormenta" and _riesgos:
		_tormenta_estado = 2
		_tormenta_t = 95.0 * [0.7, 1.0, 1.3][_dif]
		_tormenta_prox = 9999.0
		_tormenta_cond = true


func _actualizar_tormenta(delta: float) -> void:
	if _tormenta_estado == 2:
		_c_tormenta = true
	match _tormenta_estado:
		0:
			if _tiempo >= _tormenta_prox:
				_tormenta_estado = 1
				_tormenta_t = 14.0
				_hud.toast("Tormenta de polvo", "Se acerca una tormenta. Mientras dure, el Sol no recargará la batería.",
						Color(1.0, 0.72, 0.25), 9.0)
				_audio.aviso()
				_radio("tormenta", true)
		1:
			_tormenta_t -= delta
			if _tormenta_t <= 0.0:
				_tormenta_estado = 2
				_tormenta_t = _rng.randf_range(40.0, 55.0) * [0.7, 1.0, 1.3][_dif]
		2:
			_tormenta_t -= delta
			if _tormenta_t <= 0.0:
				_tormenta_estado = 0
				_tormenta_prox = _tiempo + _rng.randf_range(160.0, 260.0) * [1.6, 1.0, 0.7][_dif]
				if _tormenta_cond:
					_tormenta_cond = false
					_tormenta_prox = _tiempo + 70.0
				_hud.toast("La tormenta pasó", "El Sol vuelve a cargar la batería.", Color(0.35, 1.0, 0.5), 5.0)
				_audio.paso()
	var objetivo := 1.0 if _tormenta_estado == 2 else (0.25 if _tormenta_estado == 1 else 0.0)
	_tormenta_f = move_toward(_tormenta_f, objetivo, delta / 6.0)
	if _ambiente != null:
		_ambiente.tormenta = _tormenta_f
		_ambiente.muro_obj = 1.0 if _tormenta_estado == 2 else (0.65 if _tormenta_estado == 1 else 0.0)
	if _audio != null:
		_audio.tormenta(_tormenta_f)


func _uv_actual() -> Vector2:
	var d := _up - site_up
	return Vector2(d.dot(_f0), d.dot(_perp)) * (planet.radius / k)


func _grabar_ruta() -> void:
	var p := _uv_actual()
	if _ruta.is_empty():
		_ruta.append(p)
		_ruta_ult = p
		return
	var d := p.distance_to(_ruta_ult)
	if d >= 2.0:
		_ruta.append(p)
		_ruta_dist += d
		_ruta_ult = p


func _hito_ruta(tipo: String) -> void:
	var p := _uv_actual()
	_ruta_eventos.append({"u": p.x, "v": p.y, "t": tipo})


func _avanzar(paso: float) -> bool:
	var cand := _mover(_up, _fwd, paso)
	cand = _resolver_rocas(cand)
	var h_nueva := _altura(cand)
	var d := maxf((cand - _up).length() * planet.radius, absf(paso) * 0.25)
	d = maxf(d, 0.000001)
	if (h_nueva - _h) / d > PENDIENTE_MAX:
		_vel = 0.0
		return false
	_up = cand
	_h = h_nueva
	return true


func _resolver_rocas(cand: Vector3) -> Vector3:
	var r_robot := 1.3 * k
	for i in range(_rocas_dir.size()):
		var diff := cand - _rocas_dir[i]
		var dist := diff.length() * planet.radius
		var minimo := _rocas_r[i] + r_robot
		if dist < minimo and dist > 0.0000001:
			cand = (cand + diff.normalized() * ((minimo - dist) / planet.radius)).normalized()
	return cand


func _estimar_normal(a: float) -> void:
	var f := (_fwd - _up * _fwd.dot(_up)).normalized()
	var derecha := f.cross(_up).normalized()
	var e := 0.8 * k
	var dhf := _altura(_mover(_up, f, e)) - _h
	var dhr := _altura(_mover(_up, derecha, e)) - _h
	var nt := (_up - f * (dhf / e) - derecha * (dhr / e)).normalized()
	_normal = _normal.lerp(nt, a).normalized()


func _animar_rover(delta: float, giro: float, adelante: float) -> void:
	if _rover_pivote == null or delta <= 0.0:
		return
	_t_anim += delta
	if _radar_rot != null:
		_radar_rot.rotation.y += delta * (1.6 if _escaner_roto <= 0.0 else 0.15)
	for i in range(_luces_taller.size()):
		_luces_taller[i].scale = Vector3.ONE * (1.0 + 0.12 * sin(_t_anim * 2.2 + float(i)))
	var v_gm := _vel / k
	var vel_n := clampf(absf(_vel) / (VEL * k), 0.0, 1.5)
	var acel_n := clampf((_vel - _vel_prev) / delta / (ACEL * k), -1.5, 1.5)
	_vel_prev = _vel
	var suave := 1.0 - exp(-7.0 * delta)


	for r in _ruedas:
		var lado: float = float(r.get_meta("lado"))
		var v_lado := v_gm + lado * giro * VEL_GIRO * 1.0 * (1.0 if absf(_vel) > 0.01 or giro != 0.0 else 0.0)
		r.rotation.x -= v_lado * delta / 0.38


	var pitch_obj := acel_n * 0.03
	var roll_obj := -giro * clampf(vel_n, 0.0, 1.0) * 0.045
	_pitch_r = lerpf(_pitch_r, pitch_obj, suave)
	_roll_r = lerpf(_roll_r, roll_obj, suave)
	_rover_pivote.rotation = Vector3(_pitch_r, 0.0, _roll_r)

	_rover_pivote.position.y = (sin(_t_anim * 24.0) * 0.004 + sin(_t_anim * 9.3 + 1.7) * 0.008) * clampf(vel_n, 0.0, 1.0)


	if _cabeza_mastil != null:
		var yaw_obj := giro * 0.55
		if vel_n < 0.05 and giro == 0.0:
			yaw_obj = sin(_t_anim * 0.45) * 0.75
		_yaw_mastil = lerpf(_yaw_mastil, yaw_obj, 1.0 - exp(-2.2 * delta))
		_cabeza_mastil.rotation.y = _yaw_mastil
		_cabeza_mastil.rotation.x = sin(_t_anim * 0.31 + 0.8) * 0.05

	if _antena_dish != null:
		_antena_dish.rotation.y = sin(_t_anim * 0.13) * 0.3
		_antena_dish.rotation.x = sin(_t_anim * 0.09 + 2.0) * 0.06


	_t_polvo = maxf(_t_polvo - delta, 0.0)
	if _t_polvo <= 0.0 and activo and not _en_briefing and vel_n > 0.35 and absf(acel_n) > 0.8 and _dentro < 0.3:
		_t_polvo = 0.45
		var p_dir := _desplazar(_up, _fwd, _perp_de(_fwd), (-1.2 if acel_n > 0.0 else 1.6) * k, 0.0)
		_nube_polvo(p_dir, acel_n < 0.0)


func _nube_polvo(dir: Vector3, frenando: bool) -> void:
	var nodo := Node3D.new()
	nodo.transform = Transform3D(_base_up(dir) * Basis.from_scale(Vector3.ONE * k), _pos(dir) + dir * (0.25 * k))
	add_child(nodo)
	var p := CPUParticles3D.new()
	p.local_coords = true
	p.one_shot = true
	p.amount = 12 if frenando else 8
	p.lifetime = 1.3
	p.explosiveness = 0.9
	p.direction = Vector3.UP
	p.spread = 80.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 2.4
	p.damping_min = 1.5
	p.damping_max = 2.5
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.2
	var esf := SphereMesh.new()
	esf.radius = 0.5
	esf.height = 1.0
	esf.radial_segments = 8
	esf.rings = 4
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	esf.material = mat
	p.mesh = esf
	var col := Color(0.78, 0.55, 0.38)
	var gr := Gradient.new()
	gr.colors = PackedColorArray([Color(col.r, col.g, col.b, 0.42), Color(col.r, col.g, col.b, 0.0)])
	gr.offsets = PackedFloat32Array([0.0, 1.0])
	p.color_ramp = gr
	var crv := Curve.new()
	crv.add_point(Vector2(0.0, 0.5))
	crv.add_point(Vector2(1.0, 1.8))
	p.scale_amount_curve = crv
	nodo.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_instance_valid(nodo):
			nodo.queue_free())


func _perp_de(f: Vector3) -> Vector3:
	return _up.cross(f).normalized()


func _colocar_robot() -> void:
	var n := _normal
	var f := (_fwd - n * _fwd.dot(n)).normalized()
	var derecha := f.cross(n).normalized()
	var atras := derecha.cross(n)
	var h_vis := _h
	if _hangar != null:
		h_vis = _hangar.altura_visual(_up * (planet.radius + _h), _h)
	_pos_robot = _up * (planet.radius + h_vis)
	var b := Basis(derecha, n, atras) * Basis.from_scale(Vector3.ONE * k)
	_robot.transform = Transform3D(b, _pos_robot)
	if _sombra_robot != null:
		Realismo.actualizar_sombra(_sombra_robot, _sol_en(_robot), 2.1, 0.06)


func _muestra_cercana() -> Node3D:
	var mejor: Node3D = null
	var mejor_d := RADIO_RECOGIDA * k * float(_mej["recogida"])
	for o in _objetos:
		var od: Vector3 = o.get_meta("dir")
		var d := _arco(_up, od)
		if d < mejor_d:
			mejor_d = d
			mejor = o
	return mejor


func _muestra_mas_cercana() -> Node3D:
	var mejor: Node3D = null
	var mejor_d := 1.0e9
	for o in _objetos:
		var d := _arco(_up, o.get_meta("dir"))
		if d < mejor_d:
			mejor_d = d
			mejor = o
	return mejor


func _briefing_habla() -> void:
	if not _en_briefing:
		return
	var msg_b: Dictionary = Historia.mensaje(id_mision, "antes")
	if not msg_b.is_empty():
		_hablar(str(msg_b["j"]), HudMision.corto(str(msg_b["t"]), 140))


func _precalentar() -> void:
	if _carga == null:
		return
	var nodo := Node3D.new()
	nodo.position = Vector3(0.0, 0.6, 0.0)
	_carga.add_child(nodo)
	var vistos := {}
	for id in lista:
		if vistos.has(id):
			continue
		vistos[id] = true
		var it := Node3D.new()
		var r := RandomNumberGenerator.new()
		r.seed = 1
		Muestras.construir(it, str(id), 0.4, r)
		it.scale = Vector3.ONE * 0.02
		nodo.add_child(it)
	var col: Color = DatosMarte.material(str(lista[0]))["color"] if lista.size() > 0 else Color.WHITE
	_chispas(_up, col, 2, 0.02, 0.6)
	var anillo := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.rings = 8
	toro.ring_segments = 3
	anillo.mesh = toro
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(col.r, col.g, col.b, 0.75)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	anillo.material_override = mat
	anillo.scale = Vector3.ONE * 0.02
	nodo.add_child(anillo)
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(nodo):
			nodo.queue_free())


func _cerrar_briefing() -> void:
	if not _en_briefing:
		return
	_en_briefing = false
	_hud.cerrar_briefing()
	_precalentar()
	_salida_iniciar()
	_audio.callar()
	_audio.resultado_escaner(1)


	var t := 0.0
	if not _tut_activo:
		t = 1.6
		get_tree().create_timer(t).timeout.connect(_aviso_inicio)
	if _exp:
		get_tree().create_timer(t + 9.0).timeout.connect(_consejo.bind("expedicion"))
	elif int(Ajustes.guia_objetivo) > 0:
		get_tree().create_timer(t + 10.0).timeout.connect(_consejo.bind("guia"))


func _pedir_salida() -> void:
	if _terminada or _en_briefing:
		salir_solicitado.emit()
		return
	if _pausa != null and is_instance_valid(_pausa):
		return
	_pausa = PausaMision.new()
	add_child(_pausa)
	_pausa.salir.connect(func(): salir_solicitado.emit())


func _consejo(id: String) -> void:
	if _tut_activo or not is_instance_valid(_hud) or _terminada and id != "taller" and id != "laboratorio":
		return
	var c := AyudaContextual.tomar(id)
	if c.is_empty():
		return
	_hud.toast("CONSEJO  ·  %s" % str(c["t"]), str(c["x"]), Color(0.55, 0.85, 1.0), 9.0)


func _aviso_inicio() -> void:
	if not is_instance_valid(_hud) or _terminada or not activo:
		return
	if _modo_fotos:
		_hud.toast("Misión iniciada", "F abre la cámara. ESPACIO escanea: los destellos violeta son blancos de fotos. Los azules guardan datos curiosos (E).", COLOR_FOTO, 8.0)
	else:
		_hud.toast("Misión iniciada", "ESPACIO escanea y E recoge. J abre el diario.", COLOR_DATO, 6.0)


func _sitio_foto(frac: float, lado: float, colocados: Array[Vector3]) -> Vector3:
	var mejor := dir_uv(dist_base * frac, lado)
	for intento in range(200):
		var u: float = dist_base * (frac + _rng.randf_range(-0.04, 0.04))
		var v: float = lado + _rng.randf_range(-8.0, 8.0) * (1.0 + float(intento) / 60.0)
		var d := dir_uv(u, v)
		if not _sitio_muestra_valido(d, colocados):
			continue
		if _evaluar(d).y > 20.0:
			continue
		return d
	return mejor


func _crear_blancos_foto() -> void:
	var ids: Array = datos.get("blancos", [])
	var dirs := {}
	var colocados: Array[Vector3] = []
	for id in ids:
		var info: Dictionary = DatosMarte.BLANCOS_FOTO[str(id)]
		if str(info["tipo"]) == "cielo":
			var hor := _f0.rotated(site_up, deg_to_rad(float(info["giro"])))
			var el := deg_to_rad(float(info["elev"]))
			dirs[str(id)] = (site_up * sin(el) + hor * cos(el)).normalized()
			continue
		match str(id):
			"lander":
				dirs[str(id)] = _up_a
			"estratos":
				var d := _sitio_foto(0.36, 26.0, colocados)
				dirs[str(id)] = d
				colocados.append(d)
			"remolino":
				var d2 := _sitio_foto(0.64, -34.0, colocados)
				dirs[str(id)] = d2
				colocados.append(d2)
			_:
				dirs[str(id)] = _sitio_foto(0.5, 20.0, colocados)
	var f := FotoMision.new()
	f.configurar(self, k, semilla)
	add_child(f)
	f.crear(ids, dirs)
	_foto = f
	total_objetos = maxi(_foto.total(), 1)


func linea_libre(a: Vector3, b: Vector3) -> bool:
	var n := 10
	for i in range(1, n):
		var t := float(i) / float(n)
		if t < 0.06 or t > 0.9:
			continue
		var p := a.lerp(b, t)
		if p.length() < planet.radius + _altura(p.normalized()) + 0.25 * k:
			return false
	return true


func _camara_nodo() -> Camera3D:
	return get_viewport().get_camera_3d()


func _visor_dir() -> Vector3:
	var f := (_fwd - _up * _fwd.dot(_up)).normalized()
	var d := f.rotated(_up, _vis_yaw)
	var derecha := d.cross(_up).normalized()
	return d.rotated(derecha, _vis_pitch).normalized()


func _alternar_visor() -> void:
	if _visor:
		_cerrar_visor()
	else:
		_abrir_visor()


func _abrir_visor() -> void:
	if not _modo_fotos or _visor or _terminada or _en_briefing or _dentro > 0.6:
		return
	_visor = true
	_vel = 0.0
	_vis_yaw = 0.0
	_vis_pitch = deg_to_rad(10.0)
	_vis_fov = FOV_VISOR
	var cam := _camara_nodo()
	if cam != null:
		_fov_previo = cam.fov
	_robot.visible = false
	_hud.mostrar_visor(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_audio.resultado_escaner(1)


func _cerrar_visor() -> void:
	if not _visor:
		return
	_visor = false
	var cam := _camara_nodo()
	if cam != null:
		cam.fov = _fov_previo
	if _robot != null:
		_robot.visible = true
	if _hud != null:
		_hud.mostrar_visor(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_cam_pos_s = cam_pos
	var dv := _visor_dir()
	_cam_fwd = (dv - _up * dv.dot(_up)).normalized()


func _actualizar_visor(delta: float) -> void:
	var ky := float(_tecla(KEY_A, KEY_LEFT)) - float(_tecla(KEY_D, KEY_RIGHT))
	var kp := float(_tecla(KEY_W, KEY_UP)) - float(_tecla(KEY_S, KEY_DOWN))
	var vel_giro := 1.1 * (_vis_fov / FOV_VISOR)
	_vis_yaw = fposmod(_vis_yaw + ky * vel_giro * delta + PI, TAU) - PI
	_vis_pitch = clampf(_vis_pitch + kp * vel_giro * delta, deg_to_rad(-20.0), deg_to_rad(80.0))
	var cam := _camara_nodo()
	if cam != null:
		cam.fov = lerpf(cam.fov, _vis_fov, 1.0 - exp(-14.0 * delta))
	var dv := _visor_dir()
	if _n_frame % 3 == 0:
		_enfoque = _foto.hay_enfoque(cam_pos, dv, deg_to_rad(_vis_fov))
	var norte := Vector3.UP - _up * _up.y
	var rumbo := 0.0
	if norte.length() > 0.0001:
		norte = norte.normalized()
		var este := norte.cross(_up).normalized()
		var h := (dv - _up * dv.dot(_up)).normalized()
		rumbo = rad_to_deg(atan2(h.dot(este), h.dot(norte)))
	_hud.actualizar_visor({"zoom": FOV_VISOR / maxf(_vis_fov, 0.1), "fov": _vis_fov, "rumbo": rumbo,
			"elev": rad_to_deg(asin(clampf(dv.dot(_up), -1.0, 1.0))), "enfoque": _enfoque})


func _zoom_visor(factor: float) -> void:
	_vis_fov = clampf(_vis_fov * factor, FOV_MIN, FOV_VISOR)


func _disparar() -> void:
	if not _visor or _disparando or _terminada:
		return
	if _mem_usada >= _mem_max:
		_hud.toast("Memoria llena", "Lleva las fotos a la base (B): allí se transmiten y la memoria queda libre.", COLOR_FOTO, 6.0)
		return
	_disparando = true
	var cam := _camara_nodo()
	var fov_v := deg_to_rad(cam.fov if cam != null else _vis_fov)
	var dv := _visor_dir()
	var cands: Array[Dictionary] = _foto.evaluar(cam_pos, dv, fov_v)
	_audio.obturador()
	_hud.ocultar_para_captura(true)
	await RenderingServer.frame_post_draw
	var img: Image = null
	var tex := get_viewport().get_texture()
	if tex != null:
		img = tex.get_image()
	_hud.ocultar_para_captura(false)
	_hud.flash()

	var mejor: Dictionary = {}
	for c in cands:
		if bool(c["ok"]) and (mejor.is_empty() or int(c["estrellas"]) > int(mejor["estrellas"])):
			mejor = c
	_mem_usada += 1
	_mem_flags.append(not mejor.is_empty())
	if not mejor.is_empty():
		_hito_ruta("foto")
	if not mejor.is_empty():
		var i: int = int(mejor["i"])
		var primera: bool = not bool(_foto.blancos[i]["hecho"])
		var e: int = int(mejor["estrellas"])
		var guardada: bool = _foto.registrar(i, e, img)
		var b: Dictionary = _foto.blancos[i]
		var txt := ""
		if primera:
			txt = str(b["dato"])
		elif guardada:
			txt = "¡Mejor que la anterior!"
		else:
			txt = "Ya tenías una foto igual o mejor de este blanco."
		if e < 3 and (primera or guardada):
			txt += "\nEncuadre %d/3: para más, céntralo y acércalo con el zoom." % e
		_hud.toast("Foto: %s" % str(b["nombre"]), txt, COLOR_FOTO, 8.0 if primera else 4.0)
	elif not cands.is_empty():
		var c0: Dictionary = cands[0]
		_hud.toast("Foto descartada", "%s: %s." % [str(c0["nombre"]), str(c0["motivo"])], Color(1.0, 0.78, 0.3), 5.0)
	else:
		_hud.toast("Foto sin blanco", "No hay ningún blanco en el encuadre. Revisa la pista de la tarjeta de misión.", Color(1.0, 0.78, 0.3), 4.0)
	_refrescar_hud()
	_disparando = false


func _transmitir_uno() -> void:
	var b: Dictionary = _foto.transmitir_uno()
	if b.is_empty():
		return
	_entregados += 1
	_destello_base()
	_audio.entregar()
	_musica_destello(18.0)
	_hud.toast("Foto transmitida", "%s · encuadre %d/3" % [str(b["nombre"]), int(b["estrellas"])], COLOR_FOTO, 4.0)
	if _foto.por_transmitir() == 0:
		_mem_usada = 0
		_mem_flags.clear()
		if _entregados < total_objetos:
			_hud.toast("Memoria libre", "La cámara vuelve a tener todos sus disparos. Quedan blancos por fotografiar.", COLOR_B, 6.0)
	_refrescar_hud()
	if _entregados >= total_objetos:
		_completar()


func _crear_curiosidades() -> void:
	var fracciones: Array[float] = [0.17, 0.34, 0.5, 0.66, 0.83]
	var textos: Array[Dictionary] = RelatosMarte.curiosidades(id_mision, fracciones.size(), _rng)
	var colocados: Array[Vector3] = []
	for o in _objetos:
		colocados.append(o.get_meta("dir"))
	for i in range(textos.size()):
		var lado: float = 1.0 if i % 2 == 0 else -1.0
		var dir := Vector3.ZERO
		var hallado := false
		for intento in range(160):
			var u: float = dist_base * (fracciones[i] + _rng.randf_range(-0.05, 0.05))
			var v: float = lado * _rng.randf_range(5.0, 16.0)
			if intento > 80:
				v = -v
			var d := dir_uv(u, v)
			if not _sitio_muestra_valido(d, colocados):
				continue
			if _evaluar(d).y > PENDIENTE_MUESTRA:
				continue
			dir = d
			hallado = true
			break
		if not hallado:
			continue
		colocados.append(dir)
		_crear_baliza_dato(dir, textos[i])


func _crear_baliza_dato(dir: Vector3, dato: Dictionary) -> void:
	var raiz := _anclar_en(dir)
	raiz.set_meta("dir", dir)
	raiz.set_meta("dato", dato)
	raiz.set_meta("leido", false)
	var mat_g := _mat(COLOR_DATO, true, 2.4)
	var sm := SphereMesh.new()
	sm.radial_segments = 4
	sm.rings = 2
	sm.radius = 0.6
	sm.height = 1.2
	var gema := MeshInstance3D.new()
	gema.mesh = sm
	gema.material_override = mat_g
	gema.scale = Vector3(0.8, 1.35, 0.8)
	gema.position = Vector3(0.0, 2.6, 0.0)
	gema.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(gema)
	var aro := TorusMesh.new()
	aro.inner_radius = 1.05
	aro.outer_radius = 1.25
	aro.rings = 32
	aro.ring_segments = 6
	var mi_aro := MeshInstance3D.new()
	mi_aro.mesh = aro
	mi_aro.material_override = _mat(COLOR_DATO, true, 1.2)
	mi_aro.position = Vector3(0.0, 0.08, 0.0)
	mi_aro.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(mi_aro)
	_columna_luz(raiz, COLOR_DATO, 10.0)
	var haz := raiz.get_child(raiz.get_child_count() - 1)
	raiz.set_meta("gema", gema)
	raiz.set_meta("mat_g", mat_g)
	raiz.set_meta("haz", haz)
	_curiosidades.append(raiz)


func _crear_hallazgos() -> void:
	if _tut_activo:
		return
	var lista := Hallazgos.para_mision(datos)
	if lista.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla * 31 + 17
	var colocados: Array[Vector3] = []
	for o in _objetos:
		colocados.append(o.get_meta("dir"))
	for c in _curiosidades:
		colocados.append(c.get_meta("dir"))
	for i in range(lista.size()):
		var lado: float = -1.0 if i % 2 == 0 else 1.0
		var dir := Vector3.ZERO
		var hallado := false
		for intento in range(220):
			var u: float = dist_base * rng.randf_range(0.2, 0.85)
			var v: float = lado * rng.randf_range(16.0, 42.0)
			if intento > 110:
				v = -v
			var d := dir_uv(u, v)
			if not _sitio_muestra_valido(d, colocados):
				continue
			if _evaluar(d).y > PENDIENTE_MUESTRA:
				continue
			dir = d
			hallado = true
			break
		if not hallado:
			continue
		colocados.append(dir)
		_crear_hallazgo(dir, lista[i])


func _crear_hallazgo(dir: Vector3, h: Dictionary) -> void:
	var raiz := _anclar_en(dir)
	raiz.set_meta("dir", dir)
	raiz.set_meta("h", h)
	raiz.set_meta("recogido", false)
	var dorado := Color(1.0, 0.82, 0.25)
	var sm := SphereMesh.new()
	sm.radial_segments = 6
	sm.rings = 3
	sm.radius = 0.55
	sm.height = 1.1
	var gema := MeshInstance3D.new()
	gema.mesh = sm
	gema.material_override = _mat(dorado, true, 2.6)
	gema.scale = Vector3(1.0, 1.2, 1.0)
	gema.position = Vector3(0.0, 2.2, 0.0)
	gema.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(gema)
	var aro := TorusMesh.new()
	aro.inner_radius = 0.9
	aro.outer_radius = 1.05
	aro.rings = 24
	aro.ring_segments = 6
	var mi_aro := MeshInstance3D.new()
	mi_aro.mesh = aro
	mi_aro.material_override = _mat(dorado, true, 1.6)
	mi_aro.position = Vector3(0.0, 0.08, 0.0)
	mi_aro.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(mi_aro)
	_columna_luz(raiz, dorado, 9.0)
	raiz.set_meta("gema", gema)
	raiz.visible = false
	_hallazgos.append(raiz)


func _hablar(jefe: String, texto: String) -> void:
	_audio.hablar(jefe, texto)
	if _musica != null:
		_musica.motivo(jefe)
		_musica.hablando(clampf(float(texto.length()) * 0.07, 2.0, 14.0))


func _musica_destello(seg: float) -> void:
	if _musica != null:
		_musica.destello(seg)


func _hallazgo_revelado(h: Node3D) -> bool:
	return h.visible and not bool(h.get_meta("recogido"))


func _revelar_hallazgo(h: Node3D) -> void:
	if h.visible or bool(h.get_meta("recogido")):
		return
	h.visible = true
	_musica_destello(14.0)
	_hud.toast("¡Hallazgo escondido!", "Algo brilla entre las rocas. Acércate y pulsa E. (Está en el radar.)", Color(1.0, 0.82, 0.25), 6.0)
	_audio.resultado_escaner(1)


func _actualizar_hallazgos(delta: float) -> void:
	for i in range(_hallazgos.size()):
		var h: Node3D = _hallazgos[i]
		if bool(h.get_meta("recogido")):
			continue
		var g: MeshInstance3D = h.get_meta("gema")
		g.rotation.y += delta * 1.1
		g.position.y = 2.2 + 0.2 * sin(_tiempo * 2.2 + float(i) * 2.3)
		if h.visible or _terminada:
			continue
		var d := _arco(_up, h.get_meta("dir"))
		if d < 9.0 * k:
			_revelar_hallazgo(h)
		elif _dron != null and _dron.marcados.has(h):
			_revelar_hallazgo(h)


func _escaner_hallazgos(alcance: float) -> void:
	for h in _hallazgos:
		if not h.visible and not bool(h.get_meta("recogido")) and _arco(_up, h.get_meta("dir")) < alcance * 0.6:
			_revelar_hallazgo(h)


func _hallazgo_cercano() -> Node3D:
	var mejor: Node3D = null
	var mejor_d := RADIO_DATO * k
	for h in _hallazgos:
		if not _hallazgo_revelado(h):
			continue
		var d := _arco(_up, h.get_meta("dir"))
		if d < mejor_d:
			mejor_d = d
			mejor = h
	return mejor


func _recoger_hallazgo(h: Node3D) -> void:
	var inf: Dictionary = h.get_meta("h")
	h.set_meta("recogido", true)
	h.visible = false
	_hallazgos_mision += 1
	get_tree().create_timer(4.0).timeout.connect(_consejo.bind("hallazgo"))
	var d := int(inf.get("d", 1))
	_datos_hallazgos += d
	MetaEstado.sumar_datos(d)
	_hito_ruta("dato")
	var cab := "HALLAZGO ESCONDIDO  ·  +%d DATOS DE CIENCIA" % d
	if bool(inf.get("coleccion", false)):
		MetaEstado.marcar_hallazgo(str(inf["id"]))
		cab += "  ·  COLECCIÓN %d / %d" % [MetaEstado.num_hallazgos(), Hallazgos.total()]
	_hud.mostrar_dato({"cat": "Hallazgo", "t": str(inf["n"]), "x": str(inf["t"])}, 0, 0, cab)
	_audio.medalla()
	_musica_destello(24.0)
	if bool(inf.get("coleccion", false)) and Hallazgos.completo():
		get_tree().create_timer(2.5).timeout.connect(func():
			if is_instance_valid(_hud):
				_hud.toast("¡COLECCIÓN COMPLETA!", "Encontraste todos los hallazgos escondidos de Marte. Medalla de coleccionista en el diario.", Color(1.0, 0.82, 0.25), 9.0))


func _actualizar_curiosidades(delta: float) -> void:
	for i in range(_curiosidades.size()):
		var g: MeshInstance3D = _curiosidades[i].get_meta("gema")
		g.rotation.y += delta * 1.4
		g.position.y = 2.6 + 0.25 * sin(_tiempo * 2.0 + float(i) * 1.7)

	if _dato_actual != null and _hud != null and _hud.dato_abierto():
		var dd := _arco(_up, _dato_actual.get_meta("dir"))
		if dd > RADIO_DATO * k * 5.0:
			_hud.cerrar_dato()
			_dato_actual = null


func _curiosidad_cercana() -> Node3D:
	var mejor: Node3D = null
	var mejor_d := RADIO_DATO * k
	for c in _curiosidades:
		var d := _arco(_up, c.get_meta("dir"))
		if d < mejor_d:
			mejor_d = d
			mejor = c
	return mejor


func _accion_e() -> void:
	if _terminada:
		return
	if _eventos != null and _eventos.compartir():
		return
	var o := _muestra_cercana()
	if o != null and _bodega.size() < capacidad:
		_recoger(o)
		return
	var hz := _hallazgo_cercano()
	if hz != null:
		_recoger_hallazgo(hz)
		return
	var c := _curiosidad_cercana()
	if c != null:
		if _hud.dato_abierto() and c == _dato_actual:
			_hud.cerrar_dato()
		else:
			_leer_curiosidad(c)
		return
	if _hud.dato_abierto():
		_hud.cerrar_dato()


func _leer_curiosidad(c: Node3D) -> void:
	_dato_actual = c
	if not bool(c.get_meta("leido")):
		c.set_meta("leido", true)
		_curiosidades_leidas += 1
		_hito_ruta("dato")
		var mat_g: StandardMaterial3D = c.get_meta("mat_g")
		mat_g.albedo_color = COLOR_DATO.darkened(0.55)
		mat_g.emission = COLOR_DATO.darkened(0.55)
		mat_g.emission_energy_multiplier = 0.6
		(c.get_meta("haz") as Node3D).visible = false
		_hud.actualizar_curiosidades(_curiosidades_leidas, _curiosidades.size())
		if _curiosidades_leidas == _curiosidades.size():
			_hud.toast("¡Todos los datos curiosos!", "Leíste todos los de esta misión.", COLOR_DATO, 5.0)
	_hud.mostrar_dato(c.get_meta("dato"), _curiosidades_leidas, _curiosidades.size())
	_audio.resultado_escaner(1)


func _escanear() -> void:
	if _terminada or _escaner_cd > 0.0:
		return
	if _escaner_roto > 0.0:
		_escaner_cd = 1.5
		_hud.toast("Escáner averiado", "Quédate quieto 5 segundos para reiniciarlo.", Color(1.0, 0.72, 0.25), 3.0)
		_audio.malo_corto()
		return
	_escaner_cd = RECARGA_ESCANER * float(_mej["escaner_cd"])
	_tut_escaneo = true
	if _riesgos:
		_energia = maxf(_energia - COSTE_ESCANER, 0.0)
	_senal_t = DURACION_SENAL
	_pulso_t = 0.0
	var alcance := _alcance_esc * k
	_fx.disparar(_pos_robot + _up * (0.6 * k), alcance, Color(1.0, 0.55, 0.2))
	_audio.escanear()
	_escaner_hallazgos(alcance)


	var halladas: Array = []
	for o in _objetos:
		var d := _arco(_up, o.get_meta("dir"))
		if d < alcance:
			halladas.append([d, o])
	halladas.sort_custom(func(a, b): return a[0] < b[0])
	_senal_lista.clear()
	for h in halladas:
		_senal_lista.append(h[1])
		if not _guia_conocidas.has(h[1]):
			_guia_conocidas.append(h[1])

	var contactos: Array = []
	for i in range(mini(halladas.size(), 4)):
		var o: Node3D = halladas[i][1]
		var info := DatosMarte.material(str(o.get_meta("mat")))
		var dir: Vector3 = o.get_meta("dir")
		contactos.append({"dir": dir, "pos": _pos(dir), "color": info["color"],
				"nombre": str(info["nombre"]), "grande": false})

	var n_cuevas := 0
	for c in _cuevas:
		if _arco(_up, c.dir_centro) < alcance * 1.6:
			n_cuevas += 1
			var de: Vector3 = c.dir_entrada()
			contactos.append({"dir": de, "pos": _pos(de), "color": COLOR_CUEVA,
					"nombre": "Cueva", "grande": true})
			if not _cuevas_detectadas.has(c):
				_cuevas_detectadas.append(c)
				_hud.toast("Cueva detectada", "Una cavidad en la roca. Dentro hace más frío y está oscuro: enciende la linterna (se activa sola).",
						COLOR_CUEVA)

	var n_blancos := 0
	if _modo_fotos:
		var cs: Array = _foto.contactos_suelo(_pos_robot, ALCANCE_ESCANER * 1.4)
		n_blancos = cs.size()
		for c in cs:
			var dc: Vector3 = c["dir"]
			contactos.append({"dir": dc, "pos": _pos(dc), "color": COLOR_FOTO, "nombre": str(c["nombre"]), "grande": true})
	if _modo_fotos:
		if n_blancos == 0:
			_senal_texto = "Ningún blanco cerca. Mira también al cielo (F)."
		else:
			_senal_texto = "%d blanco%s a la vista · el más cercano a %s" % [n_blancos, "" if n_blancos == 1 else "s",
					_texto_distancia(float(_foto.contactos_suelo(_pos_robot, ALCANCE_ESCANER * 1.4)[0]["dist"]) * k)]
	elif halladas.is_empty():
		_senal_texto = "Sin muestras en %s a la redonda" % _texto_distancia(alcance)
	else:
		_senal_texto = "%d señal%s · la más cercana a %s" % [halladas.size(),
				"" if halladas.size() == 1 else "es", _texto_distancia(float(halladas[0][0]))]
	_audio.resultado_escaner(halladas.size() + n_cuevas + n_blancos)

	get_tree().create_timer(0.7).timeout.connect(func():
		if is_instance_valid(_fx) and not contactos.is_empty():
			_fx.marcar_contactos(contactos, DURACION_SENAL - 0.7))


func _logica(delta: float) -> void:
	if _modo_fotos:

		if _foto.por_transmitir() > 0 and _arco(_up, _up_b) < RADIO_BASE * k:
			_timer_tx -= delta
			if _timer_tx <= 0.0:
				_timer_tx = 0.7
				_transmitir_uno()
		else:
			_timer_tx = 0.0
		return

	if not _bodega.is_empty() and _arco(_up, _up_b) < RADIO_BASE * k:
		_timer_entrega -= delta
		if _timer_entrega <= 0.0:
			_timer_entrega = TIEMPO_ENTREGA
			_entregar_uno()
	else:
		_timer_entrega = 0.0


func _recoger(o: Node3D) -> void:
	var id := str(o.get_meta("mat"))
	var dir: Vector3 = o.get_meta("dir")
	_objetos.erase(o)
	_senal_lista.erase(o)
	_guia_conocidas.erase(o)
	_fx.quitar_baliza_de(dir)
	_chispas(dir, DatosMarte.material(id)["color"], 26, 1.0)
	o.queue_free()
	_bodega.append(id)
	_hito_ruta("muestra")
	_radio("recoger")
	_dron_festejo("recoge")

	var i := _items_carga.size()
	var col := i % 3
	var fila := floori(i / 3.0)
	var item := Node3D.new()
	item.position = Vector3((col - 1) * 0.5, 0.15 + fila * 0.45, 0.0)
	var r := RandomNumberGenerator.new()
	r.seed = semilla + i * 17
	Muestras.construir(item, id, 0.4, r)
	_carga.add_child(item)
	_items_carga.append(item)
	var escala_final := item.scale
	item.scale = Vector3.ZERO
	create_tween().tween_property(item, "scale", escala_final, 0.2)

	var info := DatosMarte.material(id)
	var dato := str(info["dato"])
	var propios: Variant = datos.get("datos_mat", {})
	if propios is Dictionary and (propios as Dictionary).has(id):
		dato = str((propios as Dictionary)[id])
	if dato.begins_with(str(info["nombre"])):
		dato = dato.substr(str(info["nombre"]).length()).lstrip(".,:; ").strip_edges()
		dato = dato.substr(0, 1).to_upper() + dato.substr(1)
	if _datos_mostrados.has(id):
		dato = "Recogido · %d / %d en la bodega" % [_bodega.size(), capacidad]
	_datos_mostrados[id] = true
	_hud.toast(str(info["nombre"]), dato, info["color"], 7.0 if dato.length() > 40 else 3.0)
	_audio.recoger()
	_refrescar_hud()


func _entregar_uno() -> void:
	_hito_ruta("entrega")
	_radio("entrega")
	_dron_festejo("entrega")
	var id: String = _bodega.pop_back()
	var item = _items_carga.pop_back()
	if item:
		item.queue_free()

	var i := _entregados
	var col := i % 3
	var fila := floori(i / 3.0) % 3
	var capa := floori(i / 9.0)
	var apilado := Node3D.new()
	apilado.position = Vector3((col - 1) * 1.8, 0.8 + capa * 0.7, 9.5 + (fila - 1) * 1.8)
	var r := RandomNumberGenerator.new()
	r.seed = semilla * 3 + i
	Muestras.construir(apilado, id, 0.5, r)
	_raiz_base.add_child(apilado)

	_entregados += 1
	_entregados_por[id] = int(_entregados_por.get(id, 0)) + 1
	_destello_base()
	_efecto_entrega(id)
	_audio.entregar()
	_musica_destello(18.0)
	if _riesgos and float(_ventajas.get("recarga", 0.0)) > 0.0:
		_energia = minf(_energia + float(_ventajas["recarga"]), 100.0)
	var total_id := lista.count(id)
	if int(_entregados_por[id]) == total_id and _entregados < total_objetos:
		var info := DatosMarte.material(id)
		_hud.toast("Muestras completas", "Entregaste todo el material «%s»." % str(info["nombre"]), info["color"], 5.0)
	_refrescar_hud()
	if _entregados >= total_objetos:
		_completar()


func _chispas(dir: Vector3, color: Color, cantidad: int, tam: float, altura_gm: float = 0.6) -> void:
	var nodo := Node3D.new()
	nodo.transform = Transform3D(_base_up(dir) * Basis.from_scale(Vector3.ONE * k), _pos(dir) + dir * (altura_gm * k))
	add_child(nodo)
	var p := CPUParticles3D.new()
	p.local_coords = true
	p.one_shot = true
	p.amount = cantidad
	p.lifetime = 0.9
	p.explosiveness = 0.95
	p.direction = Vector3.UP
	p.spread = 75.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 2.5
	p.initial_velocity_max = 7.0
	p.damping_min = 3.0
	p.damping_max = 5.0
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.3
	var esfera := SphereMesh.new()
	esfera.radius = 0.3 * tam
	esfera.height = 0.6 * tam
	esfera.radial_segments = 6
	esfera.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color.lightened(0.25)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.vertex_color_use_as_albedo = true
	esfera.material = mat
	p.mesh = esfera
	var curva := Curve.new()
	curva.add_point(Vector2(0.0, 1.0))
	curva.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = curva
	nodo.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(nodo):
			nodo.queue_free())


func _efecto_entrega(id: String) -> void:
	var color: Color = DatosMarte.material(id)["color"]
	_chispas(_up_b, color, 34, 1.3, 3.0)
	var anillo := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = 0.93
	toro.outer_radius = 1.0
	toro.rings = 32
	toro.ring_segments = 4
	anillo.mesh = toro
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(color.r, color.g, color.b, 0.75)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	anillo.material_override = mat
	anillo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var basis_up := _base_up(_up_b)
	anillo.transform = Transform3D(basis_up * Basis.from_scale(Vector3.ONE * k * 2.0), _pos(_up_b) + _up_b * (0.8 * k))
	add_child(anillo)
	var tw2 := create_tween().set_parallel(true)
	var fin := Transform3D(basis_up * Basis.from_scale(Vector3.ONE * k * 20.0), anillo.transform.origin)
	tw2.tween_property(anillo, "transform", fin, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw2.tween_property(mat, "albedo_color:a", 0.0, 0.9)
	tw2.chain().tween_callback(anillo.queue_free)


func _destello_base() -> void:
	if _mat_baliza_b == null:
		return
	_mat_baliza_b.emission_energy_multiplier = 6.0
	var tw := create_tween()
	tw.tween_property(_mat_baliza_b, "emission_energy_multiplier", 2.0, 0.35)


func _completar() -> void:
	_terminada = true
	if _dron != null:
		_dron.ocultar()
	_vel = 0.0
	_senal_t = 0.0
	var resumen: Array = []
	for id in _entregados_por:
		var info := DatosMarte.material(str(id))
		var plural := str(info["plural"])
		resumen.append({"nombre": plural.substr(0, 1).to_upper() + plural.substr(1), "n": int(_entregados_por[id]), "color": info["color"]})
	var extra := ""
	var lineas: Array[String] = []
	if not _curiosidades.is_empty():
		lineas.append("Datos curiosos leídos: %d / %d" % [_curiosidades_leidas, _curiosidades.size()])
	var cierre := str(RelatosMarte.relato(id_mision).get("cierre", ""))
	var msg_jefe := Historia.texto_final(id_mision)
	if msg_jefe != "":
		cierre += "\n\n" + msg_jefe
	var reac := HistoriaEstado.reaccion(id_mision) if not bool(datos.get("final", false)) and not _exp else ""
	if reac != "":
		cierre += "\n\n" + reac
	var album: Array = []
	if _modo_fotos and _foto != null:
		album = _foto.album()
		lineas.push_front("Fotos transmitidas: %d  ·  Encuadre total: %d / %d" % [_foto.transmitidos(), _foto.estrellas_totales(), _foto.total() * 3])
	var rango_antes := Logros.rango_idx()
	var info_ruta := _cerrar_ruta()
	lineas.append_array(_guardar_almacen())
	if _hallazgos_mision > 0:
		lineas.append("Hallazgos escondidos: %d  (+%d datos de ciencia)" % [_hallazgos_mision, _datos_hallazgos])
	var linea_comite := Comite.resumen_mision(id_mision)

	var prog := HistoriaEstado.progreso(DatosMarte.MISIONES, Ajustes.misiones_libres)
	var ofrecidas: Array[String] = []
	for i in range(prog.size()):
		if bool((prog[i] as Dictionary)["oferta"]):
			ofrecidas.append("%s · %s" % [str(DatosMarte.MISIONES[i]["era"]), str(DatosMarte.MISIONES[i]["nombre"])])
	if _exp:
		extra = ""
	elif HistoriaEstado.campana_completa(DatosMarte.MISIONES):
		extra = "¡Campaña completada, de %s a %s!" % [str(DatosMarte.MISIONES[0]["era"]), str(DatosMarte.MISIONES[DatosMarte.MISIONES.size() - 1]["era"])]
	elif not ofrecidas.is_empty():
		extra = Idioma.t("El comité te ofrece: %s") % "  /  ".join(ofrecidas)
	if extra != "":
		lineas.append(extra)
	for l in _hist_lineas:
		lineas.append(l)
	if _sec_ofrecida and not _sec.is_empty() and int(_sec.get("estado", 0)) == 1:
		_quitar_marca_sec()
	if bool(datos.get("final", false)) and not _exp:
		_final_hist = HistoriaEstado.final_id()
		HistoriaEstado.fijar_final(_final_hist)
		lineas.append("FINAL: %s" % str(HistoriaEstado.final_datos(_final_hist).get("titulo", "")))
	if linea_comite != "":
		lineas.append(linea_comite)
	var largo_r := float(info_ruta.get("distancia", 0.0))
	var directo_r := float(info_ruta.get("dist_base", 0.0))
	var nuevas: Array = []
	if _exp:
		lineas.append_array(_puntuar_expedicion())
	else:
		nuevas = Logros.registrar(id_mision, {
			"eficiencia": clampf(directo_r / largo_r, 0.0, 1.0) if largo_r > 0.1 else 0.0,
			"riesgos": _riesgos, "energia_min": _energia_min,
			"leidas": _curiosidades_leidas, "total_curiosos": _curiosidades.size(),
			"decision": _dilema_resp, "tiempo": _tiempo, "dificultad": _dif,
			"eventos": _eventos.vividos if _eventos != null else 0,
		})
	if not nuevas.is_empty():
		var nombres: Array[String] = []
		for k in nuevas:
			nombres.append(str((Logros.MEDALLAS[k] as Dictionary)["n"]))
		lineas.append(Idioma.t("Medallas ganadas: %s") % ", ".join(nombres))
		get_tree().create_timer(1.6).timeout.connect(func(): _audio.medalla())
	if Logros.rango_idx() > rango_antes:
		lineas.append("¡Nuevo rango: %s!" % Logros.rango_nombre(Ajustes.genero))
		get_tree().create_timer(2.8).timeout.connect(func(): _audio.rango())
	var restos := str(datos.get("tipo", "")) == "restos"
	var ficha: Dictionary = datos if _exp else {}
	for m in DatosMarte.MISIONES:
		if str(m["id"]) == id_mision:
			ficha = m
	var meds: Array = []
	for k in Logros.medallas(id_mision):
		if Logros.MEDALLAS.has(k):
			meds.append({"n": (Logros.MEDALLAS[k] as Dictionary)["n"], "c": (Logros.MEDALLAS[k] as Dictionary)["c"]})
	_tarjeta_datos = {
		"id": id_mision, "nombre": nombre, "era": str(ficha.get("era", "")), "nave": str(ficha.get("nave", "")),
		"piloto": Ajustes.nombre_visible(), "rango": Logros.rango_nombre(Ajustes.genero) + ((" · " + HistoriaEstado.titulo_final(Ajustes.genero)) if HistoriaEstado.titulo_final(Ajustes.genero) != "" else ""), "dificultad": _dif,
		"tiempo": _formato_tiempo(_tiempo), "km": largo_r / 10.0,
		"eficiencia": clampf(directo_r / largo_r, 0.0, 1.0) if largo_r > 0.1 else 0.0,
		"muestras": _entregados, "energia_min": _energia_min if _riesgos else -1.0,
		"eventos": _eventos.vividos if _eventos != null else 0,
		"medallas": meds, "comite": linea_comite, "restos": restos,
		"ruta": info_ruta["ruta"], "eventos_ruta": info_ruta["eventos"], "dist_base": directo_r,
		"confianza": HistoriaEstado.conf_media(),
	}
	var nombres_med: Array = []
	for k in nuevas:
		if Logros.MEDALLAS.has(k):
			nombres_med.append(str((Logros.MEDALLAS[k] as Dictionary)["n"]))
	var entrada := {
		"id": id_mision, "nombre": nombre, "era": str(ficha.get("era", "")), "exp": _exp, "semilla": semilla,
		"nivel": int(datos.get("nivel", 0)), "sol": int(datos.get("sol", 1)), "tiempo": _tiempo, "km": largo_r / 10.0,
		"muestras": _entregados, "total": total_objetos, "curiosos": _curiosidades_leidas, "total_curiosos": _curiosidades.size(),
		"hallazgos": _hallazgos_mision, "medallas": nombres_med, "decision": _dilema_resp,
		"energia_min": _energia_min if _riesgos else -1.0, "puntos": _exp_puntos,
		"eventos": _eventos.vividos if _eventos != null else 0,
		"carta": CartaFocos.datos(_c_tormenta, 2 if _ecl_visto else (1 if _ecl_estado >= 1 else 0),
				_eventos.tipos if _eventos != null else {}, _eventos != null and _eventos.rescatado),
	}
	Bitacora.registrar(entrada)
	if not _exp:
		get_tree().create_timer(5.5).timeout.connect(func():
			if _hud != null:
				_hud.toast(DronVoz.NOMBRE, CartaFocos.aviso(), DronVoz.COLOR, 6.0))
	_hud.mostrar_final(_formato_tiempo(_tiempo), resumen, "\n".join(lineas), cierre, album, info_ruta, restos)
	get_tree().create_timer(1.0).timeout.connect(AvisoGuardado.mostrar)
	if not _exp:
		_hud.mostrar_cuaderno(datos, entrada)
	_hud.mostrar_boton_final(_final_hist != "")
	_hud.mostrar_boton_lab(MetaEstado.stock_total() > 0)
	if MetaEstado.stock_total() > 0 and not _tut_activo:
		get_tree().create_timer(3.0).timeout.connect(_consejo.bind("laboratorio"))
		get_tree().create_timer(14.0).timeout.connect(_consejo.bind("taller"))
	_audio.completar()
	var msg_f := Historia.mensaje(id_mision, "despues")
	if not msg_f.is_empty():
		get_tree().create_timer(2.5).timeout.connect(func(): _hablar(str(msg_f["j"]), str(msg_f["t"])))
	_refrescar_hud()
	mision_completada.emit(id_mision, _tiempo)


func _puntuar_expedicion() -> Array[String]:
	var nivel := int(datos.get("nivel", 0))
	var r := Expedicion.puntuar({
		"muestras": _entregados, "total": total_objetos, "curiosos": _curiosidades_leidas,
		"hallazgos": _hallazgos_mision, "tiempo": _tiempo,
		"energia_min": _energia_min if _riesgos else -1.0, "nivel": nivel, "dificultad": _dif,
	})
	var puntos := int(r["puntos"])
	var antes := Expedicion.mejor(semilla, nivel)
	var pos := MetaEstado.registrar_exp(Expedicion.clave(semilla, nivel), puntos, Ajustes.nombre_visible(), _tiempo)
	_exp_puntos = puntos
	var res: Array[String] = ["EXPEDICIÓN %d  ·  PUNTUACIÓN: %d" % [semilla, puntos]]
	for l in (r["lineas"] as Array):
		res.append("   " + str(l))
	if pos == 1 and puntos > antes:
		res.append("¡NUEVO RÉCORD de esta semilla!")
	elif pos > 0:
		res.append("Entras en el top 10 de esta semilla (puesto %d)." % pos)
	return res


func _guardar_almacen() -> Array[String]:
	var res: Array[String] = []
	MetaEstado.ingresar(_entregados_por)
	var datos_ganados := _curiosidades_leidas + int(_mej["datos_mision"])
	if _modo_fotos and _foto != null:
		datos_ganados += int(_foto.transmitidos() / 2)
	datos_ganados += _datos_extra
	MetaEstado.sumar_datos(datos_ganados)
	if _entregados > 0 or datos_ganados > 0:
		res.append("Almacén: +%d muestras · +%d datos de ciencia (taller del menú y laboratorio)" % [_entregados, datos_ganados])
	return res


func _aplicar_mejoras_visuales() -> void:
	var nb := Mejoras.nivel("bateria")
	var nr := Mejoras.nivel("ruedas")
	var na := Mejoras.nivel("brazo")
	var ne := Mejoras.nivel("escaner")
	if nb + nr + na + ne == 0:
		return
	var raiz := Node3D.new()
	raiz.name = "MejorasTaller"
	_robot.add_child(raiz)
	var m_verde := _mat(Mejoras.RAMAS["bateria"]["c"], true, 1.6)
	var m_gris := _mat_pbr(Color(0.2, 0.21, 0.24), 0.4, 0.5)
	var m_ambar := _mat(Mejoras.RAMAS["ruedas"]["c"], true, 1.3)
	var m_naranja := _mat_pbr(Color(0.9, 0.42, 0.1), 0.0, 0.6)
	var m_blanco := _mat_pbr(Color(0.9, 0.9, 0.93), 0.1, 0.5)
	var m_azul := _mat(Mejoras.RAMAS["escaner"]["c"], true, 1.5)

	for i in range(nb):
		var z: float = [0.55, -0.1, -0.7][i]
		for lado in [-1.0, 1.0]:
			_caja(raiz, Vector3(0.12, 0.34, 0.5), Vector3(lado * 0.82, 0.98, z), m_gris)
			var luz := _caja(raiz, Vector3(0.13, 0.06, 0.38), Vector3(lado * 0.83, 1.08, z), m_verde)
			_luces_taller.append(luz)
	if nb >= 3:

		var m_panel := _mat_pbr(Color(0.08, 0.12, 0.3), 0.6, 0.3)
		for lado in [-1.0, 1.0]:
			_caja(raiz, Vector3(0.05, 0.05, 1.5), Vector3(lado * 0.92, 1.3, 0.1), m_gris)
			_caja(raiz, Vector3(0.9, 0.035, 1.6), Vector3(lado * 1.36, 1.5, 0.1), m_panel, Vector3(0, 0, lado * -14.0))
			_caja(raiz, Vector3(0.9, 0.012, 0.05), Vector3(lado * 1.36, 1.525, 0.1), m_gris, Vector3(0, 0, lado * -14.0))

	if nr >= 1:
		for lado in [-1.0, 1.0]:
			for z in [-0.95, 0.0, 0.95]:
				_cil(raiz, 0.2, 0.2, 0.03, Vector3(lado * 1.2, 0.38, z), m_ambar, Vector3(0, 0, 90), 16)
				if nr >= 2:
					_caja(raiz, Vector3(0.36, 0.05, 0.9), Vector3(lado * 1.0, 0.8, z), m_naranja)
				if nr >= 3:
					_caja(raiz, Vector3(0.06, 0.06, 0.7), Vector3(lado * 1.2, 0.18, z), m_ambar)
					_cil(raiz, 0.045, 0.045, 0.5, Vector3(lado * 0.9, 0.62, z), m_ambar, Vector3(0, 0, lado * 12.0), 8)

	if na >= 1:
		_caja(raiz, Vector3(0.5, 0.22, 0.46), Vector3(0.45, 1.38, -0.62), m_naranja)
		_caja(raiz, Vector3(0.52, 0.03, 0.48), Vector3(0.45, 1.5, -0.62), m_blanco)
	if na >= 2:

		_cil(raiz, 0.12, 0.12, 0.14, Vector3(-0.45, 0.68, -1.05), m_gris, Vector3.ZERO, 12)
		_cil(raiz, 0.05, 0.05, 1.0, Vector3(-0.45, 0.95, -1.5), m_blanco, Vector3(-62, 0, 0), 10)
		_esfera(raiz, 0.08, Vector3(-0.45, 1.18, -1.98), m_gris, 10)
		_cil(raiz, 0.04, 0.04, 0.9, Vector3(-0.45, 0.82, -2.38), m_blanco, Vector3(52, 0, 0), 10)
		_caja(raiz, Vector3(0.05, 0.12, 0.16), Vector3(-0.5, 0.4, -2.7), m_gris)
		_caja(raiz, Vector3(0.05, 0.12, 0.16), Vector3(-0.4, 0.4, -2.7), m_gris)
	if na >= 3:
		_caja(raiz, Vector3(0.5, 0.22, 0.46), Vector3(-0.1, 1.62, -0.62), m_naranja)

	if ne >= 1:
		_cil(raiz, 0.025, 0.025, 0.7, Vector3(-0.2, 1.65, 0.3), m_gris, Vector3.ZERO, 8)
		_cil(raiz, 0.2, 0.2, 0.02, Vector3(-0.2, 2.02, 0.3), m_blanco, Vector3(-30, 0, 0), 14)
	if ne >= 2:
		_esfera(raiz, 0.05, Vector3(-0.2, 2.1, 0.3), m_azul, 8)
		_cil(raiz, 0.28, 0.28, 0.02, Vector3(-0.2, 1.8, 0.3), m_blanco, Vector3(30, 0, 0), 14)
	if ne >= 3:
		var rad := Node3D.new()
		rad.position = Vector3(-0.2, 2.2, 0.3)
		raiz.add_child(rad)
		_caja(rad, Vector3(0.9, 0.05, 0.1), Vector3.ZERO, m_azul)
		_caja(rad, Vector3(0.05, 0.12, 0.05), Vector3(0.0, -0.06, 0.0), m_gris)
		_radar_rot = rad


func objetivos_dron() -> Array:
	var r: Array = []
	for o in _objetos:
		r.append(o)
	for c in _cuevas:
		if not c.has_meta("dir_dron"):
			c.set_meta("dir_dron", c.dir_entrada())
		r.append(c)
	for c in _curiosidades:
		if not bool(c.get_meta("leido")):
			r.append(c)
	for h in _hallazgos:
		if not bool(h.get_meta("recogido")):
			r.append(h)
	return r


func dron_objetivo_vigente(o: Node) -> bool:
	if _objetos.has(o) or _cuevas.has(o):
		return true
	if _curiosidades.has(o):
		return not bool(o.get_meta("leido"))
	if _hallazgos.has(o):
		return not bool(o.get_meta("recogido"))
	return false


func _alimentar_dron() -> void:
	_dron.oculto = not activo or _terminada or _en_briefing or _salida != 0 or _dentro > 0.4 or _tut_activo or _visor
	_dron.robot_fwd = _fwd
	_dron.robot_vel = _vel / k
	_dron.objetivo = _guia_dir_ult if int(Ajustes.guia_objetivo) > 0 else Vector3.ZERO
	_dron.tormenta = _tormenta_estado >= 1
	_dron.noche = 1.0 - dia_f


var _focos_saludo: bool = false


func _on_dron_estado(e: int) -> void:
	if _hud == null or e != Dron.E.ESCOLTA:
		return
	if int(MetaEstado.extra_get("pico_visto", 0)) == 0:
		MetaEstado.extra_set("pico_visto", 1)
		_dron_dice("presentacion", true)
	elif not _focos_saludo:
		_dron_dice("escolta_inicio", true)
	_focos_saludo = true


func _dron_dice(clave: String, forzar: bool = false) -> bool:
	if not Ajustes.radio or _tut_activo or _terminada or _en_briefing or _hud == null:
		return false
	if _dron_cd > 0.0 and not forzar:
		return false
	var t := DronVoz.frase(clave, _n_frame + int(_tiempo * 7.0))
	if t == "":
		return false
	_dron_cd = 7.0
	_focos_habla(t)
	return true


func _focos_habla(t: String, seg: float = 5.0) -> void:
	if _hud == null:
		return
	var col: Color = _dron.color_holo() if _dron != null else DronVoz.COLOR
	var estaba: bool = _hud.holo_hablando()
	if _hud.holo_decir("«%s»" % t, col, seg):
		if not estaba:
			_audio.holo(true)
		if _dron != null:
			_dron.habla_t = seg + float(t.length()) / 46.0
		if not _focos_holo_consejo:
			_focos_holo_consejo = true
			get_tree().create_timer(9.0).timeout.connect(_consejo.bind("holo"))
	else:
		_hud.toast(DronVoz.NOMBRE, "«%s»" % t, col, seg)


func _rumbo_focos(ang: float) -> String:
	var a := absf(ang)
	var der := ang > 0.0
	if a < 0.35:
		return Idioma.t("Justo delante.")
	if a < 1.2:
		return Idioma.t("Delante, hacia la derecha.") if der else Idioma.t("Delante, hacia la izquierda.")
	if a < 2.2:
		return Idioma.t("A tu derecha.") if der else Idioma.t("A tu izquierda.")
	return Idioma.t("Detrás de ti.")


func _preguntar_focos() -> void:
	if _tut_activo or _terminada or _en_briefing or _visor or not activo or _hud == null or _focos_ask_cd > 0.0:
		return
	_focos_ask_cd = 2.5
	var p: Array[String] = []
	var quedan := not _objetos.is_empty()
	var base_ya := not _bodega.is_empty() and (_bodega.size() >= capacidad or not quedan)
	if _modo_fotos:
		p.append(Idioma.t("Abre el visor con F y busca los blancos que marca el radar."))
	elif base_ya:
		p.append(Idioma.t("Llevas %d de %d muestras. Hora de entregar." % [_bodega.size(), capacidad]))
		p.append(Idioma.t("La base está a %d m." % int(_arco(_up, _up_b) / k)))
		var rb := _rel(_up_b)
		p.append(_rumbo_focos(atan2(rb.x, rb.y)))
	else:
		var lista: Array = _objetos if int(Ajustes.guia_objetivo) >= 2 else _guia_conocidas.duplicate()
		if _dron != null and int(Ajustes.guia_objetivo) < 2:
			for o in _dron.marcados:
				if not lista.has(o):
					lista.append(o)
		var mejor: Node3D = null
		var d_min := INF
		for o in lista:
			if not is_instance_valid(o) or not _objetos.has(o):
				continue
			var d := _arco(_up, o.get_meta("dir"))
			if d < d_min:
				d_min = d
				mejor = o
		if mejor != null:
			var info := DatosMarte.material(str(mejor.get_meta("mat")))
			var r := _rel(mejor.get_meta("dir"))
			p.append(Idioma.t("La muestra más cercana: %s.") % Idioma.t(str(info["nombre"])))
			p.append(Idioma.t("Está a %d m." % int(d_min / k)))
			p.append(_rumbo_focos(atan2(r.x, r.y)))
		elif quedan:
			p.append(Idioma.t("Aún no veo ninguna muestra. Escanea con ESPACIO y te aviso."))
		elif not _bodega.is_empty():
			p.append(Idioma.t("Ya no quedan muestras. Lleva lo que cargas a la base."))
			var rb2 := _rel(_up_b)
			p.append(_rumbo_focos(atan2(rb2.x, rb2.y)))
		else:
			p.append(Idioma.t("Ya no quedan muestras. ¡Buen trabajo, jefe!"))

	if _riesgos and _energia < 25.0:
		p.append(Idioma.t("Ojo con la batería: queda el %d por ciento. Evita el turbo y las cuestas." % int(_energia)))
	elif _tormenta_estado >= 1:
		p.append(Idioma.t("Hay tormenta: los paneles no cargan. Ve con calma."))
	elif dia_f < 0.25:
		p.append(Idioma.t("Es de noche: ve despacio y fíjate en el radar."))
	elif not _sec.is_empty() and int(_sec.get("estado", 0)) == 1:
		p.append(Idioma.t("Tienes una misión secundaria marcada en el radar."))
	_focos_habla(" ".join(PackedStringArray(p)), 6.0)


func _dron_marca(n: int) -> bool:
	if _dron == null:
		return false
	_dron.alegre_t = 1.5
	var cueva := false
	var muestra := false
	var ult: Array = _dron.marcados.slice(maxi(_dron.marcados.size() - n, 0))
	for o in ult:
		if _cuevas.has(o):
			cueva = true
		elif _objetos.has(o):
			muestra = true
	return _dron_dice("marca_cueva" if cueva else ("marca_muestra" if muestra else "marca_dato"))


func _actualizar_dron_voz(delta: float) -> void:
	if _dron == null or not activo or _terminada or _en_briefing:
		return
	_dron_cd = maxf(_dron_cd - delta, 0.0)
	_focos_ask_cd = maxf(_focos_ask_cd - delta, 0.0)
	_focos_guia_t = maxf(_focos_guia_t - delta, 0.0)
	_dron.asustado = _tormenta_estado >= 1
	if _tormenta_estado >= 1 and _dron_storm_prev == 0 and _dron.acompanando():
		_dron_dice("tormenta_escolta", true)
	_dron_storm_prev = _tormenta_estado
	var acompana: bool = _dron.acompanando()

	if acompana and _riesgos and _energia < 22.0 and not _focos_bat_dicho:
		_focos_bat_dicho = true
		_dron_dice("bateria_robot", true)
	elif _energia > 45.0:
		_focos_bat_dicho = false

	if acompana and _dron.objetivo != Vector3.ZERO and _focos_guia_t <= 0.0 and _tormenta_estado == 0:
		if distancia_gm(_up, _dron.objetivo) > 25.0:
			_focos_guia_t = 70.0
			_dron_dice("guia_base" if (not _bodega.is_empty() and _dron.objetivo.is_equal_approx(_up_b)) else "guia", true)
	_dron_idle -= delta
	if _dron_idle <= 0.0 and _tormenta_estado == 0:
		_dron_idle = 100.0 + float(_n_frame % 60)
		if acompana:
			_dron_dice("escolta_ocioso")
	_dron_n += delta
	if _dron_n < 0.6 or _dron_cd > 0.0:
		return
	_dron_n = 0.0
	for h in _hallazgos:
		if not is_instance_valid(h) or h.visible or bool(h.get_meta("recogido")) or _dron_hall.has(h):
			continue
		var d := distancia_gm(_up, h.get_meta("dir"))
		if d < 30.0:
			_dron_hall.append(h)
			var r := _rel(h.get_meta("dir"))
			var t := DronVoz.frase("hallazgo", 0) % [ConsultaRadio.reloj(atan2(r.x, r.y)), int(d)]
			_dron_cd = 7.0
			_hud.toast(DronVoz.NOMBRE, "«%s»" % t, DronVoz.COLOR, 6.0)
			return


func _dron_festejo(clave: String) -> void:
	if _dron == null:
		return
	_dron.festejar()
	_focos_n += 1
	if _focos_n % 3 == 1 and _dron.acompanando():
		_dron_dice(clave)


func focos_comenta(clave: String) -> void:
	if _dron == null or not _dron.acompanando():
		return
	get_tree().create_timer(3.0).timeout.connect(func():
		if _dron != null and _dron.acompanando():
			_dron_dice(clave))


func _abrir_cuaderno() -> void:
	var d := PantallaDiario.new()
	d.abrir_en = "recuerdos"
	add_child(d)


func _abrir_laboratorio() -> void:
	var lab := Laboratorio.new()
	add_child(lab)


func _ver_final() -> void:
	if _final_hist == "":
		return
	var e := Epilogo.new()
	e.configurar(_final_hist)
	add_child(e)


func _guardar_tarjeta() -> void:
	if _tarjeta_datos.is_empty() or _guardando_tarjeta:
		return
	_guardando_tarjeta = true
	var t := TarjetaResultados.new()
	t.configurar(_tarjeta_datos)
	t.guardada.connect(func(ruta: String):
		_guardando_tarjeta = false
		_hud.tarjeta_guardada(ruta))
	add_child(t)


func _cerrar_ruta() -> Dictionary:
	_ruta.append(_uv_actual())
	if not _exp:
		Rutas.registrar(id_mision, _tiempo, _ruta, _ruta_eventos, dist_base)
		HistoriaEstado.marcar_hecha(id_mision)
	var largo := 0.0
	for i in range(1, _ruta.size()):
		largo += _ruta[i].distance_to(_ruta[i - 1])
	return {"ruta": _ruta, "eventos": _ruta_eventos, "dist_base": dist_base, "distancia": largo}


func _actualizar_flecha() -> void:
	if _terminada or not activo:
		_flecha.visible = false
		return
	var destino := _up_b
	if destino == _up_b and _arco(_up, _up_b) < RADIO_BASE * k:
		_flecha.visible = false
		return
	var d := destino - _up * destino.dot(_up)
	var f := (_fwd - _normal * _fwd.dot(_normal)).normalized()
	var derecha := f.cross(_normal).normalized()
	_flecha.visible = true
	_flecha.rotation.y = atan2(-d.dot(derecha), d.dot(f))


func _formato_tiempo(t: float) -> String:
	var s := int(t)
	return "%d:%02d" % [floori(s / 60.0), s % 60]


func _alternar_captura() -> void:
	_modo_captura = not _modo_captura
	if _modo_captura:
		_hud.visible = false
		_cap_yaw = 0.0
		_cap_pitch = 33.0
		_cap_zoom = _zoom
		if _cap_capa == null:
			_crear_capa_captura()
		_cap_capa.visible = true
		_cap_ayuda.visible = true
		_cap_msg.text = ""
		_aplicar_filtro_foto()
		_cap_filtro.visible = true
		get_tree().create_timer(1.0).timeout.connect(_consejo_foto)
	else:
		_hud.visible = true
		if _cap_capa != null:
			_cap_capa.visible = false
		if _cap_filtro != null:
			_cap_filtro.visible = false


func _consejo_foto() -> void:
	if not _modo_captura:
		return
	var c := AyudaContextual.tomar("foto")
	if c.is_empty():
		return
	_cap_msg.text = "%s: %s" % [Idioma.t(str(c["t"])), Idioma.t(str(c["x"]))]


func _aplicar_filtro_foto() -> void:
	var amb: Dictionary = datos.get("amb", {})
	var cap := _cap_filtro as ModoFoto.Capa
	cap.datos = {"nombre": nombre, "sol": int(datos.get("sol", 1)), "hora": _ciclo.hora_texto() if _ciclo != null else "",
			"lat": float(datos.get("lat_real", datos.get("lat", 0.0))), "lon": float(datos.get("lon_real", datos.get("lon", 0.0))),
			"temp": float(amb.get("temp", -63.0)) - 38.0 * (1.0 - dia_f)}
	cap.aplicar(ModoFoto.filtro, ModoFoto.marco, ModoFoto.cuadricula)


func _crear_capa_captura() -> void:
	_cap_filtro = ModoFoto.Capa.new()
	_cap_filtro.visible = false
	add_child(_cap_filtro)
	_cap_capa = CanvasLayer.new()
	_cap_capa.layer = 60
	add_child(_cap_capa)
	_cap_flash = ColorRect.new()
	_cap_flash.color = Color(1, 1, 1, 0)
	_cap_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cap_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cap_capa.add_child(_cap_flash)
	_cap_ayuda = EstiloUI.etiqueta_contorno("MODO FOTO   ·   clic y arrastra o flechas: orbitar   ·   RUEDA: zoom   ·   ENTER: capturar\nF: filtro   ·   M: marco   ·   G: cuadrícula   ·   H: ocultar este texto   ·   P o ESC: salir", 16, EstiloUI.COL_TEXTO, false)
	_cap_ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cap_ayuda.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_cap_ayuda.offset_top = -72.0
	_cap_ayuda.offset_bottom = -16.0
	_cap_capa.add_child(_cap_ayuda)
	_cap_msg = EstiloUI.etiqueta_contorno("", 20, EstiloUI.COL_OK, true)
	_cap_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cap_msg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_cap_msg.offset_top = 24.0
	_cap_msg.offset_bottom = 60.0
	_cap_msg.offset_left = 80.0
	_cap_msg.offset_right = -80.0
	_cap_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cap_capa.add_child(_cap_msg)


func _entrada_captura(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P, KEY_ESCAPE:
				_alternar_captura()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_guardar_captura()
			KEY_H:
				_cap_ayuda.visible = not _cap_ayuda.visible
			KEY_F:
				_cap_msg.text = "Filtro: %s" % Idioma.t(ModoFoto.siguiente_filtro())
				_aplicar_filtro_foto()
			KEY_M:
				_cap_msg.text = "Marco: %s" % Idioma.t(ModoFoto.siguiente_marco())
				_aplicar_filtro_foto()
			KEY_G:
				ModoFoto.cuadricula = not ModoFoto.cuadricula
				_cap_msg.text = "Cuadrícula: %s" % ("activada" if ModoFoto.cuadricula else "apagada")
				_aplicar_filtro_foto()
	elif event is InputEventMouseMotion:
		if (event.button_mask & (MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT)) != 0:
			_cap_yaw -= event.relative.x * 0.006
			_cap_pitch = clampf(_cap_pitch + event.relative.y * 0.3, -4.0, 86.0)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cap_zoom = clampf(_cap_zoom * 0.92, 0.25, 3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cap_zoom = clampf(_cap_zoom * 1.09, 0.25, 3.0)


func _actualizar_captura(delta: float) -> void:
	_cap_yaw += (float(_tecla(KEY_LEFT, KEY_A)) - float(_tecla(KEY_RIGHT, KEY_D))) * 1.2 * delta
	_cap_pitch = clampf(_cap_pitch + (float(_tecla(KEY_UP, KEY_W)) - float(_tecla(KEY_DOWN, KEY_S))) * 40.0 * delta, -4.0, 86.0)
	var objetivo := _pos_robot + _up * (1.5 * k)
	var atras := (-_cam_fwd).rotated(_up, _cap_yaw)
	var p := deg_to_rad(_cap_pitch)
	var pos := objetivo + (atras * cos(p) + _up * sin(p)) * (19.1 * k * _cap_zoom)
	var dc := pos.normalized()
	var alt := pos.length() - (planet.radius + _altura(dc))
	if alt < 1.2 * k:
		pos += dc * (1.2 * k - alt)
	_cam_pos_s = pos
	cam_pos = pos
	cam_basis = Basis.looking_at(objetivo - pos, _up)


func _guardar_captura() -> void:
	var ayuda_vis := _cap_ayuda.visible
	_cap_ayuda.visible = false
	_cap_msg.visible = false
	(_cap_filtro as ModoFoto.Capa).guias(false, ModoFoto.cuadricula)
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var ruta := ModoFoto.guardar(img)
	_cap_ayuda.visible = ayuda_vis
	_cap_msg.visible = true
	(_cap_filtro as ModoFoto.Capa).guias(true, ModoFoto.cuadricula)
	_cap_msg.text = (Idioma.t("Foto guardada en el álbum: %s") % ruta) if ruta != "" else "No se pudo guardar la captura"
	_cap_flash.color = Color(1, 1, 1, 0.8)
	create_tween().tween_property(_cap_flash, "color:a", 0.0, 0.35)
	_audio.paso()


func _actualizar_camara(delta: float, inmediato: bool) -> void:
	if _cine != null and _cine.activa:
		cam_pos = _cine.cam_pos
		cam_basis = _cine.cam_basis
		_cam_pos_s = cam_pos
		return
	if _visor:

		_cam_pos_s = _pos_robot + _up * (ALTURA_MASTIL * k)
		cam_pos = _cam_pos_s
		cam_basis = Basis.looking_at(_visor_dir(), _up)
		return
	var a := 1.0 if inmediato else 1.0 - exp(-4.0 * delta)
	_cam_fwd = _cam_fwd.lerp(_fwd, a)
	_cam_fwd = _cam_fwd - _up * _cam_fwd.dot(_up)
	if _cam_fwd.length() < 0.001:
		_cam_fwd = _fwd
	_cam_fwd = _cam_fwd.normalized()

	var objetivo := _pos_robot + _up * (1.5 * k)
	if _intro_k > 1.0:
		_intro_k = move_toward(_intro_k, 1.0, delta * 0.3)
	var zz := _zoom * _intro_k
	var deseada := _pos_robot - _cam_fwd * (16.0 * k * zz) + _up * (10.5 * k * zz)
	if inmediato:
		_cam_pos_s = deseada
	else:
		_cam_pos_s = _cam_pos_s.lerp(deseada, 1.0 - exp(-9.0 * delta))


	var dc := _cam_pos_s.normalized()
	if _n_frame % 2 == 0:
		_cam_h_terreno = _altura(dc)
	var alt := _cam_pos_s.length() - (planet.radius + _cam_h_terreno)
	var minimo := 2.5 * k
	if alt < minimo:
		_cam_pos_s += dc * (minimo - alt)

	cam_pos = _cam_pos_s
	cam_basis = Basis.looking_at(objetivo - _cam_pos_s, _up)
