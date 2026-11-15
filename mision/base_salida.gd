extends Node3D


signal puerta_abierta

const ColoniaModelo := preload("res://modelos/colonia_modelo.gd")
const Recuerdos := preload("res://progreso/recuerdos.gd")
const RecuerdosModelo := preload("res://modelos/recuerdos_modelo.gd")


const ANCHO := 9.0
const LARGO := 11.0
const ALTO := 4.6
const PUERTA_ANCHO := 6.0
const PUERTA_ALTO := 4.2
const GROSOR := 0.4
const Z_ARRANQUE := -1.6
const Z_SALIDA := 11.5
const T_ABRIR := 2.8


const ESTILOS := {
	"nasa": {"muro": Color(0.90, 0.91, 0.93), "franja": Color(0.12, 0.28, 0.62), "suelo": Color(0.55, 0.56, 0.6),
			"luz": Color(0.85, 0.92, 1.0), "tapa": Color(0.78, 0.8, 0.84)},
	"urss": {"muro": Color(0.62, 0.66, 0.6), "franja": Color(0.75, 0.12, 0.1), "suelo": Color(0.42, 0.43, 0.4),
			"luz": Color(1.0, 0.93, 0.78), "tapa": Color(0.5, 0.54, 0.5)},
	"esa": {"muro": Color(0.92, 0.93, 0.95), "franja": Color(0.1, 0.45, 0.85), "suelo": Color(0.6, 0.62, 0.66),
			"luz": Color(0.8, 0.92, 1.0), "tapa": Color(0.8, 0.83, 0.88)},
	"china": {"muro": Color(0.93, 0.92, 0.9), "franja": Color(0.82, 0.1, 0.1), "suelo": Color(0.56, 0.55, 0.54),
			"luz": Color(1.0, 0.95, 0.85), "tapa": Color(0.8, 0.78, 0.74)},
	"colonia": {"muro": Color(0.2, 0.21, 0.25), "franja": Color(0.96, 0.46, 0.1), "suelo": Color(0.3, 0.3, 0.33),
			"luz": Color(1.0, 0.88, 0.7), "tapa": Color(0.26, 0.27, 0.31)},
	"estacion": {"muro": Color(0.13, 0.22, 0.24), "franja": Color(0.2, 0.9, 0.85), "suelo": Color(0.22, 0.28, 0.3),
			"luz": Color(0.6, 1.0, 0.95), "tapa": Color(0.17, 0.26, 0.28)},
}

var k: float = 1.0
var estilo: String = "nasa"
var abierta: bool = false
var abriendo: bool = false

var _pal: Dictionary = {}
var _puerta: Node3D
var _ang_cerrada: float = -90.0
var _ang_abierta: float = 6.0
var _t: float = 0.0
var _techo: Node3D
var _fondo: Node3D
var _lampara_estado: MeshInstance3D
var _mat_estado: StandardMaterial3D
var _luz_int: OmniLight3D
var _origen: Vector3 = Vector3.ZERO
var _eje_x: Vector3 = Vector3.RIGHT
var _eje_y: Vector3 = Vector3.UP
var _eje_z: Vector3 = Vector3.BACK
var _radio_planeta: float = 1.0
var _h_suelo: float = 0.0
var _h_fin: float = 0.0
var dentro: bool = false


static func estilo_de(datos: Dictionary) -> String:
	var nave := str(datos.get("nave", ""))
	var id := str(datos.get("id", ""))
	if id == "estacion_silenciosa" or nave.contains("Estación"):
		return "estacion"
	var est := str(datos.get("estilo", ""))
	if ESTILOS.has(est):
		return est
	if nave.contains("URSS"):
		return "urss"
	if nave.contains("ESA"):
		return "esa"
	if nave.contains("China"):
		return "china"
	if nave.contains("Colonia"):
		return "colonia"
	return "nasa"


