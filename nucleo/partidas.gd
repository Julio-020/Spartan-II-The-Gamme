extends RefCounted


const MAX_RANURAS := 3
const TOTAL_MISIONES := 23
const ARCHIVOS := ["perfil.cfg", "historia.json", "comite.json", "logros.json", "rutas.json", "meta.json", "bitacora.json", "bitacora.txt"]
const CARPETAS := ["fotos", "tarjetas", "capturas", "archivo"]
const COPIAS := preload("res://nucleo/copia_seguridad.gd")
const INTERVALO_COPIA := 300


const PERFIL_DEFECTOS := {
	"nombre": "", "genero": 0, "piel": 0, "pelo": 1, "perfil_hecho": false,
	"campana": 0, "tutorial_hecho": false, "misiones_libres": false, "dificultad": 1,
}

static var slot: int = 0
static var aviso: String = ""
static var _ult_copia: int = 0
static var _ult_hechas: int = -1
static var _copia_pendiente: bool = false


static func carpeta_de(n: int) -> String:
	return "user://ranura_%d" % n


static func ruta(archivo: String) -> String:
	if slot > 0:
		return "%s/%s" % [carpeta_de(slot), archivo]
	return "user://" + archivo


static func subcarpeta(nombre: String) -> String:
	return ruta(nombre)


static func existe(n: int) -> bool:
	return FileAccess.file_exists(carpeta_de(n) + "/perfil.cfg")


static func resumen(n: int) -> Dictionary:
	var r := {"existe": false}
	var cfg := ConfigFile.new()
	if cfg.load(carpeta_de(n) + "/perfil.cfg") != OK:
		return r
	r["existe"] = true
	r["nombre"] = str(cfg.get_value("perfil", "nombre", ""))
	r["genero"] = int(cfg.get_value("perfil", "genero", 0))
	r["piel"] = int(cfg.get_value("perfil", "piel", 0))
	r["pelo"] = int(cfg.get_value("perfil", "pelo", 1))
	r["hecho"] = bool(cfg.get_value("perfil", "perfil_hecho", false))
	r["rango"] = str(cfg.get_value("resumen", "rango", ""))
	r["hechas"] = int(cfg.get_value("resumen", "hechas", 0))
	r["medallas"] = int(cfg.get_value("resumen", "medallas", 0))
	r["ultima"] = int(cfg.get_value("resumen", "ultima", 0))
	r["pct"] = clampi(int(round(100.0 * float(r["hechas"]) / float(TOTAL_MISIONES))), 0, 100)
	return r


static func fecha_texto(t: int) -> String:
	if t <= 0:
		return "—"
	var d := Time.get_datetime_dict_from_unix_time(t + int(Time.get_time_zone_from_system().get("bias", 0)) * 60)
	return "%02d/%02d/%04d  %02d:%02d" % [d["day"], d["month"], d["year"], d["hour"], d["minute"]]


static func ultima_ranura() -> int:
	var mejor := 0
	var t_mejor := -1
	for n in range(1, MAX_RANURAS + 1):
		var r := resumen(n)
		if bool(r["existe"]) and int(r["ultima"]) > t_mejor:
			t_mejor = int(r["ultima"])
			mejor = n
	return mejor


static func entrar(n: int) -> void:
	n = clampi(n, 1, MAX_RANURAS)
	slot = n
	DirAccess.make_dir_recursive_absolute(carpeta_de(n))
	var nueva := not existe(n)
	_invalidar_caches()
	if nueva:
		for clave: String in PERFIL_DEFECTOS:
			_aj_escribir(clave, PERFIL_DEFECTOS[clave])
		guardar_perfil()
	else:
		recuperar_ranura(n)
		_cargar_perfil()
		_ult_copia = 0
		_planear_copia()


static func guardar_perfil() -> void:
	if slot <= 0:
		return
	DirAccess.make_dir_recursive_absolute(carpeta_de(slot))
	var cfg := ConfigFile.new()
	for clave: String in PERFIL_DEFECTOS:
		cfg.set_value("perfil", clave, _aj_leer(clave))
	cfg.set_value("resumen", "rango", _rango_actual())
	cfg.set_value("resumen", "hechas", _hechas_actuales())
	cfg.set_value("resumen", "medallas", _medallas_actuales())
	cfg.set_value("resumen", "ultima", int(Time.get_unix_time_from_system()))
	cfg.save(carpeta_de(slot) + "/perfil.cfg")
	_planear_copia()


static func borrar(n: int) -> void:
	var base := carpeta_de(n)
	for a: String in ARCHIVOS:
		_quitar_archivo("%s/%s" % [base, a])
	for c: String in CARPETAS:
		_quitar_carpeta("%s/%s" % [base, c])
	COPIAS.borrar_todo(base)
	DirAccess.remove_absolute(base)
	if slot == n:
		slot = 0
		_invalidar_caches()


