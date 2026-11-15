extends SubViewportContainer


const MarsGlobe := preload("res://interfaz/mars_globe.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")
const Historia := preload("res://historia/historia.gd")
const ColoniaModelo := preload("res://modelos/colonia_modelo.gd")
const Colonia := preload("res://progreso/colonia_estado.gd")


const VISTAS := {
	"principal": {"pos": Vector3(0.6, 1.7, 5.2), "mira": Vector3(-3.4, 2.3, -8.0), "fov": 64.0},
	"piloto": {"pos": Vector3(0.4, 1.5, 3.0), "mira": Vector3(-4.6, 1.5, 0.6), "fov": 58.0},
	"ajustes": {"pos": Vector3(-0.4, 1.5, 3.0), "mira": Vector3(4.6, 1.5, 0.6), "fov": 58.0},
	"creditos": {"pos": Vector3(-1.0, 1.0, 5.6), "mira": Vector3(-1.5, 3.0, -8.0), "fov": 52.0},
	"salir": {"pos": Vector3(0.0, 2.3, 6.5), "mira": Vector3(0.0, 2.0, -8.0), "fov": 66.0},
	"comite": {"pos": Vector3(0.0, 1.5, 2.3), "mira": Vector3(0.0, 1.38, -2.2), "fov": 52.0},
}

const PALETA := [Color(0.35, 0.85, 1.0), Color(1.0, 0.62, 0.22), Color(0.45, 1.0, 0.6)]
const SOL := Vector3(0.7, 0.32, 0.65)

const SHADER_PANTALLA := """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec3 color : source_color = vec3(0.35, 0.85, 1.0);
uniform int modo = 0;
uniform float semilla = 0.0;
uniform float proporcion = 1.6;

float h(vec2 p) {
	return fract(sin(dot(p + semilla, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;
	vec3 c = vec3(0.012, 0.02, 0.03) + color * 0.04;
	// marco fino
	float b = step(uv.x, 0.015) + step(0.985, uv.x) + step(uv.y, 0.025) + step(0.975, uv.y);
	c += color * 0.30 * clamp(b, 0.0, 1.0);

	if (modo == 0) {
		// barras de telemetría
		float n = 22.0;
		float col = floor(uv.x * n);
		float v = 0.5 + 0.45 * sin(t * (0.6 + h(vec2(col, 1.0)) * 1.8) + h(vec2(col, 2.0)) * 6.28);
		float hueco = step(fract(uv.x * n), 0.72);
		float barra = step(1.0 - uv.y, v * 0.85) * hueco;
		float seg = step(fract(uv.y * 14.0), 0.7);
		c += color * barra * seg * 0.85;
	} else if (modo == 1) {
		// radar
		vec2 p = (uv - 0.5) * vec2(proporcion, 1.0);
		float r = length(p);
		float ang = atan(p.y, p.x) / TAU;
		float anillos = smoothstep(0.012, 0.0, abs(fract(r * 5.0) - 0.5) * 0.2 - 0.0) * 0.0;
		anillos = smoothstep(0.02, 0.0, abs(fract(r * 4.0 + 0.0) - 0.0)) * step(r, 0.47);
		float cruz = smoothstep(0.006, 0.0, min(abs(p.x), abs(p.y))) * step(r, 0.47);
		float barrido = fract(ang - t * 0.25);
		float estela = pow(1.0 - barrido, 5.0) * step(r, 0.47);
		vec2 cel = floor((uv + vec2(0.0, 0.0)) * vec2(11.0, 7.0));
		float punto = step(0.93, h(cel)) * step(r, 0.45) * smoothstep(0.35, 0.0, barrido);
		c += color * (anillos * 0.35 + cruz * 0.3 + estela * 0.7 + punto * 1.2);
	} else if (modo == 2) {
		// gráfica de línea sobre cuadrícula
		float rej = smoothstep(0.01, 0.0, abs(fract(uv.x * 12.0) - 0.5) - 0.49) + smoothstep(0.012, 0.0, abs(fract(uv.y * 6.0) - 0.5) - 0.485);
		c += color * rej * 0.12;
		float y1 = 0.5 + 0.22 * sin(uv.x * 9.0 + t * 0.9) + 0.08 * sin(uv.x * 31.0 - t * 2.0);
		float y2 = 0.4 + 0.15 * sin(uv.x * 5.0 - t * 0.5 + semilla);
		c += color * smoothstep(0.016, 0.0, abs(uv.y - y1)) * 1.1;
		c += color * 0.6 * smoothstep(0.012, 0.0, abs(uv.y - y2));
		c += color * 0.07 * step(uv.y, y1);
	} else {
		// líneas de texto que suben
		float fila = floor((uv.y + t * 0.05) * 16.0);
		float dentro = step(fract((uv.y + t * 0.05) * 16.0), 0.55);
		float cel = floor(uv.x * 46.0);
		float largo = 6.0 + 34.0 * h(vec2(fila, 3.0));
		float on = step(0.3, h(vec2(cel, fila))) * step(cel, largo) * step(3.0, cel);
		float marca = step(cel, 1.5) * step(0.5, h(vec2(fila, 9.0)));
		c += color * (on * 0.75 + marca * 0.9) * dentro;
	}

	// líneas de barrido de pantalla y parpadeo suave
	c *= 0.86 + 0.14 * sin(uv.y * 240.0 + t * 3.0);
	c *= 0.94 + 0.06 * sin(t * 37.0 + semilla * 7.0);
	ALBEDO = c;
}
"""

