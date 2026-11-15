extends RefCounted


const EL_PICO := 70.0
const DIA_S := 720.0
const NOCHE_VEL := [2.4, 1.8, 1.4]

var fase: float = 0.0
var fase0: float = 0.0
var _vel_noche: float = 1.8


func _init(el0_deg: float = 45.0, dificultad: int = 1, condicion: String = "") -> void:
	fase0 = asin(clampf(el0_deg / EL_PICO, -0.95, 0.95))
	fase = fase0
	_vel_noche = float(NOCHE_VEL[clampi(dificultad, 0, 2)])
	if condicion == "noche":
		fase = PI * 1.12
		fase0 = fase
		_vel_noche = 0.25


func avanzar(delta: float) -> void:
	var v := TAU / DIA_S * (1.0 if sin(fase) >= 0.0 else _vel_noche)
	fase += v * delta


func elevacion() -> float:
	return deg_to_rad(EL_PICO) * sin(fase)


func luz() -> float:
	return smoothstep(-0.10, 0.22, sin(elevacion()))


func dir_sol(site_up: Vector3, h0: Vector3) -> Vector3:
	var e := elevacion()
	var h := h0.rotated(site_up, (fase - fase0) * 0.5)
	return (site_up * sin(e) + h * cos(e)).normalized()


func dir_luna(site_up: Vector3, h0: Vector3) -> Vector3:
	var h := h0.rotated(site_up, (fase - fase0) * 0.5 + PI)
	var e := deg_to_rad(35.0)
	return (site_up * sin(e) + h * cos(e)).normalized()


func hora() -> float:
	return fposmod(6.0 + fase / TAU * 24.0, 24.0)


func hora_texto() -> String:
	var h := hora()
	return "%02d:%02d" % [int(h), int((h - floorf(h)) * 60.0)]


func nombre() -> String:
	var l := luz()
	if l >= 0.9:
		return "DÍA"
	var p := fposmod(fase, TAU)
	if l <= 0.1:
		return "NOCHE"
	return "AMANECER" if (p < PI * 0.5 or p > PI * 1.5) else "ATARDECER"