static func migrar_legado() -> bool:
	for n in range(1, MAX_RANURAS + 1):
		if existe(n):
			return false
	var hay := false
	for a: String in ["historia.json", "logros.json", "rutas.json", "comite.json", "meta.json"]:
		if FileAccess.file_exists("user://" + a):
			hay = true
	if not hay:
		return false
	var base := carpeta_de(1)
	DirAccess.make_dir_recursive_absolute(base)
	for a: String in ["historia.json", "logros.json", "rutas.json", "comite.json", "meta.json"]:
		if FileAccess.file_exists("user://" + a):
			DirAccess.copy_absolute("user://" + a, "%s/%s" % [base, a])
	for c: String in CARPETAS:
		var origen := "user://" + c
		if DirAccess.dir_exists_absolute(origen):
			_copiar_carpeta(origen, "%s/%s" % [base, c])

	var anterior := slot
	slot = 1
	guardar_perfil()
	slot = anterior
	return true


static func _planear_copia() -> void:
	if slot <= 0 or _copia_pendiente:
		return
	var ahora := int(Time.get_unix_time_from_system())
	if _hechas_actuales() == _ult_hechas and ahora - _ult_copia < INTERVALO_COPIA:
		return
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return
	_copia_pendiente = true
	arbol.create_timer(3.0).timeout.connect(_hacer_copia)


static func _hacer_copia() -> void:
	_copia_pendiente = false
	if slot <= 0:
		return
	var r := COPIAS.respaldar(carpeta_de(slot), ARCHIVOS)
	if r != "":
		_ult_copia = int(Time.get_unix_time_from_system())
		_ult_hechas = _hechas_actuales()


static func recuperar_ranura(n: int) -> bool:
	if not DirAccess.dir_exists_absolute(carpeta_de(n)):
		return false
	var r: Array = COPIAS.recuperar(carpeta_de(n), ARCHIVOS)
	if r.is_empty():
		return false
	aviso = "Partida %d: se recuperó desde la copia del %s (%s)." % [n, COPIAS.texto_fecha(str(r[0])), ", ".join(PackedStringArray(r[1]))]
	_invalidar_caches()
	return true


static func ultima_copia(n: int) -> String:
	var l := COPIAS.listar(carpeta_de(n))
	return "" if l.is_empty() else l[0]


static func restaurar_ultima(n: int) -> bool:
	var c := ultima_copia(n)
	if c == "":
		return false
	var ok := COPIAS.restaurar(carpeta_de(n), ARCHIVOS, c)
	if ok:
		_invalidar_caches()
		if slot == n:
			_cargar_perfil()
	return ok


static func _cargar_perfil() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(carpeta_de(slot) + "/perfil.cfg") != OK:
		return
	for clave: String in PERFIL_DEFECTOS:
		_aj_escribir(clave, cfg.get_value("perfil", clave, PERFIL_DEFECTOS[clave]))


static func _aj_leer(clave: String) -> Variant:
	return (load("res://nucleo/ajustes.gd") as Script).call("leer", clave)


static func _aj_escribir(clave: String, valor: Variant) -> void:
	(load("res://nucleo/ajustes.gd") as Script).call("escribir", clave, valor)


static func _rango_actual() -> String:
	return str((load("res://nucleo/ajustes.gd") as Script).call("rango"))


static func _hechas_actuales() -> int:
	return int((load("res://progreso/historia_estado.gd") as Script).call("num_hechas"))


static func _medallas_actuales() -> int:
	return int((load("res://progreso/logros.gd") as Script).call("total_medallas"))


static func _invalidar_caches() -> void:
	for ruta_script: String in ["res://progreso/historia_estado.gd", "res://progreso/logros.gd", "res://progreso/rutas.gd", "res://progreso/meta_estado.gd", "res://progreso/bitacora.gd"]:
		(load(ruta_script) as Script).call("invalidar")


static func _quitar_archivo(p: String) -> void:
	if FileAccess.file_exists(p):
		DirAccess.remove_absolute(p)


static func _quitar_carpeta(p: String) -> void:
	var d := DirAccess.open(p)
	if d == null:
		return
	for f in d.get_files():
		DirAccess.remove_absolute("%s/%s" % [p, f])
	DirAccess.remove_absolute(p)


static func _copiar_carpeta(origen: String, destino: String) -> void:
	var d := DirAccess.open(origen)
	if d == null:
		return
	DirAccess.make_dir_recursive_absolute(destino)
	for f in d.get_files():
		DirAccess.copy_absolute("%s/%s" % [origen, f], "%s/%s" % [destino, f])
