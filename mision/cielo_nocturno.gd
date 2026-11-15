extends Node3D


const Idioma := preload("res://nucleo/idioma.gd")

const TAM_FOBOS := 0.032
const TAM_DEIMOS := 0.018

const SHADER := """
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, fog_disabled, blend_mix;

uniform float noche = 0.0;
uniform float brillo_horizonte = 0.0;
uniform vec3 arriba = vec3(0.0, 1.0, 0.0);
uniform mat3 giro = mat3(1.0);
uniform float fase_luna = 0.0;
uniform vec3 fobos_dir = vec3(0.0, 1.0, 0.0);
uniform vec3 deimos_dir = vec3(0.0, 1.0, 0.0);
uniform float fobos_r = 0.02;
uniform float deimos_r = 0.01;
uniform vec3 norte_h = vec3(0.0, 0.0, 1.0);
uniform vec3 cometa_dir = vec3(0.0, 1.0, 0.0);
uniform float aurora = 0.0;
uniform float cometa = 0.0;
uniform float lluvia = 0.0;
varying vec3 vdir;

float h13(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}
vec3 h33(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 33.33);
	return fract((p.xxy + p.yxx) * p.zyx);
}

vec3 estrellas(vec3 d, float escala, float densidad, float tam) {
	vec3 p = d * escala;
	vec3 id = floor(p);
	vec3 f = fract(p);
	vec3 r = h33(id);
	float tiene = step(densidad, h13(id + 7.0));
	float dist = length(f - r);
	float t = mix(tam * 0.5, tam, r.z);
	float b = tiene * smoothstep(t, 0.0, dist);
	float titilar = 0.75 + 0.25 * sin(TIME * (1.5 + r.x * 3.0) + r.y * 40.0);
	vec3 tinte = mix(vec3(0.72, 0.82, 1.0), vec3(1.0, 0.86, 0.70), r.y);
	return tinte * b * titilar * (0.55 + 0.9 * r.x);
}

// estrellas fugaces: rayas cortas que cruzan el cielo; con lluvia salen muchas más
vec3 fugaces(vec3 d, vec3 up, float llu) {
	vec3 acc = vec3(0.0);
	for (int i = 0; i < 3; i++) {
		float per = mix(8.0 + float(i) * 2.7, 2.2 + float(i) * 0.7, llu);
		float t = TIME / per + float(i) * 0.37;
		float id = floor(t);
		float pr = fract(t) * per / 0.9;
		if (pr > 1.0) continue;
		vec3 r = h33(vec3(id, float(i), 3.0));
		if (llu < 0.2 && r.z < 0.4) continue;
		vec3 p0 = normalize(normalize(r * 2.0 - 1.0) + up * 1.2);
		vec3 tg = normalize(cross(p0, h33(vec3(id, float(i), 9.0)) * 2.0 - 1.0));
		vec3 a = normalize(p0 + tg * 0.30 * max(pr - 0.4, 0.0));
		vec3 b = normalize(p0 + tg * 0.30 * pr);
		vec3 n = normalize(cross(a, b));
		float total = acos(clamp(dot(a, b), -1.0, 1.0));
		float ang = atan(dot(d, cross(n, a)), dot(d, a));
		float t2 = ang / max(total, 0.0001);
		float dist = abs(dot(d, n));
		float brillo = (1.0 - smoothstep(0.0, 0.0065, dist)) * step(0.0, t2) * step(t2, 1.0) * t2 * (1.0 - 0.5 * pr);
		acc += vec3(0.85, 0.92, 1.0) * brillo * 2.2;
	}
	return acc;
}

vec4 luna(vec3 d, vec3 m, float radio, float alargada, vec3 sol, vec3 tono, float semilla) {
	float c = dot(d, m);
	if (c < 0.0) return vec4(0.0);
	vec3 t1 = normalize(cross(m, vec3(0.0, 1.0, 0.0)));
	vec3 t2 = cross(m, t1);
	float x = dot(d, t1) / radio;
	float y = dot(d, t2) / radio;
	float rr = sqrt(x * x * alargada + y * y);
	if (rr > 1.0) return vec4(0.0);
	float z = sqrt(max(1.0 - rr * rr, 0.0));
	vec3 n = vec3(x, y, z);
	// fase de la luna: el Sol de noche queda bajo el horizonte, así que se inventa un ángulo de luz que va cambiando
	vec3 L = vec3(0.8 * sin(sol.x), 0.3, 0.9 + 0.4 * cos(sol.x));
	float luz = clamp(dot(n, normalize(L)) * 1.1 + 0.30, 0.22, 1.0);
	float crat = 0.80 + 0.12 * sin(x * 9.0 + semilla) * sin(y * 8.0 - semilla) + 0.08 * sin(x * 21.0 + y * 17.0 + semilla * 2.0);
	vec3 col = tono * luz * crat;
	return vec4(col, 1.0 - smoothstep(0.88, 1.0, rr));
}

void vertex() {
	vdir = VERTEX;
}

void fragment() {
	vec3 d = normalize(vdir);
	float h = dot(d, normalize(arriba));
	// degradado: casi negro azulado arriba, violeta tenue en el horizonte; al anochecer brilla naranja
	vec3 cenit = vec3(0.010, 0.018, 0.060);
	vec3 hor = vec3(0.115, 0.085, 0.150);
	vec3 cielo = mix(hor, cenit, smoothstep(-0.05, 0.75, h));
	cielo = mix(cielo, vec3(0.62, 0.28, 0.18), brillo_horizonte * pow(clamp(1.0 - h, 0.0, 1.0), 5.0));
	float a_cielo = smoothstep(0.0, 0.85, noche);

	vec3 ds = giro * d;
	vec3 st = estrellas(ds, 38.0, 0.90, 0.22) + estrellas(ds, 90.0, 0.93, 0.30) * 0.8;
	// Vía Láctea: una banda de luz difusa
	vec3 eje = normalize(vec3(0.35, 0.8, 0.5));
	float banda = exp(-pow(dot(ds, eje) / 0.20, 2.0));
	float nube = 0.5 + 0.5 * sin(ds.x * 9.0 + sin(ds.y * 7.0) * 2.0) * sin(ds.z * 8.0 + sin(ds.x * 5.0) * 2.0);
	vec3 via = vec3(0.45, 0.50, 0.72) * banda * (0.20 + 0.40 * nube) * 0.55;
	float vis_est = smoothstep(0.55, 1.0, noche) * smoothstep(-0.02, 0.18, h);
	st = (st + via) * vis_est;
	st += fugaces(d, normalize(arriba), lluvia) * vis_est;

	// cometa: cabeza brillante y dos colas (iones azules rectas, polvo dorado curva); se mueve despacio sobre el cielo
	if (cometa > 0.01) {
		vec3 ch = normalize(cometa_dir);
		vec3 tu = normalize(cross(ch, normalize(arriba)) * 0.8 + normalize(arriba) * 0.6);
		tu = normalize(tu - ch * dot(tu, ch));
		vec3 tv = cross(ch, tu);
		float ok = step(0.0, dot(d, ch));
		float u = dot(d, tu);
		float v = dot(d, tv);
		float ang = acos(clamp(dot(d, ch), -1.0, 1.0));
		float cabeza = exp(-pow(ang / 0.012, 2.0)) * 1.4 + exp(-ang / 0.05) * 0.18;
		float tub = ok * step(0.0, u) * exp(-u / 0.14) * exp(-pow(v / (0.004 + u * 0.03), 2.0)) * smoothstep(0.55, 0.0, u);
		float vp = v - u * u * 0.9;
		float tpol = ok * step(0.0, u) * exp(-u / 0.11) * exp(-pow(vp / (0.010 + u * 0.10), 2.0)) * smoothstep(0.45, 0.0, u);
		vec3 cc = vec3(0.85, 0.95, 1.0) * cabeza + vec3(0.45, 0.70, 1.0) * tub * 0.9 + vec3(1.0, 0.82, 0.55) * tpol * 0.55;
		st += cc * cometa * vis_est;
	}

	vec3 prem = cielo * a_cielo + st;
	float al = clamp(a_cielo + max(max(st.r, st.g), st.b), 0.0, 1.0);

	// aurora: cortinas verdes que se vuelven violeta arriba, hacia el norte
	if (aurora > 0.01) {
		vec3 tn = normalize(norte_h);
		vec3 te = normalize(cross(normalize(arriba), tn));
		float az = atan(dot(d, te), dot(d, tn));
		float el = asin(clamp(h, -1.0, 1.0));
		float onda = sin(az * 6.0 + TIME * 0.25 + sin(az * 2.3 + TIME * 0.17) * 2.0) * 0.5 + 0.5;
		float onda2 = sin(az * 13.0 - TIME * 0.4) * 0.5 + 0.5;
		float base_el = 0.20 + 0.10 * onda;
		float cort = smoothstep(base_el, base_el + 0.04, el) * exp(-(el - base_el) * 5.0);
		float ancho = exp(-pow(az / 1.15, 2.0));
		float aur = cort * ancho * (0.55 + 0.45 * onda2) * (0.75 + 0.25 * sin(TIME * 0.6 + az * 3.0)) * aurora * smoothstep(0.6, 1.0, noche);
		vec3 c_aur = mix(vec3(0.15, 1.0, 0.55), vec3(0.65, 0.3, 1.0), smoothstep(0.0, 0.35, el - base_el));
		prem += c_aur * aur * 0.85;
		al = clamp(al + aur * 0.7, 0.0, 1.0);
	}

	// nubes de hielo: velos rosados iluminados desde abajo en el crepúsculo
	float crep = smoothstep(0.0, 0.12, noche) * (1.0 - smoothstep(0.3, 0.6, noche));
	if (crep > 0.01) {
		float nb = (0.5 + 0.5 * sin(d.x * 6.0 + sin(d.z * 4.0 + TIME * 0.03) * 2.0)) * (0.5 + 0.5 * sin(d.z * 9.0 + d.y * 5.0 - TIME * 0.02));
		float nube = smoothstep(0.45, 0.85, nb) * smoothstep(0.06, 0.30, h) * (1.0 - smoothstep(0.55, 0.90, h)) * crep;
		vec3 c_n = mix(vec3(1.0, 0.55, 0.40), vec3(0.88, 0.62, 0.92), clamp(h * 1.6, 0.0, 1.0));
		prem += c_n * nube * 0.38;
		al = clamp(al + nube * 0.38, 0.0, 1.0);
	}

	float vis_luna = smoothstep(0.35, 0.9, noche);
	vec4 lf = luna(d, normalize(fobos_dir), fobos_r, 0.62, vec3(fase_luna, 0.0, 0.0), vec3(0.62, 0.55, 0.50), 3.0);
	vec4 ld = luna(d, normalize(deimos_dir), deimos_r, 1.0, vec3(fase_luna * 0.37 + 2.0, 0.0, 0.0), vec3(0.70, 0.65, 0.58), 11.0);
	float mf = lf.a * vis_luna;
	float md = ld.a * vis_luna;
	prem = prem * (1.0 - mf) + lf.rgb * mf;
	al = al * (1.0 - mf) + mf;
	prem = prem * (1.0 - md) + ld.rgb * md;
	al = al * (1.0 - md) + md;

	ALBEDO = prem / max(al, 0.001);
	ALPHA = al;
}
"""

