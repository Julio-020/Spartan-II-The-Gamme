extends Node3D


const SHADER_REMOLINO := """
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, fog_disabled;

uniform sampler2D ruido : repeat_enable, filter_linear;
uniform vec4 color : source_color = vec4(0.78, 0.55, 0.38, 1.0);
uniform float opacidad = 0.55;
varying float hy;

void vertex() {
	hy = clamp(VERTEX.y + 0.5, 0.0, 1.0);
	float giro = TIME * 1.2 + hy * 5.0;
	VERTEX.x += sin(giro) * 0.10 * hy;
	VERTEX.z += cos(giro * 0.9) * 0.10 * hy;
}

void fragment() {
	// dos capas de polvo que giran en sentidos opuestos: da volumen al embudo
	vec2 uv1 = vec2(UV.x * 5.0 + TIME * 0.22 + hy * 1.2, hy * 1.6 - TIME * 0.7);
	vec2 uv2 = vec2(UV.x * 9.0 - TIME * 0.35 - hy * 2.0, hy * 2.2 - TIME * 1.1);
	float n = texture(ruido, uv1).r * 0.6 + texture(ruido, uv2).r * 0.4;
	float a = smoothstep(0.32, 0.78, n);
	float base = smoothstep(0.0, 0.05, hy);
	float cima = 1.0 - smoothstep(0.5, 1.0, hy);
	// bordes difusos: el embudo es más transparente donde la superficie se ve de canto
	float suave = pow(clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0), 0.7);
	ALBEDO = color.rgb * (0.6 + 0.55 * n) * mix(0.72, 1.0, hy);
	ALPHA = a * base * cima * suave * opacidad;
}
"""


const SHADER_MURO := """
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, fog_disabled;

uniform sampler2D ruido : repeat_enable, filter_linear;
uniform vec4 color_base : source_color = vec4(0.42, 0.25, 0.15, 1.0);
uniform vec4 color_cima : source_color = vec4(0.88, 0.62, 0.40, 1.0);
uniform vec2 dir_muro = vec2(1.0, 0.0);
uniform float abertura = 0.4;
uniform float opacidad = 0.0;
varying vec3 pos_obj;
varying float hy;

void vertex() {
	pos_obj = VERTEX;
	hy = clamp(VERTEX.y + 0.5, 0.0, 1.0);
}

void fragment() {
	vec2 d = normalize(pos_obj.xz + vec2(0.00001));
	float arco = smoothstep(abertura - 0.4, abertura, dot(d, dir_muro));
	float vuelta = atan(pos_obj.z, pos_obj.x) / 6.28318 * 8.0;
	vec2 uv1 = vec2(vuelta + TIME * 0.03, hy * 1.3 - TIME * 0.06);
	vec2 uv2 = vec2(vuelta * 2.3 - TIME * 0.02, hy * 2.8 - TIME * 0.16);
	float forma = texture(ruido, uv1).r * 0.62 + texture(ruido, uv2).r * 0.38;
	// opaco abajo, se deshace en jirones arriba
	float tope = 0.42 + 0.52 * forma;
	float a = smoothstep(tope, tope - 0.24, hy) * smoothstep(0.0, 0.04, hy);
	a *= 0.5 + 0.7 * forma;
	vec3 col = mix(color_base.rgb, color_cima.rgb, smoothstep(0.05, 0.95, hy + 0.35 * (forma - 0.5)));
	ALBEDO = col * (0.8 + 0.3 * forma);
	ALPHA = clamp(a * arco * opacidad, 0.0, 1.0);
}
"""

var mision: Node3D = null
var env: Environment = null
var k: float = 0.1
var calidad: int = 2

var _amb: Dictionary = {}
var _dens_niebla: float = 0.0
var _color_niebla: Color = Color(0.78, 0.55, 0.38)
var _guardado: Dictionary = {}
var _fog_activa: bool = false
var _polvo_aire: CPUParticles3D
var _polvo_ruedas: CPUParticles3D
var _remolinos: Array[Dictionary] = []
var _mat_remolino: ShaderMaterial
var _t: float = 0.0
var _rng := RandomNumberGenerator.new()
var viento_actual: float = 0.5
var luz_f: float = 1.0
var tormenta: float = 0.0
var muro_obj: float = 0.0
var remolino_prox: float = 0.0

