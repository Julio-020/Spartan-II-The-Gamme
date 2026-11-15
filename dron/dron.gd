extends Node3D


signal marcados_nuevos(n: int)
signal estado_cambiado(estado: int)

const ALT_ESCOLTA := 3.4
const ALT_REFUGIO := 2.7
const VISION_ESCOLTA := 0.4


enum E { GUARDADO, ESCOLTA }

var estado: int = E.GUARDADO
var marcados: Array = []
var vision: float = 42.0


var oculto: bool = false
var robot_fwd: Vector3 = Vector3.FORWARD
var robot_vel: float = 0.0
var objetivo: Vector3 = Vector3.ZERO
var tormenta: bool = false
var noche: float = 0.0
var asustado: bool = false
var alegre_t: float = 0.0
var festejo_t: float = 0.0
var habla_t: float = 0.0

var _run: Node3D = null
var _dir: Vector3 = Vector3.UP
var _fwd: Vector3 = Vector3.FORWARD
var _alt: float = 0.0
var _t: float = 0.0
var _rotores: Array[Node3D] = []
var _led: MeshInstance3D
var _mat_led: StandardMaterial3D
var _ult_marca: float = 0.0
var _k: float = 0.1
var _cabeceo: float = 0.0
var _guiando: bool = false
var _luz: OmniLight3D
var _sombra: MeshInstance3D
var _mat_sombra: StandardMaterial3D
var _lado: float = 1.0
var _holo: Node3D
var _holo_fig: Node3D
var _holo_mats: Array[StandardMaterial3D] = []
var _holo_anillos: Array[Node3D] = []
var _holo_k: float = 0.0


func configurar(run: Node3D) -> void:
	_run = run
	_k = float(run.k)
	_construir()
	_construir_holo()
	_luz = OmniLight3D.new()
	_luz.light_color = Color(1.0, 0.93, 0.78)
	_luz.omni_range = 13.0 * _k
	_luz.light_energy = 0.0
	_luz.shadow_enabled = false
	_luz.visible = false
	run.add_child(_luz)
	_mat_sombra = StandardMaterial3D.new()
	_mat_sombra.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_sombra.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_sombra.albedo_color = Color(0.0, 0.0, 0.0, 0.3)
	_mat_sombra.cull_mode = BaseMaterial3D.CULL_DISABLED
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 1.0
	cm.height = 0.01
	cm.radial_segments = 20
	_sombra = MeshInstance3D.new()
	_sombra.mesh = cm
	_sombra.material_override = _mat_sombra
	_sombra.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sombra.visible = false
	run.add_child(_sombra)
	visible = false



func acompanando() -> bool:
	return estado == E.ESCOLTA


func ocultar() -> void:
	visible = false
	if _luz != null:
		_luz.visible = false
	if _sombra != null:
		_sombra.visible = false
	if estado != E.GUARDADO:
		_cambiar(E.GUARDADO)


func festejar() -> void:
	if estado == E.ESCOLTA:
		festejo_t = 1.3
		alegre_t = 1.5


func actualizar(delta: float, dir_robot: Vector3) -> void:
	_t += delta
	_girar_rotores(delta)
	if festejo_t > 0.0:
		festejo_t = maxf(festejo_t - delta, 0.0)
	if estado == E.GUARDADO:
		if not oculto:
			_aparecer(dir_robot)
	else:
		_escoltar(delta, dir_robot)
	if estado != E.GUARDADO:
		_poner()
	_actualizar_led(delta)
	_actualizar_holo(delta)
	_actualizar_luz_y_sombra()
	if estado == E.ESCOLTA and not tormenta and _t - _ult_marca >= 0.3:
		_ult_marca = _t
		_buscar()


func _cambiar(e: int) -> void:
	estado = e
	estado_cambiado.emit(e)


func _distancia(otra: Vector3) -> float:
	return float(_run.distancia_gm(_dir, otra))


func _aparecer(dir_robot: Vector3) -> void:
	_dir = dir_robot
	_fwd = (robot_fwd - dir_robot * robot_fwd.dot(dir_robot)).normalized()
	_alt = 1.6
	visible = true
	_cambiar(E.ESCOLTA)
	_poner()


