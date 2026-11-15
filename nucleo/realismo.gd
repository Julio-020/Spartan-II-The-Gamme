extends RefCounted


const CLAVES_ENTORNO := ["tonemap_mode", "tonemap_exposure", "tonemap_white",
		"glow_enabled", "glow_intensity", "glow_strength", "glow_bloom", "glow_hdr_threshold",
		"adjustment_enabled", "adjustment_brightness", "adjustment_contrast", "adjustment_saturation"]

static var _mats: Dictionary = {}
static var _malla: PlaneMesh = null


static func _material(alpha: float) -> StandardMaterial3D:
	var clave := int(round(clampf(alpha, 0.05, 1.0) * 10.0))
	if _mats.has(clave):
		return _mats[clave]
	var a := float(clave) / 10.0
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(0.0, 0.0, 0.0, 0.9 * a), Color(0.0, 0.0, 0.0, 0.62 * a),
			Color(0.0, 0.0, 0.0, 0.16 * a), Color(0.0, 0.0, 0.0, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.8, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = t
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mats[clave] = m
	return m


static func _plano() -> PlaneMesh:
	if _malla == null:
		_malla = PlaneMesh.new()
		_malla.size = Vector2(2.0, 2.0)
	return _malla


static func sombra(padre: Node3D, radio: float, alpha: float, sol_local: Vector3, y: float = 0.12) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = _plano()
	mi.material_override = _material(alpha)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(mi)
	actualizar_sombra(mi, sol_local, radio, y)
	return mi


static func actualizar_sombra(mi: MeshInstance3D, sol_local: Vector3, radio: float, y: float = 0.12) -> void:
	var s := sol_local.normalized()
	var h := Vector2(s.x, s.z)
	var elev := asin(clampf(s.y, 0.05, 1.0))
	var largo := clampf(1.0 / tan(maxf(elev, 0.2)), 1.0, 3.2)
	var dir := Vector3(-h.x, 0.0, -h.y)
	if dir.length() < 0.001:
		dir = Vector3.RIGHT
		largo = 1.0
	dir = dir.normalized()
	var ang := atan2(-dir.z, dir.x)
	var b := Basis(Vector3.UP, ang) * Basis.from_scale(Vector3(radio * largo, 1.0, radio))
	mi.transform = Transform3D(b, dir * radio * (largo - 1.0) * 0.55 + Vector3(0.0, y, 0.0))


static func transform_sombra(base: Basis, pos: Vector3, sol: Vector3, radio: float, y: float) -> Transform3D:
	var sl := base.inverse() * sol
	var h := Vector2(sl.x, sl.z)
	var elev := asin(clampf(sl.y, 0.05, 1.0))
	var largo := clampf(1.0 / tan(maxf(elev, 0.2)), 1.0, 3.2)
	var dir := Vector3(-h.x, 0.0, -h.y)
	if dir.length() < 0.001:
		dir = Vector3.RIGHT
		largo = 1.0
	dir = dir.normalized()
	var ang := atan2(-dir.z, dir.x)
	var local := Transform3D(Basis(Vector3.UP, ang) * Basis.from_scale(Vector3(radio * largo, 1.0, radio)),
			dir * radio * (largo - 1.0) * 0.55 + Vector3(0.0, y, 0.0))
	return Transform3D(base, pos) * local


static func malla_sombra() -> Mesh:
	return _plano()


static func material_sombra(alpha: float) -> Material:
	return _material(alpha)


static func gradar_entorno(env: Environment) -> Dictionary:
	var previo := {}
	if env == null:
		return previo
	for c in CLAVES_ENTORNO:
		previo[c] = env.get(c)
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.86
	env.tonemap_white = 8.0
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_strength = 0.9
	env.glow_bloom = 0.04
	env.glow_hdr_threshold = 1.3
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.14
	env.adjustment_saturation = 1.12
	return previo


static func restaurar_entorno(env: Environment, previo: Dictionary) -> void:
	if env == null:
		return
	for c in previo:
		env.set(c, previo[c])