var _muro: MeshInstance3D
var _mat_muro: ShaderMaterial
var _muro_f: float = 0.0
var _muro_p: Vector3 = Vector3.ZERO
var _muro_vivo: bool = false
var _polvo_alfa0: float = 0.3


func configurar(m: Node3D, entorno: Environment, escala: float, amb: Dictionary, cal: int, semilla: int) -> void:
	mision = m
	env = entorno
	k = escala
	_amb = amb
	calidad = cal
	_rng.seed = semilla * 31 + 7
	var niebla := clampf(float(amb.get("niebla", 0.3)), 0.0, 1.0)
	var polvo := clampf(float(amb.get("polvo", 0.5)), 0.0, 1.0)
	_dens_niebla = lerpf(0.0015, 0.05, niebla) + polvo * 0.003

	_color_niebla = Color(0.86, 0.80, 0.76).lerp(Color(0.80, 0.54, 0.34), polvo)


func _ready() -> void:
	_guardar_entorno()
	_crear_polvo_aire()
	_crear_polvo_ruedas()
	_crear_remolinos()
	_crear_muro()


func _exit_tree() -> void:
	restaurar_entorno()


func _guardar_entorno() -> void:
	if env == null:
		return
	_guardado = {
		"fog_enabled": env.fog_enabled,
		"fog_density": env.fog_density,
		"fog_light_color": env.fog_light_color,
		"fog_light_energy": env.fog_light_energy,
		"fog_sun_scatter": env.fog_sun_scatter,
		"fog_aerial_perspective": env.fog_aerial_perspective,
		"fog_sky_affect": env.fog_sky_affect,
		"ambient_light_energy": env.ambient_light_energy,
	}


func restaurar_entorno() -> void:
	if env == null or _guardado.is_empty():
		return
	for clave in _guardado:
		env.set(clave, _guardado[clave])
	_fog_activa = false


func _material_polvo(color: Color) -> StandardMaterial3D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = tex
	m.albedo_color = color
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _crear_polvo_aire() -> void:
	if calidad <= 0:
		return
	var polvo := clampf(float(_amb.get("polvo", 0.5)), 0.0, 1.0)
	var p := CPUParticles3D.new()
	p.amount = int((140.0 + 260.0 * polvo) * (1.0 if calidad >= 2 else 0.5))
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(3.0, 0.5, 3.0)
	p.direction = Vector3(1.0, 0.05, 0.2)
	p.spread = 30.0
	p.initial_velocity_min = 0.10 + 0.10 * float(_amb.get("viento", 0.5))
	p.initial_velocity_max = 0.30 + 0.30 * float(_amb.get("viento", 0.5))
	p.gravity = Vector3.ZERO
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.6
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.05)
	p.mesh = q
	_polvo_alfa0 = 0.22 + 0.2 * polvo
	p.material_override = _material_polvo(Color(_color_niebla.r, _color_niebla.g, _color_niebla.b, _polvo_alfa0))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(p)
	_polvo_aire = p


func _crear_polvo_ruedas() -> void:
	if calidad <= 0:
		return
	var p := CPUParticles3D.new()
	p.amount = 40
	p.lifetime = 1.6
	p.local_coords = false
	p.emitting = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.05
	p.direction = Vector3.UP
	p.spread = 70.0
	p.initial_velocity_min = 0.03
	p.initial_velocity_max = 0.10
	p.gravity = Vector3.ZERO
	p.damping_min = 0.04
	p.damping_max = 0.1
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.8
	var q := QuadMesh.new()
	q.size = Vector2(0.045, 0.045)
	p.mesh = q
	p.material_override = _material_polvo(Color(0.82, 0.6, 0.42, 0.32))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var c := Gradient.new()
	c.colors = PackedColorArray([Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.0)])
	c.offsets = PackedFloat32Array([0.0, 1.0])
	p.color_ramp = c
	add_child(p)
	_polvo_ruedas = p


