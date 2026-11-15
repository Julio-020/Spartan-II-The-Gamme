extends Node3D


const IconosMision := preload("res://datos/iconos_mision.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const COLOR_DISPONIBLE := Color(0.0, 1.0, 0.8)
const COLOR_HOVER := Color(1.0, 0.85, 0.2)
const COLOR_COMPLETADA := Color(0.35, 1.0, 0.35)
const COLOR_BLOQUEADA := Color(0.5, 0.5, 0.58)
const COLOR_SIGUIENTE := Color(1.0, 0.62, 0.15)

const ESCALA_BASE := 220.0
const BASE_ICONO := 2.9
const TAM_ICONO := 2.8
const ELEVACION := 20.0
const PIXEL_TEXTO := 0.0172

var id: String = ""
var nombre: String = ""
var descripcion: String = ""
var datos: Dictionary = {}
var completada: bool = false
var bloqueada: bool = false
var siguiente: bool = false
var motivo_bloqueo: String = ""

var _visual: Node3D
var _icono: Sprite3D
var _etiqueta: Label3D
var _mat_anillo: StandardMaterial3D
var _mat_haz: StandardMaterial3D
var _hover: bool = false
var _factor: float = 1.0
var _tiempo: float = 0.0


func _ready() -> void:
	_tiempo = randf() * TAU
	_construir_visual()
	_actualizar_color()


func _material_senal() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _construir_visual() -> void:
	_visual = Node3D.new()
	add_child(_visual)


	var aro := TorusMesh.new()
	aro.inner_radius = 0.92
	aro.outer_radius = 1.0
	aro.rings = 48
	aro.ring_segments = 6
	_mat_anillo = _material_senal()
	aro.material = _mat_anillo
	var mi_anillo := MeshInstance3D.new()
	mi_anillo.mesh = aro
	mi_anillo.position = Vector3(0.0, 0.02, 0.0)
	mi_anillo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(mi_anillo)


	var alto_haz := BASE_ICONO - TAM_ICONO * 0.5
	var haz := CylinderMesh.new()
	haz.top_radius = 0.05
	haz.bottom_radius = 0.1
	haz.height = alto_haz
	haz.radial_segments = 8
	haz.rings = 1
	_mat_haz = _material_senal()
	haz.material = _mat_haz
	var mi_haz := MeshInstance3D.new()
	mi_haz.mesh = haz
	mi_haz.position = Vector3(0.0, alto_haz * 0.5, 0.0)
	mi_haz.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(mi_haz)


	var tex := IconosMision.textura(IconosMision.tipo_de(id))
	_icono = Sprite3D.new()
	_icono.texture = tex
	_icono.pixel_size = TAM_ICONO / float(tex.get_width())
	_icono.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icono.shaded = false
	_icono.double_sided = true
	_icono.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_icono.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_icono.position = Vector3(0.0, BASE_ICONO, 0.0)
	_visual.add_child(_icono)


	_etiqueta = Label3D.new()
	_etiqueta.text = str(datos.get("era", ""))
	_etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_etiqueta.pixel_size = PIXEL_TEXTO
	_etiqueta.font = EstiloUI.fuente_titulo()
	_etiqueta.font_size = 38
	_etiqueta.outline_size = 12
	_etiqueta.outline_modulate = Color(0.03, 0.02, 0.03, 0.9)
	_etiqueta.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_etiqueta.position = Vector3(0.0, BASE_ICONO, 0.0)
	_etiqueta.offset = Vector2(0.0, TAM_ICONO * 0.5 / PIXEL_TEXTO + 36.0)
	_visual.add_child(_etiqueta)
	_aplicar_escala(ESCALA_BASE)


func _aplicar_escala(s: float) -> void:
	_visual.scale = Vector3.ONE * s
	_visual.position = Vector3(0.0, ELEVACION, 0.0)


func _process(delta: float) -> void:
	_tiempo += delta
	var pulso := 1.0 + (0.16 if siguiente else 0.06) * sin(_tiempo * (4.0 if siguiente else 3.0))
	var objetivo := 1.35 if _hover else 1.0
	_factor = lerpf(_factor, objetivo, 1.0 - exp(-10.0 * delta))
	_aplicar_escala(ESCALA_BASE * pulso * _factor)


func set_hover(valor: bool) -> void:
	_hover = valor
	_actualizar_color()


func marcar_completada() -> void:
	completada = true
	_actualizar_color()


func estado_campana(hecha: bool, bloq: bool, sig: bool) -> void:
	var nueva_hecha := completada or hecha
	if nueva_hecha == completada and bloq == bloqueada and sig == siguiente:
		return
	completada = nueva_hecha
	bloqueada = bloq
	siguiente = sig
	_actualizar_color()


func _actualizar_color() -> void:
	if _icono == null:
		return
	var c := COLOR_DISPONIBLE
	if bloqueada:
		c = COLOR_BLOQUEADA.lightened(0.25) if _hover else COLOR_BLOQUEADA
	elif _hover:
		c = COLOR_HOVER
	elif completada:
		c = COLOR_COMPLETADA
	elif siguiente:
		c = COLOR_SIGUIENTE
	var opaco := 0.8 if bloqueada else 1.0
	_icono.modulate = Color(c.r, c.g, c.b, opaco)
	_etiqueta.modulate = Color(c.r, c.g, c.b, opaco)
	_mat_haz.albedo_color = Color(c.r, c.g, c.b, 0.3 if bloqueada else 0.6)
	_mat_anillo.albedo_color = Color(c.r, c.g, c.b, 0.35 if bloqueada else 0.75)


func centro_click() -> Vector3:
	var arriba := global_transform.basis.y.normalized()
	return global_position + arriba * (BASE_ICONO * ESCALA_BASE * _factor + ELEVACION)


func radio_click() -> float:
	var r := ESCALA_BASE * 1.5
	var cam := get_viewport().get_camera_3d()
	if cam:
		r = maxf(r, cam.global_position.distance_to(global_position) * 0.02)
	return r
