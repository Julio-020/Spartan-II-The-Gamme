extends Node3D


const Muestras := preload("res://mision/muestras.gd")

const ANCHO := 9.0
const LARGO := 15.0
const ALTO := 8.0
const FALDA := 3.5
const BOCA_ANCHO := 6.4
const BOCA_ALTO := 5.6

var mision: Node3D = null
var k: float = 0.1
var escala: float = 1.0
var dir_centro: Vector3 = Vector3.UP
var grande: bool = false
var altura_centro: float = 0.0
var mineral: String = ""
var color_luz: Color = Color(1.0, 0.7, 0.4)

var _xl: Vector3 = Vector3.RIGHT
var _zl: Vector3 = Vector3.BACK
var _malla: Node3D
var _mat_ext: StandardMaterial3D
var _mat_ext_fade: StandardMaterial3D
var _ext: MeshInstance3D
var _mat_int: StandardMaterial3D
var _luz: OmniLight3D
var _energia_luz: float = 1.6
var _fn: FastNoiseLite
var _tipo: String = "generico"
var _mat_cristal: StandardMaterial3D
var _brillo0: float = 0.7
var _motas: CPUParticles3D
var _luces_extra: Array[OmniLight3D] = []
var _fase: float = 0.0


func construir(m: Node3D, dir: Vector3, dir_boca: Vector3, es_grande: bool, semilla: int,
		mineral_id: String, color_mineral: Color) -> void:
	mision = m
	k = m.k
	grande = es_grande
	escala = 1.6 if grande else 1.0
	dir_centro = dir
	mineral = mineral_id
	color_luz = color_mineral
	_tipo = mineral_id if mineral_id in ["hielo", "yeso"] else "generico"
	altura_centro = m.altura_en(dir)

	_zl = (dir_boca - dir * dir_boca.dot(dir)).normalized()
	_xl = dir.cross(_zl).normalized()
	transform = Transform3D(Basis(_xl, dir, _zl), dir * (m.planeta_radio() + altura_centro))

	_malla = Node3D.new()
	_malla.scale = Vector3.ONE * k
	add_child(_malla)

	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	var cupula := _generar_cupula(rng)

	_mat_ext = Muestras.mat_roca(Color(0.38, 0.26, 0.2), 0.97, 1.4, 0.45)

	_mat_ext_fade = _mat_ext.duplicate()
	_mat_ext_fade.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_int = Muestras.mat_roca(Color(0.1, 0.08, 0.075), 0.95, 1.0, 0.6).duplicate()
	_mat_int.cull_mode = BaseMaterial3D.CULL_FRONT

	_ext = MeshInstance3D.new()
	_ext.mesh = cupula
	_ext.material_override = _mat_ext
	_ext.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_malla.add_child(_ext)
	var inte := MeshInstance3D.new()
	inte.mesh = cupula
	inte.material_override = _mat_int
	inte.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_malla.add_child(inte)

	_decorar(rng)
	_crear_luz()
	_registrar_muros()


