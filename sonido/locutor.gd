extends Node


const Ajustes := preload("res://nucleo/ajustes.gd")
const HablaJefes := preload("res://sonido/habla_jefes.gd")

var volumen_db: float = -5.0

var _p: AudioStreamPlayer
var _gen: HablaJefes = null


func _ready() -> void:
	Ajustes.asegurar_buses()
	_p = AudioStreamPlayer.new()
	_p.bus = Ajustes.BUS_EFECTOS
	_p.volume_db = volumen_db
	add_child(_p)


func decir(jefe: String, texto: String) -> void:
	if not Ajustes.radio or texto.strip_edges() == "":
		return
	callar()
	var w := HablaJefes.obtener(jefe, texto)
	if w != null:
		_reproducir(w)
	else:
		_gen = HablaJefes.new(jefe, texto)


func callar() -> void:
	_gen = null
	if _p != null:
		_p.stop()


func _reproducir(w: AudioStreamWAV) -> void:
	_p.volume_db = volumen_db
	_p.stream = w
	_p.play()


func _process(_delta: float) -> void:
	if _gen != null and _gen.avanzar(3000 if OS.has_feature("web") else 6000):
		var w := _gen.resultado
		_gen = null
		_reproducir(w)
