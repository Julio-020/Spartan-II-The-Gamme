extends RefCounted


const HistoriaExtra := preload("res://historia/historia_extra.gd")
const Historia := preload("res://historia/historia.gd")
const Rutas := preload("res://progreso/rutas.gd")
const Comite := preload("res://historia/comite.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const DatosMarte := preload("res://datos/datos_marte.gd")

const Partidas := preload("res://nucleo/partidas.gd")
const JEFES := ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]
const CONF_MIN := -5
const CONF_MAX := 10
const CONF_ALTA := 3
const CONF_BAJA := -2
const OFERTAS := 1

static var _d: Dictionary = {}
static var _cargado: bool = false


static func _archivo() -> String:
	return Partidas.ruta("historia.json")


static func invalidar() -> void:
	_cargado = false
	_d = {}


static func cargar() -> void:
	_cargado = true
	_d = {}
	if FileAccess.file_exists(_archivo()):
		var f := FileAccess.open(_archivo(), FileAccess.READ)
		if f != null:
			var j: Variant = JSON.parse_string(f.get_as_text())
			if j is Dictionary:
				_d = j


static func guardar() -> void:
	var f := FileAccess.open(_archivo(), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(_d))
		f.close()
	Partidas.guardar_perfil()


static func _datos() -> Dictionary:
	if not _cargado:
		cargar()
	return _d


static func reiniciar() -> void:
	_d = {"hechas": []}
	_cargado = true
	guardar()


static func conf(jefe: String) -> int:
	var c: Variant = _datos().get("conf", {})
	if c is Dictionary:
		return int((c as Dictionary).get(jefe, 0))
	return 0


static func cambiar_conf(jefe: String, d: int) -> int:
	var datos := _datos()
	var c: Dictionary = datos.get("conf", {}) if datos.get("conf", {}) is Dictionary else {}
	var nuevo := clampi(int(c.get(jefe, 0)) + d, CONF_MIN, CONF_MAX)
	c[jefe] = nuevo
	datos["conf"] = c
	guardar()
	return nuevo


static func nivel(jefe: String) -> String:
	var v := conf(jefe)
	if v >= CONF_ALTA:
		return "alta"
	if v <= CONF_BAJA:
		return "baja"
	return "media"


static func conf_media() -> float:
	var t := 0.0
	for j in JEFES:
		t += float(conf(j))
	return t / float(JEFES.size())


static func ventajas() -> Dictionary:
	var r := {"golpe": 1.0, "recarga": 0.0, "carga": 0, "escaner": 0.0, "consumo": 0.0, "lista": []}
	for j in JEFES:
		if nivel(j) != "alta":
			continue
		var v: Dictionary = HistoriaExtra.VENTAJAS[j]
		if v.has("golpe"):
			r["golpe"] = float(r["golpe"]) * float(v["golpe"])
		r["recarga"] = float(r["recarga"]) + float(v.get("recarga", 0.0))
		r["carga"] = int(r["carga"]) + int(v.get("carga", 0))
		r["escaner"] = float(r["escaner"]) + float(v.get("escaner", 0.0))
		r["consumo"] = float(r["consumo"]) + float(v.get("consumo", 0.0))
		(r["lista"] as Array).append({"j": j, "txt": str(v["txt"])})
	return r


static func agregar_efecto(e: Dictionary) -> void:
	if e.is_empty():
		return
	var datos := _datos()
	var l: Array = datos.get("efectos", []) if datos.get("efectos", []) is Array else []
	l.append(e)
	datos["efectos"] = l
	guardar()


static func efectos_pendientes() -> Array:
	var l: Variant = _datos().get("efectos", [])
	return l if l is Array else []


static func tomar_efectos() -> Array:
	var l := efectos_pendientes().duplicate()
	if not l.is_empty():
		_datos()["efectos"] = []
		guardar()
	return l


static func sec_fijar(id_mision: String, res: String) -> void:
	var datos := _datos()
	var s: Dictionary = datos.get("sec", {}) if datos.get("sec", {}) is Dictionary else {}
	if str(s.get(id_mision, "")) != "ok":
		s[id_mision] = res
	datos["sec"] = s
	guardar()


static func charla_fijar(id_mision: String, jefe: String, tono: String) -> void:
	var datos := _datos()
	var s: Dictionary = datos.get("charlas", {}) if datos.get("charlas", {}) is Dictionary else {}
	s[id_mision] = {"j": jefe, "tono": tono}
	datos["charlas"] = s
	guardar()


static func charla_de(id_mision: String) -> Dictionary:
	var s: Variant = _datos().get("charlas", {})
	if s is Dictionary and (s as Dictionary).get(id_mision, null) is Dictionary:
		return (s as Dictionary)[id_mision]
	return {}


