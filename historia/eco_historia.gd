extends Node3D


const SondaModelo := preload("res://modelos/sonda_modelo.gd")
const HistoriaVisual := preload("res://historia/historia_visual.gd")
const MetaEstado := preload("res://progreso/meta_estado.gd")

const DIST := 260.0
const LADO := 70.0
const RADIO := 24.0
const PERIODO := 12.0

signal descubierto(primera: bool)

var _m: Node3D
var _id: String = ""
var _datos: Dictionary = {}
var _tipo: String = "aterrizaje"
var _choque: bool = false
var _k: float = 0.1
var _P: Vector3 = Vector3.ZERO
var _t: float = 0.0
var _sonda: Node3D
var _fantasma: Node3D
var _mat: StandardMaterial3D
var _haz: MeshInstance3D
var _mat_haz: StandardMaterial3D
var _anillo: MeshInstance3D
var _t_pulso: float = -99.0
var _visto: bool = false
var _luz: OmniLight3D
var activo: bool = false


func iniciar(m: Node3D, datos: Dictionary) -> bool:
	if not HistoriaVisual.aplica(datos):
		return false
	_m = m
	_datos = datos
	_id = str(datos.get("id", ""))
	_tipo = HistoriaVisual.tipo(datos)
	_choque = _tipo == "restos" and HistoriaVisual.modo(_id) == "choque"
	_k = float(m.get("k"))
	var up: Vector3 = m.get("_up")
	var f: Vector3 = m.get("_fwd")
	f = (f - up * f.dot(up)).normalized()
	var p := up.cross(f).normalized()
	var d: Vector3 = m.call("_desplazar", up, f, p, DIST * _k, -LADO * _k)
	_P = m.call("_pos", d)
	var hacia := up - d * up.dot(d)
	var z := hacia.normalized() if hacia.length() > 0.00001 else -f
	var x := d.cross(z).normalized()
	z = x.cross(d).normalized()
	transform = Transform3D(Basis(x, d, z) * Basis.from_scale(Vector3.ONE * _k), _P)
	m.add_child(self)
	_construir()
	activo = true
	return true


func _construir() -> void:
	if _tipo == "colonia":
		_sonda = SondaModelo.baliza()
	else:
		_sonda = SondaModelo.sonda(HistoriaVisual.estilo(_datos))
	_fantasma = Node3D.new()
	add_child(_fantasma)
	_fantasma.add_child(_sonda)
	_mat = SondaModelo.holograma(_fantasma)

	_haz = MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = 0.25
	c.bottom_radius = 1.6
	c.height = 90.0
	c.radial_segments = 10
	c.cap_top = false
	c.cap_bottom = false
	_haz.mesh = c
	_mat_haz = StandardMaterial3D.new()
	_mat_haz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_haz.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_haz.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_mat_haz.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat_haz.albedo_color = Color(0.35, 0.7, 1.0, 0.18)
	_haz.material_override = _mat_haz
	_haz.position = Vector3(0, 45.0, 0)
	_haz.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_haz)
	_anillo = SondaModelo.anillo()
	_anillo.visible = false
	add_child(_anillo)
	_luz = OmniLight3D.new()
	_luz.light_color = Color(0.4, 0.75, 1.0)
	_luz.light_energy = 1.2
	_luz.omni_range = 25.0
	_luz.position = Vector3(0, 3.0, 0)
	add_child(_luz)


func actualizar(delta: float, pos_robot: Vector3) -> void:
	if not activo:
		return
	_t += delta * (2.0 if _visto and _t_pulso > _t - 6.0 else 1.0)
	var u := fposmod(_t, PERIODO) / PERIODO
	var y := 0.0
	var alfa := 0.35
	if _tipo == "colonia":
		y = 0.0
		alfa = 0.25 + 0.2 * sin(_t * 2.6)
	else:
		if u < 0.5:
			y = 40.0 * pow(1.0 - u / 0.5, 2.0)
		if _choque and u > 0.38 and u < 0.5:
			alfa = 0.35 * (0.5 + 0.5 * sin(_t * 40.0))
		if u > 0.5:
			alfa = 0.35 * clampf(1.0 - (u - 0.8) / 0.2, 0.0, 1.0)
		if _choque and u > 0.5:
			alfa *= 0.5
	_sonda.position = Vector3(0, y, 0)
	if _visto:
		alfa = minf(1.0, alfa * 1.8)
	_mat.albedo_color.a = alfa
	_mat_haz.albedo_color.a = (0.35 if _visto else 0.18) * (0.8 + 0.2 * sin(_t * 3.0))

	var up_t := _t - _t_pulso
	if up_t >= 0.0 and up_t < 2.4:
		_anillo.visible = true
		var s := lerpf(1.5, 30.0, up_t / 2.4)
		_anillo.scale = Vector3(s, 1.0, s)
		_anillo.position = Vector3(0, 0.15, 0)
		var mm := _anillo.material_override as StandardMaterial3D
		mm.albedo_color = Color(0.4, 0.75, 1.0, (1.0 - up_t / 2.4) * 0.9)
		mm.emission = Color(0.4, 0.75, 1.0)
	else:
		_anillo.visible = false
	if not _visto:
		var d: float = (pos_robot - _P).length() / _k
		if d < RADIO:
			_descubrir()


func _descubrir() -> void:
	_visto = true
	_t_pulso = _t
	var primera := true
	var v: Variant = MetaEstado.extra_get("ecos", {})
	var ecos: Dictionary = v if v is Dictionary else {}
	if ecos.has(_id):
		primera = false
	else:
		ecos = ecos.duplicate()
		ecos[_id] = true
		MetaEstado.extra_set("ecos", ecos)
		MetaEstado.sumar_datos(1)
	descubierto.emit(primera)
