extends Translation


const ARCHIVOS := ["res://traducciones/en_1.gd", "res://traducciones/en_2.gd", "res://traducciones/en_3.gd", "res://traducciones/en_4.gd", "res://traducciones/en_5.gd", "res://traducciones/en_6.gd",
		"res://traducciones/en_7.gd", "res://traducciones/en_8.gd", "res://traducciones/en_9.gd", "res://traducciones/en_10.gd"]

var _exacto: Dictionary = {}
var _plantillas: Dictionary = {}
var _plantillas_libres: Array = []
var _memo: Dictionary = {}
var _re_marca: RegEx
var _re_letras: RegEx
var _re_etiquetas: RegEx
var _re_trozos: RegEx
var _re_prefijo: RegEx
var _re_numero: RegEx
var _re_frase: RegEx
var _re_trozos_k: RegEx


func _init() -> void:
	_re_marca = RegEx.new()
	_re_marca.compile("%[-+0#]*\\d*(?:\\.\\d+)?[dsfx%]")
	_re_letras = RegEx.new()
	_re_letras.compile("[A-Za-zÁÉÍÓÚÑáéíóúñÜü]{3,}")
	_re_etiquetas = RegEx.new()
	_re_etiquetas.compile("^((?:\\[[^\\]]*\\]|\\s)*)(.*?)((?:\\[[^\\]]*\\]|\\s)*)$")
	_re_prefijo = RegEx.new()
	_re_prefijo.compile("^([—–·•►▶>✓\\-]\\s+)(.+)$")
	_re_numero = RegEx.new()
	_re_numero.compile("^(\\d+(?:[.,]\\d+)?\\s+)(.+)$")
	_re_trozos_k = RegEx.new()
	_re_trozos_k.compile("\\s+·\\s+")
	_re_frase = RegEx.new()
	_re_frase.compile("[.!?…][\"»)]?\\s+")
	_re_trozos = RegEx.new()
	_re_trozos.compile("(\\s+[·—→|]\\s+|\\s·\\s|\\s{2,})")
	for ruta in ARCHIVOS:
		if not ResourceLoader.exists(ruta):
			continue
		var scr: GDScript = load(ruta)
		var d: Dictionary = scr.get_script_constant_map().get("T", {})
		for k in d:
			_agregar(str(k), str(d[k]))


func _agregar(es: String, en: String) -> void:
	_agregar_uno(es, en)

	var es2 := es.lstrip("\n").rstrip("\n")
	if es2 != es and es2 != "":
		_agregar_uno(es2, en.lstrip("\n").rstrip("\n"))

	var es3 := _sin_adornos(es)
	if es3 != es and es3 != "" and _re_letras.search(es3) != null:
		_agregar_uno(es3, _sin_adornos(en))

	if es.find("·") >= 0 and en.find("·") >= 0:
		var pe := _re_trozos_k.sub(es, "\u0001", true).split("\u0001")
		var pn := _re_trozos_k.sub(en, "\u0001", true).split("\u0001")
		if pe.size() == pn.size() and pe.size() > 1:
			for i in range(pe.size()):
				var ke := _sin_adornos(pe[i])
				if ke != "" and _re_letras.search(ke) != null and not _exacto.has(ke) and ke != _sin_adornos(pn[i]):
					_agregar_uno(ke, _sin_adornos(pn[i]))

	if es.find("\n") >= 0 and en.find("\n") >= 0:
		var le := es.split("\n")
		var ln := en.split("\n")
		if le.size() == ln.size():
			for i in range(le.size()):
				if _re_letras.search(le[i]) != null and le[i] != ln[i] and not _exacto.has(le[i]):
					_agregar_uno(le[i], ln[i])


func _agregar_uno(es: String, en: String) -> void:
	if es.find("%") >= 0 and _re_marca.search(es) != null:
		var parte := _construir_plantilla(es, en)
		if parte.is_empty():
			_exacto[es] = en
			return
		var pre := _prefijo(es)
		if pre == "":
			_plantillas_libres.append(parte)
		else:
			if not _plantillas.has(pre):
				_plantillas[pre] = []
			(_plantillas[pre] as Array).append(parte)
		return
	_exacto[es] = en

	if es.length() <= 60:
		var arriba := es.to_upper()
		if arriba != es and not _exacto.has(arriba):
			_exacto[arriba] = en.to_upper()


