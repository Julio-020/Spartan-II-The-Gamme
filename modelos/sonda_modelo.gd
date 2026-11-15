extends RefCounted


const PALETAS := {
	"nasa": {"cuerpo": Color(0.9, 0.9, 0.92), "oro": Color(0.86, 0.66, 0.26), "acento": Color(0.2, 0.4, 0.85)},
	"urss": {"cuerpo": Color(0.62, 0.67, 0.6), "oro": Color(0.7, 0.62, 0.45), "acento": Color(0.8, 0.14, 0.1)},
	"esa": {"cuerpo": Color(0.92, 0.93, 0.95), "oro": Color(0.84, 0.72, 0.4), "acento": Color(0.1, 0.5, 0.9)},
	"china": {"cuerpo": Color(0.93, 0.92, 0.9), "oro": Color(0.86, 0.7, 0.3), "acento": Color(0.84, 0.12, 0.1)},
	"colonia": {"cuerpo": Color(0.84, 0.84, 0.88), "oro": Color(0.9, 0.62, 0.25), "acento": Color(0.72, 0.5, 1.0)},
	"estacion": {"cuerpo": Color(0.6, 0.66, 0.64), "oro": Color(0.7, 0.62, 0.45), "acento": Color(0.5, 0.8, 0.7)},
}


static func paleta(estilo: String) -> Dictionary:
	return PALETAS.get(estilo, PALETAS["nasa"])


static func _m(c: Color, brillo: float = 0.0, metal: float = 0.2, rug: float = 0.55) -> StandardMaterial3D:
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


static func _cil(p: Node3D, r_sup: float, r_inf: float, alto: float, pos: Vector3, m: Material, rot: Vector3 = Vector3.ZERO, seg: int = 14) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r_sup
	c.bottom_radius = r_inf
	c.height = alto
	c.radial_segments = seg
	c.rings = 1
	mi.mesh = c
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	p.add_child(mi)
	return mi


static func _barra(p: Node3D, a: Vector3, b: Vector3, r: float, m: Material) -> MeshInstance3D:
	var d := b - a
	var l := d.length()
	var mi := _cil(p, r, r, l, (a + b) * 0.5, m, Vector3.ZERO, 6)
	if l > 0.001:
		var dir := d / l
		var q := Quaternion(Vector3.UP, dir) if absf(dir.dot(Vector3.UP)) < 0.999 else (Quaternion.IDENTITY if dir.y > 0.0 else Quaternion(Vector3.RIGHT, PI))
		mi.basis = Basis(q)
	return mi


static func sonda(estilo: String) -> Node3D:
	var pal := paleta(estilo)
	var raiz := Node3D.new()
	raiz.name = "Sonda"
	var m_cuerpo := _m(pal["cuerpo"], 0.0, 0.35, 0.45)
	var m_oro := _m(pal["oro"], 0.0, 0.7, 0.35)
	var m_ac := _m(pal["acento"], 0.0, 0.2, 0.5)
	var m_oscuro := _m(Color(0.16, 0.16, 0.19), 0.0, 0.3, 0.6)

	_cil(raiz, 1.15, 1.25, 0.32, Vector3(0, 1.1, 0), m_cuerpo, Vector3.ZERO, 8)
	_cil(raiz, 0.85, 1.05, 0.5, Vector3(0, 1.5, 0), m_oro, Vector3.ZERO, 8)
	_caja(raiz, Vector3(0.9, 0.34, 0.9), Vector3(0, 1.93, 0), m_cuerpo)
	_cil(raiz, 1.16, 1.16, 0.07, Vector3(0, 1.28, 0), m_ac, Vector3.ZERO, 8)

	_cil(raiz, 0.04, 0.04, 0.9, Vector3(0.3, 2.55, 0.2), m_oscuro)
	_caja(raiz, Vector3(0.22, 0.14, 0.14), Vector3(0.3, 3.05, 0.2), m_oscuro)

	var patas := Node3D.new()
	patas.name = "Patas"
	raiz.add_child(patas)
	for i in range(3):
		var a := TAU * float(i) / 3.0 + 0.5
		var dir := Vector3(cos(a), 0.0, sin(a))
		var sup := dir * 0.95 + Vector3(0, 1.1, 0)
		var inf := dir * 2.05 + Vector3(0, 0.08, 0)
		_barra(patas, sup, inf, 0.07, m_oro)
		_cil(patas, 0.32, 0.32, 0.07, inf, m_oscuro)

	var plato := Node3D.new()
	plato.name = "Plato"
	plato.position = Vector3(-0.45, 2.12, -0.2)
	raiz.add_child(plato)
	_cil(plato, 0.03, 0.03, 0.5, Vector3(0, 0.25, 0), m_oscuro)
	var disco := _cil(plato, 0.55, 0.12, 0.12, Vector3(0, 0.55, 0), m_cuerpo, Vector3(-25.0, 0, 0), 12)
	disco.name = "Disco"
	plato.rotation_degrees = Vector3(0, 0, 80.0)
	return raiz


