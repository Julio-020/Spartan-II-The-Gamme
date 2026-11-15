extends Node


const Ajustes := preload("res://nucleo/ajustes.gd")

const RUTAS_MUSICA := ["res://audio/musica.ogg", "res://audio/musica.mp3", "res://audio/musica.wav"]

var _musica: AudioStreamPlayer
var _p_clic: AudioStreamPlayer
var _p_hover: AudioStreamPlayer
var _p_atras: AudioStreamPlayer
var _p_impacto: AudioStreamPlayer


func _ready() -> void:
	Ajustes.asegurar_buses()
	Ajustes.aplicar_audio()

	_musica = AudioStreamPlayer.new()
	_musica.bus = Ajustes.BUS_MUSICA
	_musica.volume_db = -4.0
	_musica.stream = _cargar_musica()
	add_child(_musica)

	_p_clic = AudioStreamPlayer.new()
	_p_clic.bus = Ajustes.BUS_EFECTOS
	_p_clic.stream = _tono(0.10, 22050, [[880.0, 0.55], [1320.0, 0.3]], 38.0)
	add_child(_p_clic)

	_p_hover = AudioStreamPlayer.new()
	_p_hover.bus = Ajustes.BUS_EFECTOS
	_p_hover.volume_db = -8.0
	_p_hover.stream = _tono(0.05, 22050, [[620.0, 0.4]], 60.0)
	add_child(_p_hover)

	_p_atras = AudioStreamPlayer.new()
	_p_atras.bus = Ajustes.BUS_EFECTOS
	_p_atras.volume_db = -3.0
	_p_atras.stream = _tono(0.12, 22050, [[330.0, 0.55], [495.0, 0.3]], 30.0)
	add_child(_p_atras)

	_p_impacto = AudioStreamPlayer.new()
	_p_impacto.bus = Ajustes.BUS_EFECTOS
	_p_impacto.volume_db = -2.0
	_p_impacto.stream = _generar_impacto()
	add_child(_p_impacto)


func iniciar_musica() -> void:
	if not _musica.playing:
		_musica.play()


func atenuar_musica(si: bool) -> void:
	if _musica == null:
		return
	var db := (-40.0 if Ajustes.musica_dinamica else -18.0) if si else -4.0
	create_tween().tween_property(_musica, "volume_db", db, 1.2)


func clic() -> void:
	_p_clic.play()


func hover() -> void:
	_p_hover.play()


func atras() -> void:
	_p_atras.play()


func impacto() -> void:
	_p_impacto.play()


func _generar_impacto() -> AudioStreamWAV:
	var sr := 11025
	var n := int(3.2 * float(sr))
	var datos := PackedByteArray()
	datos.resize(n * 2)
	var fase := 0.0
	var ruido := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(n):
		var t := float(i) / float(sr)
		var f := 32.0 + 78.0 * exp(-3.0 * t)
		fase += TAU * f / float(sr)
		ruido += 0.08 * (rng.randf_range(-1.0, 1.0) - ruido)
		var v := sin(fase) * exp(-1.1 * t) * 0.9 + ruido * exp(-4.0 * t) * 0.8
		v *= minf(t * 200.0, 1.0)
		datos.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	w.stereo = false
	w.data = datos
	return w


func _cargar_musica() -> AudioStream:
	for ruta in RUTAS_MUSICA:
		if ResourceLoader.exists(ruta):
			var s := load(ruta) as AudioStream
			if s is AudioStreamOggVorbis:
				(s as AudioStreamOggVorbis).loop = true
			elif s is AudioStreamMP3:
				(s as AudioStreamMP3).loop = true
			elif s is AudioStreamWAV:
				(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			if s != null:
				return s
	return _generar_ambiente()


func _generar_ambiente() -> AudioStreamWAV:
	var sr := 6000
	var dur := 8
	var n := sr * dur
	var datos := PackedByteArray()
	datos.resize(n * 2)

	var campanas := [[0.5, 330.0], [3.0, 392.0], [5.5, 247.5]]
	for i in range(n):
		var t := float(i) / float(sr)
		var lfo := 0.65 + 0.35 * sin(TAU * t / 8.0)
		var lfo2 := 0.75 + 0.25 * sin(TAU * t / 4.0 + 1.0)
		var v := 0.34 * sin(TAU * 55.0 * t)
		v += 0.22 * sin(TAU * 82.5 * t) * lfo
		v += 0.16 * sin(TAU * 110.0 * t + 0.6 * sin(TAU * t / 8.0)) * lfo2
		v += 0.10 * sin(TAU * 165.0 * t) * (1.0 - lfo * 0.6)
		for c in campanas:
			var tc := fposmod(t - float(c[0]), 8.0)
			var e := exp(-1.4 * tc) * minf(tc * 40.0, 1.0)
			v += 0.12 * e * sin(TAU * float(c[1]) * tc)
		datos.encode_s16(i * 2, int(clampf(v * 0.55, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	w.stereo = false
	w.data = datos
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w


func _tono(dur: float, sr: int, parciales: Array, caida: float) -> AudioStreamWAV:
	var n := int(dur * float(sr))
	var datos := PackedByteArray()
	datos.resize(n * 2)
	for i in range(n):
		var t := float(i) / float(sr)
		var v := 0.0
		for p in parciales:
			v += float(p[1]) * sin(TAU * float(p[0]) * t)
		v *= exp(-caida * t) * minf(t * 400.0, 1.0)
		datos.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 28000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	w.stereo = false
	w.data = datos
	return w
