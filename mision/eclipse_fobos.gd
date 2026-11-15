extends Node3D


const TAM_FOBOS := 0.040
const TAM_SOL := 0.026
const RECORRIDO := 0.16
const MITAD_CUADRO := 0.30

const SHADER := """
shader_type spatial;
render_mode unshaded, depth_draw_never, fog_disabled, blend_mix, cull_disabled;

uniform vec2 centro = vec2(0.0);      // dónde está Fobos respecto al Sol, en radianes
uniform float mitad = 0.30;
uniform float r_fobos = 0.045;
uniform float r_sol = 0.026;
uniform float cobertura = 0.0;
uniform float giro = 0.0;
uniform float aparece = 1.0;

void fragment() {
	vec2 q = (UV - 0.5) * 2.0 * mitad;                 // radianes desde el centro del Sol
	q.y = -q.y;
	float d = length(q);
	// el Sol: disco brillante con un resplandor suave
	float disco = 1.0 - smoothstep(r_sol * 0.88, r_sol, d);
	float brillo = exp(-max(d - r_sol, 0.0) / (r_sol * 2.2)) * 0.55;
	float a_sol = clamp(max(disco, brillo * (1.0 - cobertura * 0.6)), 0.0, 1.0);
	vec3 c_sol = mix(vec3(1.0, 0.72, 0.42), vec3(1.0, 0.97, 0.88), disco);
	// Fobos: una silueta alargada y oscura
	vec2 p = q - centro;
	float cg = cos(giro);
	float sg = sin(giro);
	p = vec2(cg * p.x - sg * p.y, sg * p.x + cg * p.y) / r_fobos;
	float rr = sqrt(p.x * p.x * 0.62 + p.y * p.y);
	float a_f = 1.0 - smoothstep(0.93, 1.0, rr);
	float crat = 0.5 + 0.25 * sin(p.x * 11.0 + 1.0) * sin(p.y * 9.0 - 2.0) + 0.25 * sin(p.x * 23.0 + p.y * 19.0);
	float lado = clamp(0.55 - 0.45 * p.x + 0.25 * p.y, 0.0, 1.0);          // el lado que mira al Sol se ve un poco más claro
	vec3 c_f = vec3(0.045, 0.036, 0.034) + vec3(0.075, 0.06, 0.05) * crat * lado;
	vec3 col = c_sol * a_sol;
	float a = a_sol;
	col = col * (1.0 - a_f) + c_f * a_f;
	a = a * (1.0 - a_f) + a_f;
	// halo violeta que late cuando Fobos tapa el Sol
	float pulso = pow(max(0.0, sin(TIME * 3.1416)), 4.0);
	float halo = exp(-max(rr - 1.0, 0.0) * 5.0) * step(1.0, rr) * cobertura * (0.35 + 0.65 * pulso);
	col += vec3(0.62, 0.38, 1.0) * halo;
	a = clamp(a + halo * 0.85, 0.0, 1.0);
	ALBEDO = col / max(a, 0.001);
	ALPHA = a * aparece;
}
"""

var mision: Node3D = null
var activo_ecl: bool = false
var cobertura: float = 0.0
var _mat: ShaderMaterial
var _malla: MeshInstance3D
var _dir_sol: Vector3 = Vector3.UP
var _desp: Vector3 = Vector3.ZERO
var _prog: float = 0.0


func configurar(m: Node3D) -> void:
	mision = m
	_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER
	_mat.shader = sh
	_mat.render_priority = -40
	var q := QuadMesh.new()
	q.size = Vector2(1.0, 1.0)
	q.custom_aabb = AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	_malla = MeshInstance3D.new()
	_malla.mesh = q
	_malla.material_override = _mat
	_malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_malla.extra_cull_margin = 16384.0
	add_child(_malla)
	visible = false


func mover(p: float, sol: Vector3, arriba: Vector3) -> float:
	activo_ecl = true
	_prog = p
	_dir_sol = sol.normalized()
	var eje := _dir_sol.cross(arriba)
	if eje.length() < 0.01:
		eje = _dir_sol.cross(Vector3.RIGHT)
	eje = eje.normalized().rotated(_dir_sol, 0.35)
	var sep := (p - 0.5) * 2.0 * RECORRIDO
	_desp = _dir_sol.rotated(eje, sep) - _dir_sol
	cobertura = 1.0 - smoothstep(0.0, 0.11, absf(sep))
	return cobertura


func apagar() -> void:
	activo_ecl = false
	cobertura = 0.0
	visible = false


func _process(_delta: float) -> void:
	if mision == null or not activo_ecl or not mision.activo:
		visible = false
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		visible = false
		return
	var padre := get_parent() as Node3D
	var base := padre.global_transform.basis.orthonormalized()
	var radio: float = minf(cam.far * 0.8, 2400.0)
	var dir_mundo: Vector3 = (base * _dir_sol).normalized()
	var arriba_ref := Vector3.UP if absf(dir_mundo.dot(Vector3.UP)) < 0.98 else Vector3.RIGHT
	var orient := Basis.looking_at(dir_mundo, arriba_ref)
	var lado: float = radio * MITAD_CUADRO * 2.0
	global_transform = Transform3D(orient * Basis.from_scale(Vector3(lado, lado, lado)), cam.global_position + dir_mundo * radio)

	var d_mundo := base * _desp
	var cx := d_mundo.dot(orient.x)
	var cy := d_mundo.dot(orient.y)
	var entra := smoothstep(0.0, 0.08, _prog) * (1.0 - smoothstep(0.92, 1.0, _prog))
	_mat.set_shader_parameter("centro", Vector2(cx, cy))
	_mat.set_shader_parameter("mitad", MITAD_CUADRO)
	_mat.set_shader_parameter("r_fobos", TAM_FOBOS)
	_mat.set_shader_parameter("r_sol", TAM_SOL)
	_mat.set_shader_parameter("cobertura", cobertura)
	_mat.set_shader_parameter("giro", 0.4 + _prog * 1.2)
	_mat.set_shader_parameter("aparece", maxf(entra, 0.0) if _prog < 0.08 or _prog > 0.92 else 1.0)
	visible = true