func configurar(up: Vector3, salida: Vector3, h_suelo: float, h_fin: float, radio_planeta: float,
		escala: float, estilo_id: String, nave: String) -> void:
	k = escala
	estilo = estilo_id if ESTILOS.has(estilo_id) else "nasa"
	_pal = ESTILOS[estilo]
	_radio_planeta = radio_planeta
	_h_suelo = h_suelo
	_h_fin = h_fin
	var z := (salida - up * salida.dot(up)).normalized()
	var x := up.cross(z).normalized()
	_eje_x = x
	_eje_y = up
	_eje_z = z
	_origen = up * (radio_planeta + h_suelo)
	transform = Transform3D(Basis(x, up, z) * Basis.from_scale(Vector3.ONE * k), _origen)

	var caida := h_suelo - h_fin
	_ang_abierta = clampf(rad_to_deg(asin(clampf(caida / (PUERTA_ALTO * k), -0.25, 0.3))), -8.0, 12.0)
	_construir(nave)
	var ado := RecuerdosModelo.adorno(self, Recuerdos.puesto("adorno"))
	if ado != null:
		ado.position = Vector3(3.3, 0.08, -3.9)
	var colonia := ColoniaModelo.new()
	colonia.name = "Colonia"
	add_child(colonia)
	colonia.construir(true)
	_poner_puerta(0.0)
	_poner_estado(0)


func local_de(pos_planeta: Vector3) -> Vector3:
	var d := pos_planeta - _origen
	return Vector3(d.dot(_eje_x), d.dot(_eje_y), d.dot(_eje_z)) / k


func dir_de(x: float, z: float) -> Vector3:
	return (_eje_y + (_eje_x * x + _eje_z * z) * k / _radio_planeta).normalized()


func colisiones() -> Array:
	var r: Array = []
	var xm := ANCHO * 0.5 - 0.2
	for z in [-4.0, -2.0, 0.0, 2.0, 4.0]:
		r.append([dir_de(-xm, z), 1.0])
		r.append([dir_de(xm, z), 1.0])
	for x in [-3.4, -1.1, 1.1, 3.4]:
		r.append([dir_de(x, -LARGO * 0.5 + 0.2), 1.2])
	r.append([dir_de(-PUERTA_ANCHO * 0.5 - 0.7, LARGO * 0.5 - 0.2), 1.0])
	r.append([dir_de(PUERTA_ANCHO * 0.5 + 0.7, LARGO * 0.5 - 0.2), 1.0])
	for h: Array in ColoniaModelo.huellas():
		r.append([dir_de(float(h[0]), float(h[1])), float(h[2])])
	return r


func altura_visual(pos_robot: Vector3, h_terreno: float) -> float:
	var l := local_de(pos_robot)
	var zf := LARGO * 0.5
	if l.z < -zf or l.z > zf + PUERTA_ALTO:
		return h_terreno
	var piso := _h_suelo
	if l.z > zf:
		piso = lerpf(_h_suelo, _h_fin, (l.z - zf) / PUERTA_ALTO)
	var w := 1.0 - smoothstep(ANCHO * 0.5 - 1.2, ANCHO * 0.5 + 0.4, absf(l.x))
	return lerpf(h_terreno, piso, w)


func punto_arranque() -> Vector3:
	return dir_de(0.0, Z_ARRANQUE)


func iniciar_salida() -> void:
	if abriendo or abierta:
		return
	abriendo = true
	_t = 0.0
	_poner_estado(1)


