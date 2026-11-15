extends RefCounted


const Bitacora := preload("res://progreso/bitacora.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")

const POSDATAS := [
	"P.D.: Tengo polvo rojo hasta en los pensamientos.",
	"P.D.: El silencio de aquí no se parece a ningún otro.",
	"P.D.: Hoy el cielo tenía color de caramelo.",
	"P.D.: Me pregunto si alguien más habrá pasado por este mismo lugar.",
	"P.D.: El robot y yo ya nos entendemos sin hablar.",
	"P.D.: Desde aquí, la Tierra es una estrella más.",
	"P.D.: Lo mejor de Marte son las huellas: nadie las borra pronto.",
	"P.D.: Mañana toca otro lugar. Ya tengo la mochila lista.",
]


static func paginas() -> Array:
	var ultima := {}
	for e: Dictionary in Bitacora.entradas():
		if bool(e.get("exp", false)):
			continue
		ultima[str(e.get("id", ""))] = e
	var r: Array = []
	for m: Dictionary in DatosMarte.MISIONES:
		var id := str(m["id"])
		if ultima.has(id):
			r.append({"mision": m, "entrada": ultima[id]})
	return r


static func notas(e: Dictionary) -> Array[String]:
	var l: Array[String] = []
	var t := int(float(e.get("tiempo", 0.0)))
	if t < 240:
		l.append("Fui rápido: %d:%02d de camino." % [t / 60, t % 60])
	elif t < 420:
		l.append("Me tomó %d:%02d, sin prisa pero sin pausa." % [t / 60, t % 60])
	else:
		l.append("Tardé %d:%02d. Hoy Marte me hizo esperar." % [t / 60, t % 60])
	var total := int(e.get("total", 0))
	var n := int(e.get("muestras", 0))
	if total <= 0:
		l.append("Hoy no había muestras que cargar: era cuestión de llegar.")
	elif n >= total:
		l.append("Entregué las %d muestras. Ni una se quedó en el camino." % total)
	else:
		l.append("Entregué %d de %d muestras. La próxima vez las busco mejor." % [n, total])
	var h := int(e.get("hallazgos", 0))
	if h == 1:
		l.append("Encontré una cosa rara lejos de la ruta. La dibujé al lado.")
	elif h > 1:
		l.append("Encontré %d cosas raras lejos de la ruta. Las marqué en el dibujo." % h)
	var dec := str(e.get("decision", ""))
	if dec != "":
		l.append("Por radio decidí: %s" % dec)
	var en := float(e.get("energia_min", -1.0))
	if en >= 0.0 and en < 25.0:
		l.append("La batería bajó hasta el %d por ciento. Mejor no repetirlo." % int(en))
	var meds: Array = e.get("medallas", [])
	if not meds.is_empty():
		l.append("Me dieron la medalla: %s." % str(meds[0]))
	return l


static func posdata(id: String) -> String:
	return str(POSDATAS[absi(hash(id)) % POSDATAS.size()])
