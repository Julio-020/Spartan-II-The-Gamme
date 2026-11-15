extends RefCounted


const MetaEstado := preload("res://progreso/meta_estado.gd")
const Bitacora := preload("res://progreso/bitacora.gd")
const Cuaderno := preload("res://progreso/cuaderno.gd")
const Mejoras := preload("res://progreso/mejoras.gd")
const Recuerdos := preload("res://progreso/recuerdos.gd")

const CLAVE := "diario_visto"
const PESTANAS := ["bitacora", "recuerdos", "taller"]


static func _visto() -> Dictionary:
	var v: Variant = MetaEstado.extra_get(CLAVE, {})
	return v if v is Dictionary else {}


static func _marca(id: String) -> int:
	match id:
		"bitacora":
			return Bitacora.num()
		"recuerdos":
			return Cuaderno.paginas().size()
		"taller":
			return MetaEstado.datos() * 1000 + MetaEstado.stock_total()
	return 0


static func hay_compra() -> bool:
	for rama in Mejoras.ORDEN:
		if Mejoras.puede_comprar(rama):
			return true
	var d := MetaEstado.datos()
	for cat in Recuerdos.CATEGORIAS:
		for it: Dictionary in Recuerdos.items(cat):
			var id := str(it["id"])
			if id != "" and not Recuerdos.tiene(id) and int(it["c"]) <= d:
				return true
	return false


static func nuevo(id: String) -> bool:
	if not PESTANAS.has(id):
		return false
	var m := _marca(id)
	if id == "taller":
		return hay_compra() and int(_visto().get(id, -1)) != m
	return m > int(_visto().get(id, 0))


static func total() -> int:
	var n := 0
	for id in PESTANAS:
		if nuevo(id):
			n += 1
	return n


static func visto(id: String) -> void:
	if not PESTANAS.has(id):
		return
	var v := _visto().duplicate()
	var m := _marca(id)
	if int(v.get(id, -1)) == m:
		return
	v[id] = m
	MetaEstado.extra_set(CLAVE, v)
