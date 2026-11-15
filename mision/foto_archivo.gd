extends RefCounted


const Partidas := preload("res://nucleo/partidas.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const ANCHO := 640
const ALTO := 360

static var _cache: Dictionary = {}


static func ruta(id: String) -> String:
	return Partidas.subcarpeta("archivo") + "/" + id + ".png"


static func existe(id: String) -> bool:
	return FileAccess.file_exists(ruta(id))


static func guardar(id: String, img: Image) -> bool:
	if img == null or img.is_empty():
		return false
	DirAccess.make_dir_recursive_absolute(Partidas.subcarpeta("archivo"))
	var c := img.duplicate() as Image
	c.resize(ANCHO, ALTO, Image.INTERPOLATE_BILINEAR)
	_cache.erase(id)
	return c.save_png(ruta(id)) == OK


static func textura(id: String) -> Texture2D:
	var r := ruta(id)
	if _cache.has(r):
		return _cache[r]
	if not FileAccess.file_exists(r):
		return null
	var img := Image.load_from_file(r)
	if img == null or img.is_empty():
		return null
	var t := ImageTexture.create_from_image(img)
	_cache[r] = t
	return t


static func marco(m: Dictionary, ancho: float = 260.0, con_pie: bool = true) -> Control:
	var t := textura(str(m.get("id", "")))
	if t == null:
		return null
	var alto := ancho * float(ALTO) / float(ANCHO)
	var raiz := Control.new()
	raiz.custom_minimum_size = Vector2(ancho + 16.0, alto + (38.0 if con_pie else 16.0))
	var fondo := Panel.new()
	fondo.add_theme_stylebox_override("panel", EstiloUI.caja(Color(0.93, 0.9, 0.82), 3.0))
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(fondo)
	var tr := TextureRect.new()
	tr.texture = t
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.position = Vector2(8.0, 8.0)
	tr.size = Vector2(ancho, alto)
	tr.modulate = Color(1.0, 0.95, 0.86)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(tr)
	if not con_pie:
		return raiz
	var pie := EstiloUI.etiqueta("%s  ·  %s" % [str(m.get("era", "")), str(m.get("nave", ""))], 13, Color(0.25, 0.22, 0.2), true)
	pie.position = Vector2(10.0, alto + 12.0)
	pie.size = Vector2(ancho - 4.0, 20.0)
	pie.clip_text = true
	pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(pie)
	return raiz
