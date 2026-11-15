extends RefCounted


const JEFES := {
	"KELLY":  {"cod": "087", "rol": "Jefa del programa",          "defiende": "Terreno seguro",        "color": Color(0.95, 0.36, 0.3)},
	"JULIO":  {"cod": "020", "rol": "Agua y hielo",               "defiende": "Agua",                  "color": Color(0.35, 0.78, 1.0)},
	"REYZER": {"cod": "117", "rol": "Rutas y logística",          "defiende": "Ruta fácil a la base",  "color": Color(0.96, 0.78, 0.25)},
	"GERALD": {"cod": "479", "rol": "Ciencia y vida",             "defiende": "Interés científico",    "color": Color(0.5, 0.9, 0.5)},
	"DAID":   {"cod": "204", "rol": "Energía y comunicaciones",   "defiende": "Energía y señal",       "color": Color(0.75, 0.55, 1.0)},
}

const MENSAJES := {
	"chryse_viking": {
		"antes": {"j": "KELLY", "t": "Piloto, aquí Kelly. En 158 días llegan los primeros humanos a Marte y aún no sabemos dónde aterrizarán. Vas a visitar diez lugares reales donde ya estuvieron nuestras sondas. En cada uno recoge muestras y decide con el comité. Empezamos por Viking 1, en 1976: una llanura plana."},
		"despues": {"j": "KELLY", "t": "Chryse es llana y fácil de usar, pero tiene poca agua y poco que estudiar. Apúntalo, piloto: cada lugar tiene cosas buenas y malas. Al final elegiremos el mejor."},
	},
	"ares_pathfinder": {
		"antes": {"j": "REYZER", "t": "Soy Reyzer, de rutas. En 1997 bajó aquí Pathfinder con Sojourner, el primer rover: un cochecito de 10 kilos. Esto fue un gran cauce de agua. Fíjate en lo difícil que es moverse entre tantas rocas."},
		"despues": {"j": "REYZER", "t": "Los guijarros redondos prueban que aquí corrió agua. Pero con tantas rocas, llegar a una base sería lento. Para mí, un buen camino pesa mucho."},
	},
	"polar_lander": {
		"antes": {"j": "DAID", "t": "Soy Daid, de energía y comunicaciones. En 1999 el Mars Polar Lander se perdió al aterrizar y no volvió a hablar. Hoy buscas sus restos para saber qué falló. Y mira el Sol: cerca del polo casi no sube."},
		"despues": {"j": "DAID", "t": "Un sensor mal interpretado y se perdió todo. Y aquí el Sol apenas asoma: los paneles casi no cargan. Habría hielo, sí, pero muy poca energía."},
	},
	"pancam_husband": {
		"antes": {"j": "GERALD", "t": "Gerald, ciencia. En 2005 Spirit subió a la colina Husband y fotografió el cielo marciano. Hoy no recoges muestras: haces fotos. Cada foto buena es un dato para el comité."},
		"despues": {"j": "GERALD", "t": "Buenas fotos, buenos datos. Aquí hubo fuentes de agua caliente hace miles de millones de años: un buen sitio para buscar vida, aunque con cuestas difíciles."},
	},
	"llanura_utopia": {
		"antes": {"j": "JULIO", "t": "Julio, agua y hielo. En 2008 Phoenix aterrizó cerca del polo norte y excavó: bajo el polvo había hielo. Eso es lo que más necesitamos. Busca hielo y perclorato, una sal que también hay en el suelo."},
		"despues": {"j": "JULIO", "t": "¡Hielo a pocos centímetros! Agua casi en la puerta de casa. El perclorato obliga a cuidar los filtros, pero con agua se puede vivir. Este sitio me gusta, piloto."},
	},
	"endeavour_opportunity": {
		"antes": {"j": "KELLY", "t": "Kelly otra vez. Opportunity llegó en 2011 al borde del cráter Endeavour, tras siete años de camino. Hay arcillas y yeso, pero también pendientes. Y cuidado con las tormentas de polvo: acabaron con ella en 2018."},
		"despues": {"j": "KELLY", "t": "Mucha ciencia, pero un borde con cuestas y tormentas. No es un sitio para aterrizar a ciegas. Cada lugar tiene su precio."},
	},
	"gale_curiosity": {
		"antes": {"j": "GERALD", "t": "Gale es un cráter con una montaña en el centro. Curiosity aterrizó en 2012 y halló arcillas: aquí hubo un lago donde la vida pudo existir. Recoge arcilla y yeso. Y hay una cueva en la pared."},
		"despues": {"j": "GERALD", "t": "Un lago antiguo y habitable. Si buscamos vida, este es de los mejores lugares. Llegar hasta aquí con una base ya es otra cuestión."},
	},
	"insight_elysium": {
		"antes": {"j": "DAID", "t": "InSight no se movía: escuchaba los terremotos de Marte desde 2018. La llanura de Elysium es lisa y con mucho Sol. Recoge el sismómetro con cuidado."},
		"despues": {"j": "DAID", "t": "Llanura lisa, buen Sol y buena señal. El polvo cubrió sus paneles al final, pero eso se arregla limpiándolos. Una candidata seria."},
	},
	"zhurong_utopia": {
		"antes": {"j": "JULIO", "t": "Zhurong, de China, llegó en 2021 a las dunas de Utopia. Halló minerales con agua atrapada en la costra de las dunas. Busca sílice y yeso."},
		"despues": {"j": "JULIO", "t": "Un poco de humedad guardada en el suelo y un terreno llano. Marte aún guarda agua, aunque no se vea. Solo falta una misión, piloto."},
	},
	"jezero_perseverance": {
		"antes": {"j": "GERALD", "t": "Última misión, piloto. Perseverance aterrizó en 2021 en el cráter Jezero, el delta de un río antiguo. Guarda muestras en tubos para traerlas algún día a la Tierra. Trátalas con respeto."},
		"despues": {"j": "KELLY", "t": "Diez misiones, diez lugares. Has visto lo bueno y lo malo de cada uno. Ahora el comité decide dónde aterrizan los primeros humanos, y tú tienes la última palabra."},
	},
}


