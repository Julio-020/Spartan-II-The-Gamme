extends Node


const Ajustes := preload("res://nucleo/ajustes.gd")
const Locutor := preload("res://sonido/locutor.gd")
const Recuerdos := preload("res://progreso/recuerdos.gd")

const BUS_AMBIENTE := "Ambiente"

static var _cache: Dictionary = {}

var _cola: Array[String] = ["viento", Recuerdos.clave_motor(), "crujido", "cueva", "ping", "contacto", "nada", "bip",
		"recoger", "entregar", "completar", "gota", "obturador", "tormenta",
		"boom", "malo_corto", "aviso", "agotada", "decision", "bueno", "malo", "paso", "medalla", "rango",
			"arena", "roca", "siseo", "aullido", "remolino", "pis_arena", "pis_grava", "pis_roca", "cristal", "holo", "holo_fin"]
var _listo: bool = false
var _p_viento: AudioStreamPlayer
var _p_tormenta: AudioStreamPlayer
var _locutor: Locutor
var _tormenta_f: float = 0.0
var _p_motor: AudioStreamPlayer
var _p_crujido: AudioStreamPlayer
var _p_arena: AudioStreamPlayer
var _p_roca: AudioStreamPlayer
var _p_siseo: AudioStreamPlayer
var _p_aullido: AudioStreamPlayer
var _p_remolino: AudioStreamPlayer
var _p_cristal: AudioStreamPlayer
var _p_paso: Array[AudioStreamPlayer] = []
var _paso_i: int = 0
var _t_paso: float = 0.0
var _t_cristal: float = 4.0
var _p_cueva: AudioStreamPlayer
var _p_fx: Array[AudioStreamPlayer] = []
var _p_gota: AudioStreamPlayer
var _p_bip: AudioStreamPlayer
var _fx_i: int = 0
var _t: float = 0.0
var _t_gota: float = 3.0
var _t_bip: float = 0.0
var _filtro: AudioEffectLowPassFilter
var _reverb: AudioEffectReverb
var _activo: bool = true


func _ready() -> void:
	Ajustes.asegurar_buses()
	_asegurar_bus_ambiente()

	_p_viento = _crear_player(BUS_AMBIENTE, -80.0)
	_p_tormenta = _crear_player(BUS_AMBIENTE, -80.0)
	_locutor = Locutor.new()
	add_child(_locutor)
	_p_motor = _crear_player(BUS_AMBIENTE, -80.0)
	_p_crujido = _crear_player(BUS_AMBIENTE, -80.0)
	_p_arena = _crear_player(BUS_AMBIENTE, -80.0)
	_p_roca = _crear_player(BUS_AMBIENTE, -80.0)
	_p_siseo = _crear_player(BUS_AMBIENTE, -80.0)
	_p_aullido = _crear_player(BUS_AMBIENTE, -80.0)
	_p_remolino = _crear_player(BUS_AMBIENTE, -80.0)
	_p_cristal = _crear_player(BUS_AMBIENTE, -24.0)
	for i in range(3):
		_p_paso.append(_crear_player(BUS_AMBIENTE, -20.0))
	_p_cueva = _crear_player(BUS_AMBIENTE, -80.0)
	_p_gota = _crear_player(BUS_AMBIENTE, -6.0)
	_p_bip = _crear_player(Ajustes.BUS_EFECTOS, -14.0)
	for i in range(4):
		_p_fx.append(_crear_player(Ajustes.BUS_EFECTOS, -4.0))


func _crear_player(bus: String, db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	p.volume_db = db
	add_child(p)
	return p


func _asegurar_bus_ambiente() -> void:
	var idx := AudioServer.get_bus_index(BUS_AMBIENTE)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, BUS_AMBIENTE)
		AudioServer.set_bus_send(idx, Ajustes.BUS_EFECTOS)
		var f := AudioEffectLowPassFilter.new()
		f.cutoff_hz = 9000.0
		AudioServer.add_bus_effect(idx, f)
		var r := AudioEffectReverb.new()
		r.room_size = 0.8
		r.damping = 0.5
		r.wet = 0.04
		r.dry = 1.0
		AudioServer.add_bus_effect(idx, r)
	_filtro = AudioServer.get_bus_effect(idx, 0) as AudioEffectLowPassFilter
	_reverb = AudioServer.get_bus_effect(idx, 1) as AudioEffectReverb


