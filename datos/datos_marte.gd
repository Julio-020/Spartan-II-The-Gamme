extends RefCounted


const MATERIALES := {
	"pata": {
		"nombre": "Pata de aterrizaje", "plural": "patas de aterrizaje",
		"color": Color(0.88, 0.68, 0.26),
		"dato": "Pata de aterrizaje. La investigación del Mars Polar Lander (1999) concluyó que los sensores de las patas pudieron tomar su despliegue por un aterrizaje y apagar el motor a unos 40 m de altura.",
		"pista": "un puntal con funda dorada y un plato en la punta",
	},
	"motor": {
		"nombre": "Motor de descenso", "plural": "motores de descenso",
		"color": Color(0.62, 0.62, 0.68),
		"dato": "Motor de descenso: el que frena la nave en los últimos metros. Si se apaga demasiado pronto, la nave cae. Eso es lo que se cree que le pasó al Mars Polar Lander.",
		"pista": "una tobera cónica con tubos de cobre",
	},
	"regolito": {
		"nombre": "Regolito", "plural": "muestras de regolito",
		"color": Color(0.85, 0.42, 0.2),
		"dato": "Regolito rico en hierro. Los Viking (1976) lo excavaron con su brazo y descubrieron un suelo oxidante.",
		"pista": "manchas de suelo fino y oscuro, como si ya lo hubieran removido",
	},
	"conglomerado": {
		"nombre": "Conglomerado", "plural": "rocas de conglomerado",
		"color": Color(0.75, 0.66, 0.52),
		"dato": "Guijarros redondeados pegados en roca. Pathfinder (1997) los vio en Ares Vallis: los pulió una antigua inundación.",
		"pista": "rocas con guijarros redondos incrustados",
	},
	"hematita": {
		"nombre": "Hematita", "plural": "esférulas de hematita",
		"color": Color(0.62, 0.6, 0.72),
		"dato": "Esférulas de hematita, los \"arándanos\". Opportunity (2004) las halló en Meridiani Planum: se formaron en agua.",
		"pista": "bolitas grises metálicas sobre roca rojiza",
	},
	"jarosita": {
		"nombre": "Jarosita", "plural": "costras de jarosita",
		"color": Color(0.9, 0.75, 0.2),
		"dato": "Jarosita, un sulfato de hierro. Opportunity (2004) la usó para probar que allí hubo agua ácida.",
		"pista": "costras amarillas sobre roca oscura",
	},
	"olivino": {
		"nombre": "Olivino", "plural": "cristales de olivino",
		"color": Color(0.55, 0.85, 0.25),
		"dato": "Olivino. Spirit y Perseverance lo hallaron en rocas de lava: casi no se ha alterado desde que se enfrió.",
		"pista": "cristales verdes en roca de basalto",
	},
	"silice": {
		"nombre": "Sílice opalina", "plural": "nódulos de sílice",
		"color": Color(0.95, 0.9, 0.78),
		"dato": "Sílice opalina. Spirit (2007) la descubrió en Home Plate: señal de antiguas fuentes termales.",
		"pista": "nódulos claros y rugosos, como coliflor de piedra",
	},
	"hielo": {
		"nombre": "Hielo de agua", "plural": "bloques de hielo",
		"color": Color(0.6, 0.85, 1.0),
		"dato": "Hielo de agua. Phoenix (2008) lo encontró bajo el suelo polar: al exponerlo, se evaporó en pocos días.",
		"pista": "bloques blancos y azulados con escarcha alrededor",
	},
	"perclorato": {
		"nombre": "Perclorato", "plural": "costras de perclorato",
		"color": Color(0.9, 0.92, 0.95),
		"dato": "Sales de perclorato. Phoenix (2008) las detectó en el suelo: son tóxicas, pero sirven de oxidante y combustible.",
		"pista": "costras blancas y cristalinas sobre suelo oscuro",
	},
	"arcilla": {
		"nombre": "Arcilla", "plural": "losas de arcilla",
		"color": Color(0.7, 0.5, 0.38),
		"dato": "Arcilla. Curiosity (2013) la halló en Yellowknife Bay: el fondo de un lago antiguo donde pudo haber vida.",
		"pista": "losas finas en capas, agrietadas como barro seco",
	},
	"yeso": {
		"nombre": "Yeso", "plural": "vetas de yeso",
		"color": Color(0.96, 0.96, 0.92),
		"dato": "Vetas de sulfato de calcio. Curiosity las vio rellenando grietas: agua circulando bajo tierra.",
		"pista": "venas blancas brillantes cruzando una losa oscura",
	},
	"nucleo": {
		"nombre": "Núcleo de roca", "plural": "tubos de muestra",
		"color": Color(0.95, 0.8, 0.4),
		"dato": "Núcleo sellado en un tubo de titanio. Perseverance (2021) deja muestras para traerlas a la Tierra.",
		"pista": "un tubo metálico junto a una roca perforada",
	},
	"sismometro": {
		"nombre": "Sismómetro", "plural": "sismómetros",
		"color": Color(0.9, 0.9, 0.95),
		"dato": "Sismómetro. El de InSight (2018) apoyó una cúpula sobre el suelo de Marte y escuchó más de mil sismos: así se midió el tamaño del núcleo del planeta.",
		"pista": "una cúpula blanca sobre un plato metálico",
	},
}


