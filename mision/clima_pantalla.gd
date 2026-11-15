extends CanvasLayer


const Ajustes := preload("res://nucleo/ajustes.gd")

const SOMBREADOR := """
shader_type canvas_item;
render_mode blend_mix;

uniform float tiempo = 0.0;
uniform float tormenta = 0.0;
uniform float rayos = 0.0;
uniform float escarcha = 0.0;
uniform float nieve = 0.0;
uniform float viento = 0.5;
uniform float calidad = 2.0;
uniform vec3 color_polvo = vec3(0.78, 0.48, 0.27);
uniform vec3 color_luz = vec3(1.0, 0.86, 0.62);
uniform sampler2D pantalla : hint_screen_texture, repeat_disable, filter_linear_mipmap;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	int n = calidad > 1.5 ? 4 : 2;
	for (int i = 0; i < n; i++) {
		v += a * ruido(p);
		p = p * 2.03 + vec2(7.1, 3.7);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV;
	float asp = 16.0 / 9.0;
	vec2 c = (uv - 0.5) * vec2(asp, 1.0);
	float borde = clamp(length(c) / 0.95, 0.0, 1.0);
	vec4 col = vec4(0.0);

	// --- tormenta: velo con rachas horizontales y granos de arena
	if (tormenta > 0.01) {
		float v = 0.6 + 1.6 * viento;
		float racha = 0.85 + 0.3 * sin(tiempo * 0.7) * sin(tiempo * 0.23 + 1.0);
		float n1 = fbm(vec2(uv.x * 2.5 * asp - tiempo * v * 0.9, uv.y * 7.0 + tiempo * 0.05));
		float n2 = fbm(vec2(uv.x * 6.0 * asp - tiempo * v * 1.8 + 11.0, uv.y * 26.0));
		float a = tormenta * racha * (0.22 + 0.5 * n1 + 0.25 * n2) * (0.65 + 0.6 * borde);
		a = clamp(a, 0.0, 0.88);
		vec3 tinte = mix(color_polvo * 0.75, color_polvo * 1.1, n1);
		col = vec4(tinte, a);
		// granos: rayitas finas y rápidas que cruzan la imagen
		vec2 q = vec2(uv.x * asp * 14.0 - tiempo * v * 12.0, uv.y * 230.0);
		float hg = hash(floor(q));
		float fx = fract(q.x);
		float grano = step(0.94, hg) * smoothstep(0.0, 0.5, fx) * smoothstep(1.0, 0.5, fx) * step(0.25, fract(hg * 13.7));
		float ag = grano * tormenta * (0.2 + 0.3 * racha);
		col.rgb = mix(col.rgb, color_luz, ag / max(ag + col.a, 0.001));
		col.a = clamp(col.a + ag * (1.0 - col.a), 0.0, 1.0);
	}

	// --- rayos de sol entre el polvo (vienen de arriba a la derecha)
	if (rayos > 0.01) {
		vec2 d = vec2(uv.x * asp + uv.y * 0.55, uv.y);
		float haz = sin(d.x * 9.0 + sin(d.x * 2.3 + tiempo * 0.08) * 1.3);
		haz = pow(clamp(haz * 0.5 + 0.5, 0.0, 1.0), 5.0);
		float fino = 0.55 + 0.45 * ruido(vec2(d.x * 22.0, tiempo * 0.12));
		float caida = smoothstep(1.05, 0.0, uv.y) * smoothstep(0.0, 0.5, 1.0 - uv.x + 0.25);
		float a = haz * fino * caida * rayos * 0.42;
		col.rgb = mix(col.rgb, color_luz, a / max(a + col.a, 0.001));
		col.a = clamp(col.a + a * (1.0 - col.a), 0.0, 1.0);
	}

	// --- escarcha en los bordes
	if (escarcha > 0.01) {
		float m = smoothstep(0.78 - 0.2 * escarcha, 1.05, borde);
		float cr = fbm(uv * vec2(asp, 1.0) * 14.0);
		float vena = smoothstep(0.62, 0.9, ruido(uv * vec2(asp, 1.0) * 38.0 + cr * 3.0));
		float a = m * escarcha * (0.12 + 0.4 * cr + 0.3 * vena);
		a = clamp(a, 0.0, 0.6);
		vec3 hielo = mix(vec3(0.74, 0.88, 1.0), vec3(1.0), vena);
		col.rgb = mix(col.rgb, hielo, a / max(a + col.a, 0.001));
		col.a = clamp(col.a + a * (1.0 - col.a), 0.0, 1.0);
	}

	// --- nieve: tres capas de copos que caen con el viento
	if (nieve > 0.01) {
		float s = 0.0;
		for (int l = 0; l < 3; l++) {
			float fl = float(l);
			float esc = 9.0 + fl * 8.0;
			vec2 p = vec2(uv.x * asp, uv.y) * esc;
			p.y -= tiempo * (1.4 + fl * 0.9);
			p.x += tiempo * (0.5 + viento * 1.6) * (0.6 + fl * 0.4) + sin(tiempo * 0.7 + fl) * 0.4;
			vec2 id = floor(p);
			vec2 f = fract(p) - 0.5;
			float h = hash(id + fl * 17.0);
			vec2 off = vec2(h - 0.5, fract(h * 7.0) - 0.5) * 0.6;
			float r = length(f - off);
			float tam = 0.09 + 0.05 * fl;
			s += smoothstep(tam, 0.0, r) * step(0.55, h) * (0.55 + 0.25 * fl);
		}
		float a = clamp(s, 0.0, 1.0) * nieve * 0.8;
		col.rgb = mix(col.rgb, vec3(0.96, 0.98, 1.0), a / max(a + col.a, 0.001));
		col.a = clamp(col.a + a * (1.0 - col.a), 0.0, 1.0);
	}
	if (tormenta > 0.01) {
		// el paisaje se desenfoca (más hacia los bordes, para que el robot siga legible) y pierde color
		float lod = tormenta * (0.8 + 2.0 * borde);
		vec3 fondo = textureLod(pantalla, SCREEN_UV, lod).rgb;
		float lum = dot(fondo, vec3(0.3, 0.59, 0.11));
		fondo = mix(vec3(lum), fondo, 1.0 - 0.4 * tormenta);
		COLOR = vec4(mix(fondo, col.rgb, col.a), 1.0);
	} else {
		COLOR = col;
	}
}
"""