func _prefijo(es: String) -> String:
	var i := es.find("%")
	var p := es.substr(0, i) if i > 0 else ""
	return p.left(4)


func _construir_plantilla(es: String, en: String) -> Dictionary:
	var patron := "^"
	var pos := 0
	var n_es := 0
	for m in _re_marca.search_all(es):
		var lit := es.substr(pos, m.get_start() - pos)
		patron += _escapar(lit)
		var tok := m.get_string()
		var tipo := tok[tok.length() - 1]
		match tipo:
			"%": patron += "%"
			"d": patron += "\\s*(-?\\d+)"
			"f": patron += "\\s*(-?\\d+(?:\\.\\d+)?)"
			_:
				patron += "(.*?)" if m.get_end() == es.length() else "(.+?)"
		if tipo != "%":
			n_es += 1
		pos = m.get_end()
	patron += _escapar(es.substr(pos)) + "$"
	var re := RegEx.new()
	if re.compile(patron) != OK:
		return {}

	var trozos: Array = []
	var huecos := 0
	pos = 0
	for m in _re_marca.search_all(en):
		trozos.append(en.substr(pos, m.get_start() - pos))
		var tok := m.get_string()
		trozos.append("%" if tok.ends_with("%") else (2 if tok == "%.0s" else 1))
		if not tok.ends_with("%"):
			huecos += 1
		pos = m.get_end()
	trozos.append(en.substr(pos))
	if huecos != n_es:
		push_warning("Traducción con distinto número de %% (se ignora la plantilla): " + es)
		return {}
	return {"re": re, "trozos": trozos}


func _escapar(t: String) -> String:
	var r := ""
	for c in t:
		if c in "\\.^$|?*+()[]{}":
			r += "\\" + c
		else:
			r += c
	return r


func _get_message(src_message: StringName, _context: StringName) -> StringName:
	var s := str(src_message)
	var r := traducir(s)
	return StringName(r) if r != s else StringName()


func traducir(s: String) -> String:
	if s.length() < 3:
		return s
	if _memo.has(s):
		return _memo[s]
	var r := _traducir(s, 0)
	if _memo.size() > 8000:
		_memo.clear()
	_memo[s] = r
	return r


func _traducir(s: String, prof: int) -> String:
	if prof > 10 or _re_letras.search(s) == null:
		return s
	if _exacto.has(s):
		return _exacto[s]
	if prof > 0 and _memo.has(s):
		return _memo[s]
	var r := _traducir_nuevo(s, prof)
	if prof > 0:
		_memo[s] = r
	return r


func _traducir_nuevo(s: String, prof: int) -> String:
	var p := _por_plantilla(s, prof)
	if p != "":
		return p

	if s.find("\n") >= 0:
		var lineas := s.split("\n")
		var salida: Array[String] = []
		for l in lineas:
			salida.append(_traducir_linea(l, prof + 1))
		return "\n".join(salida)
	return _traducir_linea(s, prof + 1)