static func jefe(nombre: String) -> Dictionary:
	return JEFES.get(nombre, {})


static func mensaje(id_mision: String, cuando: String) -> Dictionary:
	var m: Dictionary = MENSAJES.get(id_mision, {})
	return m.get(cuando, {})


static func titulo(nombre: String) -> String:
	var j := jefe(nombre)
	if j.is_empty():
		return nombre
	return "%s %s" % [nombre, str(j["cod"])]


static func texto_final(id_mision: String) -> String:
	var m := mensaje(id_mision, "despues")
	if m.is_empty():
		return ""
	return "%s: «%s»" % [titulo(str(m["j"])), str(m["t"])]


const DILEMAS := [
	{"j": "JULIO", "t": "El sensor detecta una zona húmeda a pocos metros. ¿Nos desviamos a medirla?",
		"a": {"txt": "Desviarte y medirla", "coste": 12, "crit": "agua", "d": 1, "res": "Hay humedad bajo el polvo. Julio lo anota: el sitio gana en agua.", "conf": 1, "ef": {"k": "escaner", "v": 0.20, "txt": "Los datos de humedad calibran tu escáner: +20 % de alcance."}},
		"b": {"txt": "Seguir la ruta", "coste": 0, "crit": "", "d": 0, "res": "Seguimos. Quizá otra vez.", "conf": 0}},
	{"j": "KELLY", "t": "El suelo de adelante parece inestable. Tú decides cómo pasar.",
		"a": {"txt": "Rodear con cuidado", "coste": 10, "crit": "seguro", "d": 1, "res": "Rodeaste el terreno blando. Kelly anota que el sitio es más seguro de lo que parecía.", "conf": 1},
		"b": {"txt": "Cruzar por el medio", "coste": 0, "crit": "seguro", "d": -1, "res": "Las ruedas se hundieron un momento. Kelly anota que el sitio es más peligroso.", "conf": -1, "ef": {"k": "consumo", "v": 0.15, "txt": "Las ruedas quedaron algo dañadas: +15 % de consumo de batería."}}},
	{"j": "REYZER", "t": "Hay un atajo por una pendiente: acorta, pero la subida gasta mucha batería.",
		"a": {"txt": "Tomar el atajo", "coste": 15, "crit": "ruta", "d": 1, "res": "El atajo funcionó. Reyzer anota una ruta más corta hacia la base.", "conf": 1, "ef": {"k": "consumo", "v": -0.10, "txt": "El atajo quedó marcado: −10 % de consumo de batería."}},
		"b": {"txt": "Ir por el camino llano", "coste": 0, "crit": "", "d": 0, "res": "Camino largo pero seguro.", "conf": 0}},
	{"j": "GERALD", "t": "Veo una roca con capas muy llamativa. ¿Paras a analizarla?",
		"a": {"txt": "Parar y analizarla", "coste": 8, "crit": "ciencia", "d": 1, "res": "Las capas guardan mucha historia. Gerald anota el valor científico del sitio.", "conf": 1, "ef": {"k": "escaner", "v": 0.20, "txt": "Las capas de roca afinaron tu espectrómetro: +20 % de alcance de escáner."}},
		"b": {"txt": "Seguir sin parar", "coste": 0, "crit": "", "d": 0, "res": "La roca queda atrás.", "conf": 0}},
	{"j": "DAID", "t": "Se abre una ventana de señal con la Tierra. Transmitir datos extra gasta batería.",
		"a": {"txt": "Transmitir datos extra", "coste": 15, "crit": "energia", "d": 1, "res": "Buena señal y energía estable. Daid anota que el sitio es bueno para comunicarse.", "conf": 1, "ef": {"k": "consumo", "v": -0.10, "txt": "Con la antena optimizada gastas menos: −10 % de consumo."}},
		"b": {"txt": "Ahorrar batería", "coste": 0, "crit": "", "d": 0, "res": "Se perdió la ventana, pero la batería está intacta.", "conf": 0}},
	{"j": "JULIO", "t": "Parece haber hielo bajo una capa de polvo. Perforar un momento gasta energía.",
		"a": {"txt": "Perforar", "coste": 14, "crit": "agua", "d": 1, "res": "¡Hielo! Julio no lo puede creer. El sitio gana en agua.", "conf": 1, "ef": {"k": "carga", "v": 1, "txt": "La perforación liberó espacio en la bodega: +1 de carga."}},
		"b": {"txt": "No perforar", "coste": 0, "crit": "", "d": 0, "res": "Nos quedamos con la duda.", "conf": 0}},
	{"j": "KELLY", "t": "Se levanta un viento fuerte. ¿Esperas a que amaine antes de seguir?",
		"a": {"txt": "Esperar un momento", "coste": 5, "crit": "seguro", "d": 1, "res": "Pasó el viento sin daños. Kelly anota un sitio más seguro.", "conf": 1, "ef": {"k": "consumo", "v": -0.10, "txt": "Esperaste con prudencia y ahorraste energía: −10 % de consumo."}},
		"b": {"txt": "Seguir con el viento", "coste": 0, "crit": "seguro", "d": -1, "res": "El polvo golpeó los sensores. Kelly anota un sitio más hostil.", "conf": -1, "ef": {"k": "escaner", "v": -0.15, "txt": "El polvo del viento ensució los sensores: −15 % de alcance de escáner."}}},
	{"j": "GERALD", "t": "Una cueva pequeña, quizá con minerales. ¿Te asomas?",
		"a": {"txt": "Asomarte", "coste": 10, "crit": "ciencia", "d": 1, "res": "Hay minerales raros. Gerald anota el interés del lugar.", "conf": 1, "ef": {"k": "escaner", "v": 0.20, "txt": "Los minerales de la cueva calibraron tu escáner: +20 % de alcance."}},
		"b": {"txt": "No arriesgar", "coste": 0, "crit": "", "d": 0, "res": "Mejor no complicarse.", "conf": 0}},
	{"j": "REYZER", "t": "Hay rocas en medio del camino. ¿Abres un paso marcado para futuras rutas?",
		"a": {"txt": "Abrir y marcar el paso", "coste": 10, "crit": "ruta", "d": 1, "res": "Paso marcado. Reyzer anota una ruta mejor para los próximos vehículos.", "conf": 1, "ef": {"k": "consumo", "v": -0.10, "txt": "El paso marcado reduce los rodeos: −10 % de consumo."}},
		"b": {"txt": "Rodear sin marcar", "coste": 0, "crit": "", "d": 0, "res": "Seguimos sin dejar huella.", "conf": 0}},
	{"j": "DAID", "t": "Hay una colina cerca: desde arriba la antena tendría mejor señal. ¿Subes?",
		"a": {"txt": "Subir a la colina", "coste": 12, "crit": "energia", "d": 1, "res": "Mejor señal desde arriba. Daid anota que el sitio tiene buena comunicación.", "conf": 1, "ef": {"k": "escaner", "v": 0.20, "txt": "Desde la colina calibraste la antena: +20 % de alcance de escáner."}},
		"b": {"txt": "Quedarte abajo", "coste": 0, "crit": "", "d": 0, "res": "Seguimos con la señal que hay.", "conf": 0}},
]


