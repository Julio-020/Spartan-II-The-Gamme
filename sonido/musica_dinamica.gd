extends Node


const Ajustes := preload("res://nucleo/ajustes.gd")

const SR := 6000
const DUR := 16.0
const NOMBRES := ["pad_dia", "pad_noche", "tension", "melodia"]


const ACORDES_DIA := [[45, 57, 60, 64, 67], [41, 57, 60, 65, 69], [48, 55, 60, 64, 67], [43, 55, 59, 62, 67]]
const ACORDES_NOCHE := [[38, 50, 57, 60, 64], [34, 50, 58, 62, 65], [43, 50, 55, 58, 62], [45, 52, 57, 62, 67]]

const MELODIA := [[76, 0.0, 1.0], [79, 2.0, 0.8], [81, 3.5, 0.8], [76, 6.0, 0.9], [72, 8.0, 0.8],
		[74, 9.5, 0.7], [76, 11.0, 0.9], [79, 13.0, 0.8], [84, 14.5, 0.7]]


const VARIANTES := {
	"hielo": {
		"dia": [[38, 57, 62, 65, 69], [34, 53, 58, 62, 65], [41, 57, 60, 65, 69], [36, 55, 60, 64, 67]],
		"noche": [[26, 50, 57, 62, 65], [22, 46, 53, 58, 62], [29, 53, 57, 60, 65], [24, 48, 55, 60, 64]],
		"melodia": [[86, 0.0, 0.8], [81, 2.0, 0.8], [77, 3.5, 0.8], [81, 6.0, 0.9], [74, 8.0, 0.8],
				[77, 9.5, 0.7], [81, 11.0, 0.8], [86, 13.0, 0.7], [89, 14.5, 0.6]],
	},
	"polvo": {
		"dia": [[40, 52, 59, 64, 67], [36, 52, 55, 64, 67], [43, 55, 59, 62, 67], [38, 50, 57, 62, 66]],
		"noche": [[28, 40, 52, 59, 64], [24, 36, 48, 55, 64], [31, 43, 50, 55, 62], [26, 38, 50, 57, 62]],
		"melodia": [[71, 0.0, 1.0], [76, 2.0, 0.8], [78, 3.5, 0.8], [71, 6.0, 0.9], [67, 8.0, 0.8],
				[69, 9.5, 0.7], [71, 11.0, 0.9], [74, 13.0, 0.8], [79, 14.5, 0.7]],
	},
	"sombrio": {
		"dia": [[45, 57, 60, 64, 69], [46, 58, 62, 65, 69], [43, 55, 58, 62, 67], [45, 57, 60, 64, 69]],
		"noche": [[33, 45, 52, 57, 60], [34, 46, 53, 58, 62], [31, 43, 50, 55, 58], [33, 45, 52, 57, 60]],
		"melodia": [[76, 0.0, 1.0], [77, 2.0, 0.8], [81, 3.5, 0.8], [76, 6.0, 0.9], [72, 8.0, 0.8],
				[71, 9.5, 0.7], [77, 11.0, 0.9], [76, 13.0, 0.8], [72, 14.5, 0.7]],
	},
	"calido": {
		"dia": [[48, 55, 60, 64, 67], [45, 52, 60, 64, 67], [41, 57, 60, 65, 69], [43, 55, 59, 62, 67]],
		"noche": [[36, 48, 55, 60, 64], [33, 45, 52, 60, 64], [29, 45, 57, 60, 65], [31, 43, 55, 59, 62]],
		"melodia": [[79, 0.0, 1.0], [76, 2.0, 0.8], [72, 3.5, 0.8], [76, 6.0, 0.9], [79, 8.0, 0.8],
				[81, 9.5, 0.7], [79, 11.0, 0.9], [76, 13.0, 0.8], [84, 14.5, 0.7]],
	},
}