func actualizar(delta: float, pos_robot: Vector3) -> void:
	if abriendo and not abierta:
		_t += delta
		var f := clampf(_t / T_ABRIR, 0.0, 1.0)
		_poner_puerta(f * f * (3.0 - 2.0 * f))
		if _mat_estado != null:
			var on := int(_t * 5.0) % 2 == 0
			_mat_estado.emission_energy_multiplier = 3.0 if on else 0.3
		if f >= 1.0:
			abierta = true
			abriendo = false
			_poner_estado(2)
			puerta_abierta.emit()

	var l := local_de(pos_robot)

	var esta_dentro := absf(l.x) < 13.0 and l.z > -LARGO * 0.5 - 6.0 and l.z < LARGO * 0.5 + 9.0
	if esta_dentro != dentro:
		dentro = esta_dentro
		if _techo != null:
			_techo.visible = not dentro
		if _fondo != null:
			_fondo.visible = not dentro


func en_recarga(pos_robot: Vector3) -> bool:
	var l := local_de(pos_robot)
	return absf(l.x) < ANCHO * 0.5 - 0.5 and absf(l.z) < LARGO * 0.5 - 0.3


func z_de(pos_robot: Vector3) -> float:
	return local_de(pos_robot).z


func _poner_puerta(f: float) -> void:
	if _puerta != null:
		_puerta.rotation_degrees.x = lerpf(_ang_cerrada, _ang_abierta, f)


func _poner_estado(e: int) -> void:
	if _mat_estado == null:
		return
	var c := [Color(1.0, 0.18, 0.12), Color(1.0, 0.7, 0.1), Color(0.2, 1.0, 0.4)][e] as Color
	_mat_estado.albedo_color = c
	_mat_estado.emission = c
	_mat_estado.emission_energy_multiplier = 2.5


