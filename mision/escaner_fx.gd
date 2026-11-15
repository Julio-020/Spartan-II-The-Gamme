extends Node3D


const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const SHADER_CUPULA := """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, fog_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.55, 0.2, 1.0);
uniform float ancho = 0.05;
uniform float fade = 1.0;
uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;

void fragment() {
	float depth = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 vista = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vista.xyz /= vista.w;
	float diff = abs((-vista.z) - (-VERTEX.z));
	float nucleo = 1.0 - smoothstep(0.0, ancho, diff);          // línea brillante donde la cúpula toca el suelo
	float halo = 1.0 - smoothstep(0.0, ancho * 6.0, diff);      // resplandor suave alrededor
	float fres = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.5);
	ALBEDO = mix(color.rgb, vec3(1.0, 0.96, 0.82), nucleo);
	ALPHA = clamp(nucleo * 1.5 + halo * 0.32 + fres * 0.06, 0.0, 1.0) * fade;
}
"""

const SHADER_HAZ := """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, fog_disabled;
uniform vec4 color : source_color = vec4(1.0, 0.8, 0.3, 1.0);
uniform float fade = 1.0;
void fragment() {
	float h = clamp(UV.y, 0.0, 1.0);
	ALBEDO = color.rgb;
	ALPHA = (0.15 + 0.85 * (1.0 - UV.y)) * 0.55 * fade * (0.8 + 0.2 * sin(TIME * 6.0 + UV.y * 20.0));
}
"""

var k: float = 0.1
var radio_planeta: float = 3398.5

var _cupula: MeshInstance3D = null
var _mat_cupula: ShaderMaterial = null
var _t_pulso: float = -1.0
var _dur_pulso: float = 1.7
var _alcance: float = 7.0
var _pos_pulso: Vector3 = Vector3.ZERO
var _baliza: Array[Dictionary] = []
var _shader_cupula: Shader = null
var _shader_haz: Shader = null


func _ready() -> void:
	_shader_cupula = Shader.new()
	_shader_cupula.code = SHADER_CUPULA
	_shader_haz = Shader.new()
	_shader_haz.code = SHADER_HAZ


func disparar(pos: Vector3, alcance: float, color: Color = Color(1.0, 0.55, 0.2)) -> void:
	if _cupula != null:
		_cupula.queue_free()
	_alcance = alcance
	_pos_pulso = pos
	_t_pulso = 0.0
	_cupula = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 56
	sm.rings = 28
	_cupula.mesh = sm
	_mat_cupula = ShaderMaterial.new()
	_mat_cupula.shader = _shader_cupula
	_mat_cupula.set_shader_parameter("color", color)
	_cupula.material_override = _mat_cupula
	_cupula.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_cupula.position = pos
	_cupula.scale = Vector3.ONE * 0.001
	_cupula.custom_aabb = AABB(Vector3.ONE * -2.0, Vector3.ONE * 4.0)
	add_child(_cupula)


func marcar_contactos(contactos: Array, duracion: float) -> void:
	limpiar_balizas()
	for c in contactos:
		_crear_baliza(c, duracion)


func limpiar_balizas() -> void:
	for b in _baliza:
		if is_instance_valid(b["nodo"]):
			(b["nodo"] as Node3D).queue_free()
	_baliza.clear()


func quitar_baliza_de(dir: Vector3) -> void:
	for i in range(_baliza.size() - 1, -1, -1):
		var b := _baliza[i]
		if (b["dir"] as Vector3).distance_to(dir) < 0.000001:
			if is_instance_valid(b["nodo"]):
				(b["nodo"] as Node3D).queue_free()
			_baliza.remove_at(i)


func _crear_baliza(c: Dictionary, duracion: float) -> void:
	var color: Color = c["color"]
	var grande: bool = c.get("grande", false)
	var arriba := (c["pos"] as Vector3).normalized()
	var ref := Vector3.UP if absf(arriba.y) < 0.999 else Vector3.RIGHT
	var t1 := arriba.cross(ref).normalized()
	var base := Basis(t1, arriba, t1.cross(arriba))
	var raiz := Node3D.new()
	raiz.transform = Transform3D(base * Basis.from_scale(Vector3.ONE * k), c["pos"])
	add_child(raiz)


	var alto := 14.0 if grande else 9.0
	var mat_haz := ShaderMaterial.new()
	mat_haz.shader = _shader_haz
	mat_haz.set_shader_parameter("color", color)
	var haz := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.35
	cm.height = alto
	cm.radial_segments = 10
	cm.rings = 4
	haz.mesh = cm
	haz.material_override = mat_haz
	haz.position = Vector3(0.0, alto * 0.5, 0.0)
	haz.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(haz)


	var anillo := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 1.0
	tm.bottom_radius = 1.0
	tm.height = 0.04
	tm.radial_segments = 32
	anillo.mesh = tm
	anillo.material_override = mat_haz
	anillo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	anillo.position = Vector3(0.0, 0.25, 0.0)
	raiz.add_child(anillo)


	var et := Label3D.new()
	et.text = str(c["nombre"])
	et.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	et.fixed_size = true
	et.pixel_size = 0.0011
	et.font = EstiloUI.fuente_titulo()
	et.font_size = 44 if grande else 34
	et.outline_size = 10
	et.modulate = color
	et.no_depth_test = true
	et.position = Vector3(0.0, alto + 1.2, 0.0)
	raiz.add_child(et)

	_baliza.append({"nodo": raiz, "mat": mat_haz, "anillo": anillo, "etiqueta": et, "dir": c["dir"],
			"nombre": str(c["nombre"]), "t": 0.0, "dur": duracion, "grande": grande, "pos": c["pos"]})


func actualizar(delta: float, pos_robot: Vector3) -> void:

	if _t_pulso >= 0.0 and _cupula != null:
		_t_pulso += delta
		var p := clampf(_t_pulso / _dur_pulso, 0.0, 1.0)
		var e := 1.0 - pow(1.0 - p, 2.2)
		var r := _alcance * e + 0.001
		_cupula.scale = Vector3.ONE * r
		_mat_cupula.set_shader_parameter("ancho", maxf(r * 0.03, 0.01))
		_mat_cupula.set_shader_parameter("fade", clampf((1.0 - p) * 1.6, 0.0, 1.0))
		if p >= 1.0:
			_cupula.queue_free()
			_cupula = null
			_t_pulso = -1.0


	for i in range(_baliza.size() - 1, -1, -1):
		var b := _baliza[i]
		if not is_instance_valid(b["nodo"]):
			_baliza.remove_at(i)
			continue
		b["t"] = float(b["t"]) + delta
		var t: float = b["t"]
		var dur: float = b["dur"]
		var fade := clampf(minf(t / 0.35, (dur - t) / 1.2), 0.0, 1.0)
		(b["mat"] as ShaderMaterial).set_shader_parameter("fade", fade)
		var anillo: MeshInstance3D = b["anillo"]
		var pulso := fposmod(t * 0.9, 1.0)
		anillo.scale = Vector3(1.0 + pulso * 3.5, 1.0, 1.0 + pulso * 3.5)
		var et: Label3D = b["etiqueta"]

		var d_km := ((b["pos"] as Vector3) - pos_robot).length()
		et.text = "%s · %d m" % [b["nombre"], int(d_km * 1000.0)] if d_km < 1.0 \
				else "%s · %.1f km" % [b["nombre"], d_km]
		var col := et.modulate
		col.a = fade
		et.modulate = col
		if t >= dur:
			(b["nodo"] as Node3D).queue_free()
			_baliza.remove_at(i)
