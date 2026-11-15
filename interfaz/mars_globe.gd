extends Node3D


const FACTOR_HALO := 1.045

var radio: float = 3398.5
var relieve: float = 40.0

var crater_k: float = 1.0
var textura: Texture2D = null

var _mat_globo: ShaderMaterial
var _mat_halo: ShaderMaterial

const SHADER_GLOBO := """
shader_type spatial;
render_mode unshaded;

uniform vec3 sun_dir = vec3(0.55, 0.35, 0.75);
uniform float relieve = 40.0;
uniform float crater_k = 1.0;
uniform bool usar_textura = false;
uniform sampler2D tex_marte : source_color, filter_linear_mipmap, repeat_enable;

varying vec3 npos;

float hash13(vec3 p) {
	vec3 q = 50.0 * fract(p * 0.3183099 + vec3(0.71, 0.113, 0.419));
	return fract(q.x * q.y * q.z * (q.x + q.y + q.z));
}

vec3 hash33(vec3 p) {
	vec3 q = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
			dot(p, vec3(269.5, 183.3, 246.1)),
			dot(p, vec3(113.5, 271.9, 124.6)));
	return fract(sin(q) * 43758.5453123);
}

float noise3(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash13(i);
	float b = hash13(i + vec3(1.0, 0.0, 0.0));
	float c = hash13(i + vec3(0.0, 1.0, 0.0));
	float d = hash13(i + vec3(1.0, 1.0, 0.0));
	float e = hash13(i + vec3(0.0, 0.0, 1.0));
	float g = hash13(i + vec3(1.0, 0.0, 1.0));
	float h = hash13(i + vec3(0.0, 1.0, 1.0));
	float k = hash13(i + vec3(1.0, 1.0, 1.0));
	return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
			mix(mix(e, g, f.x), mix(h, k, f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float a = 0.5;
	float s = 0.0;
	for (int i = 0; i < 5; i++) {
		s += a * noise3(p);
		p = p * 2.03 + vec3(1.7, 9.2, 3.1);
		a *= 0.5;
	}
	return s;
}

// Cráteres en 3D (sin costuras ni deformación en los polos).
// Negativo dentro del cráter, positivo en el borde.
float crateres(vec3 p, float umbral) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	float h = 0.0;
	for (int z = -1; z <= 1; z++) {
		for (int y = -1; y <= 1; y++) {
			for (int x = -1; x <= 1; x++) {
				vec3 g = vec3(float(x), float(y), float(z));
				vec3 o = hash33(i + g);
				if (o.x > umbral) {
					vec3 c = g + 0.25 + 0.5 * o;
					float rad = 0.16 + 0.30 * o.y;
					float d = length(f - c) / rad;
					float cuenco = d < 1.0 ? -(1.0 - d * d) : 0.0;
					float t = (d - 1.0) * 5.0;
					float borde = exp(-t * t) * 0.6;
					h += cuenco * 0.9 + borde;
				}
			}
		}
	}
	return h;
}

// Bump mapping con derivadas de pantalla (una sola evaluación de altura).
vec3 perturbar(vec3 N, vec3 P, float h) {
	vec3 dpdx = dFdx(P);
	vec3 dpdy = dFdy(P);
	float dhdx = dFdx(h);
	float dhdy = dFdy(h);
	vec3 r1 = cross(dpdy, N);
	vec3 r2 = cross(N, dpdx);
	float det = dot(dpdx, r1);
	vec3 grad = sign(det) * (dhdx * r1 + dhdy * r2);
	vec3 v = abs(det) * N - grad;
	float l = length(v);
	if (l < 0.00000001) {
		return N;
	}
	return v / l;
}

vec3 lin(vec3 c) {
	return pow(c, vec3(2.2));
}

void vertex() {
	npos = normalize(VERTEX);
}

void fragment() {
	vec3 p = normalize(npos);

	float cg = 0.0;
	float cp = 0.0;
	if (!usar_textura) {
		cg = crateres(p * 4.0, 0.80);
		cp = crateres(p * 14.0 + vec3(3.1, 7.7, 1.3), 0.70);
		cg *= crater_k;
		cp *= crater_k;
	}

	vec3 albedo;
	float casq = 0.0;

	if (usar_textura) {
		float u = atan(p.x, p.z) / TAU + 0.5;
		float v = acos(clamp(p.y, -1.0, 1.0)) / PI;
		albedo = texture(tex_marte, vec2(u, v)).rgb;
	} else {
		float g1 = fbm(p * 1.7 + vec3(4.0, 1.0, 7.0));
		float g2 = fbm(p * 5.0 + vec3(9.0, 2.0, 3.0));
		float g3 = fbm(p * 22.0);

		vec3 c_claro = lin(vec3(0.80, 0.50, 0.29));    // polvo brillante
		vec3 c_oxido = lin(vec3(0.62, 0.30, 0.15));    // óxido de hierro
		vec3 c_oscuro = lin(vec3(0.24, 0.15, 0.12));   // basalto

		// Regiones oscuras: más hacia el ecuador y el sur, como en Marte
		float oscuro = smoothstep(0.47, 0.60, g1) * (1.0 - smoothstep(0.15, 0.75, p.y));
		float t = smoothstep(0.32, 0.72, g2 * 0.55 + g1 * 0.55);

		albedo = mix(c_oxido, c_claro, t);
		albedo = mix(albedo, c_oscuro, 0.85 * oscuro);
		albedo *= 0.86 + 0.28 * g3;

		// Cráteres: borde más claro, fondo más oscuro
		float crh = clamp(cg * 0.6 + cp * 0.35, -1.0, 1.0);
		albedo *= 1.0 + 0.22 * max(crh, 0.0) - 0.18 * max(-crh, 0.0);

		// Casquetes polares (el norte es algo más grande)
		float limite = (p.y > 0.0 ? 0.945 : 0.965) + (fbm(p * 6.0) - 0.5) * 0.07;
		casq = smoothstep(limite, limite + 0.02, abs(p.y));
		albedo = mix(albedo, lin(vec3(0.90, 0.93, 0.97)), casq);
	}

	// Relieve
	float h = 0.0;
	if (!usar_textura) {
		h = ((fbm(p * 9.0) - 0.5) * 2.0 + cg * 1.6 + cp * 0.7) * relieve * (1.0 - 0.9 * casq);
	}
	vec3 N = normalize(NORMAL);
	vec3 Nb = perturbar(N, VERTEX, h);

	// Iluminación (el sol llega como uniform, en espacio mundo)
	vec3 Nw = normalize((INV_VIEW_MATRIX * vec4(Nb, 0.0)).xyz);
	vec3 Ngw = normalize((INV_VIEW_MATRIX * vec4(N, 0.0)).xyz);
	vec3 s = normalize(sun_dir);
	float ndl = dot(Nw, s);
	float ndl_g = dot(Ngw, s);
	float dif = clamp(ndl, 0.0, 1.0) * smoothstep(-0.05, 0.2, ndl_g);
	vec3 col = albedo * (dif * 1.3 + 0.012);

	// Bruma atmosférica en el borde del disco
	vec3 V = normalize(VIEW);
	float fres = pow(1.0 - clamp(dot(N, V), 0.0, 1.0), 3.0);
	col += vec3(0.55, 0.62, 0.80) * (fres * 0.5 * clamp(ndl_g * 1.5 + 0.3, 0.0, 1.0)) * 0.6;

	ALBEDO = col;
}
"""