const MOTIVOS := {
	"KELLY":  {"notas": [57, 64, 69, 76], "paso": 0.42, "timbre": "metal", "vol": 0.9},
	"JULIO":  {"notas": [88, 83, 79, 76, 71], "paso": 0.34, "timbre": "gota", "vol": 0.85},
	"REYZER": {"notas": [52, 52, 59, 57, 52], "paso": 0.36, "timbre": "pulso", "vol": 1.0},
	"GERALD": {"notas": [72, 76, 79, 83, 84], "paso": 0.26, "timbre": "celesta", "vol": 0.8},
	"DAID":   {"notas": [84, 79, 84, 91], "paso": 0.22, "timbre": "bip", "vol": 0.6},
}

const DB_SILENCIO := -70.0

static var _cache: Dictionary = {}

var _gen_i: int = 0
var _gen_pos: int = 0
var _buf: PackedFloat32Array = PackedFloat32Array()
var _notas_cache: Array = []
var _jug: Dictionary = {}
var _db: Dictionary = {}
var _listo: bool = false
var _destello: float = 0.0
var _hablando: float = 0.0
var _fade: float = 0.0
var _parando: bool = false
var activa: bool = true
var variante: String = "base"
var _melodia_actual: Array = MELODIA
var _p_motivo: AudioStreamPlayer
var _motivos: Dictionary = {}


static func variante_de(d: Dictionary) -> String:
	var amb: Dictionary = d.get("amb", {})
	var temp := float(amb.get("temp", -63.0))
	var lat := absf(float(d.get("lat", 0.0)))
	var polvo := float(amb.get("polvo", 0.5))
	if temp <= -75.0 or lat >= 55.0:
		return "hielo"
	if polvo >= 0.8:
		return "polvo"
	if int(amb.get("cuevas", 0)) > 0:
		return "sombrio"
	if temp >= -56.0:
		return "calido"
	return "base"


func configurar(d: Dictionary) -> void:
	variante = variante_de(d)
	_melodia_actual = MELODIA if variante == "base" else (VARIANTES[variante]["melodia"] as Array)


func _clave(nombre: String) -> String:
	return nombre if nombre == "tension" else "%s/%s" % [variante, nombre]


static func _hz(midi: float) -> float:

	return roundf(440.0 * pow(2.0, (midi - 69.0) / 12.0) * 16.0) / 16.0


func _ready() -> void:
	Ajustes.asegurar_buses()
	_activa_segun_ajustes()
	for n in NOMBRES:
		var p := AudioStreamPlayer.new()
		p.bus = Ajustes.BUS_MUSICA
		p.volume_db = DB_SILENCIO
		add_child(p)
		_jug[n] = p
		_db[n] = DB_SILENCIO
	_p_motivo = AudioStreamPlayer.new()
	_p_motivo.bus = Ajustes.BUS_MUSICA
	_p_motivo.volume_db = -23.0
	add_child(_p_motivo)
	var completa := true
	for n in NOMBRES:
		if not _cache.has(_clave(n)):
			completa = false
	if completa:
		_arrancar()


func _activa_segun_ajustes() -> void:
	activa = bool(Ajustes.musica_dinamica)


func _process(_delta: float) -> void:
	if _listo or _gen_i >= NOMBRES.size() or not activa:
		return
	var nombre: String = NOMBRES[_gen_i]
	if _gen_pos == 0 and _cache.has(_clave(nombre)):
		_gen_i += 1
		if _gen_i >= NOMBRES.size():
			_arrancar()
		return
	var n := int(DUR * float(SR))
	if _gen_pos == 0:
		_buf = PackedFloat32Array()
		_buf.resize(n)
		_notas_cache = _preparar(nombre)
	var fin := mini(_gen_pos + 2500, n)
	for i in range(_gen_pos, fin):
		_buf[i] = _muestra(nombre, float(i) / float(SR))
	_gen_pos = fin
	if _gen_pos >= n:
		_cache[_clave(nombre)] = _a_wav(_buf)
		_gen_i += 1
		_gen_pos = 0
		if _gen_i >= NOMBRES.size():
			_arrancar()


func _preparar(nombre: String) -> Array:
	var r: Array = []
	match nombre:
		"pad_dia", "pad_noche":
			var src: Array = ACORDES_DIA if nombre == "pad_dia" else ACORDES_NOCHE
			if variante != "base":
				src = VARIANTES[variante]["dia" if nombre == "pad_dia" else "noche"]
			for ac in src:
				var fs: Array = []
				for m in (ac as Array):
					fs.append(_hz(float(m)))
				r.append(fs)
	return r


