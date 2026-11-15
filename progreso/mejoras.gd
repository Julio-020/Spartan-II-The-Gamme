extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")
const AvisoGuardado := preload("res://nucleo/aviso_guardado.gd")
const Colonia := preload("res://progreso/colonia_estado.gd")

const RAMAS := {
	"bateria": {
		"n": "Baterías", "c": Color(0.45, 0.95, 0.55), "icono": "B",
		"d": "Gasta menos y se recarga antes.",
		"niveles": [
			{"m": 4, "d": 0, "v": 0.10, "t": "Celdas nuevas: -10 % de consumo y +10 % de recarga"},
			{"m": 8, "d": 2, "v": 0.20, "t": "Celdas de litio: -20 % de consumo y +20 % de recarga"},
			{"m": 14, "d": 5, "v": 0.30, "t": "Banco de baterías: -30 % de consumo y +30 % de recarga"},
		],
	},
	"ruedas": {
		"n": "Ruedas", "c": Color(1.0, 0.72, 0.25), "icono": "R",
		"d": "Más velocidad y menos esfuerzo en las cuestas.",
		"niveles": [
			{"m": 4, "d": 0, "v": 0.08, "t": "Tacos nuevos: +8 % de velocidad"},
			{"m": 8, "d": 2, "v": 0.16, "t": "Ruedas anchas: +16 % de velocidad y cuestas más baratas"},
			{"m": 14, "d": 5, "v": 0.25, "t": "Suspensión: +25 % de velocidad y cuestas mucho más baratas"},
		],
	},
	"brazo": {
		"n": "Brazo y bodega", "c": Color(1.0, 0.45, 0.35), "icono": "A",
		"d": "Más muestras por viaje y recogida desde más lejos.",
		"niveles": [
			{"m": 5, "d": 0, "v": 1.0, "t": "Bandeja extra: +1 muestra de capacidad"},
			{"m": 9, "d": 2, "v": 1.0, "t": "Brazo largo: recoges desde un 40 % más lejos"},
			{"m": 15, "d": 5, "v": 1.0, "t": "Segunda bandeja: +1 muestra de capacidad"},
		],
	},
	"escaner": {
		"n": "Escáner", "c": Color(0.45, 0.82, 1.0), "icono": "E",
		"d": "Llega más lejos y se recarga antes.",
		"niveles": [
			{"m": 4, "d": 0, "v": 0.20, "t": "Antena mejor: +20 % de alcance y -15 % de recarga"},
			{"m": 8, "d": 2, "v": 0.40, "t": "Procesador: +40 % de alcance y -30 % de recarga"},
			{"m": 14, "d": 5, "v": 0.60, "t": "Radar de apertura: +60 % de alcance y -45 % de recarga"},
		],
	},
}
const ORDEN := ["bateria", "ruedas", "brazo", "escaner"]
const MAX_NIVEL := 3


static func nivel(rama: String) -> int:
	return clampi(MetaEstado.nivel(rama), 0, MAX_NIVEL)


static func siguiente(rama: String) -> Dictionary:
	var n := nivel(rama)
	if n >= MAX_NIVEL:
		return {}
	return (RAMAS[rama]["niveles"] as Array)[n]


static func puede_comprar(rama: String) -> bool:
	var s := siguiente(rama)
	return not s.is_empty() and MetaEstado.puede_pagar(int(s["m"]), int(s["d"]))


static func comprar(rama: String) -> bool:
	var s := siguiente(rama)
	if s.is_empty():
		return false
	if not MetaEstado.gastar(int(s["m"]), int(s["d"])):
		return false
	MetaEstado.fijar_nivel(rama, nivel(rama) + 1)
	AvisoGuardado.mostrar()
	return true


static func _v(rama: String) -> float:
	var n := nivel(rama)
	if n <= 0:
		return 0.0
	return float(((RAMAS[rama]["niveles"] as Array)[n - 1] as Dictionary)["v"])


static func efectos() -> Dictionary:
	var bat := _v("bateria")
	var rue := _v("ruedas")
	var nb := nivel("brazo")
	var esc := _v("escaner")
	var ne := nivel("escaner")
	var col := Colonia.bonos()
	return {
		"consumo": 1.0 - bat,
		"recarga": 1.0 + bat + float(col["recarga"]),
		"vel": 1.0 + rue,
		"pendiente": 1.0 - (0.0 if nivel("ruedas") < 2 else (0.25 if nivel("ruedas") == 2 else 0.5)),
		"capacidad": (1 if nb >= 1 else 0) + (1 if nb >= 3 else 0),
		"recogida": 1.0 + (0.4 if nb >= 2 else 0.0),
		"alcance": 1.0 + esc + float(col["escaner"]),
		"escaner_cd": 1.0 - 0.15 * float(ne),
		"datos_mision": int(col["datos"]),
	}


static func resumen() -> String:
	var partes: Array[String] = []
	for r in ORDEN:
		if nivel(r) > 0:
			partes.append("%s %d" % [str(RAMAS[r]["n"]), nivel(r)])
	return "  ·  ".join(partes)
