extends RefCounted


const SondaModelo := preload("res://modelos/sonda_modelo.gd")
const HistoriaVisual := preload("res://historia/historia_visual.gd")
const FotoArchivo := preload("res://mision/foto_archivo.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")

signal terminada

const DIST_ADELANTE := 46.0
const DIST_LADO := 16.0
const Y_INICIO := 38.0
const Y_RETRO := 18.0
const T_SUELTA := 3.2
const T_POSA := 5.2

var activa: bool = false
var t: float = 0.0
var dur: float = 8.0
var foto_pendiente: bool = false
var cam_pos: Vector3 = Vector3.ZERO
var cam_basis: Basis = Basis.IDENTITY

var _m: Node3D
var _id: String = ""
var _tipo: String = "aterrizaje"
var _choque: bool = false
var _estilo: String = "nasa"
var _k: float = 0.1
var _vel: float = 1.0
var _t_foto: float = 6.0
var _foto_hecha: bool = false
var _P: Vector3 = Vector3.ZERO
var _B: Basis = Basis.IDENTITY
var _up: Vector3 = Vector3.UP
var _raiz: Node3D
var _sonda: Node3D
var _para: Node3D
var _llama: MeshInstance3D
var _rover: Node3D
var _baliza: Node3D
var _plato: Node3D
var _anillos: Array = []
var _part: Array = []
var _polvo_hecho: bool = false
var _t_impacto: float = 99.0
var _prox_humo: float = 0.0
var _ui: CanvasLayer
var _negro: ColorRect
var _velo: ColorRect
var _lbl_nombre: Label
var _lbl_salto: Label
var _rng := RandomNumberGenerator.new()


func iniciar(m: Node3D, datos: Dictionary, ya_jugada: bool) -> bool:
	if not HistoriaVisual.aplica(datos):
		return false
	_m = m
	_id = str(datos.get("id", ""))
	_tipo = HistoriaVisual.tipo(datos)
	_choque = _tipo == "restos" and HistoriaVisual.modo(_id) == "choque"
	_estilo = HistoriaVisual.estilo(datos)
	_k = float(m.get("k"))
	_rng.seed = absi(hash(_id)) + 7
	_vel = 1.5 if ya_jugada else 1.0
	match _tipo:
		"colonia":
			dur = 7.2
			_t_foto = 4.6
		"rover":
			dur = 8.6
			_t_foto = 6.0
		"restos":
			dur = 7.9 if _choque else 8.2
			_t_foto = 6.0 if _choque else 6.3
		_:
			dur = 8.0
			_t_foto = 6.2
	if not _situar():
		return false
	_construir_actores()
	_construir_ui(datos)
	t = 0.0
	activa = true
	actualizar(0.0)
	return true


func _situar() -> bool:
	var up: Vector3 = _m.get("_up")
	var f: Vector3 = _m.get("_fwd")
	f = (f - up * f.dot(up)).normalized()
	var p := up.cross(f).normalized()
	var ds: Vector3 = _m.call("_desplazar", up, f, p, DIST_ADELANTE * _k, DIST_LADO * _k)
	_up = ds
	_P = _m.call("_pos", ds)
	var hacia := up - ds * up.dot(ds)
	if hacia.length() < 0.00001:
		hacia = -f
	var z := hacia.normalized()
	var x := ds.cross(z).normalized()
	z = x.cross(ds).normalized()
	_B = Basis(x, ds, z)
	return true


func _construir_actores() -> void:
	_raiz = Node3D.new()
	_raiz.transform = Transform3D(_B * Basis.from_scale(Vector3.ONE * _k), _P)
	_m.add_child(_raiz)
	if _tipo == "colonia":
		_baliza = SondaModelo.baliza()
		_raiz.add_child(_baliza)
		for i in range(3):
			var a := SondaModelo.anillo()
			a.visible = false
			_raiz.add_child(a)
			_anillos.append({"n": a, "t0": 0.7 + float(i) * 2.0})
		return
	_sonda = SondaModelo.sonda(_estilo)
	_raiz.add_child(_sonda)
	_plato = _sonda.get_node("Plato")
	_para = SondaModelo.paracaidas()
	_raiz.add_child(_para)
	_llama = SondaModelo.llama()
	_raiz.add_child(_llama)
	if _tipo == "rover":
		_rover = SondaModelo.rover_pequeno(_estilo)
		_rover.visible = false
		_raiz.add_child(_rover)