static func paracaidas() -> Node3D:
	var raiz := Node3D.new()
	raiz.name = "Paracaidas"
	var m_tela := _m(Color(0.97, 0.5, 0.18), 0.0, 0.0, 0.9)
	var m_b := _m(Color(0.96, 0.95, 0.92), 0.0, 0.0, 0.9)
	var alto := 7.5
	var toldo := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 3.6
	s.height = 3.6 * 2.0
	s.radial_segments = 16
	s.rings = 6
	toldo.mesh = s
	toldo.material_override = m_tela
	toldo.position = Vector3(0, alto, 0)
	toldo.scale = Vector3(1.0, 0.55, 1.0)
	raiz.add_child(toldo)
	var anillo := _cil(raiz, 3.62, 3.62, 0.2, Vector3(0, alto - 0.05, 0), m_b, Vector3.ZERO, 16)
	anillo.scale = Vector3(1, 1, 1)
	var m_cuerda := _m(Color(0.9, 0.9, 0.88), 0.0, 0.0, 0.9)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		_barra(raiz, Vector3.ZERO, Vector3(cos(a) * 3.5, alto - 0.1, sin(a) * 3.5), 0.018, m_cuerda)
	return raiz


static func llama() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = 0.45
	c.bottom_radius = 0.0
	c.height = 4.0
	c.radial_segments = 10
	mi.mesh = c
	var m := _m(Color(1.0, 0.62, 0.2), 4.0)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(1.0, 0.62, 0.2, 0.85)
	mi.material_override = m
	mi.position = Vector3(0, 0.0, 0)
	var luz := OmniLight3D.new()
	luz.light_color = Color(1.0, 0.65, 0.3)
	luz.light_energy = 3.0
	luz.omni_range = 14.0
	luz.position = Vector3(0, -1.0, 0)
	mi.add_child(luz)
	return mi


static func rover_pequeno(estilo: String) -> Node3D:
	var pal := paleta(estilo)
	var raiz := Node3D.new()
	raiz.name = "RoverPequeno"
	var m_c := _m(pal["cuerpo"], 0.0, 0.3, 0.5)
	var m_p := _m(Color(0.15, 0.15, 0.18), 0.0, 0.2, 0.7)
	var m_s := _m(Color(0.15, 0.22, 0.45), 0.0, 0.3, 0.4)
	_caja(raiz, Vector3(1.5, 0.45, 1.0), Vector3(0, 0.62, 0), m_c)
	_caja(raiz, Vector3(1.3, 0.05, 1.5), Vector3(0, 0.9, 0), m_s)
	_cil(raiz, 0.03, 0.03, 0.7, Vector3(0.5, 1.2, -0.3), m_p)
	_caja(raiz, Vector3(0.16, 0.12, 0.12), Vector3(0.5, 1.58, -0.3), m_p)
	for sx in [-1.0, 0.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_cil(raiz, 0.22, 0.22, 0.16, Vector3(sx * 0.6, 0.22, sz * 0.62), m_p, Vector3(90.0, 0, 0), 10)
	return raiz


static func baliza() -> Node3D:
	var raiz := Node3D.new()
	raiz.name = "Baliza"
	var m_mastil := _m(Color(0.7, 0.72, 0.78), 0.0, 0.5, 0.4)
	var m_luz := _m(Color(0.74, 0.5, 1.0), 3.0)
	_cil(raiz, 0.12, 0.2, 5.0, Vector3(0, 2.5, 0), m_mastil)
	_cil(raiz, 0.9, 1.1, 0.35, Vector3(0, 0.17, 0), m_mastil, Vector3.ZERO, 10)
	var esf := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 0.38
	s.height = 0.76
	esf.mesh = s
	esf.material_override = m_luz
	esf.position = Vector3(0, 5.2, 0)
	raiz.add_child(esf)
	var luz := OmniLight3D.new()
	luz.light_color = Color(0.74, 0.5, 1.0)
	luz.light_energy = 2.5
	luz.omni_range = 22.0
	luz.position = Vector3(0, 5.2, 0)
	raiz.add_child(luz)
	return raiz


static func anillo() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var t := TorusMesh.new()
	t.inner_radius = 0.93
	t.outer_radius = 1.0
	t.rings = 32
	t.ring_segments = 6
	mi.mesh = t
	var m := _m(Color(0.74, 0.5, 1.0), 1.3)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = m
	return mi


static func holograma(nodo: Node, col: Color = Color(0.4, 0.75, 1.0)) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(col.r, col.g, col.b, 0.35)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_pintar(nodo, m)
	return m


static func _pintar(n: Node, m: Material) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).material_override = m
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif n is Light3D:
		(n as Light3D).visible = false
	for c in n.get_children():
		_pintar(c, m)