const SHADER_ESTRELLAS := """
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never;

float h(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float ruido(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(h(i), h(i + vec3(1, 0, 0)), f.x), mix(h(i + vec3(0, 1, 0)), h(i + vec3(1, 1, 0)), f.x), f.y),
			mix(mix(h(i + vec3(0, 0, 1)), h(i + vec3(1, 0, 1)), f.x), mix(h(i + vec3(0, 1, 1)), h(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

varying vec3 dir;

void vertex() {
	dir = normalize(VERTEX);
}

void fragment() {
	vec3 d = normalize(dir);
	vec3 c = vec3(0.0);
	// estrellas: celdas 3D con un punto brillante
	for (int k = 0; k < 3; k++) {
		float esc = 60.0 + float(k) * 55.0;
		vec3 q = d * esc;
		vec3 i = floor(q);
		vec3 f = fract(q) - 0.5;
		float a = h(i + float(k) * 7.0);
		if (a > 0.93) {
			float tam = 0.05 + 0.06 * h(i + 3.0);
			float br = smoothstep(tam, 0.0, length(f));
			float tit = 0.7 + 0.3 * sin(TIME * (1.0 + 3.0 * h(i)) + a * 40.0);
			vec3 tono = mix(vec3(0.8, 0.88, 1.0), vec3(1.0, 0.85, 0.7), h(i + 5.0));
			c += tono * br * tit * (0.6 + float(k) * 0.2);
		}
	}
	// vía láctea tenue
	float banda = exp(-pow(d.y * 2.2 + 0.25 * sin(d.x * 3.0), 2.0) * 3.0);
	float nube = ruido(d * 5.0) * 0.6 + ruido(d * 14.0) * 0.4;
	c += vec3(0.30, 0.20, 0.34) * banda * nube * 0.22;
	c += vec3(0.05, 0.08, 0.14) * ruido(d * 3.0) * 0.12;
	ALBEDO = c;
}
"""

var _sub: SubViewport
var _env: Environment
var _cam: Camera3D
var _mundo: Node3D
var _marte: Node3D
var _fobos: MeshInstance3D
var _reloj: Label3D
var _operadores: Array = []
var _vista: String = "principal"
var _pos_obj: Vector3
var _mira_obj: Vector3
var _fov_obj: float = 62.0
var _pos: Vector3
var _mira: Vector3
var _t: float = 0.0
var _tween: Tween
var _raton: Vector2 = Vector2.ZERO
var _comite: Node3D = null
var _comite_figs: Dictionary = {}
var _comite_foco: String = ""
var _maqueta: Node3D = null


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	_sub = SubViewport.new()
	_sub.own_world_3d = true
	_sub.handle_input_locally = false
	add_child(_sub)
	_mundo = Node3D.new()
	_sub.add_child(_mundo)
	_construir_entorno()
	_construir_espacio()
	_construir_sala()
	_construir_pantallas()
	_construir_operadores()
	_construir_luces()
	_cam = Camera3D.new()
	_cam.far = 3000.0
	_cam.near = 0.05
	_cam.current = true
	_mundo.add_child(_cam)
	var v: Dictionary = VISTAS["principal"]
	_pos = v["pos"]
	_mira = v["mira"]
	_pos_obj = _pos
	_mira_obj = _mira
	_fov_obj = float(v["fov"])
	_cam.fov = _fov_obj
	_poner_camara()
	_construir_vineta()
	ajustar_calidad()


