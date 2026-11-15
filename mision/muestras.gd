extends RefCounted


static var _mallas: Dictionary = {}
static var _mats: Dictionary = {}
static var _tex: Dictionary = {}


static func _textura(clave: String, semilla: int, freq: float, tipo: int) -> Texture2D:
	if _tex.has(clave):
		return _tex[clave]
	var fn := FastNoiseLite.new()
	fn.seed = semilla
	fn.frequency = freq
	var t := NoiseTexture2D.new()
	t.width = 256
	t.height = 256
	t.seamless = true
	match tipo:
		0:
			fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			fn.fractal_type = FastNoiseLite.FRACTAL_FBM
			fn.fractal_octaves = 5
			var g := Gradient.new()
			g.offsets = PackedFloat32Array([0.0, 1.0])
			g.colors = PackedColorArray([Color(0.5, 0.5, 0.5), Color(1.1, 1.1, 1.1)])
			t.color_ramp = g
		1:
			fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			fn.fractal_type = FastNoiseLite.FRACTAL_FBM
			fn.fractal_octaves = 4
			t.as_normal_map = true
			t.bump_strength = 6.0
		2:
			fn.noise_type = FastNoiseLite.TYPE_CELLULAR
			fn.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
			var g2 := Gradient.new()
			g2.offsets = PackedFloat32Array([0.0, 0.16])
			g2.colors = PackedColorArray([Color(0.18, 0.18, 0.18), Color(1.0, 1.0, 1.0)])
			t.color_ramp = g2
		3:
			fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			fn.fractal_octaves = 2
			t.as_normal_map = true
			t.bump_strength = 3.0
	t.noise = fn
	_tex[clave] = t
	return t


static func mat_roca(color: Color, rough: float = 0.95, relieve: float = 1.0, escala: float = 0.7,
		metal: float = 0.0, grietas: bool = false) -> StandardMaterial3D:
	var clave := "m%s_%.2f_%.2f_%.2f_%.2f_%s" % [color.to_html(), rough, relieve, escala, metal, grietas]
	if _mats.has(clave):
		return _mats[clave]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.albedo_texture = _textura("grietas", 7, 0.02, 2) if grietas else _textura("motas", 3, 0.02, 0)
	m.roughness = rough
	m.metallic = metal
	m.normal_enabled = true
	m.normal_texture = _textura("normal", 5, 0.03, 1)
	m.normal_scale = relieve
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * escala
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_mats[clave] = m
	return m


static func mat_liso(color: Color, metal: float, rough: float, emision: float = 0.0,
		alpha: float = 1.0) -> StandardMaterial3D:
	var clave := "l%s_%.2f_%.2f_%.2f_%.2f" % [color.to_html(), metal, rough, emision, alpha]
	if _mats.has(clave):
		return _mats[clave]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.metallic = metal
	m.roughness = rough
	m.metallic_specular = 0.8
	if alpha < 0.99:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emision > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emision
	_mats[clave] = m
	return m


static func _mat_hielo() -> StandardMaterial3D:
	if _mats.has("hielo"):
		return _mats["hielo"]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.7, 0.87, 1.0, 0.72)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.07
	m.metallic_specular = 1.0
	m.rim_enabled = true
	m.rim = 0.6
	m.rim_tint = 0.4
	m.subsurf_scatter_enabled = true
	m.subsurf_scatter_strength = 0.6
	m.emission_enabled = true
	m.emission = Color(0.35, 0.6, 0.9)
	m.emission_energy_multiplier = 0.25
	_mats["hielo"] = m
	return m


static func _m_esfera(segs: int = 12) -> Mesh:
	var clave := "esf%d" % segs
	if not _mallas.has(clave):
		var s := SphereMesh.new()
		s.radius = 1.0
		s.height = 2.0
		s.radial_segments = segs
		s.rings = maxi(segs / 2, 4)
		_mallas[clave] = s
	return _mallas[clave]


static func _m_caja() -> Mesh:
	if not _mallas.has("caja"):
		var b := BoxMesh.new()
		b.size = Vector3.ONE
		_mallas["caja"] = b
	return _mallas["caja"]


