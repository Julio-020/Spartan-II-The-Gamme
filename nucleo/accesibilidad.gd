extends CanvasLayer


const Ajustes := preload("res://nucleo/ajustes.gd")

const SHADER := """
shader_type canvas_item;
uniform sampler2D pantalla : hint_screen_texture, filter_linear_mipmap;
uniform int modo = 1;

vec3 simular(vec3 c) {
	if (modo == 1) {          // protanopía
		return vec3(dot(c, vec3(0.152286, 1.052583, -0.204868)),
				dot(c, vec3(0.114503, 0.786281, 0.099216)),
				dot(c, vec3(-0.003882, -0.048116, 1.051998)));
	} else if (modo == 2) {   // deuteranopía
		return vec3(dot(c, vec3(0.367322, 0.860646, -0.227968)),
				dot(c, vec3(0.280085, 0.672501, 0.047413)),
				dot(c, vec3(-0.011820, 0.042940, 0.968881)));
	}
	// tritanopía
	return vec3(dot(c, vec3(1.255528, -0.076749, -0.178779)),
			dot(c, vec3(-0.078411, 0.930809, 0.147602)),
			dot(c, vec3(0.004733, 0.691367, 0.303900)));
}

void fragment() {
	vec3 c = texture(pantalla, SCREEN_UV).rgb;
	vec3 err = c - simular(c);
	vec3 corr;
	if (modo == 3) {
		corr = vec3(0.7 * err.b + err.r, 0.7 * err.b + err.g, 0.0);
	} else {
		corr = vec3(0.0, 0.7 * err.r + err.g, 0.7 * err.r + err.b);
	}
	COLOR = vec4(clamp(c + corr, 0.0, 1.0), 1.0);
}
"""

var _rect: ColorRect
var _mat: ShaderMaterial


func _ready() -> void:
	layer = 120
	add_to_group("accesibilidad")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sh := Shader.new()
	sh.code = SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _mat
	add_child(_rect)
	aplicar()


func aplicar() -> void:
	var m := clampi(Ajustes.daltonismo, 0, 3)
	visible = m > 0
	if m > 0:
		_mat.set_shader_parameter("modo", m)
