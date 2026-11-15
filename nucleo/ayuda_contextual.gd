extends RefCounted


const Ajustes := preload("res://nucleo/ajustes.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")

const CLAVE := "consejos_vistos"

const CONSEJOS := {
	"guia": {"t": "FLECHA DE OBJETIVO",
		"x": "La flecha dorada bajo la brújula apunta a lo siguiente: la base o una señal del escáner. Puedes cambiarla en Configuraciones."},
	"holo": {"t": "PREGUNTA A FOCOS",
		"x": "Pulsa H y el holograma de FOCOS te dice qué hacer ahora: la muestra más cercana, la base, la batería o la tormenta."},
	"cueva": {"t": "DENTRO DE UNA CUEVA",
		"x": "Dentro está oscuro. Mira con calma, recoge lo que haya y sal sin prisa."},
	"hallazgo": {"t": "HALLAZGOS ESCONDIDOS",
		"x": "Dan datos de ciencia y quedan guardados en DIARIO → COLECCIÓN. Hay más escondidos por todo Marte."},
	"laboratorio": {"t": "EL LABORATORIO",
		"x": "El botón LABORATORIO del panel final analiza las muestras que acabas de guardar y te da datos de ciencia."},
	"taller": {"t": "EL TALLER",
		"x": "Con las muestras y los datos del almacén puedes mejorar el robot: menú principal → DIARIO → TALLER."},
	"expedicion": {"t": "EXPEDICIÓN INFINITA",
		"x": "No tiene historia: el mapa lo decide la semilla. Con la misma semilla juegas el mismo mapa y puedes batir tu récord."},
	"radio": {"t": "RADIO A LA TIERRA",
		"x": "C abre la radio: consulta a un jefe del comité. La respuesta tarda unos segundos en volver y habla de cómo estaba todo cuando preguntaste."},
	"foto": {"t": "MODO FOTO",
		"x": "F cambia el filtro, M el marco y G enseña una cuadrícula. Las fotos se ven en el menú principal → MÁS → ÁLBUM DE FOTOS."},
}


static func _vistos() -> Array:
	var v: Variant = MetaEstado.extra_get(CLAVE, [])
	return v if v is Array else []


static func tomar(id: String) -> Dictionary:
	if int(Ajustes.consejos) <= 0 or not CONSEJOS.has(id):
		return {}
	var vistos := _vistos()
	if vistos.has(id):
		return {}
	vistos = vistos.duplicate()
	vistos.append(id)
	MetaEstado.extra_set(CLAVE, vistos)
	return CONSEJOS[id]


static func reiniciar() -> void:
	MetaEstado.extra_set(CLAVE, [])