static func _m_cil(segs: int = 12, punta: bool = false) -> Mesh:
	var clave := "cil%d_%s" % [segs, punta]
	if not _mallas.has(clave):
		var c := CylinderMesh.new()
		c.top_radius = 0.0 if punta else 1.0
		c.bottom_radius = 1.0
		c.height = 1.0
		c.radial_segments = segs
		c.rings = 1
		_mallas[clave] = c
	return _mallas[clave]


static func malla_roca(variante: int, achatado: float = 0.8, planos: int = 6, rugosidad: float = 0.28,
		plano_liso: bool = false) -> ArrayMesh:
	var clave := "roca%d_%.2f_%d_%.2f_%s" % [variante, achatado, planos, rugosidad, plano_liso]
	if _mallas.has(clave):
		return _mallas[clave]
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 18
	sm.rings = 9
	var arr := sm.get_mesh_arrays()
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var fn := FastNoiseLite.new()
	fn.seed = 300 + variante
	fn.frequency = 0.9
	fn.fractal_octaves = 3
	var rng := RandomNumberGenerator.new()
	rng.seed = 900 + variante * 7
	var normales: Array[Vector3] = []
	var dists: Array[float] = []
	for i in range(planos):
		var n := Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.6, 1.0), rng.randf_range(-1.0, 1.0))
		normales.append(n.normalized())
		dists.append(rng.randf_range(0.5, 0.82))
	var pts := PackedVector3Array()
	pts.resize(vs.size())
	for i in range(vs.size()):
		var v: Vector3 = vs[i]
		var p: Vector3 = v * (1.0 + rugosidad * fn.get_noise_3dv(v * 1.8))
		p.y *= achatado
		for j in range(planos):
			var s: float = p.dot(normales[j]) - dists[j]
			if s > 0.0:
				p -= normales[j] * s
		pts[i] = p
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if not plano_liso:
		st.set_smooth_group(-1)
	for i in idx:
		st.add_vertex(pts[i])
	st.generate_normals()
	var malla := st.commit()
	_mallas[clave] = malla
	return malla


