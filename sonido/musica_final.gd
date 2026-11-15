extends RefCounted


const SR := 6000
const DURACION := 34.5


const ACORDES := [
	[
		[0.0, 8.5, [36, 55, 59, 64, 67]],
		[7.0, 8.5, [33, 52, 55, 60, 64]],
		[14.0, 8.5, [29, 57, 60, 64, 69]],
		[21.0, 8.5, [31, 55, 59, 62, 67]],
		[28.0, 6.5, [36, 55, 60, 64, 72]],
	],
	[
		[0.0, 8.5, [33, 57, 60, 64, 71]],
		[7.0, 8.5, [29, 57, 60, 64, 69]],
		[14.0, 8.5, [36, 55, 60, 64, 67]],
		[21.0, 8.5, [31, 55, 60, 62, 67]],
		[28.0, 6.5, [33, 57, 60, 64, 69]],
	],
	[
		[0.0, 8.5, [26, 53, 57, 62, 65]],
		[7.0, 8.5, [34, 58, 62, 65, 70]],
		[14.0, 8.5, [31, 55, 58, 62, 67]],
		[21.0, 8.5, [26, 53, 57, 62, 65]],
		[28.0, 6.5, [26, 57, 62, 64, 69]],
	],
]


const MELODIAS := [
	[[72, 2.0, 0.16], [76, 4.0, 0.16], [79, 6.0, 0.16], [76, 9.0, 0.15], [81, 11.0, 0.15],
	[79, 13.0, 0.15], [84, 16.0, 0.15], [81, 18.5, 0.15], [79, 21.5, 0.15], [83, 23.5, 0.15],
	[84, 26.0, 0.16], [88, 29.5, 0.16], [84, 32.0, 0.16]],
	[[69, 3.0, 0.15], [72, 6.0, 0.15], [71, 9.5, 0.15], [67, 12.0, 0.15], [72, 15.5, 0.15],
	[74, 18.0, 0.15], [72, 21.0, 0.15], [67, 24.0, 0.15], [69, 28.0, 0.15], [64, 31.0, 0.15]],
	[[62, 4.0, 0.15], [65, 9.0, 0.15], [62, 13.0, 0.15], [60, 18.0, 0.15], [58, 22.0, 0.15],
	[62, 27.0, 0.15], [69, 31.5, 0.18]],
]

static var _cache: Dictionary = {}

var tipo: int = 0
var resultado: AudioStreamWAV = null

var _n: int = 0
var _pos: int = 0
var _fase: int = 0
var _pico: float = 0.0001
var _datos: PackedFloat32Array = PackedFloat32Array()
var _bytes: PackedByteArray = PackedByteArray()
var _ac: Array = []
var _mel: Array = []


static func obtener(t: int) -> AudioStreamWAV:
	return _cache.get(clampi(t, 0, 2), null)


static func _hz(midi: float) -> float:
	return 440.0 * pow(2.0, (midi - 69.0) / 12.0)


func _init(t: int = 0) -> void:
	tipo = clampi(t, 0, 2)
	_n = int(DURACION * float(SR))
	_datos.resize(_n)
	for a in ACORDES[tipo]:
		var fr := PackedFloat32Array()
		for m in (a[2] as Array):
			fr.append(_hz(float(m)))
		_ac.append([float(a[0]), float(a[1]), fr])
	for nt in MELODIAS[tipo]:
		var f := _hz(float(nt[0]))
		var ini := float(nt[1])
		var vol := float(nt[2])

		_mel.append([f, ini, vol])
		_mel.append([f, ini + 0.5, vol * 0.35])
		_mel.append([f, ini + 1.0, vol * 0.15])


func _muestra(i: int) -> float:
	var t := float(i) / float(SR)
	var s := 0.0
	var respira := 0.85 + 0.15 * sin(TAU * 0.1 * t)
	for a in _ac:
		var tl: float = t - float(a[0])
		var dur: float = a[1]
		if tl < 0.0 or tl > dur:
			continue
		var env := minf(tl / 2.0, 1.0) * minf((dur - tl) / 2.0, 1.0)
		env = env * env * (3.0 - 2.0 * env) * respira
		var fr: PackedFloat32Array = a[2]
		for k in range(fr.size()):
			var w := TAU * fr[k] * t
			if k == 0:
				s += (sin(w) + 0.35 * sin(2.0 * w)) * 0.32 * env
			else:
				s += (sin(w) + 0.5 * sin(w * 1.004) + 0.35 * sin(2.0 * w) + 0.12 * sin(3.0 * w)) * 0.1 * env
	for nt in _mel:
		var tn: float = t - float(nt[1])
		if tn < 0.0 or tn > 5.0:
			continue
		var e := exp(-1.4 * tn) * minf(tn * 90.0, 1.0)
		var w2 := TAU * float(nt[0]) * tn
		s += (sin(w2) + 0.4 * sin(2.0 * w2) + 0.12 * sin(2.76 * w2)) * e * float(nt[2])

	s *= clampf(t / 1.5, 0.0, 1.0) * clampf((DURACION - t) / 3.0, 0.0, 1.0)
	return s


func avanzar(presupuesto_us: int) -> bool:
	if resultado != null:
		return true
	var t0 := Time.get_ticks_usec()
	if _fase == 0:
		while _pos < _n:
			for _k in range(120):
				if _pos >= _n:
					break
				var v := _muestra(_pos)
				_datos[_pos] = v
				_pico = maxf(_pico, absf(v))
				_pos += 1
			if Time.get_ticks_usec() - t0 > presupuesto_us:
				return false
		_fase = 1
		_pos = 0
		_bytes.resize(_n * 2)
	if _fase == 1:
		var g := 0.8 / _pico
		while _pos < _n:
			for _k in range(2000):
				if _pos >= _n:
					break
				_bytes.encode_s16(_pos * 2, int(clampf(_datos[_pos] * g, -1.0, 1.0) * 30000.0))
				_pos += 1
			if Time.get_ticks_usec() - t0 > presupuesto_us:
				return false
		var w := AudioStreamWAV.new()
		w.format = AudioStreamWAV.FORMAT_16_BITS
		w.mix_rate = SR
		w.stereo = false
		w.data = _bytes
		resultado = w
		_cache[tipo] = w
		_datos = PackedFloat32Array()
	return true
