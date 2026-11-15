extends RefCounted


const Historia := preload("res://historia/historia.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")
const Rutas := preload("res://progreso/rutas.gd")

const Partidas := preload("res://nucleo/partidas.gd")
const MINIMO_VISITADOS := 6

const CRITERIOS := [
	{"k": "agua", "j": "JULIO", "n": "Agua"},
	{"k": "seguro", "j": "KELLY", "n": "Terreno seguro"},
	{"k": "ruta", "j": "REYZER", "n": "Ruta a la base"},
	{"k": "ciencia", "j": "GERALD", "n": "Ciencia y vida"},
	{"k": "energia", "j": "DAID", "n": "Energía y señal"},
]

const SITIOS := {
	"chryse_viking": {
		"agua": 2, "seguro": 5, "ruta": 5, "ciencia": 2, "energia": 4,
		"nota": "Llanura plana y abierta: Viking aterrizó sin problemas. Hay poca agua a la vista y poco que estudiar.",
		"final": "La base se levanta en Chryse Planitia, donde empezó todo: es segura y fácil de abastecer, aunque el agua y la ciencia habrá que buscarlas lejos.",
	},
	"ares_pathfinder": {
		"agua": 3, "seguro": 3, "ruta": 3, "ciencia": 4, "energia": 4,
		"nota": "Cauce de una gran inundación antigua: hay agua pasada y rocas con historia, pero tantas piedras complican el aterrizaje y los caminos.",
		"final": "La base se levanta en Ares Vallis, en el cauce de una inundación antigua: mucha geología que estudiar, a cambio de caminos con rocas.",
	},
	"polar_lander": {
		"agua": 5, "seguro": 2, "ruta": 2, "ciencia": 4, "energia": 2,
		"nota": "Capas de hielo de agua casi en la superficie: la mejor reserva. Pero el frío es extremo, la noche polar es larga y los paneles casi no cargan.",
		"final": "La base se levanta junto al polo sur, sobre las capas de hielo: tendremos agua para siempre, a cambio de inviernos larguísimos y mucha energía por traer de fuera.",
	},
	"pancam_husband": {
		"agua": 3, "seguro": 3, "ruta": 2, "ciencia": 4, "energia": 3,
		"nota": "Colinas de basalto con restos de antiguas fuentes termales: buen lugar para buscar vida, pero con cuestas y rocas sueltas.",
		"final": "La base se levanta en las colinas de Gusev: los restos de fuentes termales dan trabajo a los científicos, a cambio de cuestas duras.",
	},
	"llanura_utopia": {
		"agua": 5, "seguro": 4, "ruta": 4, "ciencia": 3, "energia": 2,
		"nota": "Llanura helada donde Phoenix encontró hielo a pocos centímetros. Es llana y tiene agua, pero cerca del polo el Sol es débil.",
		"final": "La base se levanta en la Planicie Boreal: hielo bajo los pies y terreno llano, aunque con poca luz y muchos paneles por instalar.",
	},
	"endeavour_opportunity": {
		"agua": 3, "seguro": 3, "ruta": 3, "ciencia": 5, "energia": 4,
		"nota": "Borde de un cráter gigante con arcillas y yeso: mucha ciencia, con pendientes en el borde.",
		"final": "La base se levanta en el borde del cráter Endeavour: las arcillas y el yeso darán trabajo a los científicos, a cambio de rutas con pendiente.",
	},
	"gale_curiosity": {
		"agua": 3, "seguro": 3, "ruta": 3, "ciencia": 5, "energia": 3,
		"nota": "Antiguo lago dentro de un cráter: el mejor sitio para buscar vida pasada, aunque la montaña central y el relieve complican los caminos.",
		"final": "La base se levanta en el cráter Gale, junto al antiguo lago: ciencia para décadas, con rutas largas y paneles que limpiar.",
	},
	"insight_elysium": {
		"agua": 2, "seguro": 5, "ruta": 5, "ciencia": 4, "energia": 3,
		"nota": "Llanura lisa y sin rocas: aterrizar y moverse es fácil. Poca agua a la vista, y el polvo cubre los paneles.",
		"final": "La base se levanta en Elysium Planitia: llana, segura y fácil de abastecer, con ciencia sobre el interior de Marte. Habrá que limpiar el polvo de los paneles.",
	},
	"zhurong_utopia": {
		"agua": 2, "seguro": 4, "ruta": 4, "ciencia": 3, "energia": 4,
		"nota": "Dunas llanas con algo de humedad atrapada en la costra. Es un lugar tranquilo, aunque sin mucho hielo ni ciencia espectacular.",
		"final": "La base se levanta entre las dunas de Utopia: terreno llano y buen Sol, con el agua guardada en el suelo y no a la vista.",
	},
	"jezero_perseverance": {
		"agua": 4, "seguro": 2, "ruta": 3, "ciencia": 5, "energia": 4,
		"nota": "Delta de un río antiguo, ideal para buscar vida pasada. Aterrizar y moverse entre tantas rocas es arriesgado.",
		"final": "La base se levanta en el cráter Jezero, junto al delta: allí buscaremos señales de vida con humanos y robots a la vez.",
	},
}

