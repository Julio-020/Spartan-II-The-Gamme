extends RefCounted


const Rutas := preload("res://progreso/rutas.gd")

const Partidas := preload("res://nucleo/partidas.gd")

const MEDALLAS := {
	"ruta": {"n": "Ruta directa", "d": "Tu camino fue casi una línea recta (60 % o más).", "c": Color(1.0, 0.78, 0.25)},
	"bateria": {"n": "Batería de sobra", "d": "No bajaste del 30 % de batería (con Riesgos activados).", "c": Color(0.45, 0.95, 0.55)},
	"curioso": {"n": "Curioso", "d": "Leíste todos los datos curiosos de la misión.", "c": Color(0.45, 0.82, 1.0)},
	"superviviente": {"n": "Superviviente", "d": "Sobreviviste a 2 o más eventos aleatorios en una misma misión.", "c": Color(1.0, 0.45, 0.35)},
	"decisivo": {"n": "Decisivo", "d": "Respondiste a tiempo la decisión de tu jefe.", "c": Color(0.78, 0.58, 1.0)},
}


const RANGOS := [
	{"n": "CADETE", "f": "CADETE", "p": 0},
	{"n": "EXPLORADOR", "f": "EXPLORADORA", "p": 30},
	{"n": "PILOTO", "f": "PILOTO", "p": 70},
	{"n": "CAPITÁN", "f": "CAPITANA", "p": 130},
	{"n": "COMANDANTE", "f": "COMANDANTE", "p": 220},
]

static var _datos: Dictionary = {}
static var _cargado: bool = false


static func _archivo() -> String:
	return Partidas.ruta("logros.json")


static func invalidar() -> void:
	_cargado = false
	_datos = {}


static func cargar() -> void:
	_cargado = true
	_datos = {}
	if not FileAccess.file_exists(_archivo()):
		return
	var f := FileAccess.open(_archivo(), FileAccess.READ)
	if f == null:
		return
	var j: Variant = JSON.parse_string(f.get_as_text())
	if j is Dictionary and (j as Dictionary).get("misiones", null) is Dictionary:
		_datos = (j as Dictionary)["misiones"]


static func guardar() -> void:
	var f := FileAccess.open(_archivo(), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"version": 1, "misiones": _datos}))


static func obtener(id: String) -> Dictionary:
	if not _cargado:
		cargar()
	var r: Variant = _datos.get(id, {})
	return r if r is Dictionary else {}


static func medallas(id: String) -> Array:
	var r: Variant = obtener(id).get("medallas", [])
	return r if r is Array else []


static func total_medallas() -> int:
	if not _cargado:
		cargar()
	var n := 0
	for id in _datos:
		n += medallas(str(id)).size()
	return n


static func puntos() -> int:
	if not _cargado:
		cargar()
	var extra := 0
	for id in _datos:
		if int((_datos[id] as Dictionary).get("dif", 1)) >= 2:
			extra += 5
	return Rutas.completadas() * 10 + total_medallas() * 5 + extra


static func rango_idx() -> int:
	var p := puntos()
	var idx := 0
	for i in range(RANGOS.size()):
		if p >= int(RANGOS[i]["p"]):
			idx = i
	return idx


static func rango_nombre(genero: int = 0) -> String:
	var r: Dictionary = RANGOS[rango_idx()]
	return str(r["f"] if genero == 1 else r["n"])


static func progreso(genero: int = 0) -> Dictionary:
	var i := rango_idx()
	var res := {"idx": i, "nombre": rango_nombre(genero), "puntos": puntos(), "sig_nombre": "", "sig_puntos": 0}
	if i + 1 < RANGOS.size():
		var s: Dictionary = RANGOS[i + 1]
		res["sig_nombre"] = str(s["f"] if genero == 1 else s["n"])
		res["sig_puntos"] = int(s["p"])
	return res


static func _evaluar(d: Dictionary) -> Array:
	var m: Array = []
	if float(d.get("eficiencia", 0.0)) >= 0.6:
		m.append("ruta")
	if bool(d.get("riesgos", false)) and float(d.get("energia_min", 0.0)) >= 30.0:
		m.append("bateria")
	if int(d.get("total_curiosos", 0)) > 0 and int(d.get("leidas", 0)) >= int(d.get("total_curiosos", 0)):
		m.append("curioso")
	if str(d.get("decision", "")) != "":
		m.append("decisivo")
	if int(d.get("eventos", 0)) >= 2:
		m.append("superviviente")
	return m


static func registrar(id: String, d: Dictionary) -> Array:
	if not _cargado:
		cargar()
	var previo := obtener(id)
	var antes: Array = medallas(id)
	var ahora: Array = _evaluar(d)
	var union: Array = antes.duplicate()
	var nuevas: Array = []
	for m in ahora:
		if not union.has(m):
			union.append(m)
			nuevas.append(m)
	var mejor_t := float(d.get("tiempo", 0.0))
	if previo.has("tiempo"):
		mejor_t = minf(mejor_t, float(previo["tiempo"]))
	_datos[id] = {
		"medallas": union,
		"tiempo": snappedf(mejor_t, 0.1),
		"eficiencia": snappedf(maxf(float(d.get("eficiencia", 0.0)), float(previo.get("eficiencia", 0.0))), 0.01),
		"curiosos": [int(d.get("leidas", 0)), int(d.get("total_curiosos", 0))],
		"decision": str(d.get("decision", previo.get("decision", ""))),
		"dif": maxi(int(d.get("dificultad", 1)), int(previo.get("dif", 0))),
		"veces": int(previo.get("veces", 0)) + 1,
		"fecha": Time.get_datetime_string_from_system(false, true),
	}
	guardar()
	return nuevas
