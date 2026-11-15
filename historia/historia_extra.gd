extends RefCounted


const REACCIONES := {
	"KELLY": {
		"molesto": [
			"Piloto, tus últimas decisiones me inquietan. Necesito saber que me escuchas.",
			"No me gusta cómo estás llevando esto. Cada error pesa el doble, y yo respondo ante todos.",
		],
		"leal": [
			"Me gusta cómo decides, piloto. Con alguien así al mando del robot, me cuesta menos dormir.",
			"Has ganado mi confianza. Lo que venga, lo afrontamos juntos.",
		],
	},
	"JULIO": {
		"molesto": [
			"Piloto, te has pasado de serio conmigo. El agua no se encuentra a base de órdenes, se encuentra con ganas.",
			"Esto ya no es divertido. Si seguimos así, me quedo en la cámara fría y que el hielo hable por mí.",
		],
		"leal": [
			"¡Ja! Me caes bien, piloto. Cuando esto acabe, el primer vaso de agua marciana lo bebes tú.",
			"Contigo da gusto trabajar. Y si hay agua en Marte, tú serás quien la encuentre.",
		],
	},
	"REYZER": {
		"molesto": [
			"Llevas varias rutas torcidas, piloto. Cada metro que se pierde, lo pago yo con baterías y con tiempo.",
			"No estás pensando en el camino de vuelta. Alguien tiene que hacerlo, y no pienso callarme.",
		],
		"leal": [
			"Rutas limpias, entregas a tiempo, decisiones con cabeza. Así se tiende un camino, piloto.",
			"Contigo, mis mapas por fin sirven para algo. Gracias.",
		],
	},
	"GERALD": {
		"molesto": [
			"Piloto, estás ignorando datos que importan. Si tiras la ciencia por la borda, ¿qué nos queda?",
			"Ya van varias veces que pasas por alto lo que te digo y me da rabia. La ciencia merece mejor método.",
		],
		"leal": [
			"Tienes ojo de científico, piloto. Si algún día quieres cambiar el volante por un microscopio, avísame.",
			"Tus decisiones tienen sentido. Con ese criterio, entenderemos Marte.",
		],
	},
	"DAID": {
		"molesto": [
			"Piloto, estoy gastando la energía de la base en limpiar tus errores. No me hagas repetirlo.",
			"Cuando llegue la próxima tormenta, vamos a necesitar una batería que ahora no tenemos. Piénsalo.",
		],
		"leal": [
			"Energía estable y señal limpia gracias a ti. Eres de los pocos que escucha antes de actuar.",
			"Hay silencios que se parecen a la confianza. Este es uno de ellos, piloto.",
		],
	},
}


const CHARLAS := [
	{"j": "KELLY", "t": "Llevas buen ritmo, piloto. ¿Cómo te sientes ahí fuera?",
		"serio": "Concentrado. Sin errores.", "bromista": "Como un turista con un robot de lujo.", "tecnico": "Sistemas al 100 %: ruedas y paneles sin novedad."},
	{"j": "KELLY", "t": "Una pregunta personal: ¿por qué quieres ir a Marte?",
		"serio": "Porque alguien tiene que hacerlo bien.", "bromista": "Para que las postales me las manden a mí.", "tecnico": "Porque es el mejor laboratorio natural que existe."},
	{"j": "JULIO", "t": "Piloto, si tuvieras que elegir: ¿agua o aire?",
		"serio": "Agua: es lo primero.", "bromista": "Café, y que haya agua para hacerlo.", "tecnico": "Agua: de ella sale aire, combustible y bebida."},
	{"j": "JULIO", "t": "A veces cae escarcha por la mañana. ¿Te gustaría verla?",
		"serio": "Quiero verla con mis propios ojos.", "bromista": "Si cae, hago un muñeco de nieve marciano.", "tecnico": "La escarcha de agua y la de CO2 se forman distinto."},
	{"j": "REYZER", "t": "Logística: ¿qué importa más, la velocidad o la seguridad?",
		"serio": "La seguridad. Siempre.", "bromista": "La velocidad... y unos buenos frenos.", "tecnico": "Depende de la batería y de la pendiente."},
	{"j": "REYZER", "t": "Si pierdes la señal a mitad de ruta, ¿qué haces?",
		"serio": "Vuelvo por mis huellas hasta la base.", "bromista": "Pongo música y sigo adelante.", "tecnico": "Sigo el rumbo con la brújula y la flecha de la base."},
	{"j": "GERALD", "t": "Mira ese horizonte. ¿Qué crees que hay más allá?",
		"serio": "Más Marte, y mucho trabajo.", "bromista": "Seguro que un helado. Marciano, pero helado.", "tecnico": "Probablemente más campos de roca basáltica."},
	{"j": "GERALD", "t": "¿Crees que hubo vida aquí alguna vez?",
		"serio": "No lo sé, pero merece la pena averiguarlo.", "bromista": "Si la hubo, espero que dejara el Wi-Fi.", "tecnico": "Hubo agua y química orgánica: es plausible."},
	{"j": "DAID", "t": "Energía al 100 %, en teoría. ¿Qué haces cuando la batería baja?",
		"serio": "Paro, espero al Sol y no arriesgo.", "bromista": "Rezo al Sol. Con mucho cariño.", "tecnico": "Evito el turbo, las cuestas y cargo parado."},
	{"j": "DAID", "t": "Si pudieras mejorar el robot, ¿qué le pondrías?",
		"serio": "Más batería y más protección.", "bromista": "Un asiento con calefacción y radio.", "tecnico": "Un radar mejor y un panel solar extra."},
]