func mostrar() -> void:
	_refrescar_maqueta()
	visible = true
	_sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if _tween != null and _tween.is_valid():
		_tween.kill()
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 1.6)


func ocultar(rapido: bool = false) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if rapido or not visible:
		visible = false
		_sub.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.8)
	_tween.tween_callback(func():
		visible = false
		_sub.render_target_update_mode = SubViewport.UPDATE_DISABLED)


func ajustar_calidad() -> void:
	var q := clampi(Ajustes.calidad, 0, 2)
	_sub.msaa_3d = Viewport.MSAA_2X if q == 2 else Viewport.MSAA_DISABLED
	_sub.scaling_3d_scale = [0.6, 0.8, 1.0][q]
	if _env != null:
		_env.glow_enabled = q >= 1


func ir_a(nombre: String) -> void:
	if not VISTAS.has(nombre):
		nombre = "principal"
	if nombre == _vista:
		return
	_vista = nombre
	var v: Dictionary = VISTAS[nombre]
	_pos_obj = v["pos"]
	_mira_obj = v["mira"]
	_fov_obj = float(v["fov"])


func mostrar_comite() -> void:
	if _comite == null:
		_construir_comite()
	_comite.visible = true
	mostrar()
	ir_a("comite")


func ocultar_comite() -> void:
	if _comite != null:
		_comite.visible = false


func foco_comite(jefe: String) -> void:
	_comite_foco = jefe


func _construir_comite() -> void:
	_comite = Node3D.new()
	_mundo.add_child(_comite)
	var madera := _material(Color(0.06, 0.06, 0.075), 0.35, 0.7)
	var ambar := Color(1.0, 0.55, 0.2)

	_caja(Vector3(0.0, 0.92, -1.1), Vector3(6.8, 0.07, 1.15), madera, _comite)
	_caja(Vector3(0.0, 0.96, -0.52), Vector3(6.8, 0.012, 0.03), _material(ambar, 0.5, 0.0, ambar, 2.2), _comite)
	for x: float in [-3.0, 3.0]:
		_caja(Vector3(x, 0.45, -1.1), Vector3(0.12, 0.9, 0.9), madera, _comite)

	var orden := ["JULIO", "REYZER", "KELLY", "GERALD", "DAID"]
	var traje := _material(Color(0.05, 0.055, 0.07), 0.8)
	for i in range(orden.size()):
		var j: String = orden[i]
		var inf := Historia.jefe(j)
		var col: Color = inf.get("color", Color.WHITE)
		var fig := Node3D.new()
		fig.position = Vector3((float(i) - 2.0) * 1.35, 0.0, -2.1 - 0.15 * absf(float(i) - 2.0))
		_comite.add_child(fig)
		_caja(Vector3(0.0, 0.62, 0.0), Vector3(0.2, 0.5, 0.2), traje, fig)
		_caja(Vector3(0.0, 1.16, 0.0), Vector3(0.46, 0.7, 0.26), traje, fig)
		_caja(Vector3(0.0, 1.46, 0.0), Vector3(0.62, 0.13, 0.26), traje, fig)
		var mi := _material(col, 0.4, 0.0, col, 0.8)
		_caja(Vector3(-0.1, 1.28, 0.14), Vector3(0.1, 0.1, 0.02), mi, fig)
		var cab := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = 0.135
		sp.height = 0.27
		cab.mesh = sp
		cab.material_override = _material(Color(0.12, 0.11, 0.12), 0.7)
		cab.position = Vector3(0.0, 1.66, 0.0)
		cab.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fig.add_child(cab)
		var rot := Label3D.new()
		rot.text = "%s  %s" % [j, str(inf.get("cod", ""))]
		rot.font = EstiloUI.fuente_titulo()
		rot.font_size = 34
		rot.pixel_size = 0.0045
		rot.no_depth_test = true
		rot.render_priority = 100
		rot.modulate = col
		rot.shaded = false
		rot.position = Vector3(0.0, 1.95, 0.0)
		rot.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		fig.add_child(rot)
		var luz := SpotLight3D.new()
		luz.position = Vector3(0.0, 3.4, 1.6)
		luz.light_color = Color(1.0, 0.95, 0.88)
		luz.light_energy = 0.0
		luz.spot_range = 6.0
		luz.spot_angle = 22.0
		fig.add_child(luz)
		luz.rotation_degrees = Vector3(-62.0, 0.0, 0.0)
		_comite_figs[j] = {"insignia": mi, "luz": luz, "nodo": fig}


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta

	var k := 1.0 - exp(-2.2 * delta)
	_pos = _pos.lerp(_pos_obj, k)
	_mira = _mira.lerp(_mira_obj, k)
	_cam.fov = lerpf(_cam.fov, _fov_obj, k)
	var vp := get_viewport().get_visible_rect().size
	if vp.x > 0.0 and vp.y > 0.0:
		var m := get_viewport().get_mouse_position() / vp - Vector2(0.5, 0.5)
		_raton = _raton.lerp(m, 1.0 - exp(-3.0 * delta))
	_poner_camara()

	if _marte != null:
		_marte.rotation.y += 0.035 * delta
	if _fobos != null:
		var a := _t * 0.12
		_fobos.position = _marte.position + Vector3(cos(a) * 150.0, 20.0 + sin(a) * 38.0, sin(a) * 150.0)
		_fobos.rotation.y += 0.2 * delta
	if _comite != null and _comite.visible:
		for j in _comite_figs:
			var f: Dictionary = _comite_figs[j]
			var activo: bool = (str(j) == _comite_foco)
			var luz: SpotLight3D = f["luz"]
			luz.light_energy = lerpf(luz.light_energy, 5.0 if activo else 0.0, 1.0 - exp(-5.0 * delta))
			var mi: StandardMaterial3D = f["insignia"]
			mi.emission_energy_multiplier = lerpf(mi.emission_energy_multiplier, 5.0 if activo else 0.8, 1.0 - exp(-6.0 * delta))
			var nodo: Node3D = f["nodo"]
			nodo.scale.y = 1.0 + (0.012 * sin(_t * 2.4) if activo else 0.0)
	for o in _operadores:
		var cabeza: Node3D = o[0]
		cabeza.rotation.y = sin(_t * 0.5 + float(o[1])) * 0.5
		cabeza.rotation.x = sin(_t * 0.37 + float(o[1]) * 2.0) * 0.12
	if _reloj != null:
		var s := int(_t + 4321.0)
		_reloj.text = "T+ %02d:%02d:%02d" % [s / 3600, (s / 60) % 60, s % 60]