var mision: Node3D = null
var aurora_f: float = 0.0
var cometa_f: float = 0.0
var lluvia_f: float = 0.0
var _avisos_hechos: Dictionary = {}
var _aviso_espera: float = 0.0
var _mat: ShaderMaterial
var _malla: MeshInstance3D


func configurar(m: Node3D) -> void:
	mision = m
	_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER
	_mat.shader = sh
	_mat.render_priority = -50
	var esfera := SphereMesh.new()
	esfera.radius = 1.0
	esfera.height = 2.0
	esfera.radial_segments = 48
	esfera.rings = 24
	esfera.custom_aabb = AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	_malla = MeshInstance3D.new()
	_malla.mesh = esfera
	_malla.material_override = _mat
	_malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_malla.extra_cull_margin = 16384.0
	add_child(_malla)
	visible = false

	var rec := RandomNumberGenerator.new()
	rec.seed = int(m.semilla) * 29 + 3
	aurora_f = 1.0 if rec.randf() < 0.45 else 0.0
	cometa_f = 1.0 if rec.randf() < 0.30 else 0.0
	lluvia_f = 1.0 if rec.randf() < 0.35 else 0.0
	if aurora_f + cometa_f + lluvia_f < 0.5:
		var q := rec.randi() % 3
		aurora_f = 1.0 if q == 0 else 0.0
		cometa_f = 1.0 if q == 1 else 0.0
		lluvia_f = 1.0 if q == 2 else 0.0


