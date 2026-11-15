extends RefCounted


const SR := 11025
const MAX_S := 6.5


const VOCES := {
	"KELLY":  {"f0": 215.0, "form": 1.17, "dur": 0.105, "var": 0.07, "nasal": 0.0},
	"JULIO":  {"f0": 118.0, "form": 0.98, "dur": 0.125, "var": 0.05, "nasal": 0.0},
	"REYZER": {"f0": 105.0, "form": 0.95, "dur": 0.085, "var": 0.04, "nasal": 0.0},
	"GERALD": {"f0": 138.0, "form": 1.02, "dur": 0.11, "var": 0.12, "nasal": 0.0},
	"DAID":   {"f0": 152.0, "form": 1.1, "dur": 0.09, "var": 0.06, "nasal": 0.5},
}


const FORMANTES := {
	"a": [730.0, 1090.0, 2440.0],
	"e": [530.0, 1840.0, 2480.0],
	"i": [270.0, 2290.0, 3010.0],
	"o": [570.0, 840.0, 2410.0],
	"u": [300.0, 870.0, 2240.0],
}

static var _cache: Dictionary = {}

var resultado: AudioStreamWAV = null

var _jefe: String = ""
var _p: Dictionary = {}
var _ev: Array = []
var _datos: PackedFloat32Array = PackedFloat32Array()
var _bytes: PackedByteArray = PackedByteArray()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _ei: int = 0
var _pos: int = 0
var _largo: int = 0
var _pico: float = 0.0001
var _fase: int = 0
var _i2: int = 0
var _hp: float = 0.0
var _clave: String = ""


static func clave(jefe: String, texto: String) -> String:
	return jefe + "|" + texto


static func obtener(jefe: String, texto: String) -> AudioStreamWAV:
	return _cache.get(clave(jefe, texto), null)


static func _vocal(ch: String) -> String:
	match ch:
		"a", "á", "à", "ä": return "a"
		"e", "é", "è", "ë": return "e"
		"i", "í", "ì", "ï": return "i"
		"o", "ó", "ò", "ö": return "o"
		"u", "ú", "ù", "ü": return "u"
	return ""


func _init(jefe: String = "KELLY", texto: String = "") -> void:
	_jefe = jefe
	_clave = clave(jefe, texto)
	_p = VOCES.get(jefe, VOCES["KELLY"])
	_rng.seed = _clave.hash()
	_datos.resize(int((MAX_S + 0.6) * float(SR)))
	_construir(texto.to_lower())
	_pos = int(0.07 * float(SR))
	_squelch(0, 0.4)


func _construir(txt: String) -> void:
	var dur: float = _p["dur"]
	var variacion: float = _p["var"]
	var cons := ""
	var prev_vocal := false
	var frase_voc: Array = []
	var k := 0
	var total := 0.0
	for ch in txt:
		var v := _vocal(ch)
		if v != "":
			var d := dur * (0.55 if (prev_vocal and cons == "") else 1.0)

			var m := (1.0 - 0.012 * float(mini(k, 14))) * (1.0 + _rng.randf_range(-variacion, variacion))
			_ev.append([0, v, d, m, cons])
			frase_voc.append(_ev.size() - 1)
			total += d + (0.05 if cons != "" else 0.0)
			cons = ""
			prev_vocal = true
			k += 1
		elif ch in "bcdfgjklmnñpqrstvwxyz":
			cons = ch
			prev_vocal = false
		elif ch == " ":
			_ev.append([1, "", 0.035, 1.0, ""])
			total += 0.035
			cons = ""
			prev_vocal = false
		elif ch in ",;:":
			_ev.append([1, "", 0.15, 1.0, ""])
			total += 0.15
			cons = ""
			prev_vocal = false
		elif ch in ".!?…":
			_ev.append([1, "", 0.27, 1.0, ""])
			total += 0.27
			if ch == "?":

				var n := frase_voc.size()
				for j in range(maxi(0, n - 3), n):
					var e: Array = _ev[frase_voc[j]]
					e[3] = float(e[3]) * (1.0 + 0.09 * float(j - (n - 3) + 1))
			frase_voc.clear()
			k = 0
			cons = ""
			prev_vocal = false

	var escala := clampf((MAX_S - 0.3) / maxf(total, 0.01), 0.62, 1.0)
	if escala < 1.0:
		for e in _ev:
			e[2] = float(e[2]) * escala


func _squelch(pos: int, amp: float) -> void:
	for i in range(int(0.05 * float(SR))):
		if pos + i >= _datos.size():
			break
		var t := float(i) / float(SR)
		_datos[pos + i] += (_rng.randf() * 2.0 - 1.0) * exp(-t * 65.0) * amp


func _evento(e: Array) -> void:
	var tipo: int = e[0]
	var d: float = e[2]
	if tipo == 1:
		_pos += int(d * float(SR))
		return
	var cons: String = e[4]
	if cons != "":
		_consonante(cons)
	_vocal_sintetizar(str(e[1]), d, float(e[3]))


