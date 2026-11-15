extends Node

const Ajustes := preload("res://nucleo/ajustes.gd")

const FPS_MINIMO := 26.0
const SEGUNDOS_BAJOS := 6.0
const ESPERA_INICIAL := 12.0
const ESPERA_TRAS_BAJAR := 15.0

var _espera: float = ESPERA_INICIAL
var _bajos: float = 0.0


func _process(delta: float) -> void:
	if not DisplayServer.window_is_focused() or get_tree().paused:
		_bajos = 0.0
		return
	if _espera > 0.0:
		_espera -= delta
		return
	if Ajustes.calidad <= 0:
		set_process(false)
		return
	if Engine.get_frames_per_second() < FPS_MINIMO:
		_bajos += delta
	else:
		_bajos = maxf(_bajos - delta * 2.0, 0.0)
	if _bajos >= SEGUNDOS_BAJOS:
		_bajos = 0.0
		_espera = ESPERA_TRAS_BAJAR
		Ajustes.aplicar_calidad(Ajustes.calidad - 1)
		Ajustes.aplicar(get_viewport())
		Ajustes.guardar()