static func reaccion(id_mision: String) -> String:
	var peor := ""
	var mejor := ""
	for j in JEFES:
		var c := conf(j)
		if c <= CONF_BAJA and (peor == "" or c < conf(peor)):
			peor = j
		if c >= CONF_ALTA and (mejor == "" or c > conf(mejor)):
			mejor = j
	var quien := peor if peor != "" else mejor
	if quien == "":
		return ""
	var l: Array = (HistoriaExtra.REACCIONES[quien] as Dictionary)["molesto" if peor != "" else "leal"]
	var i := absi(hash(id_mision)) % l.size()
	return "%s %s: «%s»" % [quien, str((Historia.JEFES[quien] as Dictionary)["cod"]), str(l[i])]


static func final_datos(id: String) -> Dictionary:
	return HistoriaExtra.FINALES.get(id, {})


static func final_id() -> String:
	var media := conf_media()
	if media >= 2.0:
		return "unidos"
	if media < 0.0:
		return "dividido"
	return "acuerdo"


static func lineas_comite() -> Array:
	var l: Array = [{"j": "KELLY", "t": "Última misión, piloto. Antes de bajar, el comité se reúne: cada uno propone el lugar que mejor cumple lo que defiende."}]
	for j in ["JULIO", "REYZER", "GERALD", "DAID", "KELLY"]:
		var id := Comite.recomendacion(j)
		if id == "":
			continue
		var nombre := str(Comite.mision(id).get("nombre", id))
		l.append({"j": j, "t": Idioma.t("Mi propuesta: %s. %s") % [Idioma.t(nombre), Idioma.t(Comite.reaccion(j, id))]})
	if conf_media() < 1.0:
		l.append({"j": "KELLY", "t": "No estamos muy de acuerdo, piloto. Que esta última misión nos ayude a decidir. Después, el comité te pedirá que elijas el lugar."})
	else:
		l.append({"j": "KELLY", "t": "Confiamos en ti, piloto. Termina esta última misión y después elige el lugar de aterrizaje con el comité."})
	return l


static func final_lineas(id: String) -> Array:
	var base: Array = (final_datos(id).get("lineas", []) as Array).duplicate()
	var sitio := Comite.elegida()
	if sitio == "":
		sitio = Comite.mejor()
	if sitio == "" or base.is_empty():
		return base
	var ultima: Variant = base.pop_back()
	base.append({"j": "KELLY", "t": str((Comite.SITIOS[sitio] as Dictionary)["final"])})
	base.append(ultima)
	return base


static func finales_vistos() -> Array:
	var l: Variant = _datos().get("finales", [])
	return l if l is Array else []


static func titulo_final(genero: int = 0) -> String:
	var id := str(_datos().get("ultimo_final", ""))
	if id == "" or not HistoriaExtra.TITULOS_FINAL.has(id):
		return ""
	return str((HistoriaExtra.TITULOS_FINAL[id] as Dictionary)["f" if genero == 1 else "m"])


static func fijar_final(id: String) -> void:
	var l := finales_vistos().duplicate()
	if not l.has(id):
		l.append(id)
	_datos()["finales"] = l
	_datos()["ultimo_final"] = id
	guardar()


static func _hechas() -> Array:
	var d := _datos()
	if not (d.get("hechas", null) is Array):
		var l: Array = []
		for m in DatosMarte.MISIONES:
			if not Rutas.obtener(str((m as Dictionary)["id"])).is_empty():
				l.append(str((m as Dictionary)["id"]))
		d["hechas"] = l
		guardar()
	return d["hechas"]


static func hecha(id_mision: String) -> bool:
	return _hechas().has(id_mision)


static func marcar_hecha(id_mision: String) -> void:
	var l := _hechas()
	if not l.has(id_mision):
		l.append(id_mision)
		guardar()


static func num_hechas() -> int:
	return _hechas().size()


static func progreso(misiones: Array, libres: bool = false) -> Array:
	var res: Array = []
	var ofrecidas := 0
	for m in misiones:
		var id := str((m as Dictionary)["id"])
		var h := hecha(id)
		var est := {"hecha": h, "bloq": false, "oferta": false, "motivo": ""}
		if not h:
			if ofrecidas < OFERTAS:
				ofrecidas += 1
				est["oferta"] = true
			elif not libres:
				est["bloq"] = true
				est["motivo"] = "Aún no toca: completa antes la misión anterior."
		res.append(est)
	return res


static func campana_completa(misiones: Array) -> bool:
	for m in misiones:
		if not hecha(str((m as Dictionary)["id"])):
			return false
	return true
