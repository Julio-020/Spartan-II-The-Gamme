extends RefCounted


const RUTA := "user://ajustes.cfg"
const Partidas := preload("res://nucleo/partidas.gd")
const BUS_MUSICA := "Musica"
const BUS_EFECTOS := "Efectos"


static var vol_general: float = 0.8
static var vol_musica: float = 0.6
static var vol_efectos: float = 0.8
static var silencio: bool = false


static var pantalla_completa: bool = false
static var resolucion: int = 0
static var vsync: bool = true
static var msaa: int = 1
const RESOLUCIONES := [Vector2i(0, 0), Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]
static var escala_3d: float = 1.0
static var mostrar_fps: bool = false
static var calidad_ambiente: int = 2
static var calidad: int = 2
static var sala_3d: bool = true


static var sens_giro: float = 1.0
static var giro_auto: bool = true


static var ver_intro: bool = true
static var musica_dinamica: bool = true


static var texto_grande: int = 0
static var daltonismo: int = 0
static var idioma: int = 0
static var suenos: int = 1
static var holograma: int = 1
static var pistas: int = 1
static var consejos: int = 1
static var guia_objetivo: int = 1


const NOMBRE_DEFECTO := "Piloto"
const NOMBRE_MAX := 16
static var nombre: String = ""
static var genero: int = 0
static var piel: int = 0
static var pelo: int = 1
static var perfil_hecho: bool = false


static var campana: int = 0
static var misiones_libres: bool = false
static var riesgos: bool = true
static var dificultad: int = 1
static var radio: bool = true
static var ciclo_dia: bool = true
static var eventos: bool = true
static var programa_visto: bool = false
static var tutorial_hecho: bool = false
static var graficos_reales: bool = true


static func factor_texto() -> float:
	return [1.0, 1.25, 1.5][clampi(texto_grande, 0, 2)]


static func aplicar_calidad(n: int) -> void:
	calidad = clampi(n, 0, 2)
	match calidad:
		0:
			msaa = 0
			escala_3d = 0.7
			graficos_reales = false
			calidad_ambiente = 0
		1:
			msaa = 1
			escala_3d = 0.85
			graficos_reales = true
			calidad_ambiente = 1
		_:
			msaa = 2
			escala_3d = 1.0
			graficos_reales = true
			calidad_ambiente = 2


static func calidad_para_fps(fps: float) -> int:
	if fps < 30.0:
		return 0
	if fps < 50.0:
		return 1
	return 2


static func reiniciar_campana() -> void:
	campana = 0


static func nombre_visible() -> String:
	var n := nombre.strip_edges()
	return NOMBRE_DEFECTO if n.is_empty() else n


static func rango() -> String:

	var logros = load("res://progreso/logros.gd")
	return logros.rango_nombre(genero)


static func leer(clave: String) -> Variant:
	match clave:
		"vol_general": return vol_general
		"vol_musica": return vol_musica
		"vol_efectos": return vol_efectos
		"silencio": return silencio
		"pantalla_completa": return pantalla_completa
		"resolucion": return resolucion
		"vsync": return vsync
		"msaa": return msaa
		"escala_3d": return escala_3d
		"mostrar_fps": return mostrar_fps
		"calidad_ambiente": return calidad_ambiente
		"calidad": return calidad
		"sala_3d": return sala_3d
		"sens_giro": return sens_giro
		"giro_auto": return giro_auto
		"ver_intro": return ver_intro
		"musica_dinamica": return musica_dinamica
		"texto_grande": return texto_grande
		"daltonismo": return daltonismo
		"idioma": return idioma
		"guia_objetivo": return guia_objetivo
		"consejos": return consejos
		"pistas": return pistas
		"holograma": return holograma
		"suenos": return suenos
		"nombre": return nombre
		"genero": return genero
		"piel": return piel
		"pelo": return pelo
		"perfil_hecho": return perfil_hecho
		"campana": return campana
		"misiones_libres": return misiones_libres
		"riesgos": return riesgos
		"graficos_reales": return graficos_reales
		"dificultad": return dificultad
		"radio": return radio
		"ciclo_dia": return ciclo_dia
		"eventos": return eventos
		"programa_visto": return programa_visto
		"tutorial_hecho": return tutorial_hecho
	return null