const PREFERENCIA := {
	"KELLY":  {"serio": 2, "tecnico": 1, "bromista": -1},
	"JULIO":  {"bromista": 2, "tecnico": 1, "serio": -1},
	"REYZER": {"tecnico": 2, "serio": 1, "bromista": -1},
	"GERALD": {"tecnico": 2, "bromista": 1, "serio": -1},
	"DAID":   {"tecnico": 2, "serio": 1, "bromista": -1},
}


const REPLICAS := {
	"KELLY": {
		"serio": "Eso es lo que quería oír. Gracias, piloto.",
		"tecnico": "Bien informado. Me gusta que cuides el equipo.",
		"bromista": "Ja... bueno. El humor ayuda, pero no te distraigas.",
	},
	"JULIO": {
		"bromista": "¡Ja! Eso me gusta. Con ese ánimo el hielo se encuentra solo.",
		"tecnico": "Buena respuesta, piloto. Se nota que sabes lo que haces.",
		"serio": "Vale, vale... tan serio. Algún día te saco una sonrisa.",
	},
	"REYZER": {
		"tecnico": "Eso es pensar como un logista. Bien.",
		"serio": "Correcto. Cada metro cuenta.",
		"bromista": "No bromees con eso, piloto. Pero te perdono.",
	},
	"GERALD": {
		"tecnico": "Excelente razonamiento. Eso es ciencia.",
		"bromista": "¡Ja, ja! Cierto. Aunque yo pediría un laboratorio.",
		"serio": "Hmm. Algo seco, pero cierto.",
	},
	"DAID": {
		"tecnico": "Respuesta perfecta. La energía es lo primero.",
		"serio": "Bien. Mejor prudente que sin batería.",
		"bromista": "Muy gracioso. Aun así, el Sol no escucha rezos.",
	},
}


const SECUNDARIAS := {
	"KELLY": {
		"pedido": "Piloto, hay un punto de interés a unos %d m. Quiero que lo revises, sin arriesgar la misión. ¿Vas?",
		"ok": "Revisado. Buen trabajo, piloto: lo anoto en tu historial.",
	},
	"JULIO": {
		"pedido": "Creo que hay humedad a unos %d m. ¿Te acercas a mirarla? ¡Podría ser agua!",
		"ok": "¡Humedad bajo el polvo! Gracias, piloto, me hiciste el día.",
	},
	"REYZER": {
		"pedido": "Hay una zona de paso a %d m. Si la compruebas, las rutas futuras serán mejores. ¿Te desvías?",
		"ok": "Paso comprobado. Ahorrarás tiempo a todos los que vengan después.",
	},
	"GERALD": {
		"pedido": "Detecto una anomalía a %d m: algo raro en los datos. ¿Puedes verla de cerca?",
		"ok": "Fascinante. Los datos son aún mejores de lo que esperaba.",
	},
	"DAID": {
		"pedido": "Hay una señal parásita a %d m. Quiero comprobarla antes de que moleste a la base. ¿Vas?",
		"ok": "Señal localizada: no era un fallo. Gracias por ir, piloto.",
	},
}