static func _inst(padre: Node3D, malla: Mesh, mat: Material, pos: Vector3,
		escala: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = malla
	mi.material_override = mat
	mi.position = pos
	mi.scale = escala
	mi.rotation_degrees = rot_deg
	padre.add_child(mi)
	return mi


static func _bola(padre: Node3D, radio: float, pos: Vector3, mat: Material, segs: int = 10) -> MeshInstance3D:
	return _inst(padre, _m_esfera(segs), mat, pos, Vector3.ONE * radio)


static func _cristal(padre: Node3D, radio: float, alto: float, pos: Vector3, rot_deg: Vector3, mat: Material) -> void:
	var raiz := Node3D.new()
	raiz.position = pos
	raiz.rotation_degrees = rot_deg
	padre.add_child(raiz)
	_inst(raiz, _m_cil(6), mat, Vector3(0.0, alto * 0.5, 0.0), Vector3(radio, alto, radio))
	_inst(raiz, _m_cil(6, true), mat, Vector3(0.0, alto + alto * 0.14, 0.0), Vector3(radio, alto * 0.28, radio))


static func _gira(rng: RandomNumberGenerator) -> float:
	return rng.randf() * 360.0


static func construir(raiz: Node3D, id: String, esc: float, rng: RandomNumberGenerator) -> void:
	var detalle: bool = esc >= 0.99
	match id:
		"hielo": _hielo(raiz, esc, rng, detalle)
		"hematita": _hematita(raiz, esc, rng, detalle)
		"jarosita": _jarosita(raiz, esc, rng, detalle)
		"olivino": _olivino(raiz, esc, rng, detalle)
		"silice": _silice(raiz, esc, rng, detalle)
		"perclorato": _perclorato(raiz, esc, rng, detalle)
		"arcilla": _arcilla(raiz, esc, rng)
		"yeso": _yeso(raiz, esc, rng)
		"nucleo": _nucleo(raiz, esc, rng)
		"conglomerado": _conglomerado(raiz, esc, rng, detalle)
		"regolito": _regolito(raiz, esc, rng, detalle)
		"pata": _pata(raiz, esc, rng)
		"motor": _motor(raiz, esc, rng)
		"sismometro": _sismometro(raiz, esc, rng)
		_: _regolito(raiz, esc, rng, detalle)


static func _hielo(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var hielo := _mat_hielo()
	var nucleo := mat_liso(Color(0.92, 0.96, 1.0), 0.0, 0.55)

	_inst(raiz, malla_roca(1, 0.85, 7), hielo, Vector3(0.0, 0.5 * e, 0.0), Vector3(1.05, 0.95, 0.85) * e,
			Vector3(0.0, _gira(rng), 0.0))
	_inst(raiz, malla_roca(2, 0.8, 5), nucleo, Vector3(0.05 * e, 0.45 * e, 0.0), Vector3(0.62, 0.55, 0.5) * e,
			Vector3(0.0, _gira(rng), 0.0))
	_inst(raiz, malla_roca(4, 0.7, 6), hielo, Vector3(0.95 * e, 0.22 * e, 0.45 * e), Vector3(0.5, 0.45, 0.45) * e,
			Vector3(0.0, _gira(rng), 0.0))
	if detalle:
		_inst(raiz, malla_roca(5, 0.6, 5), hielo, Vector3(-0.8, 0.16, -0.5), Vector3(0.36, 0.3, 0.32),
				Vector3(0.0, _gira(rng), 0.0))

		var escarcha := mat_liso(Color(0.9, 0.95, 1.0), 0.0, 0.9)
		for i in range(5):
			var a := rng.randf() * TAU
			var r := rng.randf_range(0.5, 1.7)
			var s := rng.randf_range(0.5, 1.2)
			_inst(raiz, _m_cil(14), escarcha, Vector3(cos(a) * r, 0.03, sin(a) * r), Vector3(s, 0.05, s * 0.8),
					Vector3(0.0, _gira(rng), 0.0))


static func _hematita(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var roca := mat_roca(Color(0.42, 0.24, 0.17), 0.95, 1.2)
	var bola := mat_liso(Color(0.4, 0.38, 0.45), 0.5, 0.28, 0.14)
	_inst(raiz, malla_roca(3, 0.5, 5), roca, Vector3(0.0, 0.2 * e, 0.0), Vector3(1.3, 1.0, 1.0) * e,
			Vector3(0.0, _gira(rng), 0.0))
	var n := 10 if detalle else 4
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.3, 1.8) * e
		var s := rng.randf_range(0.1, 0.2) * e
		_bola(raiz, s, Vector3(cos(a) * r, 0.14 * e + s * 0.3, sin(a) * r), bola, 12)
	if detalle:
		var arena := mat_roca(Color(0.5, 0.3, 0.2), 1.0, 0.6)
		_inst(raiz, _m_cil(16), arena, Vector3(0.0, 0.02, 0.0), Vector3(2.3, 0.04, 2.0))


static func _jarosita(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var roca := mat_roca(Color(0.3, 0.17, 0.12), 0.95, 1.2)
	var costra := mat_roca(Color(0.92, 0.72, 0.18), 0.8, 1.6, 1.4)
	_inst(raiz, malla_roca(2, 0.55, 6), roca, Vector3(0.0, 0.22 * e, 0.0), Vector3(1.2, 1.0, 1.0) * e,
			Vector3(0.0, _gira(rng), 0.0))
	_inst(raiz, malla_roca(6, 0.35, 4, 0.4, true), costra, Vector3(0.1 * e, 0.62 * e, 0.0),
			Vector3(0.9, 0.55, 0.75) * e, Vector3(0.0, _gira(rng), 0.0))
	var n := 8 if detalle else 3
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.2, 1.5) * e
		var s := rng.randf_range(0.14, 0.3) * e
		_inst(raiz, _m_esfera(8), costra, Vector3(cos(a) * r, 0.16 * e, sin(a) * r), Vector3(s, s * 0.6, s))


static func _olivino(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var basalto := mat_roca(Color(0.17, 0.15, 0.15), 0.9, 1.4)
	var cristal := mat_liso(Color(0.5, 0.82, 0.14), 0.0, 0.1, 0.3)
	_inst(raiz, malla_roca(2, 0.65, 7), basalto, Vector3(0.0, 0.3 * e, 0.0), Vector3(1.3, 1.0, 1.1) * e,
			Vector3(0.0, _gira(rng), 0.0))
	var n := 8 if detalle else 3
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.1, 0.9) * e
		var alto := rng.randf_range(0.3, 0.75) * e
		_cristal(raiz, rng.randf_range(0.07, 0.13) * e, alto,
				Vector3(cos(a) * r, 0.45 * e, sin(a) * r),
				Vector3(rng.randf_range(-40.0, 40.0), _gira(rng), rng.randf_range(-40.0, 40.0)), cristal)
	if detalle:
		for i in range(10):
			var a2 := rng.randf() * TAU
			var r2 := rng.randf_range(1.0, 2.0)
			_bola(raiz, rng.randf_range(0.04, 0.09), Vector3(cos(a2) * r2, 0.05, sin(a2) * r2), cristal, 6)


static func _silice(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var opalo := mat_roca(Color(0.94, 0.89, 0.77), 0.55, 1.8, 1.8)
	_inst(raiz, malla_roca(3, 0.4, 5, 0.2, true), mat_roca(Color(0.75, 0.62, 0.5), 0.9), Vector3(0.0, 0.1 * e, 0.0),
			Vector3(1.3, 0.8, 1.2) * e, Vector3(0.0, _gira(rng), 0.0))
	var n := 16 if detalle else 7
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.0, 0.95) * e
		var s := rng.randf_range(0.16, 0.38) * e * (1.0 - r / (1.6 * e))
		_bola(raiz, s, Vector3(cos(a) * r, 0.3 * e + s * 0.5 + (0.5 - r / e * 0.3) * 0.2, sin(a) * r), opalo, 9)


static func _perclorato(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var suelo := mat_roca(Color(0.22, 0.14, 0.11), 1.0, 0.8)
	var sal := mat_roca(Color(0.93, 0.94, 0.97), 0.42, 1.8, 2.2)
	var cristal := mat_liso(Color(0.96, 0.97, 1.0), 0.0, 0.15, 0.15)
	_inst(raiz, _m_cil(18), suelo, Vector3(0.0, 0.02, 0.0), Vector3(1.9, 0.04, 1.6) * e)
	var n := 7 if detalle else 3
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.0, 1.1) * e
		var s := rng.randf_range(0.35, 0.7) * e
		_inst(raiz, malla_roca(8 + i % 3, 0.28, 4, 0.2), sal, Vector3(cos(a) * r, 0.1 * e, sin(a) * r),
				Vector3(s, s, s), Vector3(0.0, _gira(rng), 0.0))
	if detalle:
		for i in range(14):
			var a2 := rng.randf() * TAU
			var r2 := rng.randf_range(0.0, 1.5)
			var s2 := rng.randf_range(0.05, 0.11)
			_inst(raiz, _m_caja(), cristal, Vector3(cos(a2) * r2, 0.12, sin(a2) * r2), Vector3(s2, s2, s2),
					Vector3(rng.randf_range(0.0, 60.0), _gira(rng), rng.randf_range(0.0, 60.0)))


static func _arcilla(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var barro := mat_roca(Color(0.62, 0.42, 0.33), 0.92, 0.7, 0.6, 0.0, true)
	var capa2 := mat_roca(Color(0.5, 0.36, 0.3), 0.92, 0.7, 0.6, 0.0, true)
	var gris := mat_roca(Color(0.55, 0.58, 0.6), 1.0, 0.5)
	var negro := mat_liso(Color(0.05, 0.04, 0.04), 0.0, 1.0)
	var y := 0.0
	for i in range(4):
		var s := (1.35 - i * 0.2) * e
		_inst(raiz, malla_roca(11 + i, 0.2, 4, 0.12), barro if i % 2 == 0 else capa2,
				Vector3(rng.randf_range(-0.08, 0.08) * e, y + 0.14 * e, rng.randf_range(-0.08, 0.08) * e),
				Vector3(s, s, s), Vector3(0.0, _gira(rng), 0.0))
		y += 0.22 * e

	_inst(raiz, _m_cil(14), gris, Vector3(0.1 * e, y + 0.02 * e, 0.0), Vector3(0.38, 0.03, 0.38) * e)
	_inst(raiz, _m_cil(12), negro, Vector3(0.1 * e, y + 0.05 * e, 0.0), Vector3(0.13, 0.03, 0.13) * e)


static func _yeso(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var losa := mat_roca(Color(0.2, 0.15, 0.14), 0.9, 1.3, 0.8, 0.0, true)
	var veta := mat_liso(Color(0.97, 0.97, 0.93), 0.0, 0.32, 0.12)
	var cuerpo := _inst(raiz, malla_roca(14, 0.3, 5, 0.1), losa, Vector3(0.0, 0.25 * e, 0.0), Vector3(1.5, 1.0, 1.3) * e,
			Vector3(0.0, _gira(rng), 0.0))
	cuerpo.rotation_degrees.x = rng.randf_range(-6.0, 6.0)

	for i in range(3):
		var ang := -50.0 + i * 40.0 + rng.randf_range(-12.0, 12.0)
		_inst(raiz, _m_caja(), veta, Vector3((i - 1) * 0.3 * e, 0.52 * e, 0.0),
				Vector3(0.07 * e, 0.05 * e, 1.9 * e), Vector3(0.0, ang, 0.0))
	_inst(raiz, _m_caja(), veta, Vector3(0.0, 0.5 * e, 0.0), Vector3(1.2 * e, 0.04 * e, 0.05 * e),
			Vector3(0.0, rng.randf_range(-20.0, 20.0), 0.0))


static func _nucleo(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var piedra := mat_roca(Color(0.5, 0.42, 0.36), 0.9, 1.2)
	var pulida := mat_roca(Color(0.72, 0.64, 0.56), 0.6, 0.4)
	var negro := mat_liso(Color(0.04, 0.04, 0.05), 0.0, 1.0)
	var titanio := mat_liso(Color(0.78, 0.8, 0.84), 0.5, 0.32, 0.18)
	var oro := mat_liso(Color(0.9, 0.7, 0.3), 0.5, 0.3, 0.3)

	_inst(raiz, malla_roca(15, 0.4, 6, 0.15), piedra, Vector3(-0.3 * e, 0.28 * e, 0.0), Vector3(1.4, 1.0, 1.2) * e,
			Vector3(0.0, _gira(rng), 0.0))
	_inst(raiz, _m_cil(16), pulida, Vector3(-0.3 * e, 0.63 * e, 0.0), Vector3(0.5, 0.03, 0.5) * e)
	_inst(raiz, _m_cil(12), negro, Vector3(-0.3 * e, 0.65 * e, 0.0), Vector3(0.13, 0.03, 0.13) * e)

	var tubo := Node3D.new()
	tubo.position = Vector3(0.9 * e, 0.16 * e, 0.6 * e)
	tubo.rotation_degrees = Vector3(0.0, rng.randf_range(-50.0, 50.0), 0.0)
	raiz.add_child(tubo)
	_inst(tubo, _m_cil(16), titanio, Vector3.ZERO, Vector3(0.14, 1.1, 0.14) * e, Vector3(0.0, 0.0, 90.0))
	_inst(tubo, _m_cil(16), oro, Vector3(0.58 * e, 0.0, 0.0), Vector3(0.155, 0.12, 0.155) * e, Vector3(0.0, 0.0, 90.0))
	_inst(tubo, _m_cil(16), negro, Vector3(-0.2 * e, 0.0, 0.0), Vector3(0.152, 0.05, 0.152) * e, Vector3(0.0, 0.0, 90.0))


static func _conglomerado(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var matriz := mat_roca(Color(0.5, 0.41, 0.33), 0.95, 1.3)
	_inst(raiz, malla_roca(16, 0.42, 6, 0.14), matriz, Vector3(0.0, 0.22 * e, 0.0), Vector3(1.5, 1.0, 1.3) * e,
			Vector3(0.0, _gira(rng), 0.0))
	var colores: Array[Color] = [Color(0.62, 0.52, 0.4), Color(0.42, 0.38, 0.36), Color(0.7, 0.6, 0.48),
			Color(0.35, 0.3, 0.28)]
	var n := 14 if detalle else 6
	for i in range(n):
		var a := rng.randf() * TAU
		var r := rng.randf_range(0.0, 1.1) * e
		var s := rng.randf_range(0.12, 0.26) * e
		var c := colores[i % colores.size()]
		_bola(raiz, s, Vector3(cos(a) * r, 0.36 * e + (1.0 - r / (1.3 * e)) * 0.18 * e, sin(a) * r),
				mat_roca(c, 0.85, 0.8), 10)
	if detalle:
		for i in range(8):
			var a2 := rng.randf() * TAU
			var r2 := rng.randf_range(1.2, 2.2)
			var s2 := rng.randf_range(0.1, 0.22)
			_bola(raiz, s2, Vector3(cos(a2) * r2, s2 * 0.6, sin(a2) * r2), mat_roca(colores[i % 4], 0.85, 0.8), 10)


static func _regolito(raiz: Node3D, e: float, rng: RandomNumberGenerator, detalle: bool) -> void:
	var fino := mat_roca(Color(0.74, 0.4, 0.22), 1.0, 0.5, 1.1)
	var oscuro := mat_roca(Color(0.34, 0.17, 0.12), 1.0, 0.5, 1.1)
	_inst(raiz, malla_roca(17, 0.3, 0, 0.18, true), fino, Vector3(0.0, 0.12 * e, 0.0), Vector3(1.6, 1.0, 1.3) * e,
			Vector3(0.0, _gira(rng), 0.0))

	_inst(raiz, malla_roca(18, 0.2, 0, 0.12, true), oscuro, Vector3(0.1 * e, 0.2 * e, 0.0), Vector3(1.0, 0.8, 0.45) * e,
			Vector3(0.0, rng.randf_range(-30.0, 30.0), 0.0))
	if detalle:
		for i in range(3):
			_inst(raiz, _m_caja(), oscuro, Vector3(-0.5 + i * 0.5, 0.31, 0.5), Vector3(0.12, 0.04, 0.9),
					Vector3(0.0, 8.0 * (i - 1), 0.0))
		for i in range(6):
			var a := rng.randf() * TAU
			var r := rng.randf_range(0.9, 1.9)
			_inst(raiz, malla_roca(19 + i % 3, 0.7, 4), mat_roca(Color(0.3, 0.2, 0.17)),
					Vector3(cos(a) * r, 0.06, sin(a) * r), Vector3.ONE * rng.randf_range(0.06, 0.16))


static func _pata(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var dorado := mat_liso(Color(0.86, 0.66, 0.24), 0.8, 0.3, 0.1)
	var gris := mat_liso(Color(0.55, 0.57, 0.62), 0.6, 0.4, 0.1)
	var pieza := Node3D.new()
	pieza.position = Vector3(0.0, 0.2 * e, 0.0)
	pieza.rotation_degrees = Vector3(rng.randf_range(-10.0, 10.0), _gira(rng), rng.randf_range(-20.0, 20.0))
	raiz.add_child(pieza)
	_inst(pieza, _m_cil(10), gris, Vector3.ZERO, Vector3(0.07, 1.6, 0.07) * e, Vector3(0.0, 0.0, 88.0))
	_inst(pieza, _m_cil(10), dorado, Vector3(0.15 * e, 0.0, 0.0), Vector3(0.13, 0.9, 0.13) * e, Vector3(0.0, 0.0, 88.0))
	_inst(pieza, _m_cil(14), gris, Vector3(-0.82 * e, -0.02 * e, 0.0), Vector3(0.28, 0.05, 0.28) * e, Vector3(0.0, 0.0, 12.0))
	_inst(pieza, _m_caja(), gris, Vector3(0.7 * e, 0.05 * e, 0.0), Vector3(0.14, 0.18, 0.18) * e)


static func _motor(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var metal := mat_liso(Color(0.5, 0.5, 0.54), 0.8, 0.35, 0.1)
	var oscuro := mat_liso(Color(0.16, 0.15, 0.15), 0.5, 0.5)
	var cobre := mat_liso(Color(0.75, 0.4, 0.22), 0.8, 0.35, 0.1)
	var pieza := Node3D.new()
	pieza.position = Vector3(0.0, 0.34 * e, 0.0)
	pieza.rotation_degrees = Vector3(rng.randf_range(-6.0, 6.0), _gira(rng), rng.randf_range(70.0, 90.0))
	raiz.add_child(pieza)
	_inst(pieza, _m_cil(16, true), metal, Vector3(0.0, 0.0, 0.0), Vector3(0.5, 1.0, 0.5) * e, Vector3(180.0, 0.0, 0.0))
	_inst(pieza, _m_cil(16), oscuro, Vector3(0.0, 0.62 * e, 0.0), Vector3(0.22, 0.32, 0.22) * e)
	_inst(pieza, _m_cil(8), cobre, Vector3(0.28 * e, 0.62 * e, 0.0), Vector3(0.04, 0.5, 0.04) * e, Vector3(0.0, 0.0, -10.0))
	_inst(pieza, _m_cil(8), cobre, Vector3(-0.28 * e, 0.62 * e, 0.0), Vector3(0.04, 0.5, 0.04) * e, Vector3(0.0, 0.0, 10.0))


static func _sismometro(raiz: Node3D, e: float, rng: RandomNumberGenerator) -> void:
	var blanco := mat_liso(Color(0.9, 0.9, 0.93), 0.5, 0.4, 0.3)
	var plata := mat_liso(Color(0.7, 0.72, 0.78), 0.8, 0.3, 0.2)
	var cable := mat_liso(Color(0.95, 0.55, 0.15), 0.1, 0.6, 0.3)
	var pieza := Node3D.new()
	pieza.position = Vector3(0.0, 0.1 * e, 0.0)
	pieza.rotation_degrees = Vector3(0.0, _gira(rng), 0.0)
	raiz.add_child(pieza)
	_inst(pieza, _m_cil(18), plata, Vector3.ZERO, Vector3(0.95, 0.08, 0.95) * e)
	_bola(pieza, 0.36 * e, Vector3(0.0, 0.12 * e, 0.0), blanco, 14)
	_inst(pieza, _m_cil(10), cable, Vector3(0.55 * e, 0.05 * e, 0.0), Vector3(0.05, 0.5, 0.05) * e, Vector3(0.0, 0.0, 90.0))
	_inst(pieza, _m_caja(), plata, Vector3(0.0, 0.0, 0.5 * e), Vector3(0.3, 0.1, 0.14) * e)


const TIPOS_ROCA := [
	[Color(0.33, 0.22, 0.17), 0.98],
	[Color(0.28, 0.21, 0.18), 0.98],
	[Color(0.5, 0.33, 0.24), 0.96],
	[Color(0.4, 0.29, 0.23), 0.96],
]


static func roca_escenario(rng: RandomNumberGenerator, radio: float) -> MeshInstance3D:
	var t: Array = TIPOS_ROCA[rng.randi() % TIPOS_ROCA.size()]
	var mi := MeshInstance3D.new()
	mi.mesh = malla_roca(rng.randi_range(1, 6), rng.randf_range(0.6, 0.95), rng.randi_range(4, 8))
	mi.material_override = mat_roca(t[0], t[1], 1.3, 0.55)
	mi.scale = Vector3(radio, radio * rng.randf_range(0.7, 0.95), radio * rng.randf_range(0.9, 1.2))
	return mi


static func malla_guijarro(i: int) -> Mesh:
	return malla_roca(30 + i % 3, 0.7, 4 + i % 3, 0.3)


static func mat_guijarro() -> Material:
	return mat_roca(Color(0.45, 0.31, 0.24), 0.97, 1.0, 1.2)