const REACCIONES := {
	"JULIO": {
		"alto": "Hay agua cerca. Eso lo cambia todo, piloto: beber, respirar y hacer combustible.",
		"medio": "Agua habrá, pero tocará buscarla. Lo conseguiremos.",
		"bajo": "Aquí el agua escasea. Me preocupa, pero no me voy a rendir.",
	},
	"KELLY": {
		"alto": "Terreno firme y aterrizajes limpios. Con esto duermo tranquila.",
		"medio": "No es perfecto, pero se puede hacer con cuidado. Y yo voy a cuidarlo.",
		"bajo": "Es un sitio peligroso. Lo asumo porque tú lo elegiste, pero nada de improvisar.",
	},
	"REYZER": {
		"alto": "Rutas cortas y despejadas: podré mover gente y material sin sobresaltos.",
		"medio": "Rutas aceptables. Habrá que señalizarlas bien.",
		"bajo": "Caminos duros y largos. Prepararé más robots y más baterías.",
	},
	"GERALD": {
		"alto": "Aquí hay ciencia para décadas. Nuestros nietos seguirán descubriendo.",
		"medio": "Habrá cosas que estudiar, aunque no sea el mejor sitio.",
		"bajo": "Poco que investigar cerca... tendremos que salir mucho a explorar.",
	},
	"DAID": {
		"alto": "Sol de sobra y buena señal con la Tierra. La base tendrá luz y voz.",
		"medio": "Energía suficiente con buenos paneles y baterías.",
		"bajo": "Poca energía y mala señal. Necesitaremos reactores y antenas extra.",
	},
}


static func sitios() -> Array:
	return SITIOS.keys()


static func mision(id: String) -> Dictionary:
	for m in DatosMarte.MISIONES:
		if str(m["id"]) == id:
			return m
	return {}


static func visitado(id: String) -> bool:
	return not Rutas.obtener(id).is_empty()


static func visitados() -> Array:
	var r: Array = []
	for id in SITIOS:
		if visitado(id):
			r.append(id)
	return r


static func mejor() -> String:
	var id_mejor := ""
	var t_mejor := -1
	for id in visitados():
		var t := total(id)
		if t > t_mejor:
			id_mejor = id
			t_mejor = t
	return id_mejor


static func puede_decidir() -> bool:
	return visitados().size() >= MINIMO_VISITADOS


static func eficiencia(id: String) -> float:
	var r := Rutas.obtener(id)
	if r.is_empty():
		return -1.0
	var largo := float(r.get("distancia", 0.0))
	var directo := float(r.get("directa", 0.0))
	if largo <= 0.1 or directo <= 0.1:
		return -1.0
	return clampf(directo / largo, 0.0, 1.0)


static func nota(id: String, criterio: String) -> int:
	var base := float((SITIOS[id] as Dictionary)[criterio])
	if criterio == "ruta":
		var ef := eficiencia(id)
		if ef >= 0.0:
			base = 0.6 * base + 0.4 * (1.0 + 4.0 * ef)
	var b := bono(id)
	if not b.is_empty() and str(b.get("crit", "")) == criterio:
		base += float(b.get("d", 0))
	return clampi(roundi(base), 1, 5)


static func bono(id: String) -> Dictionary:
	var b: Variant = _leer().get("bonos", {})
	if b is Dictionary and (b as Dictionary).get(id, null) is Dictionary:
		return (b as Dictionary)[id]
	return {}