func _poner_camara() -> void:
	var resp := Vector3(sin(_t * 0.23) * 0.16, sin(_t * 0.31) * 0.05, sin(_t * 0.17) * 0.28)
	var par := Vector3(_raton.x * 0.5, -_raton.y * 0.22, 0.0)
	_cam.position = _pos + resp + par
	_cam.look_at(_mira + resp * 0.3 + par * 0.6 + Vector3(_raton.x * 0.7, -_raton.y * 0.3, 0.0), Vector3.UP)


func _material(color: Color, rugosidad: float = 0.7, metal: float = 0.0, emision: Color = Color.BLACK, energia: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rugosidad
	m.metallic = metal
	if energia > 0.0:
		m.emission_enabled = true
		m.emission = emision
		m.emission_energy_multiplier = energia
	return m


func _caja(centro: Vector3, tam: Vector3, mat: Material, padre: Node = null) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = tam
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = centro
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(padre if padre != null else _mundo).add_child(mi)
	return mi


func _construir_entorno() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.0, 0.0, 0.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.42, 0.40, 0.50)
	env.ambient_light_energy = 0.95
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.08
	_env = env
	var we := WorldEnvironment.new()
	we.environment = env
	_mundo.add_child(we)


func _construir_espacio() -> void:

	var sh := Shader.new()
	sh.code = SHADER_ESTRELLAS
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var esfera := SphereMesh.new()
	esfera.radius = 1500.0
	esfera.height = 3000.0
	esfera.radial_segments = 48
	esfera.rings = 24
	var cielo := MeshInstance3D.new()
	cielo.mesh = esfera
	cielo.material_override = mat
	cielo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mundo.add_child(cielo)

	_marte = Node3D.new()
	_marte.position = Vector3(34.0, -4.0, -320.0)
	_marte.rotation = Vector3(0.18, 0.0, 0.1)
	_mundo.add_child(_marte)
	var g := MarsGlobe.new()
	g.radio = 85.0
	g.relieve = 0.5
	g.crater_k = 0.3
	_marte.add_child(g)
	g.poner_sol(SOL)

	var pm := SphereMesh.new()
	pm.radius = 5.0
	pm.height = 9.0
	pm.radial_segments = 24
	pm.rings = 12
	_fobos = MeshInstance3D.new()
	_fobos.mesh = pm
	_fobos.scale = Vector3(1.25, 0.9, 1.0)
	_fobos.material_override = _material(Color(0.42, 0.37, 0.34), 1.0)
	_fobos.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mundo.add_child(_fobos)
	var sol := DirectionalLight3D.new()
	sol.light_color = Color(1.0, 0.86, 0.72)
	sol.light_energy = 1.1
	sol.rotation = Basis.looking_at(-SOL.normalized(), Vector3.UP).get_euler()
	sol.shadow_enabled = false
	_mundo.add_child(sol)