func _process(delta: float) -> void:

	if not _cola.is_empty():
		var nombre: String = _cola.pop_front()
		if not _cache.has(nombre):
			_cache[nombre] = _fabricar(nombre)
		if _cola.is_empty():
			_arrancar()


func _arrancar() -> void:
	_p_viento.stream = _cache["viento"]
	_p_tormenta.stream = _cache["tormenta"]
	_p_motor.stream = _cache[Recuerdos.clave_motor()]
	_p_crujido.stream = _cache["crujido"]
	_p_arena.stream = _cache["arena"]
	_p_roca.stream = _cache["roca"]
	_p_siseo.stream = _cache["siseo"]
	_p_aullido.stream = _cache["aullido"]
	_p_remolino.stream = _cache["remolino"]
	_p_cristal.stream = _cache["cristal"]
	_p_cueva.stream = _cache["cueva"]
	_p_gota.stream = _cache["gota"]
	_p_bip.stream = _cache["bip"]
	for p in [_p_viento, _p_tormenta, _p_motor, _p_crujido, _p_arena, _p_roca, _p_siseo, _p_aullido, _p_remolino, _p_cueva]:
		p.play()
	_listo = true


func actualizar(delta: float, vel: float, turbo: bool, dentro: float, viento: float, prox: float,
		suelo: Vector3 = Vector3(1.0, 0.0, 0.0), remolino: float = 0.0) -> void:
	if not _listo or not _activo:
		return
	_t += delta

	var rafaga := 0.5 + 0.5 * sin(_t * 0.35) * sin(_t * 0.13 + 1.0)
	_p_viento.volume_db = -30.0 + viento * 14.0 + rafaga * 5.0 - dentro * 14.0 + _tormenta_f * 6.0
	_p_viento.pitch_scale = 0.9 + 0.25 * rafaga
	var fuerza := clampf((viento - 0.45) * 1.8 + _tormenta_f * 0.9, 0.0, 1.0)
	_p_aullido.volume_db = -80.0 if fuerza < 0.04 else (-38.0 + fuerza * 22.0 + rafaga * 4.0 - dentro * 18.0)
	_p_aullido.pitch_scale = 0.85 + 0.3 * rafaga + 0.2 * _tormenta_f


	_p_tormenta.volume_db = -80.0 if _tormenta_f < 0.02 else (-32.0 + _tormenta_f * 24.0 - dentro * 12.0)
	_p_tormenta.pitch_scale = 0.9 + 0.2 * rafaga
	var siseo := _tormenta_f * _tormenta_f
	_p_siseo.volume_db = -80.0 if siseo < 0.03 else (-40.0 + siseo * 22.0 + rafaga * 3.0 - dentro * 20.0)
	_p_siseo.pitch_scale = 0.95 + 0.12 * rafaga

	_p_remolino.volume_db = -80.0 if remolino < 0.02 else (-38.0 + remolino * 24.0 - dentro * 16.0)
	_p_remolino.pitch_scale = 0.9 + 0.2 * remolino


	var v := absf(vel)
	var mov := clampf(v * 1.6, 0.0, 1.0)
	_p_motor.volume_db = -80.0 if v < 0.01 else (-34.0 + mov * 20.0 + (3.0 if turbo else 0.0))
	_p_motor.pitch_scale = 0.75 + v * 0.9 + (0.15 if turbo else 0.0)

	var base := -80.0 if v < 0.02 else (-30.0 + mov * 18.0)
	_p_crujido.volume_db = _db_capa(base, suelo.x, 0.0)
	_p_arena.volume_db = _db_capa(base, suelo.y, -17.0)
	_p_roca.volume_db = _db_capa(base, suelo.z, -4.0)
	_p_crujido.pitch_scale = 0.8 + v * 0.6
	_p_arena.pitch_scale = 0.85 + v * 0.5
	_p_roca.pitch_scale = 0.9 + v * 0.5

	if v > 0.05:
		_t_paso -= delta
		if _t_paso <= 0.0:
			_t_paso = clampf(0.55 / (0.35 + 2.0 * v), 0.17, 0.8) * randf_range(0.85, 1.15)
			_pisada(suelo, mov)
	else:
		_t_paso = 0.0


	_p_cueva.volume_db = -80.0 if dentro < 0.02 else (-30.0 + dentro * 16.0)
	if _filtro != null:
		_filtro.cutoff_hz = lerpf(9000.0, 1100.0, dentro)
	if _reverb != null:
		_reverb.wet = lerpf(0.04, 0.5, dentro)
	if dentro > 0.3:
		_t_gota -= delta
		if _t_gota <= 0.0:
			_t_gota = randf_range(1.5, 4.5)
			_p_gota.pitch_scale = randf_range(0.8, 1.25)
			_p_gota.volume_db = -14.0 + dentro * 8.0
			_p_gota.play()

		_t_cristal -= delta
		if _t_cristal <= 0.0:
			_t_cristal = randf_range(5.0, 12.0)
			_p_cristal.pitch_scale = [0.75, 0.9, 1.0, 1.12, 1.33, 1.5][randi() % 6]
			_p_cristal.volume_db = -26.0 + dentro * 8.0
			_p_cristal.play()


	if prox > 0.02:
		_t_bip -= delta
		if _t_bip <= 0.0:
			_t_bip = lerpf(1.1, 0.12, prox)
			_p_bip.pitch_scale = 0.9 + prox * 0.6
			_p_bip.play()
	else:
		_t_bip = 0.0


