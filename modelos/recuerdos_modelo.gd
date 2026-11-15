extends RefCounted


static func _m(c: Color, brillo: float = 0.0, metal: float = 0.1, rug: float = 0.6) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rug
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if brillo > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = brillo
	return m


static func _caja(p: Node3D, tam: Vector3, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = tam
	mi.mesh = b
	mi.material_override = m
	mi.position = pos
	p.add_child(mi)
	return mi


static func _cil(p: Node3D, r_sup: float, r_inf: float, alto: float, pos: Vector3, m: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r_sup
	c.bottom_radius = r_inf
	c.height = alto
	c.radial_segments = 14
	mi.mesh = c
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	p.add_child(mi)
	return mi


static func _esf(p: Node3D, r: float, pos: Vector3, m: Material, achatada: float = 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 16
	s.rings = 8
	mi.mesh = s
	mi.material_override = m
	mi.position = pos
	mi.scale = Vector3(1.0, achatada, 1.0)
	p.add_child(mi)
	return mi


static func bandera(padre: Node3D, id: String) -> Node3D:
	if id == "":
		return null
	var raiz := Node3D.new()
	raiz.name = "Bandera"
	raiz.position = Vector3(-0.62, 1.32, 0.92)
	padre.add_child(raiz)
	var m_asta := _m(Color(0.85, 0.85, 0.88), 0.0, 0.5, 0.4)
	_cil(raiz, 0.012, 0.012, 0.95, Vector3(0, 0.47, 0), m_asta)
	_esf(raiz, 0.022, Vector3(0, 0.96, 0), m_asta)
	var tela := Node3D.new()
	tela.position = Vector3(0.21, 0.78, 0.0)
	raiz.add_child(tela)
	match id:
		"ban_colombia":
			_caja(tela, Vector3(0.4, 0.09, 0.008), Vector3(0, 0.045, 0), _m(Color(0.98, 0.8, 0.1)))
			_caja(tela, Vector3(0.4, 0.045, 0.008), Vector3(0, -0.0225, 0), _m(Color(0.1, 0.25, 0.7)))
			_caja(tela, Vector3(0.4, 0.045, 0.008), Vector3(0, -0.0675, 0), _m(Color(0.8, 0.1, 0.15)))
		"ban_tierra":
			_caja(tela, Vector3(0.4, 0.2, 0.008), Vector3.ZERO, _m(Color(0.04, 0.07, 0.16)))
			_esf(tela, 0.05, Vector3(0, 0, 0.006), _m(Color(0.3, 0.55, 1.0), 0.6), 1.0).scale = Vector3(1, 1, 0.15)
		"ban_marte":
			_caja(tela, Vector3(0.4, 0.2, 0.008), Vector3.ZERO, _m(Color(0.82, 0.33, 0.18)))
			_cil(tela, 0.055, 0.055, 0.01, Vector3(0.06, 0.0, 0.006), _m(Color(0.25, 0.1, 0.07)), Vector3(90, 0, 0))
	return raiz


static func adorno(padre: Node3D, id: String) -> Node3D:
	if id == "":
		return null
	var raiz := Node3D.new()
	raiz.name = "Adorno"
	padre.add_child(raiz)

	var m_rep := _m(Color(0.34, 0.34, 0.38), 0.0, 0.3, 0.6)
	_caja(raiz, Vector3(0.9, 0.8, 0.9), Vector3(0, 0.46, 0), m_rep)
	_caja(raiz, Vector3(0.96, 0.05, 0.96), Vector3(0, 0.885, 0), _m(Color(0.7, 0.7, 0.75), 0.0, 0.4, 0.4))
	var tope := Node3D.new()
	tope.position = Vector3(0, 0.91, 0)
	raiz.add_child(tope)
	match id:
		"ado_planta":
			_cil(tope, 0.2, 0.15, 0.26, Vector3(0, 0.13, 0), _m(Color(0.6, 0.3, 0.2), 0.0, 0.0, 0.9))
			_cil(tope, 0.012, 0.012, 0.34, Vector3(0, 0.42, 0), _m(Color(0.3, 0.6, 0.25)))
			var hoja := _m(Color(0.35, 0.8, 0.35), 0.35)
			var h1 := _esf(tope, 0.1, Vector3(0.09, 0.56, 0), hoja, 0.3)
			h1.rotation_degrees = Vector3(0, 0, -25)
			var h2 := _esf(tope, 0.1, Vector3(-0.09, 0.5, 0.02), hoja, 0.3)
			h2.rotation_degrees = Vector3(0, 0, 25)
			_esf(tope, 0.06, Vector3(0.0, 0.62, 0), hoja, 0.5)
		"ado_globo":
			_cil(tope, 0.14, 0.18, 0.05, Vector3(0, 0.025, 0), _m(Color(0.15, 0.15, 0.18)))
			_cil(tope, 0.012, 0.012, 0.3, Vector3(0, 0.2, 0), _m(Color(0.7, 0.7, 0.75), 0.0, 0.6, 0.3))
			var g := Node3D.new()
			g.position = Vector3(0, 0.5, 0)
			g.rotation_degrees = Vector3(0, 0, 23)
			tope.add_child(g)
			_esf(g, 0.2, Vector3.ZERO, _m(Color(0.15, 0.4, 0.85), 0.5))
			for v in [Vector3(0.08, 0.1, 0.15), Vector3(-0.12, -0.05, 0.14), Vector3(0.05, -0.14, -0.14), Vector3(-0.1, 0.12, -0.14)]:
				_esf(g, 0.06, v, _m(Color(0.3, 0.7, 0.35), 0.3), 0.7)
		"ado_cohete":
			_cil(tope, 0.15, 0.17, 0.04, Vector3(0, 0.02, 0), _m(Color(0.15, 0.15, 0.18)))
			var blanco := _m(Color(0.95, 0.95, 0.97), 0.0, 0.2, 0.4)
			var rojo := _m(Color(0.9, 0.2, 0.18), 0.0, 0.2, 0.5)
			_cil(tope, 0.08, 0.08, 0.5, Vector3(0, 0.3, 0), blanco)
			_cil(tope, 0.0, 0.08, 0.2, Vector3(0, 0.65, 0), rojo)
			for a in [0.0, 120.0, 240.0]:
				var f := _caja(tope, Vector3(0.015, 0.16, 0.12), Vector3(0, 0.12, 0), rojo)
				f.rotation_degrees = Vector3(0, a, 0)
				f.position = Vector3(sin(deg_to_rad(a)) * 0.1, 0.12, cos(deg_to_rad(a)) * 0.1)
	return raiz
