extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")

const LISTA := [
	{"id": "h_viking_bigjoe", "m": "chryse_viking", "n": "Roca «Big Joe»", "d": 1, "f": false,
		"t": "Cerca del Viking 1 había una roca de más de un metro que los ingenieros bautizaron «Big Joe». Su brazo no pudo llegar hasta ella, pero sirvió para medir el tamaño de las cosas en las fotos."},
	{"id": "h_viking_zanja", "m": "chryse_viking", "n": "Zanja del brazo", "d": 1, "f": false,
		"t": "El brazo de Viking cavó pequeñas zanjas para meter tierra marciana en sus experimentos de biología. Las marcas se veían en las fotos del suelo durante años."},
	{"id": "h_polar_hielo", "m": "polar_lander", "n": "Hielo de los polos", "d": 2, "f": false,
		"t": "Los polos de Marte tienen capas de hielo de agua cubiertas en invierno por una escarcha de dióxido de carbono (hielo seco). Es lo que el Mars Polar Lander iba a estudiar en 1999."},
	{"id": "h_husband_mojon", "m": "pancam_husband", "n": "Mojón de la cumbre", "d": 1, "f": false,
		"t": "El Spirit subió a la cima de Husband Hill en 2005, tras meses de camino. Desde allí su Pancam tomó panorámicas del cráter Gusev. (El mojón es ficción; la subida es real.)"},
	{"id": "h_ares_yogi", "m": "ares_pathfinder", "n": "Roca «Yogi»", "d": 1, "f": false,
		"t": "Sojourner se acercó a rocas a las que los ingenieros pusieron nombres de dibujos animados, como «Yogi» y «Barnacle Bill», y las analizó con su espectrómetro."},
	{"id": "h_phoenix_zanja", "m": "llanura_utopia", "n": "Zanja «Dodo-Goldilocks»", "d": 2, "f": false,
		"t": "En esa zanja Phoenix dejó al aire trozos blancos que desaparecieron en pocos días: era hielo de agua que se evaporaba."},
	{"id": "h_gale_jake", "m": "gale_curiosity", "n": "Roca «Jake Matijevic»", "d": 2, "f": false,
		"t": "Fue la primera roca que Curiosity tocó con su brazo y analizó. Lleva el nombre de un ingeniero de la misión fallecido poco después del aterrizaje."},
	{"id": "h_zhurong_duna", "m": "zhurong_utopia", "n": "Costra de duna", "d": 2, "f": false,
		"t": "Zhurong halló en la costra de las dunas minerales con agua atrapada: señal de humedad relativamente reciente."},
	{"id": "h_endeavour_homestake", "m": "endeavour_opportunity", "n": "Veta «Homestake»", "d": 2, "f": false,
		"t": "En el borde del cráter Endeavour, Opportunity encontró una veta brillante de sulfato de calcio (yeso), depositada por agua que no era ácida: un lugar más amable para la vida."},
	{"id": "h_insight_topo", "m": "insight_elysium", "n": "El topo atascado", "d": 2, "f": false,
		"t": "El «topo» de InSight debía enterrarse 5 m para medir el calor interno de Marte, pero el suelo era demasiado suelto y no encontraba apoyo. Se intentó empujarlo durante casi dos años."},
	{"id": "h_jezero_ingenuity", "m": "jezero_perseverance", "n": "Pieza de Ingenuity", "d": 2, "f": false,
		"t": "El helicóptero Ingenuity hizo en 2021 el primer vuelo con motor en otro planeta. Pensado para 5 vuelos, hizo 72. (La pieza hallada es ficción; el helicóptero es real.)"},
]


const GENERICOS := [
	{"id": "g_meteorito", "n": "Meteorito de hierro", "d": 1, "f": false,
		"t": "Opportunity y Curiosity han hallado meteoritos de hierro y níquel en Marte, como «Heat Shield Rock». El suelo seco los conserva bien."},
	{"id": "g_diablo", "n": "Huella de torbellino", "d": 1, "f": false,
		"t": "Los remolinos de polvo (diablos) dejan rastros oscuros al barrer la capa clara del suelo. Los rovers los han fotografiado muchas veces."},
	{"id": "g_hielo", "n": "Parche de escarcha", "d": 1, "f": false,
		"t": "En zonas a la sombra y por la noche puede formarse una fina capa de escarcha de agua o de hielo seco."},
	{"id": "g_concrecion", "n": "Concreción mineral", "d": 1, "f": false,
		"t": "Esferas o nódulos de mineral dentro de la roca, producto del agua que circuló por ella hace miles de millones de años."},
	{"id": "g_tubo", "n": "Tubo extraviado", "d": 2, "f": true,
		"t": "(Ficción) Un tubo de muestras de una expedición anterior, perdido y cubierto de polvo. Aún tiene su etiqueta."},
	{"id": "g_baliza", "n": "Baliza apagada", "d": 2, "f": true,
		"t": "(Ficción) Una baliza de socorro sin batería. Alguien pasó por aquí y siguió adelante."},
]


static func todos() -> Array:
	return LISTA


static func total() -> int:
	return LISTA.size()


static func de_mision(id_mision: String) -> Array:
	var r: Array = []
	for h in LISTA:
		if str(h["m"]) == id_mision:
			r.append(h)
	return r


static func por_id(id: String) -> Dictionary:
	for h in LISTA:
		if str(h["id"]) == id:
			return h
	return {}


static func progreso_mision(id_mision: String) -> Vector2i:
	var hechos := 0
	var lista := de_mision(id_mision)
	for h in lista:
		if MetaEstado.hallazgo_hecho(str(h["id"])):
			hechos += 1
	return Vector2i(hechos, lista.size())


static func completo() -> bool:
	return MetaEstado.num_hallazgos() >= LISTA.size()


static func para_mision(datos: Dictionary) -> Array:
	var r: Array = []
	if bool(datos.get("expedicion", false)):
		var rng := RandomNumberGenerator.new()
		rng.seed = int(datos.get("semilla", 1)) * 13 + 5
		var pool: Array = GENERICOS.duplicate()
		var n := 1 + int(datos.get("nivel", 0))
		for i in range(mini(n, pool.size())):
			var h: Dictionary = (pool.pop_at(rng.randi() % pool.size()) as Dictionary).duplicate()
			h["coleccion"] = false
			r.append(h)
		return r
	for h in de_mision(str(datos.get("id", ""))):
		if not MetaEstado.hallazgo_hecho(str(h["id"])):
			var c: Dictionary = (h as Dictionary).duplicate()
			c["coleccion"] = true
			r.append(c)
	return r