const SHADER_HALO := """
shader_type spatial;
render_mode unshaded, cull_front, blend_add, depth_draw_never;

uniform vec3 sun_dir = vec3(0.55, 0.35, 0.75);
uniform vec3 color_halo = vec3(0.45, 0.55, 0.85);
uniform float ancho = 0.29;

varying vec3 saliente;

void vertex() {
	saliente = normalize(VERTEX);
}

void fragment() {
	vec3 N = normalize(NORMAL);
	vec3 V = normalize(VIEW);
	float d = abs(dot(N, V));
	float a = pow(smoothstep(0.0, ancho, d), 2.5);
	float luz = clamp(dot(normalize(saliente), normalize(sun_dir)) + 0.05, 0.0, 1.0);
	ALBEDO = color_halo;
	ALPHA = a * luz * 0.8;
}
"""


func _ready() -> void:
	_mat_globo = _crear_material(SHADER_GLOBO)
	_mat_globo.set_shader_parameter("relieve", relieve)
	_mat_globo.set_shader_parameter("crater_k", crater_k)
	if textura != null:
		_mat_globo.set_shader_parameter("usar_textura", true)
		_mat_globo.set_shader_parameter("tex_marte", textura)

	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	malla.radial_segments = 256
	malla.rings = 128
	var globo := MeshInstance3D.new()
	globo.name = "Superficie"
	globo.mesh = malla
	globo.material_override = _mat_globo
	globo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(globo)

	_mat_halo = _crear_material(SHADER_HALO)
	_mat_halo.set_shader_parameter("ancho", sqrt(1.0 - 1.0 / (FACTOR_HALO * FACTOR_HALO)))
	var malla_h := SphereMesh.new()
	malla_h.radius = radio * FACTOR_HALO
	malla_h.height = radio * FACTOR_HALO * 2.0
	malla_h.radial_segments = 128
	malla_h.rings = 64
	var halo := MeshInstance3D.new()
	halo.name = "Halo"
	halo.mesh = malla_h
	halo.material_override = _mat_halo
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(halo)


func _crear_material(codigo: String) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = codigo
	var mat := ShaderMaterial.new()
	mat.shader = sh
	return mat


func poner_sol(dir: Vector3) -> void:
	if _mat_globo == null:
		return
	_mat_globo.set_shader_parameter("sun_dir", dir)
	_mat_halo.set_shader_parameter("sun_dir", dir)
