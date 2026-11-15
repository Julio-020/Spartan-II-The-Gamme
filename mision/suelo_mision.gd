extends Node3D


const Muestras := preload("res://mision/muestras.gd")
const Realismo := preload("res://nucleo/realismo.gd")

var mision: Node3D = null
var k: float = 0.1
var calidad: int = 2


const CASILLA := 2.4
var _n: int = 32
var _mm_guij: MultiMesh
var _mmi_guij: MultiMeshInstance3D
var _mm_somb: MultiMesh = null
var _mmi_somb: MultiMeshInstance3D = null
var sombras: bool = false
var sol_dir: Vector3 = Vector3.UP
var _celda_slot: PackedInt32Array
var _centro_u: int = -999999
var _centro_v: int = -999999
var _origen: Vector3 = Vector3.ZERO
var _semilla: int = 1


const MAX_HUELLAS := 700
var _mm_huella: MultiMesh
var _mmi_huella: MultiMeshInstance3D
var _i_huella: int = 0
var _dist_huella: float = 0.0
var _ult_pos: Vector3 = Vector3.ZERO
var _lado: float = 1.0


func configurar(m: Node3D, escala: float, cal: int, semilla: int) -> void:
	mision = m
	k = escala
	calidad = cal
	_semilla = semilla
	_n = 0 if cal <= 0 else (24 if cal == 1 else 34)


func _ready() -> void:
	_origen = mision.punto_suelo(mision.site_up)
	if _n > 0:
		_crear_guijarros()
	if calidad >= 1:
		_crear_huellas()


func _crear_guijarros() -> void:
	_mm_guij = MultiMesh.new()
	_mm_guij.transform_format = MultiMesh.TRANSFORM_3D
	_mm_guij.mesh = Muestras.malla_guijarro(0)
	_mm_guij.instance_count = _n * _n
	_mmi_guij = MultiMeshInstance3D.new()
	_mmi_guij.multimesh = _mm_guij
	_mmi_guij.material_override = Muestras.mat_guijarro()
	_mmi_guij.position = _origen
	_mmi_guij.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mmi_guij.custom_aabb = AABB(Vector3.ONE * -400.0, Vector3.ONE * 800.0)
	add_child(_mmi_guij)
	if sombras:
		_mm_somb = MultiMesh.new()
		_mm_somb.transform_format = MultiMesh.TRANSFORM_3D
		_mm_somb.mesh = Realismo.malla_sombra()
		_mm_somb.instance_count = _n * _n
		_mmi_somb = MultiMeshInstance3D.new()
		_mmi_somb.multimesh = _mm_somb
		_mmi_somb.material_override = Realismo.material_sombra(0.7)
		_mmi_somb.position = _origen
		_mmi_somb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_mmi_somb.custom_aabb = AABB(Vector3.ONE * -400.0, Vector3.ONE * 800.0)
		add_child(_mmi_somb)
	_celda_slot.resize(_n * _n * 2)
	for i in range(_n * _n):
		_celda_slot[i * 2] = -999999
		_celda_slot[i * 2 + 1] = -999999
		_mm_guij.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
		if _mm_somb != null:
			_mm_somb.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))


func _uv(dir: Vector3) -> Vector2:
	var d: Vector3 = (dir - mision.site_up) * mision.planeta_radio() / k
	return Vector2(d.dot(mision.eje_f0()), d.dot(mision.eje_perp()))


func _hash(a: int, b: int, s: int) -> float:
	var h: int = (a * 374761393 + b * 668265263 + s * 1274126177) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h & 0xffff) / 65535.0


func actualizar(delta: float, dir_robot: Vector3, pos_robot: Vector3, up: Vector3, fwd: Vector3, vel: float) -> void:
	if _n > 0:
		var uv := _uv(dir_robot)
		var cu := floori(uv.x / CASILLA)
		var cv := floori(uv.y / CASILLA)
		if cu != _centro_u or cv != _centro_v:
			_centro_u = cu
			_centro_v = cv
			_reciclar()
	if calidad >= 1:
		_huellas(delta, pos_robot, up, fwd, vel)


func _reciclar() -> void:
	var mitad := _n / 2
	for su in range(_n):
		for sv in range(_n):

			var iu := _centro_u - mitad + posmod(su - (_centro_u - mitad), _n)
			var iv := _centro_v - mitad + posmod(sv - (_centro_v - mitad), _n)
			var s := su * _n + sv
			if _celda_slot[s * 2] == iu and _celda_slot[s * 2 + 1] == iv:
				continue
			_celda_slot[s * 2] = iu
			_celda_slot[s * 2 + 1] = iv
			_colocar(s, iu, iv)