const SEC_CONF := 2
const SEC_BATERIA := 10.0
const SEC_ALCANCE := 4.0
const SEC_TIEMPO := [180.0, 140.0, 110.0]


const VENTAJAS := {
	"KELLY":  {"txt": "Golpes y sucesos hacen la mitad de daño", "golpe": 0.5},
	"JULIO":  {"txt": "Recuperas 5 % de batería en cada entrega", "recarga": 5.0},
	"REYZER": {"txt": "El robot carga 1 muestra más", "carga": 1},
	"GERALD": {"txt": "El escáner llega un 25 % más lejos", "escaner": 0.25},
	"DAID":   {"txt": "El robot gasta un 15 % menos de batería", "consumo": -0.15},
}


const TITULOS_FINAL := {
	"unidos": {"m": "PILOTO DE LA PRIMERA BASE", "f": "PILOTA DE LA PRIMERA BASE"},
	"acuerdo": {"m": "PILOTO DEL COMITÉ", "f": "PILOTA DEL COMITÉ"},
	"dividido": {"m": "ÚLTIMO DEL PROGRAMA", "f": "ÚLTIMA DEL PROGRAMA"},
}

const FINALES := {
	"unidos": {
		"titulo": "UN EQUIPO UNIDO", "color": Color(0.45, 0.9, 0.55),
		"resumen": "El equipo confió en ti y eligió el lugar de aterrizaje con acuerdo.",
		"lineas": [
			{"j": "KELLY", "t": "Piloto, lo conseguimos. Diez lugares, diez informes y un comité que confía en ti."},
			{"j": "GERALD", "t": "Cada dato que trajiste cuenta. Hemos decidido con ciencia, no con suposiciones."},
			{"j": "DAID", "t": "Con la energía y la señal que midió tu rover, la base tendrá luz y voz desde el primer día."},
			{"j": "JULIO", "t": "Y el agua está donde tú dijiste. Eso lo cambia todo."},
			{"j": "REYZER", "t": "Los caminos que abriste los usarán los primeros humanos. Gracias, piloto."},
			{"j": "KELLY", "t": "SPARTANS II ha terminado, pero la historia de Marte acaba de empezar. Tu nombre queda en la puerta de la primera base."},
		],
	},
	"acuerdo": {
		"titulo": "UN ACUERDO A TIEMPO", "color": Color(1.0, 0.78, 0.3),
		"resumen": "El comité llegó a un acuerdo, con algunas dudas por el camino.",
		"lineas": [
			{"j": "KELLY", "t": "Hemos llegado a un acuerdo, piloto. No todos pensamos igual, pero sí lo bastante."},
			{"j": "GERALD", "t": "Habría pedido más datos, pero con lo que hay se puede decidir bien."},
			{"j": "DAID", "t": "Habrá que reforzar la energía y la señal, pero es un buen punto de partida."},
			{"j": "REYZER", "t": "Prepararé las rutas con calma. Se puede hacer."},
			{"j": "KELLY", "t": "Gracias por tu trabajo, piloto. Los primeros humanos llegarán con tus mapas en la mano."},
		],
	},
	"dividido": {
		"titulo": "UNA DECISIÓN DIVIDIDA", "color": Color(1.0, 0.4, 0.35),
		"resumen": "El equipo quedó dividido, pero el lugar de aterrizaje ya está elegido.",
		"lineas": [
			{"j": "KELLY", "t": "La decisión está tomada, piloto, aunque el equipo no está del todo unido."},
			{"j": "GERALD", "t": "No estoy de acuerdo con todo, pero lo asumo. La ciencia tendrá que esperar su turno."},
			{"j": "REYZER", "t": "Cada uno trabajará por su lado un tiempo. Quizá más adelante podamos hablar con calma."},
			{"j": "KELLY", "t": "En Marte hay que confiar los unos en los otros. La próxima vez, escucha más a tu equipo."},
		],
	},
}


static func charla(n: int) -> Dictionary:
	return CHARLAS[posmod(n, CHARLAS.size())]


static func preferencia(jefe: String, tono: String) -> int:
	return int((PREFERENCIA.get(jefe, {}) as Dictionary).get(tono, 0))


static func replica(jefe: String, tono: String) -> String:
	return str((REPLICAS.get(jefe, {}) as Dictionary).get(tono, ""))