func detener() -> void:
	_activo = false
	_locutor.callar()
	for p in [_p_viento, _p_tormenta, _p_motor, _p_crujido, _p_arena, _p_roca, _p_siseo, _p_aullido, _p_remolino, _p_cueva]:
		if p != null:
			p.stop()


func _db_capa(base: float, peso: float, ajuste: float) -> float:
	if base <= -79.0 or peso < 0.02:
		return -80.0
	return maxf(base + linear_to_db(peso) + ajuste, -80.0)


func _pisada(suelo: Vector3, mov: float) -> void:
	var tot := maxf(suelo.x + suelo.y + suelo.z, 0.001)
	var r := randf() * tot
	var clave := "pis_grava"
	var db := -27.0
	var tono := randf_range(0.9, 1.15)
	if r > suelo.x + suelo.y:
		clave = "pis_roca"
		db = -28.0
	elif r > suelo.x:
		clave = "pis_arena"
		db = -26.0
		tono = randf_range(0.8, 1.05)
	if not _cache.has(clave):
		return
	var p := _p_paso[_paso_i]
	_paso_i = (_paso_i + 1) % _p_paso.size()
	p.stream = _cache[clave]
	p.pitch_scale = tono
	p.volume_db = db + mov * 7.0 + randf_range(-2.0, 1.0)
	p.play()


func _fx(nombre: String, db: float = -4.0) -> void:
	if not _cache.has(nombre) or not _activo:
		return
	var p := _p_fx[_fx_i]
	_fx_i = (_fx_i + 1) % _p_fx.size()
	p.stream = _cache[nombre]
	p.volume_db = db
	p.pitch_scale = 1.0
	p.play()


func escanear() -> void:
	_fx("ping", -3.0)


func resultado_escaner(n: int) -> void:
	if n > 0:
		get_tree().create_timer(0.55).timeout.connect(func(): _fx("contacto", -4.0))
	else:
		get_tree().create_timer(0.55).timeout.connect(func(): _fx("nada", -6.0))


func recoger() -> void:
	_fx("recoger", -3.0)


func entregar() -> void:
	_fx("entregar", -5.0)


func completar() -> void:
	_fx("completar", -2.0)


func obturador() -> void:
	_fx("obturador", -3.0)


func tormenta(f: float) -> void:
	_tormenta_f = clampf(f, 0.0, 1.0)


func hablar(jefe: String, texto: String) -> void:
	if _activo:
		_locutor.decir(jefe, texto)


func callar() -> void:
	_locutor.callar()


func aviso() -> void:
	_fx("aviso", -6.0)


func holo(enciende: bool) -> void:
	_fx("holo" if enciende else "holo_fin", -9.0)


func agotada() -> void:
	_fx("agotada", -4.0)


func decision() -> void:
	_fx("decision", -5.0)


func decision_resultado(d: int) -> void:
	_fx("bueno" if d > 0 else ("malo" if d < 0 else "paso"), -5.0)


func bueno() -> void:
	_fx("bueno", -6.0)


func boom(dist_gm: float) -> void:
	_fx("boom", clampf(-2.0 - dist_gm / 6.0, -24.0, -2.0))


func malo_corto() -> void:
	_fx("malo_corto", -6.0)


func paso() -> void:
	_fx("paso", -7.0)


func medalla() -> void:
	_fx("medalla", -4.0)


func rango() -> void:
	_fx("rango", -3.0)