func _construir_ui(datos: Dictionary) -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 30
	_m.add_child(_ui)
	_velo = ColorRect.new()
	_velo.color = Color(0, 0, 0, 0)
	_velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_velo)
	for arriba in [true, false]:
		var b := ColorRect.new()
		b.color = Color.BLACK
		b.anchor_right = 1.0
		b.anchor_top = 0.0 if arriba else 0.89
		b.anchor_bottom = 0.11 if arriba else 1.0
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui.add_child(b)
	_lbl_nombre = EstiloUI.etiqueta_contorno("%s   ·   %s" % [str(datos.get("era", "")), str(datos.get("nave", "")).to_upper()], 30, Color.WHITE, true)
	_lbl_nombre.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_lbl_nombre.offset_left = 48.0
	_lbl_nombre.offset_top = -126.0
	_lbl_nombre.offset_bottom = -84.0
	_lbl_nombre.offset_right = 900.0
	_lbl_nombre.modulate.a = 0.0
	_ui.add_child(_lbl_nombre)
	_lbl_salto = EstiloUI.etiqueta("ESPACIO · saltar", 14, Color(1, 1, 1, 0.6))
	_lbl_salto.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_lbl_salto.offset_left = -220.0
	_lbl_salto.offset_right = -40.0
	_lbl_salto.offset_top = -50.0
	_lbl_salto.offset_bottom = -22.0
	_lbl_salto.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ui.add_child(_lbl_salto)
	_negro = ColorRect.new()
	_negro.color = Color(0, 0, 0, 1)
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_negro)


func ocultar_ui(oculto: bool) -> void:
	if _ui != null and is_instance_valid(_ui):
		_ui.visible = not oculto


func saltar() -> void:
	if activa:
		_terminar()


func _terminar() -> void:
	if not activa:
		return
	activa = false
	if _raiz != null and is_instance_valid(_raiz):
		_raiz.queue_free()
	if _ui != null and is_instance_valid(_ui):
		_ui.queue_free()
	terminada.emit()


func actualizar(delta: float) -> void:
	if not activa:
		return
	var vel := _vel
	if _choque and t > 3.5 and t < _t_impacto + 0.5:
		vel *= 0.45
	t += delta * vel
	if t >= dur:
		_terminar()
		return
	if _tipo == "colonia":
		_animar_colonia()
	else:
		_animar_sonda()
	_animar_particulas(delta * vel)
	_actualizar_camara()
	_actualizar_ui()
	if not _foto_hecha and t >= _t_foto:
		_foto_hecha = true
		foto_pendiente = not FotoArchivo.existe(_id)


func _y_sonda() -> float:
	if t < 0.3:
		return Y_INICIO
	if t < T_SUELTA:
		return lerpf(Y_INICIO, Y_RETRO, (t - 0.3) / (T_SUELTA - 0.3))
	var dur_p := T_POSA - T_SUELTA
	if _choque:
		var tc := T_SUELTA + 0.3
		if t <= tc:
			var u := (t - T_SUELTA) / dur_p
			return Y_RETRO * pow(1.0 - u, 2.0)
		var uc := (tc - T_SUELTA) / dur_p
		var y0 := Y_RETRO * pow(1.0 - uc, 2.0)
		var v0 := 2.0 * Y_RETRO * (1.0 - uc) / dur_p
		var d := t - tc
		return maxf(0.0, y0 - v0 * d - 4.5 * d * d)
	if t < T_POSA:
		var u2 := (t - T_SUELTA) / dur_p
		return Y_RETRO * pow(1.0 - u2, 2.0)
	return 0.0