func _mat(c: Color, metal: float = 0.1, rugosidad: float = 0.7, brillo: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rugosidad
	if brillo > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = brillo
	return m


func _caja(padre: Node3D, tam: Vector3, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = tam
	mi.mesh = bm
	mi.material_override = m
	mi.position = pos
	padre.add_child(mi)
	return mi


func _cil(padre: Node3D, r: float, h: float, pos: Vector3, m: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 14
	mi.mesh = cm
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	padre.add_child(mi)
	return mi


func _construir(nave: String) -> void:
	var muro: Color = _pal["muro"]
	var franja: Color = _pal["franja"]
	var m_muro := _mat(muro, 0.1, 0.65)
	var m_tapa := _mat(_pal["tapa"], 0.15, 0.6)
	var m_franja := _mat(franja, 0.1, 0.5)
	var m_suelo := _mat(_pal["suelo"], 0.0, 0.9)
	var m_oscuro := _mat(Color(0.08, 0.08, 0.1), 0.2, 0.7)
	var m_hormigon := _mat(Color(0.36, 0.34, 0.33), 0.0, 1.0)
	var m_amarillo := _mat(Color(0.92, 0.75, 0.12), 0.0, 0.6)
	var luz_c: Color = _pal["luz"]
	var m_luz := _mat(luz_c, 0.0, 0.4, 2.2)

	var xm := ANCHO * 0.5
	var zm := LARGO * 0.5


	_caja(self, Vector3(ANCHO + 1.8, 3.4, LARGO + 1.8), Vector3(0.0, -1.75, 0.0), m_hormigon)
	_caja(self, Vector3(ANCHO - 0.4, 0.12, LARGO - 0.4), Vector3(0.0, 0.02, 0.0), m_suelo)
	for lado in [-1.0, 1.0]:
		_caja(self, Vector3(0.12, 0.02, LARGO - 1.6), Vector3(lado * 2.2, 0.09, 0.0), m_amarillo)


	for lado in [-1.0, 1.0]:
		_caja(self, Vector3(GROSOR, ALTO, LARGO), Vector3(lado * (xm - GROSOR * 0.5), ALTO * 0.5, 0.0), m_muro)
		_caja(self, Vector3(0.06, 0.55, LARGO - 0.4), Vector3(lado * (xm + 0.02), 1.5, 0.0), m_franja)
		for z in [-4.0, -1.3, 1.4, 4.1]:
			_caja(self, Vector3(0.18, ALTO, 0.3), Vector3(lado * (xm + 0.05), ALTO * 0.5, z), m_tapa)
		_caja(self, Vector3(0.05, 0.12, LARGO - 1.0), Vector3(lado * (xm - GROSOR - 0.02), 3.7, 0.0), m_luz)


	_fondo = Node3D.new()
	add_child(_fondo)
	_caja(_fondo, Vector3(ANCHO, ALTO, GROSOR), Vector3(0.0, ALTO * 0.5, -zm + GROSOR * 0.5), m_muro)
	_caja(_fondo, Vector3(ANCHO - 0.6, 0.5, 0.06), Vector3(0.0, 1.5, -zm - 0.02), m_franja)


	var ancho_bloque := xm - PUERTA_ANCHO * 0.5
	for lado in [-1.0, 1.0]:
		_caja(self, Vector3(ancho_bloque, ALTO, GROSOR + 0.1), Vector3(lado * (PUERTA_ANCHO * 0.5 + ancho_bloque * 0.5), ALTO * 0.5, zm - GROSOR * 0.5), m_muro)
		_caja(self, Vector3(0.25, PUERTA_ALTO, 0.5), Vector3(lado * (PUERTA_ANCHO * 0.5 + 0.12), PUERTA_ALTO * 0.5, zm - GROSOR * 0.5), m_tapa)
	_caja(self, Vector3(PUERTA_ANCHO + 0.5, ALTO - PUERTA_ALTO, GROSOR + 0.1), Vector3(0.0, PUERTA_ALTO + (ALTO - PUERTA_ALTO) * 0.5, zm - GROSOR * 0.5), m_muro)
	_caja(self, Vector3(PUERTA_ANCHO + 0.5, 0.35, 0.06), Vector3(0.0, PUERTA_ALTO + 0.18, zm + 0.04), m_franja)


	_mat_estado = _mat(Color(1.0, 0.18, 0.12), 0.0, 0.4, 2.5)
	_lampara_estado = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.28
	sm.height = 0.56
	_lampara_estado.mesh = sm
	_lampara_estado.material_override = _mat_estado
	_lampara_estado.position = Vector3(0.0, ALTO + 0.45, zm - 0.3)
	add_child(_lampara_estado)
	_caja(self, Vector3(0.7, 0.16, 0.7), Vector3(0.0, ALTO + 0.1, zm - 0.3), m_oscuro)


	var et := Label3D.new()
	et.text = "BASE · " + nave.to_upper()
	et.font_size = 64
	et.pixel_size = 0.0075
	et.modulate = franja.lerp(Color.WHITE, 0.35) if estilo != "estacion" else Color(0.5, 1.0, 0.95)
	et.outline_size = 0
	et.position = Vector3(0.0, PUERTA_ALTO + 0.62, zm + 0.12)
	et.shaded = false
	et.double_sided = false
	add_child(et)


	_techo = Node3D.new()
	add_child(_techo)
	_caja(_techo, Vector3(ANCHO + 0.6, 0.35, LARGO + 0.6), Vector3(0.0, ALTO + 0.17, 0.0), m_tapa)
	_caja(_techo, Vector3(ANCHO + 0.62, 0.1, 0.5), Vector3(0.0, ALTO + 0.36, zm - 0.9), m_franja)
	for z in [-3.0, 0.0, 3.0]:
		_caja(_techo, Vector3(ANCHO - 2.0, 0.05, 0.5), Vector3(0.0, ALTO + 0.37, z), m_luz)
	if estilo == "colonia" or estilo == "estacion":
		var m_panel := _mat(Color(0.07, 0.11, 0.24), 0.4, 0.3)
		for z in [-3.2, 0.6, 4.2]:
			_caja(_techo, Vector3(ANCHO - 1.2, 0.08, 2.6), Vector3(0.0, ALTO + 0.58, z), m_panel)
	_cil(_techo, 0.07, 3.0, Vector3(-3.4, ALTO + 1.9, -3.5), m_tapa)
	_cil(_techo, 0.4, 0.1, Vector3(-3.4, ALTO + 3.2, -3.5), m_muro, Vector3(-25.0, 0.0, 0.0))
	var m_baliza := _mat(Color(1.0, 0.75, 0.2), 0.0, 0.4, 3.0)
	var bal := MeshInstance3D.new()
	var bm := SphereMesh.new()
	bm.radius = 0.2
	bm.height = 0.4
	bal.mesh = bm
	bal.material_override = m_baliza
	bal.position = Vector3(3.6, ALTO + 0.8, -4.6)
	_techo.add_child(bal)

	var mc := StandardMaterial3D.new()
	mc.albedo_color = Color(1.0, 0.75, 0.2, 0.25)
	mc.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mc.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var col := _cil(self, 0.3, 24.0, Vector3(3.6, ALTO + 12.0, -4.6), mc)
	col.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


	var m_carga := _mat(Color(0.2, 1.0, 0.45), 0.0, 0.4, 2.2)
	_caja(self, Vector3(3.2, 1.3, 0.7), Vector3(0.0, 0.7, -zm + 0.9), m_oscuro)
	_caja(self, Vector3(2.6, 0.12, 0.05), Vector3(0.0, 1.1, -zm + 1.27), m_carga)
	_caja(self, Vector3(0.6, 2.2, 0.5), Vector3(-1.9, 1.2, -zm + 0.9), m_tapa)
	_caja(self, Vector3(0.6, 2.2, 0.5), Vector3(1.9, 1.2, -zm + 0.9), m_tapa)
	var m_caja := _mat(franja.darkened(0.15), 0.0, 0.7)
	for z in [-3.6, -2.3, 3.2]:
		_caja(self, Vector3(1.1, 0.9, 1.1), Vector3(-xm + 1.0, 0.5, z), m_caja)
	_caja(self, Vector3(0.9, 0.7, 0.9), Vector3(-xm + 1.0, 1.35, -3.6), m_caja)
	_caja(self, Vector3(0.5, 2.4, 3.6), Vector3(xm - 0.7, 1.3, -1.0), m_tapa)
	for i in range(4):
		_caja(self, Vector3(0.55, 0.06, 3.6), Vector3(xm - 0.7, 0.5 + float(i) * 0.6, -1.0), m_oscuro)
	_luz_int = OmniLight3D.new()
	_luz_int.light_color = luz_c
	_luz_int.light_energy = 1.6
	_luz_int.omni_range = 12.0
	_luz_int.position = Vector3(0.0, 3.6, 0.0)
	_luz_int.shadow_enabled = false
	add_child(_luz_int)


	_puerta = Node3D.new()
	_puerta.position = Vector3(0.0, 0.05, zm)
	add_child(_puerta)
	var largo := PUERTA_ALTO
	_caja(_puerta, Vector3(PUERTA_ANCHO - 0.1, 0.22, largo), Vector3(0.0, 0.0, largo * 0.5), m_tapa)
	_caja(_puerta, Vector3(PUERTA_ANCHO - 0.1, 0.03, largo - 0.2), Vector3(0.0, -0.12, largo * 0.5), m_franja)
	for lado in [-1.0, 1.0]:
		_caja(_puerta, Vector3(0.14, 0.32, largo), Vector3(lado * (PUERTA_ANCHO * 0.5 - 0.1), 0.1, largo * 0.5), m_oscuro)
	for i in range(8):
		_caja(_puerta, Vector3(PUERTA_ANCHO - 0.7, 0.04, 0.12), Vector3(0.0, 0.13, 0.4 + float(i) * (largo - 0.8) / 7.0), m_oscuro)
	_caja(_puerta, Vector3(PUERTA_ANCHO - 0.4, 0.04, 0.3), Vector3(0.0, 0.13, largo - 0.15), m_amarillo)
