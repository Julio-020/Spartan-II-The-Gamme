extends RefCounted


const Partidas := preload("res://nucleo/partidas.gd")
const AvisoGuardado := preload("res://nucleo/aviso_guardado.gd")

static var _d: Dictionary = {}
static var _cargado: bool = false


static func _archivo() -> String:
	return Partidas.ruta("meta.json")


static func _vacio() -> Dictionary:
	return {"stock": {}, "total": {}, "datos": 0, "datos_total": 0, "niveles": {}, "hallazgos": [],
			"analisis": 0, "perfectos": 0, "expediciones": {}, "mejor_exp": 0, "extra": {}}


static func invalidar() -> void:
	_cargado = false
	_d = {}


static func cargar() -> void:
	_cargado = true
	_d = _vacio()
	if not FileAccess.file_exists(_archivo()):
		return
	var f := FileAccess.open(_archivo(), FileAccess.READ)
	if f == null:
		return
	var j: Variant = JSON.parse_string(f.get_as_text())
	if j is Dictionary:
		for k in (j as Dictionary):
			_d[k] = (j as Dictionary)[k]


static func guardar() -> void:
	if not _cargado:
		return
	var f := FileAccess.open(_archivo(), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(_d))


static func _asegurar() -> void:
	if not _cargado:
		cargar()


static func extra_get(clave: String, defecto: Variant = null) -> Variant:
	_asegurar()
	var e: Variant = _d.get("extra", {})
	if e is Dictionary:
		return (e as Dictionary).get(clave, defecto)
	return defecto


static func extra_set(clave: String, valor: Variant) -> void:
	_asegurar()
	if not (_d.get("extra", null) is Dictionary):
		_d["extra"] = {}
	(_d["extra"] as Dictionary)[clave] = valor
	guardar()


static func perder_muestras(n: int) -> int:
	_asegurar()
	var st: Dictionary = _d["stock"]
	var quitadas := 0
	while quitadas < n:
		var mejor := ""
		var mejor_n := 0
		for k in st:
			if int(st[k]) > mejor_n:
				mejor_n = int(st[k])
				mejor = str(k)
		if mejor == "":
			break
		st[mejor] = int(st[mejor]) - 1
		quitadas += 1
	if quitadas > 0:
		guardar()
	return quitadas


static func stock() -> Dictionary:
	_asegurar()
	return (_d["stock"] as Dictionary).duplicate()


static func stock_total() -> int:
	_asegurar()
	var n := 0
	for k in (_d["stock"] as Dictionary):
		n += int((_d["stock"] as Dictionary)[k])
	return n


static func total_recogido() -> int:
	_asegurar()
	var n := 0
	for k in (_d["total"] as Dictionary):
		n += int((_d["total"] as Dictionary)[k])
	return n


static func ingresar(entregados: Dictionary) -> void:
	_asegurar()
	for id in entregados:
		var n := int(entregados[id])
		if n <= 0:
			continue
		(_d["stock"] as Dictionary)[str(id)] = int((_d["stock"] as Dictionary).get(str(id), 0)) + n
		(_d["total"] as Dictionary)[str(id)] = int((_d["total"] as Dictionary).get(str(id), 0)) + n
	guardar()


static func datos() -> int:
	_asegurar()
	return int(_d["datos"])


static func datos_total() -> int:
	_asegurar()
	return int(_d["datos_total"])


static func sumar_datos(n: int) -> void:
	if n <= 0:
		return
	_asegurar()
	_d["datos"] = int(_d["datos"]) + n
	_d["datos_total"] = int(_d["datos_total"]) + n
	guardar()


static func consumir(material: String) -> bool:
	_asegurar()
	var st: Dictionary = _d["stock"]
	if int(st.get(material, 0)) <= 0:
		return false
	st[material] = int(st[material]) - 1
	guardar()
	return true


static func puede_pagar(muestras: int, datos_: int) -> bool:
	return stock_total() >= muestras and datos() >= datos_


static func gastar(muestras: int, datos_: int) -> bool:
	if not puede_pagar(muestras, datos_):
		return false
	var resto := muestras
	var st: Dictionary = _d["stock"]
	while resto > 0:
		var mejor := ""
		var mejor_n := 0
		for k in st:
			if int(st[k]) > mejor_n:
				mejor_n = int(st[k])
				mejor = str(k)
		if mejor == "":
			break
		st[mejor] = mejor_n - 1
		resto -= 1
	_d["datos"] = int(_d["datos"]) - datos_
	guardar()
	return true


static func nivel(rama: String) -> int:
	_asegurar()
	return int((_d["niveles"] as Dictionary).get(rama, 0))


static func fijar_nivel(rama: String, n: int) -> void:
	_asegurar()
	(_d["niveles"] as Dictionary)[rama] = n
	guardar()


static func niveles_total() -> int:
	_asegurar()
	var n := 0
	for k in (_d["niveles"] as Dictionary):
		n += int((_d["niveles"] as Dictionary)[k])
	return n


static func hallazgo_hecho(id: String) -> bool:
	_asegurar()
	return (_d["hallazgos"] as Array).has(id)


static func num_hallazgos() -> int:
	_asegurar()
	return (_d["hallazgos"] as Array).size()


static func marcar_hallazgo(id: String) -> bool:
	_asegurar()
	if (_d["hallazgos"] as Array).has(id):
		return false
	(_d["hallazgos"] as Array).append(id)
	guardar()
	return true


static func analisis_hechos() -> int:
	_asegurar()
	return int(_d["analisis"])


static func registrar_analisis(perfecto: bool) -> void:
	_asegurar()
	_d["analisis"] = int(_d["analisis"]) + 1
	if perfecto:
		_d["perfectos"] = int(_d["perfectos"]) + 1
	guardar()
	AvisoGuardado.mostrar()


static func records_exp(semilla: int) -> Array:
	_asegurar()
	var r: Variant = (_d["expediciones"] as Dictionary).get(str(semilla), [])
	return r if r is Array else []


static func mejor_exp() -> int:
	_asegurar()
	return int(_d["mejor_exp"])


static func registrar_exp(semilla: int, puntos: int, nombre: String, tiempo: float) -> int:
	_asegurar()
	var lista: Array = records_exp(semilla).duplicate()
	lista.append({"p": puntos, "n": nombre, "t": snappedf(tiempo, 0.1)})
	lista.sort_custom(func(a, b): return int(a["p"]) > int(b["p"]))
	var pos := 0
	for i in range(lista.size()):
		if int(lista[i]["p"]) == puntos and str(lista[i]["n"]) == nombre and absf(float(lista[i]["t"]) - snappedf(tiempo, 0.1)) < 0.01:
			pos = i + 1
			break
	if lista.size() > 10:
		lista.resize(10)
	if pos > 10:
		pos = 0
	(_d["expediciones"] as Dictionary)[str(semilla)] = lista
	_d["mejor_exp"] = maxi(int(_d["mejor_exp"]), puntos)
	guardar()
	return pos