static func escribir(clave: String, valor: Variant) -> void:
	match clave:
		"vol_general": vol_general = float(valor)
		"vol_musica": vol_musica = float(valor)
		"vol_efectos": vol_efectos = float(valor)
		"silencio": silencio = bool(valor)
		"pantalla_completa": pantalla_completa = bool(valor)
		"resolucion": resolucion = clampi(int(valor), 0, RESOLUCIONES.size() - 1)
		"vsync": vsync = bool(valor)
		"msaa": msaa = int(valor)
		"escala_3d": escala_3d = float(valor)
		"mostrar_fps": mostrar_fps = bool(valor)
		"calidad_ambiente": calidad_ambiente = clampi(int(valor), 0, 2)
		"calidad": calidad = clampi(int(valor), 0, 2)
		"sala_3d": sala_3d = bool(valor)
		"sens_giro": sens_giro = float(valor)
		"giro_auto": giro_auto = bool(valor)
		"ver_intro": ver_intro = bool(valor)
		"musica_dinamica": musica_dinamica = bool(valor)
		"texto_grande": texto_grande = clampi(int(valor), 0, 2)
		"daltonismo": daltonismo = clampi(int(valor), 0, 3)
		"idioma": idioma = clampi(int(valor), 0, 1)
		"guia_objetivo": guia_objetivo = clampi(int(valor), 0, 2)
		"consejos": consejos = clampi(int(valor), 0, 1)
		"pistas": pistas = clampi(int(valor), 0, 1)
		"holograma": holograma = clampi(int(valor), 0, 1)
		"suenos": suenos = clampi(int(valor), 0, 1)
		"nombre": nombre = str(valor).strip_edges().left(NOMBRE_MAX)
		"genero": genero = clampi(int(valor), 0, 1)
		"piel": piel = clampi(int(valor), 0, 3)
		"pelo": pelo = clampi(int(valor), 0, 3)
		"perfil_hecho": perfil_hecho = bool(valor)
		"campana": campana = clampi(int(valor), 0, 99)
		"misiones_libres": misiones_libres = bool(valor)
		"riesgos": riesgos = bool(valor)
		"graficos_reales": graficos_reales = bool(valor)
		"dificultad": dificultad = clampi(int(valor), 0, 2)
		"radio": radio = bool(valor)
		"ciclo_dia": ciclo_dia = bool(valor)
		"eventos": eventos = bool(valor)
		"programa_visto": programa_visto = bool(valor)
		"tutorial_hecho": tutorial_hecho = bool(valor)


const CLAVES := ["vol_general", "vol_musica", "vol_efectos", "silencio",
		"pantalla_completa", "resolucion", "vsync", "msaa", "escala_3d", "mostrar_fps", "calidad_ambiente", "calidad", "sala_3d",
		"sens_giro", "giro_auto", "ver_intro", "musica_dinamica", "texto_grande", "daltonismo", "idioma", "guia_objetivo", "consejos", "pistas", "holograma", "suenos", "nombre", "genero", "piel", "pelo", "perfil_hecho", "campana", "misiones_libres", "riesgos", "graficos_reales", "dificultad", "radio", "ciclo_dia", "eventos", "programa_visto", "tutorial_hecho"]


static func restablecer() -> void:
	vol_general = 0.8
	vol_musica = 0.6
	vol_efectos = 0.8
	silencio = false
	pantalla_completa = false
	resolucion = 0
	vsync = true
	msaa = 1
	escala_3d = 1.0
	mostrar_fps = false
	calidad_ambiente = 2
	calidad = 2
	sala_3d = true
	sens_giro = 1.0
	giro_auto = true
	ver_intro = true
	musica_dinamica = true
	texto_grande = 0
	daltonismo = 0
	guia_objetivo = 1
	consejos = 1
	pistas = 1
	holograma = 1
	suenos = 1
	riesgos = true
	graficos_reales = true
	dificultad = 1
	radio = true
	ciclo_dia = true
	eventos = true


static func cargar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(RUTA) != OK:
		return
	for clave in CLAVES:
		var actual: Variant = leer(clave)
		escribir(clave, cfg.get_value("ajustes", clave, actual))


static func guardar() -> void:
	var cfg := ConfigFile.new()
	for clave in CLAVES:
		cfg.set_value("ajustes", clave, leer(clave))
	cfg.save(RUTA)
	Partidas.guardar_perfil()


static func aplicar(vp: Viewport) -> void:
	aplicar_audio()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pantalla_completa
			else DisplayServer.WINDOW_MODE_WINDOWED)
	if not pantalla_completa and resolucion > 0 and resolucion < RESOLUCIONES.size():
		var tam: Vector2i = RESOLUCIONES[resolucion]
		var pant := DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
		tam = Vector2i(mini(tam.x, pant.x), mini(tam.y, pant.y))
		if DisplayServer.window_get_size() != tam:
			DisplayServer.window_set_size(tam)
			var origen := DisplayServer.screen_get_position(DisplayServer.window_get_current_screen())
			DisplayServer.window_set_position(origen + (pant - tam) / 2)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync
			else DisplayServer.VSYNC_DISABLED)
	if vp != null:
		match msaa:
			1: vp.msaa_3d = Viewport.MSAA_2X
			2: vp.msaa_3d = Viewport.MSAA_4X
			_: vp.msaa_3d = Viewport.MSAA_DISABLED
		vp.scaling_3d_scale = clampf(escala_3d, 0.5, 1.0)


static func asegurar_buses() -> void:
	_crear_bus(BUS_MUSICA)
	_crear_bus(BUS_EFECTOS)


static func _crear_bus(nombre: String) -> void:
	if AudioServer.get_bus_index(nombre) != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, nombre)
	AudioServer.set_bus_send(idx, "Master")


static func _db(v: float) -> float:
	return -80.0 if v <= 0.001 else linear_to_db(v)


static func aplicar_audio() -> void:
	asegurar_buses()
	AudioServer.set_bus_volume_db(0, _db(vol_general))
	AudioServer.set_bus_mute(0, silencio)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSICA), _db(vol_musica))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_EFECTOS), _db(vol_efectos))