func _crear_remolinos() -> void:
	var n := int(_amb.get("remolinos", 0))
	if n <= 0 or calidad <= 0:
		return
	var fn := FastNoiseLite.new()
	fn.seed = 77
	fn.frequency = 0.04
	fn.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.noise = fn
	tex.width = 256
	tex.height = 256
	tex.seamless = true
	var sh := Shader.new()
	sh.code = SHADER_REMOLINO
	_mat_remolino = ShaderMaterial.new()
	_mat_remolino.shader = sh
	_mat_remolino.set_shader_parameter("ruido", tex)
	_mat_remolino.set_shader_parameter("color", Color(_color_niebla.r, _color_niebla.g, _color_niebla.b, 1.0).lightened(0.05))
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 0.26
	cm.height = 1.0
	cm.radial_segments = 28
	cm.rings = 16
	for i in range(n):
		var mi := MeshInstance3D.new()
		mi.mesh = cm
		mi.material_override = _mat_remolino
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.custom_aabb = AABB(Vector3(-2.0, -1.0, -2.0), Vector3(4.0, 3.0, 4.0))
		mision.add_child(mi)
		var d := {"nodo": mi, "dir": mision.dir_lejana(_rng.randf_range(60.0, 220.0), _rng.randf() * TAU),
				"rumbo": _rng.randf() * TAU, "vel": _rng.randf_range(2.0, 4.0),
				"alto": _rng.randf_range(30.0, 55.0), "radio": _rng.randf_range(3.5, 6.5)}
		_remolinos.append(d)
		_colocar_remolino(d)


func _colocar_remolino(d: Dictionary) -> void:
	var dir: Vector3 = d["dir"]
	var mi: MeshInstance3D = d["nodo"]
	var alto: float = d["alto"] * k
	var radio: float = d["radio"] * k
	var b: Basis = mision.base_en(dir) * Basis.from_scale(Vector3(radio * 2.0, alto, radio * 2.0))
	mi.transform = Transform3D(b, mision.punto_suelo(dir) + dir * (alto * 0.5))


func _crear_muro() -> void:
	if calidad <= 0:
		return
	var fn := FastNoiseLite.new()
	fn.seed = 91
	fn.frequency = 0.035
	fn.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.noise = fn
	tex.width = 256
	tex.height = 256
	tex.seamless = true
	var sh := Shader.new()
	sh.code = SHADER_MURO
	_mat_muro = ShaderMaterial.new()
	_mat_muro.shader = sh
	_mat_muro.set_shader_parameter("ruido", tex)
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 1.0
	cm.height = 1.0
	cm.radial_segments = 64
	cm.rings = 1
	cm.cap_top = false
	cm.cap_bottom = false
	_muro = MeshInstance3D.new()
	_muro.mesh = cm
	_muro.material_override = _mat_muro
	_muro.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_muro.custom_aabb = AABB(Vector3(-2.0, -2.0, -2.0), Vector3(4.0, 4.0, 4.0))
	_muro.visible = false
	mision.add_child(_muro)


func _actualizar_muro(delta: float, up: Vector3) -> void:
	if _mat_muro == null:
		return
	_muro_f = move_toward(_muro_f, muro_obj, delta * (1.0 / 12.0 if muro_obj > _muro_f else 1.0 / 6.0))
	if _muro_f < 0.01:
		_muro.visible = false
		_muro_vivo = false
		return
	if not _muro_vivo:
		_muro_vivo = true

		var rumbo: Vector3 = mision.fwd_robot().rotated(up, _rng.randf_range(-0.95, 0.95))
		_muro_p = mision.mover_dir(up, rumbo, 220.0 * k)
	var e := smoothstep(0.0, 1.0, _muro_f)
	var radio := lerpf(230.0, 28.0, e) * k
	var alto := 140.0 * k
	var b: Basis = mision.base_en(up)
	var hacia := _muro_p - up * _muro_p.dot(up)
	hacia = hacia.normalized() if hacia.length() > 0.0001 else b.x
	var loc := b.transposed() * hacia
	var d2 := Vector2(loc.x, loc.z)
	d2 = d2.normalized() if d2.length() > 0.0001 else Vector2(1.0, 0.0)
	var ancho := smoothstep(0.55, 0.9, _muro_f)
	var op := 0.95 * smoothstep(0.0, 0.25, _muro_f) * (1.0 - smoothstep(0.82, 1.0, _muro_f))
	var luz := lerpf(0.25, 1.0, luz_f)
	_mat_muro.set_shader_parameter("dir_muro", d2)
	_mat_muro.set_shader_parameter("abertura", lerpf(0.5, -1.0, ancho))
	_mat_muro.set_shader_parameter("opacidad", op)
	_mat_muro.set_shader_parameter("color_base", Color(0.42 * luz, 0.25 * luz, 0.15 * luz))
	_mat_muro.set_shader_parameter("color_cima", Color(0.88 * luz, 0.62 * luz, 0.40 * luz))
	_muro.transform = Transform3D(b * Basis.from_scale(Vector3(radio, alto, radio)),
			mision.punto_suelo(up) + up * (alto * 0.5 - 14.0 * k))
	_muro.visible = op > 0.01