func _escoltar(delta: float, dir_robot: Vector3) -> void:
	if oculto:
		ocultar()
		return
	var rf := (robot_fwd - dir_robot * robot_fwd.dot(dir_robot)).normalized()
	var destino := dir_robot
	var alt_obj := ALT_ESCOLTA + 0.25 * sin(_t * 2.1)
	var mirar := rf
	_guiando = false
	if tormenta:
		destino = _run.mover_dir(dir_robot, -rf, 1.0 * _k)
		alt_obj = ALT_REFUGIO
	else:
		var d_obj := 0.0
		if objetivo != Vector3.ZERO:
			d_obj = float(_run.distancia_gm(dir_robot, objetivo))
		if d_obj > 10.0:

			var hacia_obj: Vector3 = (objetivo - dir_robot * objetivo.dot(dir_robot)).normalized()
			destino = _run.mover_dir(dir_robot, hacia_obj, minf(7.0, d_obj * 0.5) * _k)
			mirar = hacia_obj
			alt_obj = ALT_ESCOLTA + 1.1 + 0.3 * sin(_t * 3.0)
			_guiando = true
		elif d_obj > 0.0:

			destino = objetivo
			alt_obj = ALT_ESCOLTA + 2.4 + 0.4 * sin(_t * 3.4)
			mirar = (objetivo - dir_robot * objetivo.dot(dir_robot)).normalized()
			_guiando = true
		else:

			if int(_t / 14.0) != int((_t - delta) / 14.0):
				_lado = -_lado
			var ang := (0.9 + 0.35 * sin(_t * 0.4)) * _lado
			destino = _run.mover_dir(dir_robot, rf.rotated(dir_robot, ang), 3.6 * _k)
	var d := _distancia(destino)
	if d > 70.0:
		_dir = destino
		d = 0.0
	if d > 0.05:
		var hacia: Vector3 = (destino - _dir * destino.dot(_dir))
		if hacia.length() > 0.000001:
			hacia = hacia.normalized()
			var vel := clampf(d * 3.2, 0.0, 38.0)
			_dir = _run.mover_dir(_dir, hacia, minf(vel * delta, d) * _k)

	var m := (mirar - _dir * mirar.dot(_dir))
	if m.length() > 0.00001:
		m = m.normalized()
		var f_act := (_fwd - _dir * _fwd.dot(_dir)).normalized()
		var ang_m := f_act.signed_angle_to(m, _dir)
		_fwd = f_act.rotated(_dir, clampf(ang_m, -4.0 * delta, 4.0 * delta))

	_alt = move_toward(_alt, alt_obj, 5.0 * delta)
	var velo := 0.0 if tormenta else clampf(d * 3.2, 0.0, 38.0)
	_cabeceo = lerpf(_cabeceo, clampf(velo / 38.0, 0.0, 1.0) * 0.32, 1.0 - exp(-4.0 * delta))



func _buscar() -> void:
	var radio := vision * (VISION_ESCOLTA if estado == E.ESCOLTA else 1.0)
	var nuevos := 0
	for o in _run.objetivos_dron():
		if not is_instance_valid(o) or marcados.has(o):
			continue
		var d: Vector3 = o.get_meta("dir_dron") if o.has_meta("dir_dron") else o.get_meta("dir")
		if _distancia(d) <= radio:
			marcados.append(o)
			nuevos += 1
	if nuevos > 0:
		marcados_nuevos.emit(nuevos)


func limpiar() -> void:
	var vivos: Array = []
	for o in marcados:
		if is_instance_valid(o) and _run.dron_objetivo_vigente(o):
			vivos.append(o)
	marcados = vivos


