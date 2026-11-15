extends RefCounted


const MAX_COPIAS := 5
const CARPETA := "copias"


static func _dir(base: String) -> String:
	return "%s/%s" % [base, CARPETA]


static func sano(ruta: String) -> bool:
	if not FileAccess.file_exists(ruta):
		return false
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return false
	if f.get_length() == 0:
		return false
	if ruta.ends_with(".json"):
		var js := JSON.new()
		if js.parse(f.get_as_text()) != OK:
			return false
		return js.data is Dictionary or js.data is Array
	if ruta.ends_with(".cfg"):
		f.close()
		var cfg := ConfigFile.new()
		return cfg.load(ruta) == OK
	return true


static func listar(base: String) -> Array[String]:
	var r: Array[String] = []
	var d := DirAccess.open(_dir(base))
	if d == null:
		return r
	for n in d.get_directories():
		r.append(n)
	r.sort()
	r.reverse()
	return r


static func texto_fecha(nombre: String) -> String:
	if nombre.length() < 13:
		return nombre
	return "%s/%s  %s:%s" % [nombre.substr(6, 2), nombre.substr(4, 2), nombre.substr(9, 2), nombre.substr(11, 2)]


static func _copia_sana(base: String, nombre: String, archivos: Array) -> bool:
	for a in archivos:
		var p := "%s/%s/%s" % [_dir(base), nombre, str(a)]
		if FileAccess.file_exists(p) and not sano(p):
			return false
	return true


static func respaldar(base: String, archivos: Array, con_poda: bool = true) -> String:
	var tiene := false
	for a in archivos:
		var p := "%s/%s" % [base, str(a)]
		if FileAccess.file_exists(p):
			tiene = true
			if not sano(p):
				return ""
	if not tiene:
		return ""
	var t := Time.get_datetime_dict_from_system()
	var nombre := "%04d%02d%02d_%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	while DirAccess.dir_exists_absolute("%s/%s" % [_dir(base), nombre]):
		nombre += "x"
	var destino := "%s/%s" % [_dir(base), nombre]
	DirAccess.make_dir_recursive_absolute(destino)
	for a in archivos:
		var p := "%s/%s" % [base, str(a)]
		if FileAccess.file_exists(p):
			DirAccess.copy_absolute(p, "%s/%s" % [destino, str(a)])
	if con_poda:
		_podar(base)
	return nombre


static func _podar(base: String) -> void:
	var l := listar(base)
	for i in range(MAX_COPIAS, l.size()):
		_borrar_copia(base, l[i])


static func _borrar_copia(base: String, nombre: String) -> void:
	var p := "%s/%s" % [_dir(base), nombre]
	var d := DirAccess.open(p)
	if d == null:
		return
	for f in d.get_files():
		DirAccess.remove_absolute("%s/%s" % [p, f])
	DirAccess.remove_absolute(p)


static func borrar_todo(base: String) -> void:
	for n in listar(base):
		_borrar_copia(base, n)
	DirAccess.remove_absolute(_dir(base))
	var d := DirAccess.open(base)
	if d != null:
		for f in d.get_files():
			if f.ends_with(".dañado"):
				DirAccess.remove_absolute("%s/%s" % [base, f])


static func recuperar(base: String, archivos: Array) -> Array:
	var malos: Array[String] = []
	var hay_otros := false
	for a in archivos:
		var p := "%s/%s" % [base, str(a)]
		if FileAccess.file_exists(p):
			hay_otros = true
			if not sano(p):
				malos.append(str(a))
	if not hay_otros:
		return []

	for a in ["perfil.cfg", "historia.json", "meta.json"]:
		if archivos.has(a) and not FileAccess.file_exists("%s/%s" % [base, a]) and not malos.has(a):
			malos.append(a)
	if malos.is_empty():
		return []
	for nombre in listar(base):
		if not _copia_sana(base, nombre, archivos):
			continue
		var arreglados: Array[String] = []
		for a in malos:
			var origen := "%s/%s/%s" % [_dir(base), nombre, a]
			if not FileAccess.file_exists(origen):
				continue
			var actual := "%s/%s" % [base, a]
			if FileAccess.file_exists(actual):
				DirAccess.copy_absolute(actual, actual + ".dañado")
			if DirAccess.copy_absolute(origen, actual) == OK:
				arreglados.append(a)
		if not arreglados.is_empty():
			return [nombre, arreglados]
	return []


static func restaurar(base: String, archivos: Array, nombre: String) -> bool:
	var origen := "%s/%s" % [_dir(base), nombre]
	if not DirAccess.dir_exists_absolute(origen):
		return false
	respaldar(base, archivos, false)
	for a in archivos:
		var o := "%s/%s" % [origen, str(a)]
		var destino := "%s/%s" % [base, str(a)]
		if FileAccess.file_exists(o):
			DirAccess.copy_absolute(o, destino)
		elif FileAccess.file_exists(destino):
			DirAccess.remove_absolute(destino)
	return true