func _muestra(nombre: String, t: float) -> float:
	match nombre:
		"pad_dia": return _pad(t, 0.075, 1.0)
		"pad_noche": return _pad(t, 0.085, 0.7)
		"tension": return _tension(t)
		"melodia": return _melodia(t)
	return 0.0


func _pad(t: float, amp: float, brillo: float) -> float:
	var s := 0.0
	for ci in range(4):
		var ph := fposmod(t - float(ci) * 4.0 + 1.0, DUR)
		if ph >= 6.0:
			continue
		var w := sin(PI * ph / 6.0)
		w *= w
		for f in (_notas_cache[ci] as Array):
			var a := TAU * float(f) * t
			s += w * (sin(a) + 0.22 * brillo * sin(2.0 * a) + 0.5 * sin(TAU * (float(f) + 0.125) * t)) * amp
	return s


func _tension(t: float) -> float:
	var s := 0.0

	s += 0.20 * sin(TAU * 55.0 * t) + 0.18 * sin(TAU * 58.3125 * t)
	s += 0.07 * sin(TAU * 155.5 * t) * (0.6 + 0.4 * sin(TAU * 0.25 * t))

	for k in range(8):
		var tl := t - float(k) * 2.0
		if tl < 0.0:
			tl += DUR
		if tl < 0.9:
			s += 0.55 * sin(TAU * 46.0 * tl) * exp(-tl * 6.0)
		var t2 := tl - 0.35
		if t2 >= 0.0 and t2 < 0.9:
			s += 0.35 * sin(TAU * 40.0 * t2) * exp(-t2 * 7.0)

	s += 0.03 * sin(TAU * 1760.0 * t + 4.0 * sin(TAU * 0.5 * t)) * (0.5 + 0.5 * sin(TAU * 0.0625 * t))
	return s


func _melodia(t: float) -> float:
	var s := 0.0
	for nt in _melodia_actual:
		var f := 440.0 * pow(2.0, (float(nt[0]) - 69.0) / 12.0)
		var ini := float(nt[1])
		var vol := float(nt[2])
		for eco in range(3):
			var tl := fposmod(t - ini - float(eco) * 0.5, DUR)
			if tl > 3.2:
				continue
			var env := exp(-tl * 1.9) * (1.0 - exp(-tl * 160.0))
			var ev: float = vol * float([1.0, 0.33, 0.12][eco]) * env
			s += ev * (sin(TAU * f * tl) + 0.35 * sin(TAU * f * 2.76 * tl) * exp(-tl * 3.0)) * 0.22
	return s