const DILEMA_DE := {
	"chryse_viking": 1, "ares_pathfinder": 2, "polar_lander": 6, "pancam_husband": 4, "llanura_utopia": 5,
	"endeavour_opportunity": 8, "gale_curiosity": 7, "insight_elysium": 9, "zhurong_utopia": 0, "jezero_perseverance": 3,
}


static func dilema(id_mision: String) -> Dictionary:
	if DILEMA_DE.has(id_mision):
		return DILEMAS[int(DILEMA_DE[id_mision]) % DILEMAS.size()]
	var h := 0
	for i in range(id_mision.length()):
		h = (h * 31 + id_mision.unicode_at(i)) % 100003
	return DILEMAS[h % DILEMAS.size()]


const RADIO := {
	"recoger": [
		{"j": "KELLY", "t": "Muestra a bordo. Buen trabajo, piloto."},
		{"j": "GERALD", "t": "¡Eso es! Cuídala: para la ciencia vale oro."},
		{"j": "JULIO", "t": "Perfecto. Mantén la carga estable."},
		{"j": "REYZER", "t": "Bien. Ahora piensa la ruta hasta la base, sin prisas."},
	],
	"entrega": [
		{"j": "KELLY", "t": "Entrega recibida en la base. Sigue así."},
		{"j": "DAID", "t": "Carga y datos confirmados. Señal limpia."},
		{"j": "GERALD", "t": "Ya tengo la muestra en el laboratorio. Gracias, piloto."},
		{"j": "JULIO", "t": "Otra entrega más. Vamos muy bien."},
	],
	"bateria_baja": [
		{"j": "DAID", "t": "Batería baja. Evita el turbo y las cuestas."},
		{"j": "KELLY", "t": "Cuida la energía, piloto: sin batería no hay misión."},
	],
	"tormenta": [
		{"j": "DAID", "t": "Detecto una tormenta de polvo. Los paneles no cargarán mientras dure."},
		{"j": "KELLY", "t": "Tormenta a la vista. Calma, y no gastes más batería de la necesaria."},
	],
	"meteoritos": [
		{"j": "DAID", "t": "¡Alerta! Detecto meteoritos entrando. Sal de las zonas rojas."},
		{"j": "REYZER", "t": "Lluvia de meteoritos. Muévete ya, piloto, y no te quedes parado."},
		{"j": "KELLY", "t": "Meteoritos. Mantén la calma y fíjate en los círculos rojos."},
	],
	"remolino": [
		{"j": "JULIO", "t": "Un remolino enorme viene hacia ti. Apártate de su camino."},
		{"j": "REYZER", "t": "Remolino a la vista. Esquívalo: dentro vas lento y gastas batería."},
	],
	"sensor": [
		{"j": "DAID", "t": "Fallo en el escáner. Quédate quieto cinco segundos y lo reinicio."},
		{"j": "GERALD", "t": "El sensor se bloqueó. Tranquilo, se arregla parando un momento."},
	],
	"anochecer": [
		{"j": "DAID", "t": "Anochece. Sin Sol los paneles no cargan: no te alejes más de la cuenta."},
		{"j": "REYZER", "t": "Se acaba la luz. Ve despacio con los faros y busca un camino claro."},
		{"j": "KELLY", "t": "Es de noche en Marte. Con calma, piloto: la seguridad primero."},
	],
	"amanecer": [
		{"j": "DAID", "t": "Amanece. Los paneles vuelven a cargar."},
		{"j": "JULIO", "t": "Sale el Sol. Qué bonito es el amanecer sobre Marte."},
	],
	"eclipse": [
		{"j": "GERALD", "t": "Fobos pasa delante del Sol unos segundos. Es raro verlo: mira, piloto."},
		{"j": "DAID", "t": "Fobos tapa el Sol: los paneles rinden menos unos segundos. Es normal."},
		{"j": "KELLY", "t": "No pasa a menudo. Párate un momento y míralo, piloto."},
	],
	"rescate": [
		{"j": "JULIO", "t": "Bien hecho. Aquí nadie se queda tirado, ni los robots."},
		{"j": "KELLY", "t": "Ayudar a otro rover cuesta batería, pero eso es lo que hace un buen equipo."},
		{"j": "GERALD", "t": "¡Sus datos son oro! Gracias por parar, piloto."},
	],
	"cueva": [
		{"j": "GERALD", "t": "Una cueva... ¡buen sitio para buscar minerales!"},
		{"j": "KELLY", "t": "Con cuidado ahí dentro. La señal puede fallar."},
	],
	"quieto": [
		{"j": "REYZER", "t": "¿Todo bien, piloto? Llevas un rato parado."},
		{"j": "JULIO", "t": "¿Descansando? Aprovecha y escanea los alrededores."},
	],
	"mitad": [
		{"j": "KELLY", "t": "Vas por la mitad de la misión. Sigue así."},
		{"j": "REYZER", "t": "Mitad del trabajo hecho. Buen ritmo."},
	],
}