func _construir_sala() -> void:
	var pared := _material(Color(0.07, 0.075, 0.09), 0.55, 0.5)
	var oscuro := _material(Color(0.03, 0.032, 0.04), 0.5, 0.6)
	var suelo := _material(Color(0.05, 0.05, 0.06), 0.28, 0.75)
	var alto := 5.2

	_caja(Vector3(0.0, -0.1, 0.0), Vector3(14.0, 0.2, 20.0), suelo)
	_caja(Vector3(0.0, alto + 0.1, 0.0), Vector3(14.0, 0.2, 20.0), oscuro)

	var z := -8.2
	_caja(Vector3(-6.7, alto * 0.5, z), Vector3(0.6, alto, 0.4), pared)
	_caja(Vector3(6.7, alto * 0.5, z), Vector3(0.6, alto, 0.4), pared)
	_caja(Vector3(0.0, 4.7, z), Vector3(14.0, 1.0, 0.4), pared)
	_caja(Vector3(0.0, 0.3, z), Vector3(14.0, 0.7, 0.4), pared)
	for x: float in [-3.2, 0.0, 3.2]:
		_caja(Vector3(x, 2.45, z + 0.05), Vector3(0.13, 3.5, 0.18), oscuro)
	var ambar := Color(1.0, 0.55, 0.2)
	_caja(Vector3(0.0, 0.72, z + 0.18), Vector3(12.4, 0.035, 0.04), _material(ambar, 0.5, 0.0, ambar, 2.4))
	_caja(Vector3(0.0, 4.2, z + 0.18), Vector3(12.4, 0.035, 0.04), _material(ambar, 0.5, 0.0, ambar, 1.6))

	for lado: float in [-1.0, 1.0]:
		_caja(Vector3(7.15 * lado, alto * 0.5, 0.0), Vector3(0.3, alto, 20.0), pared)
		for zz in range(-7, 9, 2):
			_caja(Vector3(6.9 * lado, alto * 0.5, float(zz)), Vector3(0.2, alto, 0.22), oscuro)

		var fr := Color(0.35, 0.8, 1.0) if lado < 0.0 else ambar
		_caja(Vector3(6.97 * lado, 3.9, 0.0), Vector3(0.05, 0.05, 18.0), _material(fr, 0.5, 0.0, fr, 1.8))

	for zz: float in [6.5, 2.5, -1.5, -5.5]:
		_caja(Vector3(0.0, 4.95, zz), Vector3(14.0, 0.3, 0.45), oscuro)
		var luz := Color(1.0, 0.92, 0.82)
		_caja(Vector3(-3.0, 4.78, zz), Vector3(3.2, 0.04, 0.16), _material(luz, 0.5, 0.0, luz, 1.3))
		_caja(Vector3(3.0, 4.78, zz), Vector3(3.2, 0.04, 0.16), _material(luz, 0.5, 0.0, luz, 1.3))

	for x: float in [-1.9, 1.9]:
		var c := Color(0.3, 0.8, 1.0) if x < 0.0 else ambar
		_caja(Vector3(x, 0.012, 0.0), Vector3(0.05, 0.02, 18.0), _material(c, 0.5, 0.0, c, 1.4))

	var tit := Label3D.new()
	tit.text = Idioma.t("SPARTANS II  ·  CENTRO DE CONTROL DE MISIÓN")
	tit.font = EstiloUI.fuente_titulo()
	tit.font_size = 64
	tit.pixel_size = 0.0058
	tit.modulate = Color(1.0, 0.62, 0.25)
	tit.outline_size = 0
	tit.shaded = false
	tit.position = Vector3(0.0, 4.82, -7.95)
	_mundo.add_child(tit)
	_reloj = Label3D.new()
	_reloj.text = "T+ 00:00:00"
	_reloj.font = EstiloUI.fuente_titulo()
	_reloj.font_size = 56
	_reloj.pixel_size = 0.0058
	_reloj.modulate = Color(0.45, 0.9, 1.0)
	_reloj.shaded = false
	_reloj.position = Vector3(0.0, 4.4, -7.95)
	_mundo.add_child(_reloj)


