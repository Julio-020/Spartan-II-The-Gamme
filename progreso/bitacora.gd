extends RefCounted


const Partidas := preload("res://nucleo/partidas.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const MAX_ENTRADAS := 400

static var _d: Array = []
static var _cargado: bool = false


static func _archivo() -> String:
	return Partidas.ruta("bitacora.json")


static func invalidar() -> void:
	_cargado = false
	_d = []


static func _asegurar() -> void:
	if _cargado:
		return
	_cargado = true
	_d = []
	if not FileAccess.file_exists(_archivo()):
		return
	var f := FileAccess.open(_archivo(), FileAccess.READ)
	if f == null:
		return
	var j: Variant = JSON.parse_string(f.get_as_text())
	if j is Array:
		_d = j


static func guardar() -> void:
	if not _cargado:
		return
	var f := FileAccess.open(_archivo(), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(_d))


static func registrar(e: Dictionary) -> void:
	_asegurar()
	var n := e.duplicate()
	n["n"] = _d.size() + 1
	n["fecha"] = Time.get_datetime_string_from_system(false, true)
	_d.append(n)
	while _d.size() > MAX_ENTRADAS:
		_d.pop_front()
	guardar()


static func entradas() -> Array:
	_asegurar()
	return _d.duplicate()


static func num() -> int:
	_asegurar()
	return _d.size()


static func titulo_entrada(e: Dictionary) -> String:
	if bool(e.get("exp", false)):
		return "ENTRADA %d · EXPEDICIÓN %d" % [int(e.get("n", 0)), int(e.get("semilla", 0))]
	return "ENTRADA %d · SOL %d · %s" % [int(e.get("n", 0)), int(e.get("sol", 1)), str(e.get("nombre", "")).to_upper()]


static func lineas_entrada(e: Dictionary) -> Array[String]:
	var l: Array[String] = []
	var t := int(float(e.get("tiempo", 0.0)))
	l.append("Misión terminada en %d:%02d y %.1f km recorridos." % [t / 60, t % 60, float(e.get("km", 0.0))])
	l.append("Entregué %d de %d muestras." % [int(e.get("muestras", 0)), int(e.get("total", 0))])
	if int(e.get("total_curiosos", 0)) > 0:
		l.append("Leí %d de %d datos curiosos." % [int(e.get("curiosos", 0)), int(e.get("total_curiosos", 0))])
	if int(e.get("hallazgos", 0)) > 0:
		l.append("Encontré %d hallazgos escondidos." % int(e.get("hallazgos", 0)))
	if bool(e.get("exp", false)) and int(e.get("puntos", 0)) > 0:
		l.append("Puntuación de la expedición: %d." % int(e.get("puntos", 0)))
	var dec := str(e.get("decision", ""))
	if dec != "":
		l.append("Decisión por radio: %s" % dec)
	var meds: Array = e.get("medallas", [])
	if not meds.is_empty():
		l.append("Medallas ganadas: %s." % ", ".join(PackedStringArray(meds)))
	l.append(frase_final(e))
	return l


static func frase_final(e: Dictionary) -> String:
	var en := float(e.get("energia_min", -1.0))
	var total := int(e.get("total", 0))
	var muestras := int(e.get("muestras", 0))
	if en >= 0.0 and en < 20.0:
		return "Volví a la base con la batería casi vacía. No quiero acercarme más a ese límite."
	if int(e.get("hallazgos", 0)) > 0:
		return "Encontré algo que no figuraba en ningún informe. Lo anoto aquí para que no se pierda."
	if str(e.get("decision", "")) != "":
		return "Todavía le doy vueltas a lo que decidí por radio."
	if total > 0 and muestras >= total and float(e.get("tiempo", 999.0)) < 300.0:
		return "Todo salió según el plan. El robot se portó de maravilla."
	if int(e.get("eventos", 0)) >= 2:
		return "Marte no lo puso fácil: tuvimos varios sustos por el camino."
	return "Otro día de trabajo en Marte. El polvo ya se asienta."


static func texto_entrada(e: Dictionary) -> String:
	var partes: Array[String] = [titulo_entrada(e)]
	partes.append_array(lineas_entrada(e))
	return "\n".join(PackedStringArray(partes))


static func texto_exportable() -> String:
	_asegurar()
	var s := Idioma.t("BITÁCORA DEL PILOTO · SPARTANS II") + "\n\n"
	for e in _d:
		s += "%s  (%s)\n" % [titulo_entrada(e), str(e.get("fecha", ""))]
		for l in lineas_entrada(e):
			s += "  " + l + "\n"
		s += "\n"
	return s


static func exportar_txt() -> String:
	var ruta := Partidas.ruta("bitacora.txt")
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(texto_exportable())
	return ProjectSettings.globalize_path(ruta)


static func cifras() -> Dictionary:
	_asegurar()
	var c := {"misiones": 0, "expediciones": 0, "tiempo": 0.0, "km": 0.0, "muestras": 0, "curiosos": 0, "hallazgos": 0,
			"medallas": 0, "decisiones": 0, "sustos": 0, "mejor_exp": 0, "mas_rapida": -1.0}
	for e in _d:
		if bool(e.get("exp", false)):
			c["expediciones"] = int(c["expediciones"]) + 1
			c["mejor_exp"] = maxi(int(c["mejor_exp"]), int(e.get("puntos", 0)))
		else:
			c["misiones"] = int(c["misiones"]) + 1
			var tt := float(e.get("tiempo", 0.0))
			if tt > 0.0 and (float(c["mas_rapida"]) < 0.0 or tt < float(c["mas_rapida"])):
				c["mas_rapida"] = tt
		c["tiempo"] = float(c["tiempo"]) + float(e.get("tiempo", 0.0))
		c["km"] = float(c["km"]) + float(e.get("km", 0.0))
		c["muestras"] = int(c["muestras"]) + int(e.get("muestras", 0))
		c["curiosos"] = int(c["curiosos"]) + int(e.get("curiosos", 0))
		c["hallazgos"] = int(c["hallazgos"]) + int(e.get("hallazgos", 0))
		c["medallas"] = int(c["medallas"]) + (e.get("medallas", []) as Array).size()
		if str(e.get("decision", "")) != "":
			c["decisiones"] = int(c["decisiones"]) + 1
		c["sustos"] = int(c["sustos"]) + int(e.get("eventos", 0))
	return c
