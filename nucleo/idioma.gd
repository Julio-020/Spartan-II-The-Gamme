extends RefCounted


const Ajustes := preload("res://nucleo/ajustes.gd")

static var _tr: Translation = null
static var _puesta: bool = false


static func en_ingles() -> bool:
	return Ajustes.idioma == 1


static func aplicar() -> void:
	if en_ingles():
		if _tr == null:
			var clase: GDScript = load("res://nucleo/traductor_en.gd")
			_tr = clase.new()
			_tr.locale = "en"
		if not _puesta:
			TranslationServer.add_translation(_tr)
			_puesta = true
		TranslationServer.set_locale("en")
	else:
		if _tr != null and _puesta:
			TranslationServer.remove_translation(_tr)
			_puesta = false
		TranslationServer.set_locale("es")


static func t(texto: String) -> String:
	if not en_ingles() or _tr == null:
		return texto
	return _tr.call("traducir", texto)
