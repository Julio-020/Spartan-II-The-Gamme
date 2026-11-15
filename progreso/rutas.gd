extends RefCounted


const DatosMarte := preload("res://datos/datos_marte.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")

const Partidas := preload("res://nucleo/partidas.gd")
const MAX_PUNTOS := 240
const METROS_POR_GM := 100.0

static var _datos: Dictionary = {}
static var _cargado: bool = false


static func _archivo() -> String:
	return Partidas.ruta("rutas.json")


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


static func completadas() -> int:
	if not _cargado:
		cargar()
	return _datos.size()


static func registrar(id: String, tiempo: float, ruta: Array, eventos: Array, dist_base: float) -> void:
	if not _cargado:
		cargar()
	var puntos: Array = _reducir(ruta)
	var largo := 0.0
	for i in range(1, ruta.size()):
		largo += (ruta[i] as Vector2).distance_to(ruta[i - 1] as Vector2)
	var ev: Array = []
	for e in eventos:
		ev.append([snappedf(float(e["u"]), 0.1), snappedf(float(e["v"]), 0.1), str(e["t"])])
	var previo := obtener(id)
	var veces: int = int(previo.get("veces", 0)) + 1
	var mejor := previo.is_empty() or tiempo < float(previo.get("tiempo", 1.0e9))
	if mejor:
		_datos[id] = {
			"tiempo": snappedf(tiempo, 0.1),
			"distancia": snappedf(largo, 0.1),
			"directa": snappedf(dist_base, 0.1),
			"ruta": puntos,
			"eventos": ev,
			"fecha": Time.get_datetime_string_from_system(false, true),
			"veces": veces,
		}
	else:
		previo["veces"] = veces
		_datos[id] = previo
	guardar()


static func _reducir(ruta: Array) -> Array:
	var res: Array = []
	if ruta.is_empty():
		return res
	var paso: int = maxi(1, ceili(float(ruta.size()) / float(MAX_PUNTOS)))
	var i := 0
	while i < ruta.size():
		var p: Vector2 = ruta[i]
		res.append([snappedf(p.x, 0.1), snappedf(p.y, 0.1)])
		i += paso
	var ult: Vector2 = ruta[ruta.size() - 1]
	var l: Array = res[res.size() - 1]
	if absf(float(l[0]) - ult.x) > 0.05 or absf(float(l[1]) - ult.y) > 0.05:
		res.append([snappedf(ult.x, 0.1), snappedf(ult.y, 0.1)])
	return res


static func lat_lon(m: Dictionary) -> Vector2:
	return Vector2(float(m.get("lat_real", m.get("lat", 0.0))), float(m.get("lon_real", m.get("lon", 0.0))))


static func es_fallida(m: Dictionary) -> bool:
	return str(m.get("tipo", "")) == "restos"


static func exportar() -> String:
	if not _cargado:
		cargar()
	var lista: Array = []
	for m in DatosMarte.MISIONES:
		var id := str(m["id"])
		var ll := lat_lon(m)
		var entrada := {
			"id": id,
			"nombre": str(m["nombre"]),
			"nave": str(m["nave"]),
			"anio": str(m["era"]),
			"tipo": str(m.get("tipo", "recoger")),
			"resultado_original": "fallida" if es_fallida(m) else ("ficcion" if str(m["nave"]).contains("ficción") or str(m["nave"]).contains("Colonia") else "exitosa"),
			"lat": ll.x,
			"lon": ll.y,
			"coordenadas": "aproximadas",
			"rumbo_grados": float(m.get("rumbo", 0.0)),
			"jugada": _datos.has(id),
		}
		if _datos.has(id):
			entrada["recorrido"] = _datos[id]
		lista.append(entrada)
	var salida := {
		"juego": "SPARTANS II",
		"formato": 1,
		"piloto": Ajustes.nombre_visible(),
		"fecha": Time.get_datetime_string_from_system(false, true),
		"unidades": {
			"ruta": "[u, v] en metros de juego desde el punto de aterrizaje A; u = hacia la base B, v = a un lado",
			"metros_reales_por_unidad": METROS_POR_GM,
		},
		"misiones": lista,
	}
	var f := FileAccess.open(Partidas.ruta("spartans_rutas.json"), FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(JSON.stringify(salida, "\t"))
	return ProjectSettings.globalize_path(Partidas.ruta("spartans_rutas.json"))