static func bono_fijar(id: String, crit: String, d: int) -> void:
	var datos := _leer()
	var b: Dictionary = datos.get("bonos", {}) if datos.get("bonos", {}) is Dictionary else {}
	if crit == "" or d == 0:
		b.erase(id)
	else:
		b[id] = {"crit": crit, "d": d}
	datos["bonos"] = b
	_escribir(datos)


static func nombre_criterio(k: String) -> String:
	for c in CRITERIOS:
		if str(c["k"]) == k:
			return str(c["n"])
	return k


static func resumen_mision(id: String) -> String:
	if not SITIOS.has(id):
		return ""
	var partes: Array[String] = ["Comité · %s: %d / 25" % [str(mision(id).get("nombre", id)), total(id)]]
	var ef := eficiencia(id)
	if ef >= 0.0:
		partes.append("tu ruta: %d %% directa" % roundi(ef * 100.0))
	var b := bono(id)
	if not b.is_empty():
		var d := int(b["d"])
		partes.append("tu decisión: %s %s%d" % [nombre_criterio(str(b["crit"])).to_lower(), "+" if d > 0 else "", d])
	return "  ·  ".join(partes)


static func total(id: String) -> int:
	var t := 0
	for c in CRITERIOS:
		t += nota(id, str(c["k"]))
	return t


static func recomendacion(jefe: String) -> String:
	var crit := ""
	for c in CRITERIOS:
		if str(c["j"]) == jefe:
			crit = str(c["k"])
	var mejor := ""
	var mejor_n := -1
	var mejor_t := -1
	for id in visitados():
		var n := nota(id, crit)
		var t := total(id)
		if n > mejor_n or (n == mejor_n and t > mejor_t):
			mejor = id
			mejor_n = n
			mejor_t = t
	return mejor


static func reaccion(jefe: String, id: String) -> String:
	var crit := ""
	for c in CRITERIOS:
		if str(c["j"]) == jefe:
			crit = str(c["k"])
	var n := nota(id, crit)
	var nivel := "alto" if n >= 4 else ("medio" if n == 3 else "bajo")
	return str((REACCIONES[jefe] as Dictionary)[nivel])


static func final_tipo(id: String) -> int:
	var t := total(id)
	if t >= 20:
		return 0
	if t >= 16:
		return 1
	return 2


static func criterio_debil(id: String) -> String:
	var peor := ""
	var peor_n := 99
	for c in CRITERIOS:
		var n := nota(id, str(c["k"]))
		if n < peor_n:
			peor_n = n
			peor = str(c["k"])
	return peor


const PROBLEMAS := {
	"agua": "el agua llega siempre con racionamiento",
	"seguro": "los aterrizajes y los viajes son peligrosos",
	"ruta": "los caminos hasta la base son largos y duros",
	"ciencia": "hay poco que investigar cerca de la base",
	"energia": "las tormentas dejan la base sin luz con demasiada frecuencia",
}


static func problema(id: String) -> String:
	return str(PROBLEMAS.get(criterio_debil(id), ""))


static func cierre_kelly(id: String) -> String:
	var t := total(id)
	if t >= 20:
		return "Es una elección excelente, piloto. Sin tu archivo de rutas no habríamos llegado a esta decisión. SPARTANS II cumplió."
	if t >= 16:
		return "Es una buena elección, con riesgos que sabemos medir. Gracias por tu trabajo, piloto: la base será tuya tanto como nuestra."
	return "Es una apuesta arriesgada. Pero los primeros humanos en Marte también lo son. Hagámosla bien."


static func _leer() -> Dictionary:
	if not FileAccess.file_exists(Partidas.ruta("comite.json")):
		return {}
	var f := FileAccess.open(Partidas.ruta("comite.json"), FileAccess.READ)
	if f == null:
		return {}
	var j: Variant = JSON.parse_string(f.get_as_text())
	return j if j is Dictionary else {}


static func _escribir(datos: Dictionary) -> void:
	var f := FileAccess.open(Partidas.ruta("comite.json"), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(datos))


static func elegida() -> String:
	var id := str(_leer().get("sitio", ""))
	return id if SITIOS.has(id) else ""


static func elegir(id: String) -> void:
	var datos := _leer()
	datos["sitio"] = id
	datos["fecha"] = Time.get_datetime_string_from_system(false, true)
	_escribir(datos)