func actualizar(delta: float, pos_robot: Vector3, up: Vector3, vel: float, alt_cam: float, dentro: float) -> void:
	_t += delta
	var pos_cam := pos_robot

	var viento := float(_amb.get("viento", 0.5))
	viento_actual = clampf(viento * (0.75 + 0.35 * sin(_t * 0.31) * sin(_t * 0.11 + 1.0)) + 0.1 * sin(_t * 0.9), 0.0, 1.0)
	viento_actual = clampf(viento_actual + 0.55 * tormenta, 0.0, 1.0)


	if env != null:
		var f := 1.0 - smoothstep(3.0, 60.0, alt_cam)
		if f > 0.01:
			if not _fog_activa:
				_fog_activa = true
				env.fog_enabled = true
				env.fog_light_color = _color_niebla
				env.fog_light_energy = 1.0
				env.fog_sun_scatter = 0.12
				env.fog_aerial_perspective = 0.45
				env.fog_sky_affect = 0.15
			env.fog_density = _dens_niebla * f * (1.0 + 0.2 * sin(_t * 0.2)) * (1.0 + 0.8 * dentro) * (1.0 + 14.0 * tormenta * (1.0 - dentro))
			env.fog_light_color = _color_niebla.lerp(Color(0.74, 0.45, 0.27), tormenta)
			env.fog_light_energy = lerpf(1.0, 0.1, dentro) * lerpf(0.1, 1.0, luz_f)
		elif _fog_activa:
			env.fog_density = 0.0
			env.fog_enabled = false
			_fog_activa = false


	if env != null and _guardado.has("ambient_light_energy"):
		env.ambient_light_energy = float(_guardado["ambient_light_energy"]) * lerpf(1.0, 0.3, dentro) * lerpf(0.65, 1.0, luz_f)


	if _polvo_aire != null:
		var b: Basis = mision.base_en(up)
		_polvo_aire.global_transform = Transform3D(
				mision.global_transform.basis * b,
				mision.to_global(pos_cam + up * (4.0 * k)))
		_polvo_aire.direction = Vector3(1.0, 0.05, 0.25)
		_polvo_aire.initial_velocity_max = (0.15 + 0.5 * viento_actual)
		var mp := _polvo_aire.material_override as StandardMaterial3D
		if mp != null:
			var c := mp.albedo_color
			mp.albedo_color = Color(c.r, c.g, c.b, _polvo_alfa0 + 0.3 * tormenta)


	if _polvo_ruedas != null:
		_polvo_ruedas.emitting = absf(vel) > 0.25
		var b2: Basis = mision.base_en(up)
		_polvo_ruedas.global_transform = Transform3D(mision.global_transform.basis * b2,
				mision.to_global(mision.pos_robot_local() - mision.fwd_robot() * (1.3 * k) + up * (0.15 * k)))
		_polvo_ruedas.initial_velocity_max = 0.05 + 0.09 * absf(vel)

	_actualizar_muro(delta, up)


	var d_min := 9999.0
	for d in _remolinos:
		var dir: Vector3 = d["dir"]
		var rumbo: float = d["rumbo"] + _rng.randf_range(-0.4, 0.4) * delta
		d["rumbo"] = rumbo
		var tang: Vector3 = mision.tangente_en(dir, rumbo)
		d["dir"] = mision.mover_dir(dir, tang, float(d["vel"]) * k * delta)
		var dist_r: float = mision.distancia_gm(d["dir"], up)
		if dist_r > 260.0:
			d["dir"] = mision.dir_lejana(_rng.randf_range(140.0, 220.0), _rng.randf() * TAU)
		d_min = minf(d_min, dist_r)
		_colocar_remolino(d)
	remolino_prox = clampf(1.0 - (d_min - 8.0) / 70.0, 0.0, 1.0)