func _mat_holo(a: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = Color(0.4, 0.9, 1.0, a)
	m.set_meta("a", a)
	_holo_mats.append(m)
	return m


func _pieza_holo(padre: Node3D, malla: Mesh, a: float, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = malla
	mi.material_override = _mat_holo(a)
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(mi)
	return mi


func _anillo_holo(padre: Node3D, r: float, grosor: float, a: float, inclinacion: Vector3) -> Node3D:
	var giro := Node3D.new()
	giro.rotation_degrees = inclinacion
	padre.add_child(giro)
	var tm := TorusMesh.new()
	tm.inner_radius = r - grosor
	tm.outer_radius = r + grosor
	tm.rings = 28
	tm.ring_segments = 6
	_pieza_holo(giro, tm, a)
	_holo_anillos.append(giro)
	return giro


func _construir_holo() -> void:
	_holo = Node3D.new()
	_holo.position = Vector3(0.0, 0.34, 0.0)
	_holo.visible = false
	add_child(_holo)

	var haz := CylinderMesh.new()
	haz.top_radius = 0.4
	haz.bottom_radius = 0.07
	haz.height = 1.5
	haz.radial_segments = 14
	_pieza_holo(_holo, haz, 0.13, Vector3(0.0, 0.75, 0.0))
	_anillo_holo(_holo, 0.13, 0.012, 0.8, Vector3.ZERO)

	_holo_fig = Node3D.new()
	_holo_fig.position = Vector3(0.0, 1.75, 0.0)
	_holo.add_child(_holo_fig)
	var nucleo := SphereMesh.new()
	nucleo.radius = 0.2
	nucleo.height = 0.4
	nucleo.radial_segments = 14
	nucleo.rings = 8
	_pieza_holo(_holo_fig, nucleo, 0.42)
	var visor := BoxMesh.new()
	visor.size = Vector3(0.3, 0.06, 0.05)
	_pieza_holo(_holo_fig, visor, 0.95, Vector3(0.0, 0.02, -0.19))
	_anillo_holo(_holo_fig, 0.42, 0.012, 0.8, Vector3(0, 0, 0))
	_anillo_holo(_holo_fig, 0.33, 0.01, 0.6, Vector3(62, 0, 0))
	_anillo_holo(_holo_fig, 0.33, 0.01, 0.6, Vector3(-62, 0, 0))
	for s in [-1.0, 1.0]:
		var ala := BoxMesh.new()
		ala.size = Vector3(0.34, 0.012, 0.1)
		var a := _pieza_holo(_holo_fig, ala, 0.5, Vector3(s * 0.46, 0.0, 0.0))
		a.rotation_degrees = Vector3(0, 0, s * 18.0)


func color_holo() -> Color:
	if asustado:
		return Color(1.0, 0.66, 0.2)
	return Color(0.45, 0.82, 1.0)


func _actualizar_holo(delta: float) -> void:
	if _holo == null:
		return
	var habla := habla_t > 0.0 and visible and estado != E.GUARDADO
	if habla_t > 0.0:
		habla_t = maxf(habla_t - delta, 0.0)
	_holo_k = move_toward(_holo_k, 1.0 if habla else 0.0, delta * 3.2)
	_holo.visible = _holo_k > 0.01
	if not _holo.visible:
		return
	var c := color_holo()
	var parp := 0.85 + 0.15 * sin(_t * 37.0)
	for m in _holo_mats:
		m.albedo_color = Color(c.r, c.g, c.b, float(m.get_meta("a")) * _holo_k * parp)
	_holo.scale = Vector3(1.0, 0.25 + 0.75 * _holo_k, 1.0)
	_holo_fig.position.y = 1.75 + 0.07 * sin(_t * 2.3)
	_holo_fig.scale = Vector3.ONE * (1.0 + 0.06 * sin(_t * 17.0))
	for i in range(_holo_anillos.size()):
		var g := _holo_anillos[i]
		g.rotation.y += delta * (1.4 + 0.5 * float(i % 3)) * (1.0 if i % 2 == 0 else -1.0)


func _actualizar_led(delta: float) -> void:
	if _mat_led == null:
		return
	var parpadeo := int(_t * (7.0 if asustado else 2.5)) % 2 == 0
	var c := Color(1.0, 0.65, 0.15) if asustado else Color(0.3, 1.0, 0.45)
	if _guiando and not asustado:
		c = Color(0.4, 0.9, 1.0)
		parpadeo = int(_t * 4.0) % 2 == 0
	if alegre_t > 0.0:
		alegre_t = maxf(alegre_t - delta, 0.0)
		c = Color(0.4, 0.9, 1.0)
		parpadeo = true
	_mat_led.albedo_color = c
	_mat_led.emission = c
	_mat_led.emission_energy_multiplier = 3.0 if parpadeo else 0.4


func _actualizar_luz_y_sombra() -> void:
	var presente := visible and estado != E.GUARDADO
	if _luz != null:
		var e := clampf((noche - 0.1) / 0.4, 0.0, 1.0) * 1.7 if not tormenta else 0.0
		_luz.visible = presente and e > 0.02
		_luz.light_energy = e
		_luz.transform = Transform3D(Basis.IDENTITY, transform.origin - _dir * (0.4 * _k))
	if _sombra != null:
		_sombra.visible = presente
		if presente:
			var suelo: Vector3 = _run.punto_suelo(_dir) + _dir * (0.05 * _k)
			var r := (0.9 + _alt * 0.07) * _k
			_sombra.transform = Transform3D(_run.base_en(_dir) * Basis.from_scale(Vector3(r, 1.0, r)), suelo)
			_mat_sombra.albedo_color.a = clampf(0.34 - _alt * 0.014, 0.08, 0.34)


func _poner() -> void:
	var extra := 0.0
	var giro_fest := 0.0
	if festejo_t > 0.0:
		var f := 1.0 - festejo_t / 1.3
		extra = 1.3 * sin(PI * f)
		giro_fest = TAU * f
	var h: float = float(_run.altura_en(_dir)) + (_alt + extra) * _k
	var pos: Vector3 = _dir * (float(_run.planeta_radio()) + h)
	var arriba := _dir
	var f2 := (_fwd - arriba * _fwd.dot(arriba)).normalized()
	if giro_fest != 0.0:
		f2 = f2.rotated(arriba, giro_fest)
	var der := f2.cross(arriba).normalized()
	var atras := der.cross(arriba)
	var incl := 0.0
	if estado == E.ESCOLTA:
		incl = 0.1 * sin(_t * 1.7)
	var b := Basis(der, arriba, atras) * Basis.from_scale(Vector3.ONE * _k)
	b = b.rotated(f2, incl)
	b = b.rotated(der, -_cabeceo)
	transform = Transform3D(b, pos)


func _girar_rotores(delta: float) -> void:
	var v := 0.0
	if estado == E.ESCOLTA:
		v = 60.0 if not (estado == E.ESCOLTA and tormenta) else 8.0
	for r in _rotores:
		r.rotation.y += v * delta


func _mat(c: Color, metal: float = 0.3, rug: float = 0.5) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rug
	return m


func _construir() -> void:
	var m_cuerpo := _mat(Color(0.92, 0.93, 0.96), 0.2, 0.45)
	var m_oscuro := _mat(Color(0.12, 0.13, 0.16), 0.4, 0.5)
	var m_naranja := _mat(Color(0.95, 0.45, 0.12), 0.1, 0.55)
	var m_helice := StandardMaterial3D.new()
	m_helice.albedo_color = Color(0.1, 0.1, 0.12, 0.55)
	m_helice.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_led = StandardMaterial3D.new()
	_mat_led.albedo_color = Color(0.3, 1.0, 0.45)
	_mat_led.emission_enabled = true
	_mat_led.emission = Color(0.3, 1.0, 0.45)
	_mat_led.emission_energy_multiplier = 2.0
	var cuerpo := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.9, 0.28, 0.9)
	cuerpo.mesh = bm
	cuerpo.material_override = m_cuerpo
	add_child(cuerpo)
	var tapa := MeshInstance3D.new()
	var bm2 := BoxMesh.new()
	bm2.size = Vector3(0.6, 0.12, 0.6)
	tapa.mesh = bm2
	tapa.material_override = m_naranja
	tapa.position = Vector3(0, 0.2, 0)
	add_child(tapa)
	var cam := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.16
	sm.height = 0.32
	cam.mesh = sm
	cam.material_override = m_oscuro
	cam.position = Vector3(0, -0.2, -0.3)
	add_child(cam)
	_led = MeshInstance3D.new()
	var sm2 := SphereMesh.new()
	sm2.radius = 0.07
	sm2.height = 0.14
	_led.mesh = sm2
	_led.material_override = _mat_led
	_led.position = Vector3(0, 0.3, 0.3)
	add_child(_led)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var brazo := MeshInstance3D.new()
			var bb := BoxMesh.new()
			bb.size = Vector3(0.9, 0.06, 0.08)
			brazo.mesh = bb
			brazo.material_override = m_oscuro
			brazo.position = Vector3(sx * 0.6, 0.0, sz * 0.6)
			brazo.rotation_degrees = Vector3(0, 45.0 * sx * sz, 0)
			add_child(brazo)
			var rot := Node3D.new()
			rot.position = Vector3(sx * 0.95, 0.12, sz * 0.95)
			add_child(rot)
			var disco := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.55
			cm.bottom_radius = 0.55
			cm.height = 0.015
			cm.radial_segments = 16
			disco.mesh = cm
			disco.material_override = m_helice
			rot.add_child(disco)
			var pala := MeshInstance3D.new()
			var pm := BoxMesh.new()
			pm.size = Vector3(1.0, 0.02, 0.07)
			pala.mesh = pm
			pala.material_override = m_oscuro
			rot.add_child(pala)
			_rotores.append(rot)