func _crear_pantalla(centro: Vector3, tam: Vector2, giro_y: float, modo: int, color: Color, semilla: float) -> void:
	var sh := Shader.new()
	sh.code = SHADER_PANTALLA
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("color", color)
	mat.set_shader_parameter("modo", modo)
	mat.set_shader_parameter("semilla", semilla)
	mat.set_shader_parameter("proporcion", tam.x / tam.y)
	var q := QuadMesh.new()
	q.size = tam
	var mi := MeshInstance3D.new()
	mi.mesh = q
	mi.material_override = mat
	mi.position = centro
	mi.rotation.y = giro_y
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mundo.add_child(mi)

	var marco := _caja(Vector3.ZERO, Vector3(tam.x + 0.14, tam.y + 0.14, 0.05), _material(Color(0.02, 0.02, 0.025), 0.6, 0.5))
	marco.position = centro - Vector3(sin(giro_y), 0.0, cos(giro_y)) * 0.04
	marco.rotation.y = giro_y


func _construir_pantallas() -> void:
	var madera := _material(Color(0.045, 0.048, 0.06), 0.45, 0.6)
	var n := 0
	for lado: float in [-1.0, 1.0]:
		var giro := (PI * 0.5 - 0.35) * -lado
		for i in range(5):
			var z := 4.6 - float(i) * 2.6

			_caja(Vector3(5.0 * lado, 0.45, z), Vector3(1.6, 0.9, 2.1), madera)
			_caja(Vector3(4.2 * lado, 0.92, z), Vector3(1.0, 0.07, 2.1), _material(Color(0.07, 0.075, 0.09), 0.4, 0.5))

			var c1: Color = PALETA[n % 3]
			var c2: Color = PALETA[(n + 1) % 3]
			_crear_pantalla(Vector3(5.1 * lado, 1.55, z - 0.5), Vector2(0.95, 0.62), giro, n % 4, c1, float(n) * 3.7)
			_crear_pantalla(Vector3(5.1 * lado, 1.55, z + 0.5), Vector2(0.95, 0.62), giro, (n + 2) % 4, c2, float(n) * 5.3 + 1.0)
			_crear_pantalla(Vector3(5.3 * lado, 2.28, z), Vector2(1.9, 0.5), giro, 3, c1, float(n) * 1.9)
			n += 1

	_crear_pantalla(Vector3(-6.8, 3.0, -4.0), Vector2(3.4, 1.6), PI * 0.5 - 0.2, 2, PALETA[0], 4.0)
	_crear_pantalla(Vector3(6.8, 3.0, -4.0), Vector2(3.4, 1.6), -PI * 0.5 + 0.2, 1, PALETA[1], 9.0)


func _construir_operadores() -> void:
	var tela := _material(Color(0.045, 0.05, 0.065), 0.9)
	var n := 0
	for lado: float in [-1.0, 1.0]:
		for i in range(5):
			if (i + int(lado)) % 3 == 0:
				continue
			var z := 4.6 - float(i) * 2.6
			var x := 3.3 * lado
			var op := Node3D.new()
			op.position = Vector3(x, 0.0, z + (0.2 if i % 2 == 0 else -0.2))
			_mundo.add_child(op)
			_caja(Vector3(0.0, 0.5, 0.0), Vector3(0.5, 0.07, 0.5), tela, op)
			_caja(Vector3(0.28 * lado, 0.78, 0.0), Vector3(0.07, 0.6, 0.46), tela, op)
			_caja(Vector3(0.0, 0.18, 0.0), Vector3(0.06, 0.36, 0.06), tela, op)
			_caja(Vector3(0.05 * lado, 0.88, 0.0), Vector3(0.28, 0.58, 0.46), tela, op)
			var cab := Node3D.new()
			cab.position = Vector3(-0.0, 1.32, 0.0)
			op.add_child(cab)
			var sph := SphereMesh.new()
			sph.radius = 0.12
			sph.height = 0.25
			sph.radial_segments = 16
			sph.rings = 8
			var mc := MeshInstance3D.new()
			mc.mesh = sph
			mc.material_override = tela
			mc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			cab.add_child(mc)

			_caja(Vector3(0.0, 0.03, 0.12), Vector3(0.04, 0.05, 0.04), _material(Color(0.2, 0.7, 1.0), 0.5, 0.0, Color(0.2, 0.7, 1.0), 2.0), cab)
			_operadores.append([cab, float(n) * 1.7])
			n += 1