func _animar_sonda() -> void:
	var y := _y_sonda()
	_sonda.position = Vector3(0, y, 0)
	_sonda.rotation_degrees = Vector3.ZERO

	if t < T_SUELTA:
		_para.visible = true
		_para.position = Vector3(0, y + 2.2, 0)
		_para.rotation_degrees = Vector3(sin(t * 1.4) * 4.0, 0, cos(t * 1.1) * 4.0)
	else:
		var d := t - T_SUELTA
		_para.visible = d < 2.2
		_para.position = Vector3(5.0 * d, Y_RETRO + 3.0 + 3.0 * d - 1.5 * d * d, -1.5 * d)
		_para.rotation_degrees = Vector3(20.0 * d, 0, -35.0 * d)

	var llama_on := t >= T_SUELTA and t < T_POSA
	if _choque:
		llama_on = t >= T_SUELTA and t < T_SUELTA + 0.3
	_llama.visible = llama_on
	if llama_on:
		_llama.position = Vector3(0, y - 1.8, 0)
		var f := 0.85 + 0.25 * sin(t * 70.0)
		_llama.scale = Vector3(f, 1.0 + 0.3 * sin(t * 55.0), f)

	if _choque and t > T_SUELTA + 0.3:
		var caida := clampf((t - (T_SUELTA + 0.3)) / 0.7, 0.0, 1.0)
		_sonda.rotation_degrees = Vector3(0, 0, 18.0 * caida)
		if t >= _t_impacto_calc() and not _polvo_hecho:
			_polvo_hecho = true
			_t_impacto = t
			_explosion_polvo(true)
		if _polvo_hecho:
			_sonda.rotation_degrees = Vector3(7.0, 0, 27.0)
			_sonda.position = Vector3(0, -0.25, 0)
			if t > _t_impacto + 0.3 and t >= _prox_humo:
				_prox_humo = t + 0.11
				_humo()

	if not _choque and t >= T_POSA and not _polvo_hecho:
		_polvo_hecho = true
		_explosion_polvo(false)
	if not _choque and t >= T_POSA:
		var asiento := clampf((t - T_POSA) / 0.35, 0.0, 1.0)
		_sonda.position.y = -0.12 * sin(asiento * PI)

	if _plato != null:
		var abre := 0.0
		if not _choque and not (_tipo == "restos"):
			abre = clampf((t - (T_POSA + 0.4)) / 1.1, 0.0, 1.0)
		elif _tipo == "restos" and not _choque:
			abre = 0.0
		_plato.rotation_degrees = Vector3(0, 0, lerpf(80.0, 0.0, abre))
		if _choque and _polvo_hecho:
			_plato.rotation_degrees = Vector3(0, 40.0, 55.0)

	if _rover != null:
		var sale := t - (T_POSA + 0.6)
		_rover.visible = sale > 0.0
		if sale > 0.0:
			var s := clampf(sale / 1.4, 0.0, 1.0)
			var x := 3.2 + 2.2 * maxf(0.0, sale - 1.0) * 1.2 + s * 1.5
			_rover.position = Vector3(x, 0.0, 1.2 * s)
			_rover.rotation_degrees = Vector3(0, -14.0 * s, 0)


func _t_impacto_calc() -> float:

	var dur_p := T_POSA - T_SUELTA
	var tc := T_SUELTA + 0.3
	var uc := 0.3 / dur_p
	var y0 := Y_RETRO * pow(1.0 - uc, 2.0)
	var v0 := 2.0 * Y_RETRO * (1.0 - uc) / dur_p
	var d := (-v0 + sqrt(v0 * v0 + 4.0 * 4.5 * y0)) / (2.0 * 4.5)
	return tc + d


func _animar_colonia() -> void:
	var esf := _baliza.get_child(2) as MeshInstance3D
	var pulso := 0.0
	for a: Dictionary in _anillos:
		var u := (t - float(a["t0"])) / 3.2
		var n := a["n"] as MeshInstance3D
		if u < 0.0 or u > 1.0:
			n.visible = false
			continue
		n.visible = true
		var s := lerpf(1.5, 38.0, u)
		n.scale = Vector3(s, 1.0, s)
		n.position = Vector3(0, 0.12, 0)
		var mat := n.material_override as StandardMaterial3D
		mat.albedo_color = Color(0.74, 0.5, 1.0, (1.0 - u) * 0.85)
		pulso = maxf(pulso, 1.0 - u)
	var mat_e := esf.material_override as StandardMaterial3D
	mat_e.emission_energy_multiplier = 1.5 + 4.0 * pulso
	(_baliza.get_child(3) as OmniLight3D).light_energy = 1.5 + 4.0 * pulso


func _nueva_part(pos: Vector3, vel: Vector3, r0: float, crece: float, col: Color, vida: float, alfa: float) -> void:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = r0
	s.height = r0 * 2.0
	s.radial_segments = 8
	s.rings = 4
	mi.mesh = s
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(col.r, col.g, col.b, alfa)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	_raiz.add_child(mi)
	_part.append({"n": mi, "mat": mat, "p0": pos, "v": vel, "g": crece, "vida": vida, "edad": 0.0, "col": col, "a": alfa})