func _luna_dir(arriba: Vector3, f0: Vector3, azimut: float, inclinacion: float, ang: float) -> Vector3:
	var h := f0.rotated(arriba, azimut)
	var lado := arriba.cross(h).normalized()
	var subida := arriba * cos(inclinacion) + lado * sin(inclinacion)
	return (h * cos(ang) + subida * sin(ang)).normalized()


func _avisar(delta: float, noche: float) -> void:
	_aviso_espera = maxf(_aviso_espera - delta, 0.0)
	if noche < 0.9 or _aviso_espera > 0.0 or mision._terminada:
		return
	var cola := [["aurora", aurora_f, "Aurora boreal", "En Marte también hay auroras. Mira hacia el norte: las cortinas verdes cambian a violeta."],
			["cometa", cometa_f, "Un cometa", "Un cometa cruza el cielo con dos colas: una azul de gas y otra dorada de polvo. Pasa solo esta noche."],
			["lluvia", lluvia_f, "Lluvia de estrellas", "Una lluvia de estrellas fugaces. Mira arriba: cada una es un grano de polvo que se quema en el aire."]]
	for e in cola:
		if float(e[1]) > 0.5 and not _avisos_hechos.has(e[0]):
			_avisos_hechos[e[0]] = true
			mision._hud.toast(Idioma.t(str(e[2])), Idioma.t(str(e[3])), Color(0.6, 0.9, 0.8), 6.0)
			mision._audio.aviso()
			_aviso_espera = 8.0
			mision.focos_comenta("cielo")
			return


