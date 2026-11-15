extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")

const NIVELES := ["NORMAL", "DIFÍCIL", "EXTREMA"]
const MULT_NIVEL := [1.0, 1.5, 2.2]
const MULT_DIFICULTAD := [0.9, 1.0, 1.2]

const ZONAS := ["Cráter", "Valle", "Llanura", "Mesa", "Dunas", "Colinas", "Cañón", "Meseta", "Cuenca", "Escarpe"]
const APODOS := ["del Óxido", "Rojo", "de la Aurora", "del Viento", "Pálido", "de las Sombras", "del Hierro", "Dorado",
		"de la Escarcha", "Silencioso", "de las Cenizas", "del Alba", "Perdido", "de Cobre", "Lejano", "de la Calma"]

const ESTILOS_BASE := ["nasa", "esa", "urss", "china"]

const MATERIALES := ["regolito", "hielo", "olivino", "silice", "hematita", "jarosita", "conglomerado", "arcilla",
		"yeso", "perclorato", "nucleo"]
const SEMILLA_MAX := 999999


static func semilla_al_azar() -> int:
	return randi_range(1, SEMILLA_MAX)


static func clave(semilla: int, nivel: int) -> int:
	return semilla * 10 + clampi(nivel, 0, 2)


static func generar(semilla: int, nivel: int) -> Dictionary:
	nivel = clampi(nivel, 0, 2)
	semilla = clampi(semilla, 1, SEMILLA_MAX)
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla * 7 + nivel * 100003 + 12345
	var nombre := "%s %s" % [ZONAS[rng.randi() % ZONAS.size()], APODOS[rng.randi() % APODOS.size()]]

	var pool: Array = MATERIALES.duplicate()
	var muestras := {}
	var tipos := 2 if nivel < 2 else 3
	for i in range(tipos):
		var m: String = pool.pop_at(rng.randi() % pool.size())
		muestras[m] = rng.randi_range(2, 3 + nivel)
	var total := 0
	for m in muestras:
		total += int(muestras[m])
	var amb := {
		"niebla": snappedf(rng.randf_range(0.1, 0.45 + 0.2 * float(nivel)), 0.05),
		"polvo": snappedf(rng.randf_range(0.2, 0.6 + 0.15 * float(nivel)), 0.05),
		"remolinos": rng.randi_range(0, 1 + nivel),
		"viento": snappedf(rng.randf_range(0.2, 0.6 + 0.15 * float(nivel)), 0.05),
		"cuevas": rng.randi_range(0, 2),
		"sol_elev": snappedf(rng.randf_range(18.0, 62.0), 1.0),
		"temp": snappedf(rng.randf_range(-85.0, -35.0), 1.0),
	}
	var d := {
		"id": "exp_%d_%d" % [semilla, nivel],
		"nombre": nombre, "era": "EXPEDICIÓN", "nave": "Rover SPARTANS", "estilo": ESTILOS_BASE[rng.randi() % ESTILOS_BASE.size()],
		"descripcion": "Expedición libre %d (nivel %s). Reúne %d muestras y llévalas a la base (B), a unos %d km. Puntúa rapidez, batería, datos curiosos y hallazgos.",
		"real": "",
		"lat_real": 0.0, "lon_real": 0.0,
		"lat": snappedf(rng.randf_range(-55.0, 55.0), 0.5), "lon": snappedf(rng.randf_range(-179.0, 179.0), 0.5),
		"rumbo": snappedf(rng.randf_range(0.0, 359.0), 1.0),
		"dist": snappedf(rng.randf_range(220.0, 300.0 + 40.0 * float(nivel)), 5.0),
		"muestras": muestras, "capacidad": rng.randi_range(2, 3), "semilla": semilla,
		"amb": amb,
		"expedicion": true, "nivel": nivel,
	}

	var azar := rng.randf()
	if azar < 0.18 + 0.12 * float(nivel):
		d["condicion"] = "noche" if rng.randf() < 0.5 else "tormenta"
	d["descripcion"] = str(d["descripcion"]) % [semilla, str(NIVELES[nivel]).to_lower(), total, roundi(float(d["dist"]) / 10.0)]
	return d


static func puntuar(p: Dictionary) -> Dictionary:
	var lineas: Array[String] = []
	var base := 0
	var m := int(p.get("muestras", 0)) * 100
	base += m
	lineas.append("Muestras %d × 100 = %d" % [int(p.get("muestras", 0)), m])
	var c := int(p.get("curiosos", 0)) * 25
	if c > 0:
		base += c
		lineas.append("Datos curiosos %d × 25 = %d" % [int(p.get("curiosos", 0)), c])
	var h := int(p.get("hallazgos", 0)) * 50
	if h > 0:
		base += h
		lineas.append("Hallazgos %d × 50 = %d" % [int(p.get("hallazgos", 0)), h])
	var par := 300.0 + 40.0 * float(int(p.get("total", 0)))
	var t := float(p.get("tiempo", 0.0))
	var bt := roundi(clampf(par - t, 0.0, par))
	if bt > 0 and int(p.get("muestras", 0)) >= int(p.get("total", 0)):
		base += bt
		lineas.append("Rapidez (tiempo base %d s) = +%d" % [roundi(par), bt])
	var e := float(p.get("energia_min", -1.0))
	if e >= 0.0:
		var be := roundi(e * 2.0)
		base += be
		lineas.append("Batería mínima %d %% = +%d" % [roundi(e), be])
	var nivel := clampi(int(p.get("nivel", 0)), 0, 2)
	var dif := clampi(int(p.get("dificultad", 1)), 0, 2)
	var mult := float(MULT_NIVEL[nivel]) * float(MULT_DIFICULTAD[dif])
	var total := roundi(float(base) * mult)
	lineas.append("Multiplicador ×%s (nivel %s, dificultad)" % [str(snappedf(mult, 0.01)), str(NIVELES[nivel]).to_lower()])
	return {"puntos": total, "lineas": lineas}


static func es_expedicion(d: Dictionary) -> bool:
	return bool(d.get("expedicion", false))


static func mejor(semilla: int, nivel: int) -> int:
	var r := MetaEstado.records_exp(clave(semilla, nivel))
	return int((r[0] as Dictionary)["p"]) if not r.is_empty() else 0