func _generar_cupula(rng: RandomNumberGenerator) -> ArrayMesh:
	var fn := FastNoiseLite.new()
	fn.seed = rng.randi()
	fn.frequency = 0.9
	fn.fractal_octaves = 3
	_fn = fn
	var w := ANCHO * escala
	var l := LARGO * escala
	var h := ALTO * escala
	var falda := FALDA * escala
	var n_th := 40
	var n_ph := 14

	var pts: Array = []
	for i in range(n_ph + 2):
		var fila: Array = []
		for j in range(n_th):
			var th := TAU * float(j) / float(n_th)
			var ph: float = (PI * 0.5) * float(mini(i, n_ph)) / float(n_ph)
			var u := Vector3(sin(ph) * cos(th), cos(ph), sin(ph) * sin(th))
			var r := 1.0 + 0.2 * fn.get_noise_3dv(u * 2.4) + 0.06 * fn.get_noise_3dv(u * 7.0)
			var p := Vector3(w * u.x * r, h * u.y * r, l * u.z * r)
			if i == n_ph + 1:
				p.y = -falda
			fila.append(p)
		pts.append(fila)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mw := BOCA_ANCHO * escala
	var mh := BOCA_ALTO * escala
	for i in range(n_ph + 1):
		for j in range(n_th):
			var j2 := (j + 1) % n_th
			var a: Vector3 = pts[i][j]
			var b: Vector3 = pts[i][j2]
			var c: Vector3 = pts[i + 1][j]
			var d: Vector3 = pts[i + 1][j2]
			for tri in [[a, c, b], [b, c, d]]:
				var cen: Vector3 = (tri[0] + tri[1] + tri[2]) / 3.0

				if cen.z > l * 0.35 and (cen.x * cen.x) / (mw * mw) + (cen.y * cen.y) / (mh * mh) < 1.0:
					continue
				for v in tri:
					st.add_vertex(v)
	st.generate_normals()
	return st.commit()


func _decorar(rng: RandomNumberGenerator) -> void:
	var w := ANCHO * escala
	var l := LARGO * escala
	var n := 9 if grande else 6
	for i in range(n):
		var a := rng.randf_range(0.0, TAU)
		var f := rng.randf_range(0.45, 0.78)
		var x := cos(a) * w * f
		var z := sin(a) * l * f
		if z > l * 0.4 and absf(x) < BOCA_ANCHO * escala:
			continue
		var r := rng.randf_range(0.8, 1.9) * (1.2 if grande else 1.0)
		var roca := Muestras.roca_escenario(rng, r)
		roca.position = Vector3(x, _alto_local(x, z) + r * 0.2, z)
		roca.rotation.y = rng.randf() * TAU
		_malla.add_child(roca)

	var n_pe := 16 if grande else 11
	for i in range(n_pe):
		var ap := TAU * (float(i) + rng.randf_range(-0.3, 0.3)) / float(n_pe)
		if absf(angle_difference(ap, PI * 0.5)) < 0.95:
			continue
		var fp := rng.randf_range(1.05, 1.3)
		var xp := cos(ap) * w * fp
		var zp := sin(ap) * l * fp
		var rp := rng.randf_range(2.0, 4.2) * (1.25 if grande else 1.0)
		var peña := Muestras.roca_escenario(rng, rp)
		peña.position = Vector3(xp, _alto_local(xp, zp) + rp * 0.1, zp)
		peña.rotation.y = rng.randf() * TAU
		_malla.add_child(peña)
		mision.registrar_obstaculo(dir_en(xp, zp), rp * 0.8 * k)
	_decorar_minerales(rng)


func _material_cristal() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	match _tipo:
		"hielo":
			m.albedo_color = Color(0.72, 0.88, 1.0, 0.62)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.06
			m.emission = Color(0.45, 0.75, 1.0)
			_brillo0 = 0.55
		"yeso":
			m.albedo_color = Color(0.95, 0.92, 0.82)
			m.roughness = 0.3
			m.emission = Color(1.0, 0.94, 0.78)
			_brillo0 = 0.3
		_:
			m.albedo_color = color_luz.darkened(0.1)
			m.roughness = 0.25
			m.emission = color_luz
			_brillo0 = 0.7
	m.emission_enabled = true
	m.emission_energy_multiplier = _brillo0
	m.metallic_specular = 0.9
	return m