func _fabricar(nombre: String) -> AudioStreamWAV:
	match nombre:
		"viento": return _s_viento()
		"motor": return _s_motor()
		"motor_grave", "motor_silbido", "motor_coro": return _s_motor_v(nombre)
		"crujido": return _s_crujido()
		"cueva": return _s_cueva()
		"ping": return _s_ping()
		"contacto": return _s_contacto()
		"nada": return _s_nada()
		"bip": return _s_bip()
		"recoger": return _s_recoger()
		"entregar": return _s_entregar()
		"completar": return _s_completar()
		"obturador": return _s_obturador()
		"tormenta": return _s_tormenta()
		"arena": return _s_arena()
		"roca": return _s_roca()
		"siseo": return _s_siseo()
		"aullido": return _s_aullido()
		"remolino": return _s_remolino()
		"pis_arena", "pis_grava", "pis_roca": return _s_pisada(nombre)
		"cristal": return _notas([[1760.0, 0.0, 1.7], [2637.0, 0.02, 1.3], [3520.0, 0.07, 0.9]], 1.9, 0.22)
		"holo": return _notas([[1046.5, 0.0, 0.07], [1568.0, 0.06, 0.07], [2093.0, 0.12, 0.16]], 0.35, 0.22)
		"holo_fin": return _notas([[1568.0, 0.0, 0.06], [1046.5, 0.05, 0.12]], 0.25, 0.18)
		"boom": return _s_boom()
		"malo_corto": return _notas([[220.0, 0.0, 0.2]], 0.3, 0.5)
		"aviso": return _notas([[880.0, 0.0, 0.14], [880.0, 0.2, 0.14]], 0.45, 0.45)
		"agotada": return _notas([[660.0, 0.0, 0.22], [520.0, 0.24, 0.22], [390.0, 0.48, 0.5]], 1.1, 0.5)
		"decision": return _notas([[523.25, 0.0, 0.16], [784.0, 0.13, 0.32]], 0.55, 0.45)
		"bueno": return _notas([[659.25, 0.0, 0.14], [880.0, 0.1, 0.14], [1318.5, 0.2, 0.4]], 0.75, 0.4)
		"malo": return _notas([[330.0, 0.0, 0.22], [247.0, 0.16, 0.5]], 0.85, 0.5)
		"paso": return _notas([[988.0, 0.0, 0.12], [1318.5, 0.08, 0.28]], 0.5, 0.35)
		"medalla": return _notas([[1046.5, 0.0, 0.5], [1318.5, 0.12, 0.5], [1568.0, 0.24, 0.5], [2093.0, 0.36, 0.9]], 1.5, 0.3)
		"rango": return _notas([[392.0, 0.0, 0.3], [523.25, 0.25, 0.3], [659.25, 0.5, 0.3], [784.0, 0.75, 0.9], [1046.5, 0.75, 0.9]], 2.0, 0.3)
		_: return _s_gota()


