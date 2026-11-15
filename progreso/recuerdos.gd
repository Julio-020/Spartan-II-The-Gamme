extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")

const CLAVE := "recuerdos"

const CATEGORIAS := ["pintura", "bandera", "adorno", "motor"]

const NOMBRES := {"pintura": "Pintura del robot", "bandera": "Bandera en el mástil",
		"adorno": "Adorno de la base", "motor": "Sonido del motor"}
const DESCRIPCIONES := {
	"pintura": "El color del chasis. El robot es el mismo, pero se ve distinto.",
	"bandera": "Una banderita en la parte de atrás. Se mueve con tu robot por todo Marte.",
	"adorno": "Algo que te espera sobre la repisa del hangar antes de salir.",
	"motor": "Cómo suena tu robot al avanzar. No cambia la velocidad.",
}


const ITEMS := {
	"pintura": [
		{"id": "", "n": "Blanco de fábrica", "t": "El de siempre.", "c": 0, "col": Color(0.91, 0.91, 0.93)},
		{"id": "pin_rojo", "n": "Rojo Marte", "t": "Como el polvo del planeta.", "c": 3, "col": Color(0.78, 0.27, 0.17)},
		{"id": "pin_azul", "n": "Azul profundo", "t": "Para que se vea desde lejos.", "c": 3, "col": Color(0.18, 0.38, 0.78)},
		{"id": "pin_oro", "n": "Dorado", "t": "El de las mantas térmicas.", "c": 4, "col": Color(0.86, 0.68, 0.25)},
		{"id": "pin_negro", "n": "Negro mate", "t": "Sigiloso. Elegante. Absorbe calor.", "c": 4, "col": Color(0.13, 0.13, 0.15)},
	],
	"bandera": [
		{"id": "", "n": "Sin bandera", "t": "El mástil queda limpio.", "c": 0, "col": Color(0.5, 0.5, 0.55)},
		{"id": "ban_colombia", "n": "Colombia", "t": "Amarillo, azul y rojo, en Marte.", "c": 2, "col": Color(0.98, 0.8, 0.1)},
		{"id": "ban_tierra", "n": "La Tierra", "t": "Un punto azul pálido.", "c": 2, "col": Color(0.2, 0.45, 0.9)},
		{"id": "ban_marte", "n": "Marte", "t": "Roja, con una luna oscura.", "c": 2, "col": Color(0.85, 0.35, 0.2)},
	],
	"adorno": [
		{"id": "", "n": "Repisa vacía", "t": "Todavía no hay nada.", "c": 0, "col": Color(0.5, 0.5, 0.55)},
		{"id": "ado_planta", "n": "La primera planta", "t": "Una maceta con una hojita verde.", "c": 4, "col": Color(0.4, 0.8, 0.4)},
		{"id": "ado_globo", "n": "Globo de la Tierra", "t": "Para recordar de dónde vienes.", "c": 4, "col": Color(0.3, 0.55, 0.95)},
		{"id": "ado_cohete", "n": "Cohete de juguete", "t": "El que soñabas de niño.", "c": 5, "col": Color(0.95, 0.3, 0.25)},
	],
	"motor": [
		{"id": "", "n": "Motor de fábrica", "t": "Zumbido eléctrico normal.", "c": 0, "col": Color(0.6, 0.6, 0.65)},
		{"id": "mot_grave", "n": "Grave", "t": "Un ronroneo hondo, de camión viejo.", "c": 3, "col": Color(0.55, 0.45, 0.35)},
		{"id": "mot_silbido", "n": "Silbido", "t": "Agudo y limpio, de tren eléctrico.", "c": 3, "col": Color(0.5, 0.8, 1.0)},
		{"id": "mot_coro", "n": "Acorde", "t": "Tres notas a la vez. Tu robot canta.", "c": 4, "col": Color(0.8, 0.6, 1.0)},
	],
}


static func _estado() -> Dictionary:
	var e: Variant = MetaEstado.extra_get(CLAVE, {})
	if e is Dictionary:
		return e
	return {}


static func _guardar(e: Dictionary) -> void:
	MetaEstado.extra_set(CLAVE, e)


static func items(cat: String) -> Array:
	return ITEMS.get(cat, [])


static func item(id: String) -> Dictionary:
	for cat in CATEGORIAS:
		for it: Dictionary in ITEMS[cat]:
			if str(it["id"]) == id and id != "":
				return it
	return {}


static func categoria_de(id: String) -> String:
	for cat in CATEGORIAS:
		for it: Dictionary in ITEMS[cat]:
			if str(it["id"]) == id and id != "":
				return cat
	return ""


static func tiene(id: String) -> bool:
	if id == "":
		return true
	var l: Variant = _estado().get("tiene", [])
	return l is Array and (l as Array).has(id)


static func puesto(cat: String) -> String:
	var p: Variant = _estado().get("puesto", {})
	if p is Dictionary:
		var id := str((p as Dictionary).get(cat, ""))
		if tiene(id):
			return id
	return ""


static func poner(cat: String, id: String) -> bool:
	if not CATEGORIAS.has(cat) or not tiene(id):
		return false
	if id != "" and categoria_de(id) != cat:
		return false
	var e := _estado().duplicate(true)
	var p: Dictionary = e.get("puesto", {})
	p[cat] = id
	e["puesto"] = p
	_guardar(e)
	return true


static func comprar(id: String) -> bool:
	var it := item(id)
	if it.is_empty() or tiene(id):
		return false
	if not MetaEstado.gastar(0, int(it["c"])):
		return false
	var e := _estado().duplicate(true)
	var l: Array = e.get("tiene", [])
	l.append(id)
	e["tiene"] = l
	_guardar(e)
	return poner(categoria_de(id), id)


static func color_pintura() -> Color:
	var id := puesto("pintura")
	if id == "":
		return Color(0.91, 0.91, 0.93)
	return item(id).get("col", Color(0.91, 0.91, 0.93))


static func clave_motor() -> String:
	var id := puesto("motor")
	return "motor" if id == "" else "motor_" + id.trim_prefix("mot_")