func _decorar_minerales(rng: RandomNumberGenerator) -> void:
	var w := ANCHO * escala
	var l := LARGO * escala
	_fase = rng.randf() * TAU
	_mat_cristal = _material_cristal()
	var alto_max := 3.3 if _tipo == "yeso" else 2.4
	var n_grupos := 6 if grande else 4
	for g in range(n_grupos):
		var a := rng.randf_range(PI * 0.95, PI * 2.05)
		var f := rng.randf_range(0.72, 0.86)
		var cx := cos(a) * w * f
		var cz := sin(a) * l * f
		var hacia := Vector3(cx / (w * w), 0.0, cz / (l * l)).normalized()
		var eje := Vector3.UP.cross(hacia).normalized()
		var suelo := _alto_local(cx, cz)
		for i in range(rng.randi_range(5, 9)):
			var ox := rng.randf_range(-1.1, 1.1)
			var oz := rng.randf_range(-1.1, 1.1)
			var cerca := clampf(Vector2(ox, oz).length() / 1.5, 0.0, 1.0)
			var h := rng.randf_range(0.8, alto_max) * (1.0 - 0.3 * cerca)
			var cm := CylinderMesh.new()
			cm.height = h
			cm.bottom_radius = rng.randf_range(0.1, 0.22) * (1.0 + h * 0.1)
			cm.top_radius = cm.bottom_radius * (0.35 if _tipo == "yeso" else 0.0)
			cm.radial_segments = 6
			cm.rings = 1
			var mi := MeshInstance3D.new()
			mi.mesh = cm
			mi.material_override = _mat_cristal
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var incl := rng.randf_range(0.1, 0.6)
			mi.basis = Basis(eje, incl) * Basis(Vector3.UP, rng.randf() * TAU)
			var px := cx + ox
			var pz := cz + oz
			mi.position = Vector3(px, _alto_local(px, pz) + h * 0.42, pz)
			_malla.add_child(mi)

		if g < 2:
			var lz := OmniLight3D.new()
			lz.light_color = _mat_cristal.emission.lerp(Color.WHITE, 0.2)
			lz.omni_range = 11.0 * escala * k
			lz.omni_attenuation = 1.4
			lz.light_energy = 0.0
			lz.shadow_enabled = false
			lz.visible = false
			lz.position = Vector3(cx, suelo + 1.8, cz) * k
			add_child(lz)
			_luces_extra.append(lz)

	var mat_col: Material = _mat_cristal if _tipo == "hielo" else Muestras.mat_roca(Color(0.2, 0.15, 0.13), 0.95, 1.2, 0.5)
	for i in range(8 if grande else 5):
		var a2 := rng.randf_range(PI * 0.9, PI * 2.1)
		var f2 := rng.randf_range(0.7, 0.84)
		var x2 := cos(a2) * w * f2
		var z2 := sin(a2) * l * f2
		var cm2 := CylinderMesh.new()
		cm2.height = rng.randf_range(0.9, 2.2) * escala
		cm2.bottom_radius = rng.randf_range(0.25, 0.5) * escala
		cm2.top_radius = cm2.bottom_radius * rng.randf_range(0.0, 0.35)
		cm2.radial_segments = 7
		cm2.rings = 1
		var col := MeshInstance3D.new()
		col.mesh = cm2
		col.material_override = mat_col
		col.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		col.rotation_degrees = Vector3(rng.randf_range(-6.0, 6.0), rng.randf() * 360.0, rng.randf_range(-6.0, 6.0))
		col.position = Vector3(x2, _alto_local(x2, z2) + cm2.height * 0.4, z2)
		_malla.add_child(col)
	_crear_motas()


func _crear_motas() -> void:
	var w := ANCHO * escala
	var l := LARGO * escala
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 32
	tex.height = 32
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = tex
	m.albedo_color = Color(color_luz.lerp(Color.WHITE, 0.45), 0.8)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	var vida := Gradient.new()
	vida.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	vida.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	var p := CPUParticles3D.new()
	p.amount = 60 if grande else 36
	p.lifetime = 9.0
	p.preprocess = 9.0
	p.local_coords = true
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(w * 0.6, 1.6, l * 0.55) * k
	p.position = Vector3(0.0, 2.4 * escala, -l * 0.08) * k
	p.direction = Vector3(0.3, 1.0, 0.2)
	p.spread = 60.0
	p.initial_velocity_min = 0.05 * k
	p.initial_velocity_max = 0.2 * k
	p.gravity = Vector3.ZERO
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.3
	p.color_ramp = vida
	var q := QuadMesh.new()
	q.size = Vector2(0.18, 0.18) * k
	p.mesh = q
	p.material_override = m
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.visible = false
	add_child(p)
	_motas = p