func _wav(datos: PackedFloat32Array, sr: int, bucle: bool) -> AudioStreamWAV:
	var n := datos.size()
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		bytes.encode_s16(i * 2, int(clampf(datos[i], -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	w.stereo = false
	w.data = bytes
	if bucle:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = n
	return w


func _cerrar_bucle(buf: PackedFloat32Array, n: int, solape: int) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		out[i] = buf[i]
	for i in range(solape):
		var w := float(i) / float(solape)
		out[i] = buf[i] * w + buf[n + i] * (1.0 - w)
	return out


func _s_viento() -> AudioStreamWAV:
	var sr := 5000
	var n := sr * 8
	var solape := sr
	var total := n + solape
	var rng := RandomNumberGenerator.new()
	rng.seed = 11

	var coef: Array = []
	for f0 in [260.0, 470.0]:
		var w0 := TAU * float(f0) / float(sr)
		var alfa := sin(w0) / (2.0 * 5.0)
		var a0 := 1.0 + alfa
		coef.append([alfa / a0, -2.0 * cos(w0) / a0, (1.0 - alfa) / a0])
	var bajo := 0.0
	var buf := PackedFloat32Array()
	buf.resize(total)
	var x1 := [0.0, 0.0]
	var x2 := [0.0, 0.0]
	var y1 := [0.0, 0.0]
	var y2 := [0.0, 0.0]
	for i in range(total):
		var r := rng.randf_range(-1.0, 1.0)
		bajo += 0.03 * (r - bajo)
		var sil := 0.0
		for k in range(2):
			var c: Array = coef[k]
			var y: float = float(c[0]) * (r - x2[k]) - float(c[1]) * y1[k] - float(c[2]) * y2[k]
			x2[k] = x1[k]
			x1[k] = r
			y2[k] = y1[k]
			y1[k] = y
			sil += y
		buf[i] = bajo * 4.0 + sil * 0.9
	var out := _cerrar_bucle(buf, n, solape)
	for i in range(n):
		var t := float(i) / float(sr)
		var g := 0.55 + 0.25 * sin(TAU * t / 8.0 + 0.6) + 0.2 * sin(TAU * t * 3.0 / 8.0 + 2.0)
		out[i] = out[i] * g * 0.55
	return _wav(out, sr, true)


func _s_boom() -> AudioStreamWAV:
	var sr := 11025
	var n := int(1.6 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var fase := 0.0
	var lp := 0.0
	for i in range(n):
		var t := float(i) / float(sr)
		fase += TAU * (90.0 * exp(-3.0 * t) + 28.0) / float(sr)
		lp += 0.08 * ((rng.randf() * 2.0 - 1.0) - lp)
		out[i] = sin(fase) * exp(-3.2 * t) * 0.8 + lp * exp(-4.0 * t) * 1.6
	return _wav(out, sr, false)


func _s_tormenta() -> AudioStreamWAV:
	var sr := 8000
	var n := sr * 6
	var solape := sr / 2
	var total := n + solape
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	var buf := PackedFloat32Array()
	buf.resize(total)
	var y1 := 0.0
	var y2 := 0.0
	for i in range(total):
		var x := rng.randf() * 2.0 - 1.0
		y1 += 0.16 * (x - y1)
		y2 += 0.45 * (x - y2)
		buf[i] = y1 * 2.2 + y2 * 0.9
	var out := _cerrar_bucle(buf, n, solape)
	var pico := 0.0001
	for i in range(n):
		var t := float(i) / float(sr)

		out[i] *= 0.65 + 0.35 * sin(TAU * t / 3.0) * sin(TAU * t / 2.0 + 0.7)
		pico = maxf(pico, absf(out[i]))
	for i in range(n):
		out[i] = out[i] / pico * 0.85
	return _wav(out, sr, true)


func _normalizar(buf: PackedFloat32Array, objetivo: float) -> void:
	var pico := 0.0001
	for x in buf:
		pico = maxf(pico, absf(x))
	var g := objetivo / pico
	for i in range(buf.size()):
		buf[i] *= g


func _s_arena() -> AudioStreamWAV:
	var sr := 8000
	var n := sr * 2
	var solape := sr / 4
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	var buf := PackedFloat32Array()
	buf.resize(n + solape)
	var y1 := 0.0
	var y2 := 0.0
	for i in range(n + solape):
		var x := rng.randf_range(-1.0, 1.0)
		y1 += 0.12 * (x - y1)
		y2 += 0.5 * (x - y2)
		buf[i] = y1 * 2.4 + (y2 - y1) * 0.5
	var out := _cerrar_bucle(buf, n, solape)
	for i in range(n):
		var t := float(i) / float(sr)

		out[i] *= 0.65 + 0.35 * sin(TAU * t * 5.0) * sin(TAU * t + 0.4)
	_normalizar(out, 0.8)
	return _wav(out, sr, true)


func _s_roca() -> AudioStreamWAV:
	var sr := 11025
	var n := sr * 2
	var rng := RandomNumberGenerator.new()
	rng.seed = 47
	var out := PackedFloat32Array()
	out.resize(n)
	for g in range(30):
		var ini := rng.randi_range(0, n - 1)
		var amp := rng.randf_range(0.3, 1.0)
		var largo := rng.randi_range(70, 170)
		var f := rng.randf_range(900.0, 2400.0)
		for j in range(largo):
			var t := float(j) / float(sr)
			var env := exp(-9.0 * float(j) / float(largo))
			out[(ini + j) % n] += (sin(TAU * f * t) * 0.6 + rng.randf_range(-1.0, 1.0) * 0.5) * env * amp * 0.5
	_normalizar(out, 0.8)
	return _wav(out, sr, true)


func _s_siseo() -> AudioStreamWAV:
	var sr := 11025
	var n := sr * 6
	var solape := sr / 2
	var rng := RandomNumberGenerator.new()
	rng.seed = 53
	var buf := PackedFloat32Array()
	buf.resize(n + solape)
	var lp := 0.0
	for i in range(n + solape):
		var x := rng.randf_range(-1.0, 1.0)
		lp += 0.3 * (x - lp)
		buf[i] = x - lp
	var out := _cerrar_bucle(buf, n, solape)
	for i in range(n):
		var t := float(i) / float(sr)
		out[i] *= 0.6 + 0.4 * sin(TAU * t / 3.0 + 1.0) * sin(TAU * t / 2.0)
	_normalizar(out, 0.7)
	return _wav(out, sr, true)


func _s_aullido() -> AudioStreamWAV:
	var sr := 8000
	var n := sr * 8
	var solape := sr
	var rng := RandomNumberGenerator.new()
	rng.seed = 61
	var buf := PackedFloat32Array()
	buf.resize(n + solape)
	var low := 0.0
	var band := 0.0
	var q := 1.0 / 14.0
	for i in range(n + solape):
		var t := float(i) / float(sr)
		var fc := 520.0 + 170.0 * sin(TAU * t / 8.0) + 70.0 * sin(TAU * t * 3.0 / 8.0 + 1.3)
		var f := 2.0 * sin(PI * fc / float(sr))
		var x := rng.randf_range(-1.0, 1.0)
		low += f * band
		var high := x - low - q * band
		band += f * high
		buf[i] = band
	var out := _cerrar_bucle(buf, n, solape)
	for i in range(n):
		var t2 := float(i) / float(sr)
		out[i] *= 0.6 + 0.4 * sin(TAU * t2 / 4.0 + 0.5)
	_normalizar(out, 0.6)
	return _wav(out, sr, true)


func _s_remolino() -> AudioStreamWAV:
	var sr := 8000
	var n := sr * 4
	var solape := sr / 2
	var rng := RandomNumberGenerator.new()
	rng.seed = 67
	var buf := PackedFloat32Array()
	buf.resize(n + solape)
	var low := 0.0
	var band := 0.0
	var gr := 0.0
	var f := 2.0 * sin(PI * 380.0 / float(sr))
	for i in range(n + solape):
		var x := rng.randf_range(-1.0, 1.0)
		low += f * band
		var high := x - low - 0.35 * band
		band += f * high
		gr += 0.05 * (x - gr)
		buf[i] = band * 0.9 + gr * 2.0
	var out := _cerrar_bucle(buf, n, solape)
	for i in range(n):
		var t := float(i) / float(sr)

		out[i] *= 0.55 + 0.45 * sin(TAU * t * 1.5)
	_normalizar(out, 0.7)
	return _wav(out, sr, true)


func _s_pisada(nombre: String) -> AudioStreamWAV:
	var sr := 11025
	var dur := 0.3 if nombre == "pis_arena" else (0.22 if nombre == "pis_grava" else 0.14)
	var n := int(dur * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 71
	match nombre:
		"pis_arena":
			var lp := 0.0
			for i in range(n):
				var t := float(i) / float(sr)
				lp += 0.2 * (rng.randf_range(-1.0, 1.0) - lp)
				out[i] = lp * minf(t * 90.0, 1.0) * exp(-14.0 * t) * 1.4 + sin(TAU * (62.0 - 60.0 * t) * t) * exp(-22.0 * t) * 0.5
		"pis_grava":
			for g in range(8):
				var ini := rng.randi_range(0, int(0.09 * float(sr)))
				var amp := rng.randf_range(0.4, 1.0)
				var largo := rng.randi_range(40, 90)
				var lp2 := 0.0
				for j in range(largo):
					if ini + j >= n:
						break
					lp2 += 0.45 * (rng.randf_range(-1.0, 1.0) - lp2)
					out[ini + j] += lp2 * exp(-5.0 * float(j) / float(largo)) * amp
		_:
			for i in range(n):
				var t2 := float(i) / float(sr)
				out[i] = (rng.randf_range(-1.0, 1.0) * exp(-260.0 * t2) * 0.8 + sin(TAU * 1300.0 * t2) * exp(-45.0 * t2) * 0.6)
	_normalizar(out, 0.85)
	return _wav(out, sr, false)


func _s_motor() -> AudioStreamWAV:
	var sr := 8000
	var n := sr
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / float(sr)
		var flutter := 1.0 + 0.12 * sin(TAU * 12.0 * t)
		var v := 0.5 * sin(TAU * 60.0 * t) + 0.28 * sin(TAU * 120.0 * t + 0.4) \
				+ 0.16 * sin(TAU * 180.0 * t + 1.1) + 0.08 * sin(TAU * 360.0 * t)
		out[i] = v * flutter * 0.5
	return _wav(out, sr, true)


func _s_motor_v(nombre: String) -> AudioStreamWAV:
	var sr := 8000
	var out := PackedFloat32Array()
	out.resize(sr)
	for i in range(sr):
		var t := float(i) / float(sr)
		var v := 0.0
		match nombre:
			"motor_grave":
				v = (0.55 * sin(TAU * 40.0 * t) + 0.3 * sin(TAU * 80.0 * t + 0.5) + 0.18 * sin(TAU * 120.0 * t + 1.3)) \
						* (1.0 + 0.2 * sin(TAU * 8.0 * t))
			"motor_silbido":
				v = (0.4 * sin(TAU * 240.0 * t + 1.5 * sin(TAU * 6.0 * t)) + 0.2 * sin(TAU * 480.0 * t) + 0.1 * sin(TAU * 720.0 * t)) \
						* (1.0 + 0.08 * sin(TAU * 4.0 * t))
			_:
				v = (0.3 * sin(TAU * 110.0 * t) + 0.26 * sin(TAU * 165.0 * t + 0.7) + 0.22 * sin(TAU * 220.0 * t + 1.2) \
						+ 0.1 * sin(TAU * 330.0 * t)) * (1.0 + 0.25 * sin(TAU * 3.0 * t))
		out[i] = v * 0.5
	return _wav(out, sr, true)


func _s_crujido() -> AudioStreamWAV:
	var sr := 8000
	var n := sr * 2
	var rng := RandomNumberGenerator.new()
	rng.seed = 23
	var out := PackedFloat32Array()
	out.resize(n)
	var golpes := 70
	for g in range(golpes):
		var ini := rng.randi_range(0, n - 1)
		var amp := rng.randf_range(0.2, 1.0)
		var largo := rng.randi_range(30, 90)
		var lp := 0.0
		for j in range(largo):
			var env := exp(-5.0 * float(j) / float(largo))
			lp += 0.45 * (rng.randf_range(-1.0, 1.0) - lp)
			out[(ini + j) % n] += lp * env * amp * 0.5
	return _wav(out, sr, true)


func _s_cueva() -> AudioStreamWAV:
	var sr := 4000
	var n := sr * 4
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / float(sr)
		var v := 0.5 * sin(TAU * 40.0 * t) + 0.35 * sin(TAU * 60.25 * t + 1.0) + 0.18 * sin(TAU * 27.0 * t + 2.0)
		out[i] = v * (0.6 + 0.4 * sin(TAU * t / 4.0)) * 0.7
	return _wav(out, sr, true)


func _s_ping() -> AudioStreamWAV:
	var sr := 22050
	var n := int(1.7 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var ecos := [[0.0, 1.0], [0.42, 0.45], [0.84, 0.2]]
	for e in ecos:
		var ini := int(float(e[0]) * float(sr))
		var g: float = e[1]
		var fase := 0.0
		for i in range(int(0.5 * float(sr))):
			if ini + i >= n:
				break
			var t := float(i) / float(sr)
			var f := 700.0 + 900.0 * exp(-9.0 * t)
			fase += TAU * f / float(sr)
			var env := exp(-7.0 * t) * minf(t * 300.0, 1.0)
			out[ini + i] += (sin(fase) + 0.25 * sin(fase * 2.0)) * env * g * 0.55
	return _wav(out, sr, false)


func _s_contacto() -> AudioStreamWAV:
	return _notas([[1100.0, 0.0, 0.09], [1650.0, 0.1, 0.16]], 0.3, 0.5)


func _s_nada() -> AudioStreamWAV:
	var sr := 22050
	var n := int(0.45 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var fase := 0.0
	for i in range(n):
		var t := float(i) / float(sr)
		fase += TAU * (520.0 - 260.0 * t / 0.45) / float(sr)
		out[i] = sin(fase) * exp(-5.0 * t) * minf(t * 200.0, 1.0) * 0.5
	return _wav(out, sr, false)


func _s_bip() -> AudioStreamWAV:
	return _notas([[1800.0, 0.0, 0.05]], 0.08, 0.5)


func _notas(notas: Array, dur: float, amp: float) -> AudioStreamWAV:
	var sr := 22050
	var n := int(dur * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	for nota in notas:
		var f: float = nota[0]
		var ini := int(float(nota[1]) * float(sr))
		var largo := int(float(nota[2]) * float(sr))
		for i in range(largo):
			if ini + i >= n:
				break
			var t := float(i) / float(sr)
			var env := exp(-5.0 * t / float(nota[2])) * minf(t * 500.0, 1.0)
			out[ini + i] += (sin(TAU * f * t) + 0.3 * sin(TAU * f * 2.0 * t)) * env * amp
	return _wav(out, sr, false)


func _s_obturador() -> AudioStreamWAV:
	var sr := 22050
	var n := int(0.3 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for par in [[0.0, 1.0, 2600.0], [0.085, 0.75, 1700.0]]:
		var ini := int(float(par[0]) * float(sr))
		var lp := 0.0
		for i in range(int(0.06 * float(sr))):
			if ini + i >= n:
				break
			var t := float(i) / float(sr)
			lp += 0.55 * (rng.randf_range(-1.0, 1.0) - lp)
			out[ini + i] += (lp * 0.8 + 0.5 * sin(TAU * float(par[2]) * t)) * exp(-95.0 * t) * float(par[1]) * 0.7
	for i in range(int(0.12 * float(sr))):
		var t2 := float(i) / float(sr)
		var j := int(0.1 * float(sr)) + i
		if j < n:
			out[j] += sin(TAU * (420.0 + 700.0 * t2) * t2) * sin(PI * t2 / 0.12) * 0.12
	return _wav(out, sr, false)


func _s_recoger() -> AudioStreamWAV:
	var sr := 22050
	var n := int(0.9 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var lp := 0.0
	for i in range(int(0.34 * float(sr))):
		var t := float(i) / float(sr)
		lp += 0.18 * (rng.randf_range(-1.0, 1.0) - lp)
		var env := sin(PI * t / 0.34)
		out[i] += (lp * 0.9 + 0.35 * sin(TAU * (95.0 + 60.0 * t) * t)) * env * 0.5
	for i in range(int(0.2 * float(sr))):
		var t2 := float(i) / float(sr)
		var j := int(0.34 * float(sr)) + i
		out[j] += sin(TAU * 140.0 * t2) * exp(-26.0 * t2) * 0.9
	for par in [[880.0, 0.42], [1320.0, 0.55]]:
		var ini := int(float(par[1]) * float(sr))
		for i in range(int(0.3 * float(sr))):
			if ini + i >= n:
				break
			var t3 := float(i) / float(sr)
			out[ini + i] += sin(TAU * float(par[0]) * t3) * exp(-9.0 * t3) * 0.4
	return _wav(out, sr, false)


func _s_entregar() -> AudioStreamWAV:
	var sr := 22050
	var n := int(0.8 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	for k in range(3):
		var f: float = [660.0, 880.0, 1100.0][k]
		var ini := int(0.11 * float(k) * float(sr))
		for i in range(int(0.22 * float(sr))):
			var t := float(i) / float(sr)
			out[ini + i] += sin(TAU * f * t) * exp(-12.0 * t) * 0.42
	for i in range(int(0.3 * float(sr))):
		var t2 := float(i) / float(sr)
		out[i] += sin(TAU * (90.0 - 40.0 * t2) * t2) * exp(-12.0 * t2) * 0.5
	return _wav(out, sr, false)


func _s_completar() -> AudioStreamWAV:
	var sr := 16000
	var n := int(3.0 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	var notas := [[523.25, 0.0], [659.25, 0.18], [783.99, 0.36], [1046.5, 0.54]]
	for nota in notas:
		var ini := int(float(nota[1]) * float(sr))
		for i in range(n - ini):
			var t := float(i) / float(sr)
			var env := exp(-1.6 * t) * minf(t * 120.0, 1.0)
			out[ini + i] += (sin(TAU * float(nota[0]) * t) + 0.35 * sin(TAU * float(nota[0]) * 2.0 * t)) * env * 0.22
	return _wav(out, sr, false)


func _s_gota() -> AudioStreamWAV:
	var sr := 16000
	var n := int(1.0 * float(sr))
	var out := PackedFloat32Array()
	out.resize(n)
	for e in [[0.0, 1.0], [0.16, 0.45], [0.33, 0.25], [0.55, 0.12]]:
		var ini := int(float(e[0]) * float(sr))
		var fase := 0.0
		for i in range(int(0.07 * float(sr))):
			if ini + i >= n:
				break
			var t := float(i) / float(sr)
			fase += TAU * (2300.0 - 9000.0 * t) / float(sr)
			out[ini + i] += sin(fase) * exp(-45.0 * t) * float(e[1]) * 0.6
	return _wav(out, sr, false)