func _construir_luces() -> void:
	var l := [
		[Vector3(-2.5, 2.4, 2.0), Color(0.4, 0.8, 1.0), 3.0, 11.0],
		[Vector3(2.5, 2.4, 2.0), Color(1.0, 0.6, 0.3), 3.0, 11.0],
		[Vector3(-2.5, 2.4, -4.5), Color(0.4, 0.8, 1.0), 2.6, 11.0],
		[Vector3(2.5, 2.4, -4.5), Color(1.0, 0.6, 0.3), 2.6, 11.0],
		[Vector3(0.0, 3.0, -6.0), Color(1.0, 0.55, 0.35), 2.0, 12.0],
	]
	for e in l:
		var o := OmniLight3D.new()
		o.position = e[0]
		o.light_color = e[1]
		o.light_energy = e[2]
		o.omni_range = e[3]
		o.shadow_enabled = false
		_mundo.add_child(o)


func _construir_vineta() -> void:
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.0))
	g.set_color(1, Color(0, 0, 0, 0.75))
	g.set_offset(0, 0.55)
	g.set_offset(1, 1.0)
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)


func _refrescar_maqueta() -> void:
	if _maqueta != null and is_instance_valid(_maqueta):
		_maqueta.queue_free()
	_maqueta = Node3D.new()
	_maqueta.name = "MaquetaColonia"
	_maqueta.position = Vector3(1.9, 0.0, -0.9)
	_mundo.add_child(_maqueta)
	var m_ped := _material(Color(0.1, 0.11, 0.14), 0.5, 0.4)
	var m_acento := _material(Color(0.99, 0.24, 0.13), 0.5, 0.0, Color(0.99, 0.24, 0.13), 1.6)
	var m_suelo := _material(Color(0.62, 0.34, 0.22), 0.9)
	var m_hangar := _material(Color(0.88, 0.9, 0.93), 0.5)
	var ped := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.05
	cm.bottom_radius = 1.15
	cm.height = 0.95
	ped.mesh = cm
	ped.material_override = m_ped
	ped.position = Vector3(0, 0.475, 0)
	_maqueta.add_child(ped)
	for par in [[1.07, 0.04, 0.97, m_acento], [0.98, 0.04, 1.0, m_suelo]]:
		var d := MeshInstance3D.new()
		var dm := CylinderMesh.new()
		dm.top_radius = float(par[0])
		dm.bottom_radius = float(par[0])
		dm.height = float(par[1])
		d.mesh = dm
		d.material_override = par[3]
		d.position = Vector3(0, float(par[2]), 0)
		_maqueta.add_child(d)
	var esc := 0.04
	_caja(Vector3(0, 1.02 + 4.6 * 0.5 * esc, 0), Vector3(9.0, 4.6, 11.0) * esc, m_hangar, _maqueta)
	var col := ColoniaModelo.new()
	col.position = Vector3(0, 1.02, 0)
	col.scale = Vector3.ONE * esc
	_maqueta.add_child(col)
	col.construir(false)
	var et := Label3D.new()
	et.text = Idioma.t("COLONIA  ·  %d / 12" % Colonia.niveles_total() if Colonia.niveles_total() > 0 else "COLONIA  ·  sin construir")
	et.font_size = 48
	et.pixel_size = 0.0024
	et.modulate = Color(1.0, 0.7, 0.45)
	et.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	et.no_depth_test = false
	et.position = Vector3(0, 1.62, 0)
	_maqueta.add_child(et)