func _process(delta: float) -> void:
	if mision == null or not mision.activo or mision._ciclo == null:
		visible = false
		return
	var noche: float = 1.0 - mision.dia_f
	if noche < 0.02:
		visible = false
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		visible = false
		return
	visible = true
	var radio: float = minf(cam.far * 0.85, 2500.0)

	var padre := get_parent() as Node3D
	global_transform = Transform3D(padre.global_transform.basis.orthonormalized() * Basis.from_scale(Vector3.ONE * radio), cam.global_position)
	var arriba: Vector3 = mision.site_up
	var f0: Vector3 = mision._f0
	var fase: float = mision._ciclo.fase
	_mat.set_shader_parameter("noche", noche)
	_mat.set_shader_parameter("brillo_horizonte", clampf(4.0 * noche * (1.0 - noche), 0.0, 1.0))
	_mat.set_shader_parameter("arriba", arriba)
	_mat.set_shader_parameter("giro", Basis(Vector3.UP, fase))
	_mat.set_shader_parameter("fase_luna", fase * 0.7)
	_mat.set_shader_parameter("fobos_dir", _luna_dir(arriba, f0, 0.5, 0.45, -fase * 3.0 + 1.0))
	_mat.set_shader_parameter("deimos_dir", _luna_dir(arriba, f0, 3.3, -0.35, fase * 0.9 + 2.2))
	_mat.set_shader_parameter("norte_h", (Vector3.UP - arriba * arriba.y).normalized() if absf(arriba.y) < 0.98 else f0)
	_mat.set_shader_parameter("cometa_dir", _luna_dir(arriba, f0, 1.2, 0.35, 0.85 + 0.35 * sin(fase * 0.7)))
	_mat.set_shader_parameter("aurora", aurora_f)
	_mat.set_shader_parameter("cometa", cometa_f)
	_mat.set_shader_parameter("lluvia", lluvia_f)
	_avisar(delta, noche)
	_mat.set_shader_parameter("fobos_r", TAM_FOBOS)
	_mat.set_shader_parameter("deimos_r", TAM_DEIMOS)
