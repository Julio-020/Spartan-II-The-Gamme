extends RefCounted


const Idioma := preload("res://nucleo/idioma.gd")

const NOMBRE := "FOCOS"
const COLOR := Color(0.45, 0.82, 1.0)

const FRASES := {
	"presentacion": ["Hola, soy FOCOS, tu ayudante. Luz verde: estoy contento. Luz roja: tengo problemas. Luz naranja: tengo miedo."],
	"marca_muestra": ["¡Veo algo brillar! Ya lo marqué en el radar.", "Allá abajo hay una muestra. Anotada.", "¡Eso es una muestra! ¿O es una roca presumida?"],
	"marca_cueva": ["Hay una grieta oscura allá abajo. No me gusta, pero la marqué.", "Una cueva. Yo no entro, que no cabe mi orgullo."],
	"marca_dato": ["Veo algo curioso en el suelo. Lo dejé marcado.", "Eso parece un dato interesante. ¡A leerlo!"],
	"escolta_inicio": ["¡Listo, jefe! Voy contigo. Pulsa H y te digo qué hacer.", "FOCOS a tu lado. Si me necesitas, pulsa H."],
	"escolta_ocioso": ["Todo tranquilo por aquí. Yo vigilo el cielo.", "¿Sabías que mi luz verde significa «todo bien»? Hoy es verde.", "Voy flotando a tu lado. Es lo mejor de ser FOCOS.",
			"Si ves algo raro, dímelo y lo apunto.", "Marte es enorme. Menos mal que somos dos."],
	"guia": ["¡Sígueme, jefe! Hay algo por allá.", "Voy delante: mi luz azul marca el camino.", "Por aquí. ¡Yo hago de flecha!"],
	"guia_base": ["Llevas muestras. La base está por allá: sígueme.", "Hora de entregar. Mi luz azul te lleva a la base."],
	"recoge": ["¡Muestra a bordo! Buen trabajo, jefe.", "¡Eso! Una más para la colección.", "¡Guau! Qué bonita. Bueno, es una piedra, pero bonita."],
	"entrega": ["¡Entregado! La base nos lo agradece.", "Misión cumplida por ahora. ¿Y la siguiente?", "¡Qué orgullo de equipo!"],
	"bateria_robot": ["Jefe, tu batería está baja. Ve a la base o espera al Sol: yo te acompaño.", "Poca energía en el robot. Vamos con calma, ¿sí?"],
	"tormenta_escolta": ["¡Tormenta! Me agarro a tu lomo. ¡No arranques fuerte!", "Viento y polvo... me escondo en tu espalda. Gracias por el refugio."],
	"cielo": ["¡Mira arriba, jefe! Qué cielo más bonito.", "Esto es mejor que cualquier misión. Mira ese cielo.", "Voy a apuntar esto en mi diario: cielo precioso."],
	"eclipse": ["Fobos tapa el Sol... qué pulso tan raro. ¿Tú también lo notas?", "¡Eclipse! Tengo la luz azul de la emoción."],
	"hallazgo": ["Mi sensor pita... Hay algo escondido %s, a unos %d m."],
}


static func frase(clave: String, semilla: int) -> String:
	if not FRASES.has(clave):
		return ""
	var l: Array = FRASES[clave]
	return Idioma.t(str(l[absi(semilla) % l.size()]))