func _traducir_linea(l: String, prof: int) -> String:
	if l.length() < 3 or _re_letras.search(l) == null:
		return l

	var m := _re_etiquetas.search(l)
	if m != null and (m.get_string(1) != "" or m.get_string(3) != ""):
		var nucleo := m.get_string(2)
		if nucleo == "":
			return l
		return m.get_string(1) + _traducir(nucleo, prof) + m.get_string(3)
	if _exacto.has(l):
		return _exacto[l]

	var c0 := l.substr(0, 1)
	var alt := (c0.to_lower() if c0 != c0.to_lower() else c0.to_upper()) + l.substr(1)
	if alt != l and _exacto.has(alt):
		var ten: String = _exacto[alt]
		return ten.substr(0, 1).to_upper() + ten.substr(1) if c0 != c0.to_lower() else ten.substr(0, 1).to_lower() + ten.substr(1)
	var p := _por_plantilla(l, prof)
	if p != "":
		return p

	if l.length() > 4 and ((l.begins_with("«") and l.ends_with("»")) or (l.begins_with("\"") and l.ends_with("\""))):
		var dentro := l.substr(1, l.length() - 2)
		var td := _traducir(dentro, prof + 1)
		if td != dentro:
			return l.left(1) + td + l.right(1)

	var mp := _re_prefijo.search(l)
	if mp != null:
		var resto := _traducir(mp.get_string(2), prof + 1)
		if resto != mp.get_string(2):
			return mp.get_string(1) + resto

	var partes := _re_trozos.sub(l, "\u0001$1\u0001", true).split("\u0001")
	if partes.size() > 1:
		var salida := ""
		var cambio := false
		for i in range(partes.size()):
			var t := partes[i]
			if i % 2 == 1:
				salida += t
			else:
				var tt := _traducir(t, prof + 1)
				if tt != t:
					cambio = true
				salida += tt
		if cambio:
			return salida

	var i2 := l.find(": ")
	if i2 > 0 and _re_frase.search(l.substr(0, i2)) == null:
		var izq := l.substr(0, i2)
		var der := l.substr(i2 + 2)
		var a := _traducir(izq, prof + 1)
		var b := _traducir(der, prof + 1)
		if a != izq or b != der:
			return a + ": " + b

	var fr := _por_frases(l, prof)
	if fr != "":
		return fr

	if l.find(", ") > 0:
		var xs := l.split(", ")
		var cambio2 := false
		var res: Array[String] = []
		for x in xs:
			var tx := _traducir(x, prof + 1)
			if tx != x:
				cambio2 = true
			res.append(tx)
		if cambio2:
			return ", ".join(res)

	var mn := _re_numero.search(l)
	if mn != null:
		var rn := _traducir(mn.get_string(2), prof + 1)
		if rn != mn.get_string(2):
			return mn.get_string(1) + rn
	return l


func _por_plantilla(s: String, prof: int) -> String:
	var candidatas: Array = []
	for largo in range(1, 5):
		var k := s.left(largo)
		if _plantillas.has(k):
			candidatas = candidatas + (_plantillas[k] as Array)
	candidatas = candidatas + _plantillas_libres
	for pl in candidatas:
		var m: RegExMatch = (pl["re"] as RegEx).search(s)
		if m == null:
			continue
		var salida := ""
		var g := 1
		for t in (pl["trozos"] as Array):
			if t is String:
				salida += (t as String).replace("%%", "%") if t != "%" else "%"
			elif t is int and int(t) == 2:
				g += 1
			else:
				var val := m.get_string(g)
				g += 1
				salida += _traducir(val, prof + 1) if _re_letras.search(val) != null else val
		return salida
	return ""


func _por_frases(l: String, prof: int) -> String:
	if l.length() < 12:
		return ""
	var cortes: Array[int] = []
	for m in _re_frase.search_all(l):
		cortes.append(m.get_end())
	if cortes.is_empty() or cortes.size() > 10:
		return ""
	for c in cortes:
		if c >= l.length():
			continue
		var a := l.substr(0, c)
		var b := l.substr(c)
		var ta := _traducir(a, prof + 1)
		var tb := _traducir(b, prof + 1)
		if ta != a and tb != b:
			return ta + tb
	var salida := ""
	var cambio := false
	var ini := 0
	var fines: Array[int] = cortes.duplicate()
	if fines.is_empty() or fines[fines.size() - 1] < l.length():
		fines.append(l.length())
	for c in fines:
		var f := l.substr(ini, c - ini)
		ini = c
		var tf := _traducir(f, prof + 1)
		if tf != f:
			cambio = true
		salida += tf
	return salida if cambio else ""


func _sin_adornos(t: String) -> String:
	var r := t.strip_edges()
	while r.begins_with("·") or r.begins_with("—") or r.begins_with("•"):
		r = r.substr(1).strip_edges()
	while r.ends_with("·") or r.ends_with("—") or r.ends_with(":"):
		r = r.left(r.length() - 1).strip_edges()
	return r