const MISIONES := [
	{
		"id": "chryse_viking", "nombre": "Chryse Planitia", "era": "1976", "nave": "Viking 1",
		"descripcion": "Llanura de aterrizaje del primer laboratorio que analizó el suelo marciano. La base está a 28 km. Recoge muestras de REGOLITO.",
		"real": "Viking 1 aterrizó el 20 de julio de 1976. Su brazo excavó el suelo y sus experimentos de biología dieron resultados desconcertantes: décadas después se atribuyeron a percloratos.",
		"lat_real": 22.3, "lon_real": -48.0,
		"lat": 15.0, "lon": -20.0, "rumbo": 120.0, "dist": 280.0,
		"muestras": {"regolito": 4}, "capacidad": 2, "semilla": 76,
		"amb": {"niebla": 0.35, "polvo": 0.5, "remolinos": 1, "viento": 0.5, "cuevas": 0,
				"sol_elev": 42.0, "temp": -60.0},
	},
	{
		"id": "ares_pathfinder", "nombre": "Ares Vallis", "era": "1997", "nave": "Pathfinder · Sojourner",
		"descripcion": "Cauce de una gran inundación antigua. La base está a 30 km. Busca rocas de CONGLOMERADO con guijarros redondos.",
		"real": "Pathfinder aterrizó el 4 de julio de 1997 con Sojourner, el primer rover de Marte (10 kg). Sus rocas con guijarros redondeados probaron que allí corrió agua.",
		"lat_real": 19.1, "lon_real": -33.2,
		"lat": -10.0, "lon": -10.0, "rumbo": 270.0, "dist": 300.0,
		"muestras": {"conglomerado": 5}, "capacidad": 2, "semilla": 97,
		"amb": {"niebla": 0.2, "polvo": 0.5, "remolinos": 2, "viento": 0.6, "cuevas": 0,
				"sol_elev": 50.0, "temp": -55.0},
	},
	{
		"id": "polar_lander", "nombre": "Planum Australe", "era": "1999", "nave": "Mars Polar Lander",
		"tipo": "restos",
		"descripcion": "INVESTIGACIÓN. El Mars Polar Lander se perdió al aterrizar cerca del polo sur y sus restos nunca se han encontrado. Imagina que los hallas: recoge las patas y el motor de descenso, esparcidos por la llanura helada, y llévalos a la base (B), a 30 km, para saber qué falló.",
		"real": "El Mars Polar Lander (NASA) se lanzó el 3 de enero de 1999 y se perdió el 3 de diciembre durante el descenso, cerca del polo sur de Marte. La investigación concluyó que lo más probable es que las vibraciones al desplegar las patas se tomaran por un aterrizaje y el motor se apagara a unos 40 m de altura. Sus restos nunca se han localizado: unas imágenes de 2000 parecían mostrarlos, pero en 2005 se descartó.",
		"lat_real": -76.0, "lon_real": 165.0,
		"lat": -60.0, "lon": -45.0, "rumbo": 60.0, "dist": 300.0,
		"muestras": {"pata": 3, "motor": 1}, "capacidad": 2, "semilla": 1999,
		"amb": {"niebla": 0.55, "polvo": 0.2, "remolinos": 0, "viento": 0.4, "cuevas": 0,
				"sol_elev": 14.0, "temp": -90.0},
	},
	{
		"id": "pancam_husband", "nombre": "Cumbre Husband", "era": "2005", "nave": "Spirit · Pancam",
		"tipo": "fotos",
		"descripcion": "Misión de fotografía: lleva la cámara panorámica del mástil por la llanura y fotografía 5 blancos (el módulo de aterrizaje, un remolino de polvo, rocas con capas, la Tierra y Fobos). Transmite las fotos en la base, a 30 km.",
		"real": "Entre 2004 y 2005 Spirit subió a las Colinas Columbia y trepó la colina Husband. Su cámara panorámica (Pancam), en un mástil a 1,5 m del suelo, fotografió remolinos de polvo, capas de roca, la Tierra y la luna Fobos en el cielo marciano.",
		"lat_real": -14.6, "lon_real": 175.5,
		"lat": -3.0, "lon": 60.0, "rumbo": 45.0, "dist": 300.0,
		"muestras": {}, "capacidad": 1, "semilla": 2005,
		"blancos": ["lander", "estratos", "remolino", "tierra", "fobos"],
		"disparos": 14,
		"amb": {"niebla": 0.2, "polvo": 0.5, "remolinos": 0, "viento": 0.5, "cuevas": 0,
				"sol_elev": 38.0, "temp": -60.0},
	},
	{
		"id": "llanura_utopia", "nombre": "Planicie Boreal", "era": "2008", "nave": "Phoenix",
		"descripcion": "Llanura helada cerca del polo norte. La base está a 25 km. Busca bloques de HIELO y costras de PERCLORATO.",
		"real": "Phoenix aterrizó el 25 de mayo de 2008. Excavó una zanja, expuso hielo de agua bajo el suelo, vio caer nieve y descubrió percloratos.",
		"lat_real": 68.2, "lon_real": -125.7,
		"lat": -10.0, "lon": 5.0, "rumbo": 45.0, "dist": 250.0,
		"muestras": {"hielo": 3, "perclorato": 2}, "capacidad": 3, "semilla": 11,
		"amb": {"niebla": 0.75, "polvo": 0.2, "remolinos": 0, "viento": 0.4, "cuevas": 0,
				"sol_elev": 26.0, "temp": -78.0},
	},
	{
		"id": "endeavour_opportunity", "nombre": "Cráter Endeavour", "era": "2011", "nave": "Opportunity · Endeavour",
		"descripcion": "Borde de un cráter enorme, tras siete años de camino. La base está a 34 km. Busca vetas de YESO y arcillas de ARCILLA.",
		"real": "En agosto de 2011 Opportunity llegó al borde del cráter Endeavour, de 22 km de ancho. Allí encontró una veta brillante de yeso, llamada Homestake, y más tarde arcillas: agua menos ácida que la de Meridiani, más amable para la vida.",
		"lat_real": -2.3, "lon_real": -5.2,
		"lat": 35.0, "lon": 35.0, "rumbo": 15.0, "dist": 340.0,
		"muestras": {"yeso": 3, "arcilla": 2}, "capacidad": 3, "semilla": 2011, "condicion": "tormenta",
		"datos_mat": {
			"yeso": "Yeso, como la veta Homestake. Opportunity la halló en 2011: un sulfato de calcio que dejó agua circulando por una grieta.",
			"arcilla": "Arcilla. En 2013 Opportunity halló arcillas en el borde de Endeavour: se forman con agua de pH casi neutro, un ambiente más amable para la vida.",
		},
		"amb": {"niebla": 0.15, "polvo": 0.8, "remolinos": 3, "viento": 0.75, "cuevas": 0,
				"sol_elev": 56.0, "temp": -52.0},
	},
	{
		"id": "gale_curiosity", "nombre": "Cráter Gale", "era": "2012", "nave": "Curiosity",
		"descripcion": "Cráter con una montaña en el centro. La base está a 36 km. Recoge losas de ARCILLA y vetas de YESO. Hay una cueva en la pared.",
		"real": "Curiosity aterrizó el 6 de agosto de 2012. En Yellowknife Bay halló arcillas y vetas de sulfato: el fondo de un lago antiguo y habitable. Lleva una estación meteorológica (REMS).",
		"lat_real": -4.6, "lon_real": 137.4,
		"lat": -30.0, "lon": 50.0, "rumbo": 90.0, "dist": 360.0,
		"muestras": {"arcilla": 3, "yeso": 3}, "capacidad": 3, "semilla": 12,
		"amb": {"niebla": 0.3, "polvo": 0.6, "remolinos": 1, "viento": 0.5, "cuevas": 1,
				"sol_elev": 50.0, "temp": -63.0, "cueva_mat": "yeso", "cueva_n": 2},
	},
	{
		"id": "insight_elysium", "nombre": "Elysium Planitia", "era": "2018", "nave": "InSight",
		"descripcion": "Llanura lisa donde un módulo quieto escuchó el interior de Marte. La base está a 30 km. Recoge REGOLITO y recupera un SISMÓMETRO.",
		"real": "InSight aterrizó el 26 de noviembre de 2018. No se movía: su sismómetro, apoyado en el suelo, registró más de mil sismos y reveló el tamaño del núcleo (líquido) y el grosor de la corteza. La misión terminó en 2022, cuando el polvo cubrió sus paneles solares.",
		"lat_real": 4.5, "lon_real": 135.6,
		"lat": 5.0, "lon": 135.0, "rumbo": 120.0, "dist": 300.0,
		"muestras": {"regolito": 3, "sismometro": 1}, "capacidad": 2, "semilla": 2018,
		"datos_mat": {
			"regolito": "Regolito de Elysium. La sonda térmica de InSight intentó enterrarse en él y no pudo: el suelo se pegaba. Aun así, enseñó cómo se comporta el polvo de Marte.",
		},
		"amb": {"niebla": 0.1, "polvo": 0.55, "remolinos": 2, "viento": 0.45, "cuevas": 0,
				"sol_elev": 58.0, "temp": -56.0},
	},
	{
		"id": "zhurong_utopia", "nombre": "Dunas de Utopia", "era": "2021", "nave": "Zhurong", "estilo": "china",
		"descripcion": "Llanura de dunas donde llegó el primer rover chino. La base está a 32 km. Busca costras de SÍLICE y vetas de YESO en las dunas.",
		"real": "Zhurong, de la misión china Tianwen-1, aterrizó el 14 de mayo de 2021 en Utopia Planitia y recorrió casi dos kilómetros. Halló minerales hidratados en la costra de las dunas: señal de que hubo humedad relativamente reciente. Quedó en reposo en 2022.",
		"lat_real": 25.1, "lon_real": 109.9,
		"lat": 40.0, "lon": -150.0, "rumbo": 330.0, "dist": 320.0,
		"muestras": {"silice": 2, "yeso": 2}, "capacidad": 2, "semilla": 2022,
		"datos_mat": {
			"silice": "Sílice hidratada. Zhurong detectó minerales con agua en la costra de las dunas: eso sugiere humedad en épocas geológicas recientes.",
			"yeso": "Sulfato hidratado, como el de las dunas de Zhurong. Pequeñas cantidades de agua se quedan atrapadas en el mineral.",
		},
		"amb": {"niebla": 0.2, "polvo": 0.6, "remolinos": 2, "viento": 0.6, "cuevas": 0,
				"sol_elev": 44.0, "temp": -60.0},
	},
	{
		"id": "jezero_perseverance", "nombre": "Cráter Jezero", "era": "2021", "nave": "Perseverance",
		"descripcion": "Antiguo delta de un río marciano. La base está a 34 km. Recoge TUBOS DE MUESTRA y cristales de OLIVINO.",
		"real": "Perseverance aterrizó el 18 de febrero de 2021 con el helicóptero Ingenuity. Guarda muestras selladas en tubos de titanio para una futura misión que las traiga a la Tierra.",
		"lat_real": 18.4, "lon_real": 77.5,
		"lat": -20.0, "lon": -90.0, "rumbo": 180.0, "dist": 340.0,
		"muestras": {"nucleo": 4, "olivino": 2}, "capacidad": 3, "semilla": 2021, "final": true,
		"amb": {"niebla": 0.25, "polvo": 0.5, "remolinos": 2, "viento": 0.5, "cuevas": 0,
				"sol_elev": 48.0, "temp": -55.0},
	},
]