func _alto_local(x: float, z: float) -> float:
	var d := dir_en(x, z)
	return (mision.altura_en(d) - altura_centro) / k


func dir_en(x: float, z: float) -> Vector3:
	return (dir_centro + (_zl * (z * k) + _xl * (x * k)) / mision.planeta_radio()).normalized()


func _crear_luz() -> void:
	_luz = OmniLight3D.new()
	_luz.light_color = color_luz.lerp(Color(1, 1, 1), 0.35)
	_luz.omni_range = 24.0 * escala * k
	_luz.light_energy = 0.0
	_luz.shadow_enabled = false
	_luz.position = Vector3(0.0, 2.6 * escala * k, 0.0)
	add_child(_luz)


func _registrar_muros() -> void:
	var w := ANCHO * escala
	var l := LARGO * escala
	var paso := 24 if not grande else 34
	for i in range(paso):
		var a := TAU * float(i) / float(paso)
		var x := cos(a) * w
		var z := sin(a) * l

		if absf(angle_difference(a, PI * 0.5)) < 0.8:
			continue
		mision.registrar_obstaculo(dir_en(x, z), 1.9 * escala * k)


func puntos_interior(n: int, rng: RandomNumberGenerator) -> Array[Vector3]:
	var res: Array[Vector3] = []
	var w := ANCHO * escala
	var l := LARGO * escala
	var intentos := 0
	while res.size() < n and intentos < 60:
		intentos += 1
		var a := rng.randf() * TAU
		var f := rng.randf_range(0.25, 0.5)
		var x := cos(a) * (w - 3.2 * escala) * f * 1.6
		var z := sin(a) * (l - 3.2 * escala) * f * 1.3 - l * 0.12
		if (x * x) / (w * w) + (z * z) / (l * l) > 0.42:
			continue
		var d := dir_en(x, z)
		var ok := true
		for q in res:
			if mision.distancia_entre(d, q) < 4.0:
				ok = false
				break
		if ok:
			res.append(d)
	return res


func factor_dentro(dir: Vector3) -> float:
	var v: Vector3 = (dir - dir_centro) * (mision.planeta_radio() / k)
	var x: float = v.dot(_xl) / (ANCHO * escala)
	var z: float = v.dot(_zl) / (LARGO * escala)
	var d := sqrt(x * x + z * z)
	return 1.0 - smoothstep(0.62, 0.95, d)


func actualizar(dentro: float) -> void:
	var a := 1.0 - smoothstep(0.08, 0.55, dentro)
	if a >= 0.99:
		_ext.visible = true
		_ext.material_override = _mat_ext
	elif a <= 0.02:
		_ext.visible = false
	else:
		_ext.visible = true
		_mat_ext_fade.albedo_color.a = a
		_ext.material_override = _mat_ext_fade
	_luz.light_energy = _energia_luz * (0.35 + 0.65 * dentro) * (1.0 if grande else 0.8)

	var pulso := 0.8 + 0.2 * sin(float(Time.get_ticks_msec()) * 0.0013 + _fase)
	if _mat_cristal != null:
		_mat_cristal.emission_energy_multiplier = _brillo0 * (0.35 + 0.65 * dentro) * pulso
	for lz in _luces_extra:
		lz.visible = dentro > 0.03
		lz.light_energy = 0.9 * dentro * pulso
	if _motas != null:
		_motas.visible = dentro > 0.03


func dir_entrada() -> Vector3:
	return dir_en(0.0, LARGO * escala * 0.95)