func _consonante(c: String) -> void:
	if c in "sfzjx":

		var n := int(0.05 * float(SR))
		var prev := 0.0
		for i in range(n):
			var r := _rng.randf() * 2.0 - 1.0
			var t := float(i) / float(n)
			_datos[_pos + i] += (r - prev) * 0.5 * sin(PI * t) * 0.35
			prev = r
		_pos += n
	elif c in "pbtdkgcq":

		var n2 := int(0.014 * float(SR))
		for i in range(n2):
			var t2 := float(i) / float(SR)
			_datos[_pos + i] += (_rng.randf() * 2.0 - 1.0) * exp(-t2 * 220.0) * 0.5
		_pos += n2 + int(0.012 * float(SR))


func _vocal_sintetizar(v: String, dur: float, f0m: float) -> void:
	var n := int(dur * float(SR))
	if _pos + n >= _datos.size():
		n = _datos.size() - _pos - 1
	if n <= 8:
		return
	var f: Array = FORMANTES[v]
	var form: float = _p["form"]
	var nasal: float = _p["nasal"]
	var qs := [7.0, 9.0, 11.0]
	var gs := [1.0, 0.75 * (1.0 + 0.4 * nasal), 0.4 * (1.0 + nasal)]
	var b0: Array = []
	var a1: Array = []
	var a2: Array = []
	for k in range(3):
		var w0 := TAU * minf(float(f[k]) * form, float(SR) * 0.45) / float(SR)
		var alfa := sin(w0) / (2.0 * float(qs[k]))
		var a0 := 1.0 + alfa
		b0.append(alfa / a0)
		a1.append(-2.0 * cos(w0) / a0)
		a2.append((1.0 - alfa) / a0)
	var x1 := 0.0
	var x2 := 0.0
	var y1a := 0.0
	var y2a := 0.0
	var y1b := 0.0
	var y2b := 0.0
	var y1c := 0.0
	var y2c := 0.0
	var f0: float = float(_p["f0"]) * f0m
	var fase := 0.0
	var att := int(0.012 * float(SR))
	var rel := int(0.02 * float(SR))
	var b0a: float = b0[0]
	var b0b: float = b0[1]
	var b0c: float = b0[2]
	var a1a: float = a1[0]
	var a1b: float = a1[1]
	var a1c: float = a1[2]
	var a2a: float = a2[0]
	var a2b: float = a2[1]
	var a2c: float = a2[2]
	var g1: float = gs[0]
	var g2: float = gs[1]
	var g3: float = gs[2]
	for i in range(n):
		var t := float(i) / float(n)

		fase += f0 * (1.0 + 0.06 * (0.5 - t)) / float(SR)
		if fase >= 1.0:
			fase -= 1.0
		var x := (2.0 * fase - 1.0) + (_rng.randf() * 2.0 - 1.0) * 0.04

		var ya := b0a * (x - x2) - a1a * y1a - a2a * y2a
		var yb := b0b * (x - x2) - a1b * y1b - a2b * y2b
		var yc := b0c * (x - x2) - a1c * y1c - a2c * y2c
		x2 = x1
		x1 = x
		y2a = y1a
		y1a = ya
		y2b = y1b
		y1b = yb
		y2c = y1c
		y1c = yc
		var env := minf(float(i) / float(att), 1.0) * minf(float(n - i) / float(rel), 1.0) * (0.85 + 0.15 * (1.0 - t))
		var s := (ya * g1 + yb * g2 + yc * g3) * env
		_datos[_pos + i] += s
		_pico = maxf(_pico, absf(s))
	_pos += n


func avanzar(presupuesto_us: int) -> bool:
	if resultado != null:
		return true
	var t0 := Time.get_ticks_usec()
	if _fase == 0:
		while _ei < _ev.size() and _pos < int(MAX_S * float(SR)):
			_evento(_ev[_ei])
			_ei += 1
			if Time.get_ticks_usec() - t0 > presupuesto_us:
				return false
		_largo = mini(_pos + int(0.12 * float(SR)), _datos.size())
		_squelch(maxi(_pos + int(0.03 * float(SR)), 0), 0.25)
		_fase = 1
		_i2 = 0
		_bytes.resize(_largo * 2)
	if _fase == 1:
		var g := 0.55 / _pico
		while _i2 < _largo:
			for _k in range(1500):
				if _i2 >= _largo:
					break
				var x := _datos[_i2] * g

				_hp += 0.07 * (x - _hp)
				var y := tanh((x - _hp) * 1.8) * 0.8
				_bytes.encode_s16(_i2 * 2, int(clampf(y, -1.0, 1.0) * 30000.0))
				_i2 += 1
			if Time.get_ticks_usec() - t0 > presupuesto_us:
				return false
		var w := AudioStreamWAV.new()
		w.format = AudioStreamWAV.FORMAT_16_BITS
		w.mix_rate = SR
		w.stereo = false
		w.data = _bytes
		resultado = w
		_cache[_clave] = w
		_datos = PackedFloat32Array()
	return true