static func _a_wav(datos: PackedFloat32Array) -> AudioStreamWAV:
	var n := datos.size()
	var pico := 0.0001
	for i in range(n):
		pico = maxf(pico, absf(datos[i]))
	var k := 0.8 / pico
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		bytes.encode_s16(i * 2, int(clampf(datos[i] * k, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SR
	w.stereo = false
	w.data = bytes
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w


func _arrancar() -> void:
	if _listo:
		return
	for n in NOMBRES:
		var p: AudioStreamPlayer = _jug[n]
		p.stream = _cache[_clave(n)]
		if activa:
			p.play()
	_listo = true


func destello(seg: float) -> void:
	_destello = maxf(_destello, seg)


func hablando(seg: float) -> void:
	_hablando = maxf(_hablando, seg)


func motivo(jefe: String) -> void:
	if not activa or not _listo or not MOTIVOS.has(jefe) or _p_motivo == null:
		return
	if not _motivos.has(jefe):
		_motivos[jefe] = _crear_motivo(MOTIVOS[jefe])
	_p_motivo.stream = _motivos[jefe]
	_p_motivo.play()


static func _crear_motivo(m: Dictionary) -> AudioStreamWAV:
	var notas: Array = m["notas"]
	var paso := float(m["paso"])
	var timbre := str(m["timbre"])
	var vol := float(m["vol"])
	var dur := paso * float(notas.size()) + 1.4
	var n := int(dur * float(SR))
	var d := PackedFloat32Array()
	d.resize(n)
	for k in range(notas.size()):
		var f := 440.0 * pow(2.0, (float(notas[k]) - 69.0) / 12.0)
		var i0 := int(float(k) * paso * float(SR))
		var largo := int(1.3 * float(SR))
		for j in range(mini(largo, n - i0)):
			var tl := float(j) / float(SR)
			d[i0 + j] += _voz(timbre, f, tl) * vol
	var w := _a_wav(d)
	w.loop_mode = AudioStreamWAV.LOOP_DISABLED
	return w


static func _voz(timbre: String, f: float, t: float) -> float:
	var ataque := 1.0 - exp(-t * 220.0)
	match timbre:
		"metal":
			var v := 1.0 + 0.004 * sin(TAU * 5.5 * t)
			return ataque * exp(-t * 2.4) * (sin(TAU * f * v * t) + 0.45 * sin(TAU * 3.0 * f * t) + 0.2 * sin(TAU * 5.0 * f * t)) * 0.3
		"gota":
			var fg := f * (1.0 + 0.06 * exp(-t * 18.0))
			return ataque * exp(-t * 4.2) * (sin(TAU * fg * t) + 0.3 * sin(TAU * fg * 2.4 * t) * exp(-t * 6.0)) * 0.34
		"pulso":
			return ataque * exp(-t * 7.0) * (sin(TAU * f * t) + 0.5 * sin(TAU * 2.0 * f * t) + 0.25 * sin(TAU * 3.0 * f * t)) * 0.4
		"celesta":
			return ataque * exp(-t * 3.6) * (sin(TAU * f * t) + 0.5 * sin(TAU * 4.0 * f * t) * exp(-t * 9.0)) * 0.3
		"bip":
			var q := 1.0 if sin(TAU * f * t) >= 0.0 else -1.0
			return ataque * exp(-t * 9.0) * (0.55 * q + 0.45 * sin(TAU * f * t)) * 0.22
	return 0.0


func actualizar(delta: float, s: Dictionary) -> void:
	if not _listo:
		return
	var ahora := bool(Ajustes.musica_dinamica)
	if ahora != activa:
		activa = ahora
		for n in NOMBRES:
			var p: AudioStreamPlayer = _jug[n]
			if activa and not p.playing:
				p.play()
			elif not activa:
				p.stop()
	if not activa:
		return
	_destello = maxf(_destello - delta, 0.0)
	_hablando = maxf(_hablando - delta, 0.0)
	_fade = move_toward(_fade, 0.0 if _parando else 1.0, delta / 3.0)
	var energia := float(s.get("energia", 1.0))
	var noche := clampf(float(s.get("noche", 0.0)), 0.0, 1.0)
	var tormenta := clampf(float(s.get("tormenta", 0.0)), 0.0, 1.0)
	var cueva := clampf(float(s.get("cueva", 0.0)), 0.0, 1.0)
	var final := bool(s.get("final", false))
	var t := clampf(maxf(maxf((0.3 - energia) / 0.3, tormenta * 0.9), cueva * 0.7), 0.0, 1.0)
	if final:
		t = 0.0
	var duck := -5.0 if _hablando > 0.0 else 0.0
	var obj := {
		"pad_dia": lerpf(-25.0, DB_SILENCIO, noche) - 7.0 * tormenta,
		"pad_noche": lerpf(DB_SILENCIO, -24.0, noche) - 4.0 * tormenta,
		"tension": lerpf(DB_SILENCIO, -20.0, t) if t > 0.02 else DB_SILENCIO,
		"melodia": (-22.0 - 5.0 * t) if (_destello > 0.0 or final) else DB_SILENCIO,
	}
	for n in NOMBRES:
		var meta: float = float(obj[n]) + duck
		var cur: float = _db[n]
		cur = move_toward(cur, meta, (16.0 if meta > cur else 9.0) * delta)
		_db[n] = cur
		var p: AudioStreamPlayer = _jug[n]
		var db_final := cur if cur <= DB_SILENCIO + 1.0 else cur + linear_to_db(maxf(_fade, 0.0001))
		p.volume_db = maxf(db_final, DB_SILENCIO)


func detener() -> void:
	_parando = true
