extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")
const HistoriaEstado := preload("res://progreso/historia_estado.gd")
const Comite := preload("res://historia/comite.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")


const MODULOS := {
	"invernadero": {"n": "Invernadero", "c": Color(0.45, 0.95, 0.5), "u": [5, 12, 22], "txt": "muestras entregadas",
			"bono": "+1 dato de ciencia por misión y nivel"},
	"antena": {"n": "Antena de largo alcance", "c": Color(0.45, 0.82, 1.0), "u": [2, 5, 9], "txt": "misiones completadas",
			"bono": "+8 % de alcance del escáner por nivel"},
	"paneles": {"n": "Campo solar", "c": Color(1.0, 0.78, 0.3), "u": [2, 5, 9], "txt": "mejoras instaladas en el robot",
			"bono": "+12 % de recarga solar por nivel"},
	"laboratorio": {"n": "Laboratorio", "c": Color(0.78, 0.58, 1.0), "u": [1, 4, 9], "txt": "análisis hechos",
			"bono": "+4 s de tiempo y una pista extra en cada análisis, por nivel"},
}
const ORDEN := ["invernadero", "antena", "paneles", "laboratorio"]


static func progreso_de(id: String) -> int:
	match id:
		"invernadero": return MetaEstado.total_recogido()
		"antena": return HistoriaEstado.num_hechas()
		"paneles": return MetaEstado.niveles_total()
		"laboratorio": return MetaEstado.analisis_hechos()
	return 0


static func nivel(id: String) -> int:
	var p := progreso_de(id)
	var n := 0
	for u in (MODULOS[id]["u"] as Array):
		if p >= int(u):
			n += 1
	return n


static func falta(id: String) -> int:
	var n := nivel(id)
	if n >= 3:
		return 0
	return int((MODULOS[id]["u"] as Array)[n]) - progreso_de(id)


static func niveles_total() -> int:
	var t := 0
	for id in ORDEN:
		t += nivel(id)
	return t


static func bonos() -> Dictionary:
	return {
		"datos": nivel("invernadero"),
		"escaner": 0.08 * float(nivel("antena")),
		"recarga": 0.12 * float(nivel("paneles")),
		"lab_tiempo": 4.0 * float(nivel("laboratorio")),
		"lab_pistas": nivel("laboratorio"),
	}


static func lugar() -> String:
	var id := Comite.elegida()
	if id == "":
		return "Sin sitio elegido (decide en el comité)"
	for m in DatosMarte.MISIONES:
		if str(m["id"]) == id:
			return str(m["nombre"])
	return id


static func linea(id: String) -> String:
	var n := nivel(id)
	var d: Dictionary = MODULOS[id]
	if n >= 3:
		return "%s · nivel 3/3 (máximo)" % str(d["n"])
	return "%s · nivel %d/3 · faltan %d (%s)" % [str(d["n"]), n, falta(id), str(d["txt"])]