static func radio(evento: String, n: int) -> Dictionary:
	var l: Array = RADIO.get(evento, [])
	if l.is_empty():
		return {}
	return l[n % l.size()]


const TUTORIAL := [
	"Bienvenido, piloto. Muévete con W A S D. Con SHIFT vas en turbo, pero gastas más batería.",
	"Bien. Pulsa ESPACIO para escanear: las muestras cercanas se revelan con un destello.",
	"Acércate a una muestra y pulsa E para recogerla. Luego llévala a la base B (el punto verde del radar te guía).",
	"¡Perfecto! Ya sabes lo básico. Los destellos azules son datos curiosos: se leen con E. Suerte.",
]


const PROGRAMA_INICIO := "En 158 días llegan las primeras personas a Marte y nadie sabe dónde deben aterrizar.\n\nEl comité de SPARTANS necesita un piloto que visite diez lugares reales donde ya estuvieron nuestras sondas, de Viking en 1976 a Perseverance en 2021.\n\nCon lo que encuentres, tú y el comité elegirán el lugar de aterrizaje."
const PROGRAMA_FIN := "Así funciona.\n\n1. Cada misión es un lugar real. Recoge sus muestras y llévalas a la base.\n2. En cada misión te toca una decisión. Cada jefe del comité defiende algo distinto: agua, seguridad, rutas, ciencia o energía.\n3. Tus decisiones dan puntos al lugar y confianza a los jefes. Con mucha confianza, un jefe te da una ventaja.\n4. Con al menos 6 lugares visitados, abres el Comité en el menú y eliges dónde aterrizar.\n\nEmpieza cuando quieras, piloto."
const FOCOS_FRASE := "Soy FOCOS, tu ayudante. Floto a tu lado en cada misión, marco en el radar lo que veo y, si pulsas H, te digo qué hacer. Luz verde: contento. Luz azul: te guío. Luz naranja: miedo."

const FRASES := {
	"KELLY": "Yo dirijo el programa. En Marte lo primero es volver con vida, y yo me encargo de que nadie se precipite.",
	"JULIO": "Sin agua no hay base. Si tú encuentras hielo, yo te sigo hasta el fin del mundo... o de Marte.",
	"REYZER": "Cada metro cuenta. Un buen camino ahorra tiempo, energía y vidas.",
	"GERALD": "Marte guarda respuestas de miles de millones de años. Yo solo quiero hacer las preguntas correctas.",
	"DAID": "Energía y señal: la base vive de las dos. Sin una antena no somos nada.",
}