const BLANCOS_FOTO := {
	"lander": {
		"nombre": "El módulo de aterrizaje", "tipo": "suelo", "radio": 6.0, "dmin": 70.0,
		"pista": "Aléjate del módulo de aterrizaje (A) y mira hacia atrás: fotografíalo desde lejos.",
		"dato": "Los ingenieros usan las fotos del rover para revisar su estado y planear la ruta: mirar hacia atrás también sirve.",
	},
	"estratos": {
		"nombre": "Rocas con capas", "tipo": "suelo", "radio": 5.5, "dmin": 8.0,
		"pista": "Busca un afloramiento de roca con capas, cerca de la ruta. El escáner (ESPACIO) lo marca.",
		"dato": "Las capas de una roca son como páginas: cada una guarda una época. Spirit halló rocas en capas en Home Plate, posiblemente depósitos de explosiones volcánicas.",
	},
	"remolino": {
		"nombre": "Remolino de polvo", "tipo": "suelo", "radio": 9.0, "dmin": 15.0,
		"pista": "Un remolino de polvo vaga por la llanura. Escanea para ubicarlo y fotografíalo antes de que se aleje.",
		"dato": "Spirit filmó muchos remolinos de polvo en Gusev. A veces limpiaban sus paneles solares y le devolvían energía.",
	},
	"tierra": {
		"nombre": "La Tierra en el cielo", "tipo": "cielo", "ang": 1.1, "elev": 28.0, "giro": 330.0,
		"pista": "Mira al cielo, lejos del Sol: la Tierra se ve como una estrella azulada y muy brillante. Usa el zoom.",
		"dato": "Desde Marte la Tierra se ve como un punto brillante. Spirit la fotografió en el cielo de Gusev en 2004.",
	},
	"fobos": {
		"nombre": "Fobos, la luna veloz", "tipo": "cielo", "ang": 2.4, "elev": 46.0, "giro": 70.0,
		"pista": "Fobos, una de las dos lunas de Marte, cruza el cielo como una papa gris. Búscala alto en el cielo y usa el zoom.",
		"dato": "Fobos da la vuelta a Marte en menos de 8 horas: sale por el oeste y se pone por el este, el revés que el Sol.",
	},
}