func _explosion_polvo(fuerte: bool) -> void:
	var n := 22 if fuerte else 14
	var col := Color(0.74, 0.47, 0.32) if not fuerte else Color(0.55, 0.38, 0.3)
	for i in range(n):
		var ang := TAU * float(i) / float(n) + _rng.randf_range(-0.2, 0.2)
		var sp := _rng.randf_range(3.0, 8.0) * (1.3 if fuerte else 1.0)
		_nueva_part(Vector3(0, 0.4, 0), Vector3(cos(ang) * sp, _rng.randf_range(0.6, 2.2), sin(ang) * sp), 0.9, 1.6 if not fuerte else 2.2, col, 2.4, 0.55)
	if fuerte:
		for i in range(6):
			_nueva_part(Vector3(_rng.randf_range(-0.6, 0.6), 1.0, _rng.randf_range(-0.6, 0.6)), Vector3(_rng.randf_range(-1.5, 1.5), _rng.randf_range(3.0, 6.0), _rng.randf_range(-1.5, 1.5)),
					0.7, 1.8, Color(1.0, 0.78, 0.4), 0.9, 0.8)


func _humo() -> void:
	_nueva_part(Vector3(_rng.randf_range(-0.4, 0.6), 1.3, _rng.randf_range(-0.4, 0.4)), Vector3(_rng.randf_range(-0.5, 0.9), _rng.randf_range(2.4, 3.6), _rng.randf_range(-0.4, 0.4)),
			0.55, 1.2, Color(0.16, 0.14, 0.13), 3.0, 0.5)


func _animar_particulas(delta: float) -> void:
	var vivas: Array = []
	for p: Dictionary in _part:
		p["edad"] = float(p["edad"]) + delta
		var u := float(p["edad"]) / float(p["vida"])
		var n := p["n"] as MeshInstance3D
		if u >= 1.0:
			n.queue_free()
			continue
		var e := float(p["edad"])
		var v: Vector3 = p["v"]
		n.position = (p["p0"] as Vector3) + v * e * (1.0 - 0.35 * u)
		var s := 1.0 + float(p["g"]) * u
		n.scale = Vector3(s, s * 0.8, s)
		var col: Color = p["col"]
		(p["mat"] as StandardMaterial3D).albedo_color = Color(col.r, col.g, col.b, float(p["a"]) * (1.0 - u))
		vivas.append(p)
	_part = vivas


func _actualizar_camara() -> void:
	var tt := clampf(t / dur, 0.0, 1.0)
	var a := lerpf(-0.6, 0.35, tt)
	var r := lerpf(34.0, 11.0, smoothstep(0.0, 1.0, tt))
	var h := lerpf(9.0, 3.2, tt)
	var objetivo := Vector3(0, 2.0, 0)
	if _tipo == "colonia":
		a = lerpf(-0.35, 0.3, tt)
		r = lerpf(36.0, 17.0, smoothstep(0.0, 1.0, tt))
		h = lerpf(8.0, 4.0, tt)
		objetivo = Vector3(0, 3.5, 0)
	else:
		var y := _y_sonda()
		objetivo = Vector3(0, clampf(y * 0.8 + 1.0, 1.6, 30.0), 0)
		if _rover != null and _rover.visible:
			objetivo.x = _rover.position.x * 0.55
	var loc := Vector3(sin(a) * r, h, -cos(a) * r)
	if _t_impacto < 90.0:
		var sac := exp(-(t - _t_impacto) * 3.5) * 0.35
		loc += Vector3(sin(t * 63.0), sin(t * 71.0 + 1.0), 0.0) * sac
	var pos: Vector3 = _P + _B * (loc * _k)
	var obj: Vector3 = _P + _B * (objetivo * _k)

	var dc := pos.normalized()
	var radio_planeta: float = float(_m.get("planet").radius)
	var alt := pos.length() - (radio_planeta + float(_m.call("_altura", dc)))
	if alt < 1.5 * _k:
		pos += dc * (1.5 * _k - alt)
	cam_pos = pos
	cam_basis = Basis.looking_at(obj - pos, _up)


func _actualizar_ui() -> void:
	if _ui == null:
		return
	var fade_in := clampf(1.0 - t / 0.7, 0.0, 1.0)
	var fade_out := clampf((t - (dur - 0.5)) / 0.5, 0.0, 1.0)
	_negro.color.a = maxf(fade_in, fade_out)
	_lbl_nombre.modulate.a = clampf((t - 0.6) / 0.6, 0.0, 1.0) * (1.0 - fade_out)

	var v := 0.0
	if _tipo == "restos" and not _choque and t > _t_foto + 0.3:
		v = clampf((t - _t_foto - 0.3) / 1.4, 0.0, 1.0) * 0.5
	_velo.color = Color(0.02, 0.02, 0.04, v)