var _rect: ColorRect
var _mat: ShaderMaterial
var _t: float = 0.0
var _escarcha_base: float = 0.0
var _nieve_base: float = 0.0
var _polvo_aire: float = 0.3
var _sol_bajo: float = 0.0
var _f_tormenta: float = 0.0
var _f_rayos: float = 0.0
var _f_escarcha: float = 0.0
var _f_nieve: float = 0.0
var _activo: bool = true


func _init() -> void:
	layer = 4


func _ready() -> void:
	_activo = Ajustes.calidad_ambiente > 0
	if not _activo:
		visible = false
		return
	_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SOMBREADOR
	_mat.shader = sh
	_mat.set_shader_parameter("calidad", float(Ajustes.calidad_ambiente))
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _mat
	add_child(_rect)


func configurar(datos: Dictionary) -> void:
	var amb: Dictionary = datos.get("amb", {})
	var temp := float(amb.get("temp", -60.0))
	_escarcha_base = clampf((-temp - 62.0) / 26.0, 0.0, 1.0) * 0.75
	if absf(float(datos.get("lat_real", datos.get("lat", 0.0)))) >= 65.0:
		_nieve_base = 1.0
		_escarcha_base = maxf(_escarcha_base, 0.35)
	_polvo_aire = clampf(float(amb.get("polvo", 0.3)), 0.0, 1.0)
	var elev := float(amb.get("sol_elev", 45.0))
	_sol_bajo = clampf((62.0 - elev) / 46.0, 0.0, 1.0)


func objetivos(tormenta: float, dentro: float, luz_dia: float) -> Dictionary:
	var fuera := 1.0 - clampf(dentro, 0.0, 1.0)
	var calma := 1.0 - clampf(tormenta * 2.0, 0.0, 1.0)
	var r := _polvo_aire * (0.35 + 0.65 * _sol_bajo) * clampf((luz_dia - 0.35) * 2.0, 0.0, 1.0) * calma * fuera
	var noche := 1.0 - clampf(luz_dia, 0.0, 1.0)
	var e := clampf(_escarcha_base * (1.0 + 0.45 * noche), 0.0, 1.0) * lerpf(1.0, 0.55, clampf(dentro, 0.0, 1.0))
	var n := _nieve_base * fuera * (1.0 - 0.5 * clampf(tormenta, 0.0, 1.0))
	if Ajustes.calidad_ambiente < 2:
		n *= 0.0 if Ajustes.calidad_ambiente == 0 else 0.7
	return {"tormenta": clampf(tormenta, 0.0, 1.0) * fuera, "rayos": clampf(r, 0.0, 1.0),
			"escarcha": e, "nieve": n}


func actualizar(delta: float, tormenta: float, dentro: float, luz_dia: float, viento: float) -> void:
	if not _activo:
		return
	_t += delta
	var o := objetivos(tormenta, dentro, luz_dia)
	var k := 1.0 - exp(-1.6 * delta)
	_f_tormenta = lerpf(_f_tormenta, float(o["tormenta"]), k)
	_f_rayos = lerpf(_f_rayos, float(o["rayos"]), k * 0.6)
	_f_escarcha = lerpf(_f_escarcha, float(o["escarcha"]), k * 0.4)
	_f_nieve = lerpf(_f_nieve, float(o["nieve"]), k)
	_mat.set_shader_parameter("tiempo", _t)
	_mat.set_shader_parameter("tormenta", _f_tormenta)
	_mat.set_shader_parameter("rayos", _f_rayos)
	_mat.set_shader_parameter("escarcha", _f_escarcha)
	_mat.set_shader_parameter("nieve", _f_nieve)
	_mat.set_shader_parameter("viento", clampf(viento, 0.0, 1.0))
	_rect.visible = _f_tormenta > 0.005 or _f_rayos > 0.005 or _f_escarcha > 0.005 or _f_nieve > 0.005