static func material(id: String) -> Dictionary:
	return MATERIALES.get(id, MATERIALES["regolito"])


const CONDICIONES := {
	"noche": {"n": "MISIÓN NOCTURNA", "c": Color(0.55, 0.62, 1.0),
		"d": "Empiezas al anochecer y la noche dura mucho más. Casi no hay luz y el Sol no recarga la batería: usa el escáner y el radar."},
	"tormenta": {"n": "TORMENTA DE POLVO", "c": Color(1.0, 0.72, 0.25),
		"d": "Una tormenta de polvo cubre la zona desde el primer minuto: el Sol casi no llega y la batería no se recarga mientras dura. (Necesita Riesgos activados.)"},
}


static func condicion(datos: Dictionary) -> Dictionary:
	return CONDICIONES.get(str(datos.get("condicion", "")), {})


static func lista_muestras(datos: Dictionary) -> Array[String]:
	var res: Array[String] = []
	if str(datos.get("tipo", "")) == "fotos":
		return res
	var m: Dictionary = datos.get("muestras", {})
	if m.is_empty():

		var id := str(datos.get("material", "oro"))
		for i in range(int(datos.get("objetos", 4))):
			res.append(id)
		return res
	for id in m:
		for i in range(int(m[id])):
			res.append(str(id))
	return res


static func afinidad(id: String, e: float, pend: float) -> float:
	match id:
		"hielo":
			return 1.0 - smoothstep(0.03, 0.14, e)
		"perclorato", "arcilla":
			return 1.0 - smoothstep(0.04, 0.2, e)
		"yeso":
			return 1.0 - smoothstep(0.08, 0.25, e)
		"hematita", "jarosita":
			return smoothstep(0.03, 0.09, e) * (1.0 - smoothstep(0.25, 0.45, e)) \
					* (1.0 - smoothstep(12.0, 26.0, pend))
		"olivino":
			return smoothstep(0.06, 0.14, e) * smoothstep(8.0, 20.0, pend)
		"silice":
			return smoothstep(0.05, 0.15, e) * (1.0 - smoothstep(10.0, 22.0, pend))
		"conglomerado":
			return smoothstep(0.02, 0.08, e) * (1.0 - smoothstep(0.2, 0.35, e))
		"regolito":
			return 1.0 - smoothstep(8.0, 18.0, pend)
		"nucleo":
			return 0.6
		"pata", "motor", "sismometro":
			return 1.0 - smoothstep(6.0, 16.0, pend)
		_:
			return smoothstep(0.12, 0.30, e) * smoothstep(10.0, 24.0, pend)