func _colocar(s: int, iu: int, iv: int) -> void:
	var r0 := _hash(iu, iv, _semilla)
	var r1 := _hash(iu, iv, _semilla + 11)
	var r2 := _hash(iu, iv, _semilla + 23)
	var r3 := _hash(iu, iv, _semilla + 37)
	var r4 := _hash(iu, iv, _semilla + 51)

	if r0 > 0.5:
		_ocultar(s)
		return
	var u := (float(iu) + r1) * CASILLA
	var v := (float(iv) + r2) * CASILLA
	var d: Vector3 = mision.dir_uv(u, v)

	if mision.distancia_entre(d, mision.dir_a()) < 6.0 or mision.distancia_entre(d, mision.dir_b()) < 14.0:
		_ocultar(s)
		return
	var tam := (0.1 + 0.4 * r3 * r3) * k
	var b: Basis = mision.base_en(d).rotated(d, r4 * TAU)
	b = b * Basis.from_scale(Vector3(tam * (0.8 + r1 * 0.6), tam * (0.55 + r2 * 0.3), tam * (0.8 + r3 * 0.5)))
	var p: Vector3 = mision.punto_suelo(d) - _origen + d * (tam * 0.1)
	_mm_guij.set_instance_transform(s, Transform3D(b, p))
	if _mm_somb != null:
		var base_n: Basis = mision.base_en(d)
		var psom: Vector3 = mision.punto_suelo(d) - _origen + d * (0.07 * k)
		_mm_somb.set_instance_transform(s, Realismo.transform_sombra(base_n, psom, sol_dir, tam * 2.3, 0.0))


func _ocultar(s: int) -> void:
	_mm_guij.set_instance_transform(s, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
	if _mm_somb != null:
		_mm_somb.set_instance_transform(s, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))


func _crear_huellas() -> void:
	_mm_huella = MultiMesh.new()
	_mm_huella.transform_format = MultiMesh.TRANSFORM_3D
	_mm_huella.use_colors = true
	var q := PlaneMesh.new()
	q.size = Vector2(0.55, 0.9)
	_mm_huella.mesh = q
	_mm_huella.instance_count = MAX_HUELLAS
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(0.1, 0.05, 0.035, 0.42)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mmi_huella = MultiMeshInstance3D.new()
	_mmi_huella.multimesh = _mm_huella
	_mmi_huella.material_override = m
	_mmi_huella.position = _origen
	_mmi_huella.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mmi_huella.custom_aabb = AABB(Vector3.ONE * -400.0, Vector3.ONE * 800.0)
	add_child(_mmi_huella)
	for i in range(MAX_HUELLAS):
		_mm_huella.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
		_mm_huella.set_instance_color(i, Color(1, 1, 1, 0))
	_ult_pos = Vector3.ZERO


func _huellas(delta: float, pos_robot: Vector3, up: Vector3, fwd: Vector3, vel: float) -> void:
	if absf(vel) < 0.0005:
		return
	if _ult_pos == Vector3.ZERO:
		_ult_pos = pos_robot
		return
	var paso := (pos_robot - _ult_pos).length() / k
	_dist_huella += paso
	_ult_pos = pos_robot
	if _dist_huella < 0.85:
		return
	_dist_huella = 0.0
	var f := (fwd - up * fwd.dot(up)).normalized()
	var derecha := f.cross(up).normalized()
	for lado: float in [-1.0, 1.0]:
		var d: Vector3 = (up + derecha * (lado * 1.0 * k) / mision.planeta_radio()).normalized()
		var n: Vector3 = mision.normal_aprox(d)
		var eje_z := (f - n * f.dot(n)).normalized()
		var eje_x := eje_z.cross(n).normalized()
		var b := Basis(eje_x, n, -eje_z) * Basis.from_scale(Vector3.ONE * k)

		var p: Vector3 = mision.punto_suelo(d) - _origen + n * (0.07 * k)
		_mm_huella.set_instance_transform(_i_huella, Transform3D(b, p))
		_mm_huella.set_instance_color(_i_huella, Color(1, 1, 1, 1))
		_i_huella = (_i_huella + 1) % MAX_HUELLAS
