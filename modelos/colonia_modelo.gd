extends Node3D


const Colonia := preload("res://progreso/colonia_estado.gd")


const POS := {
	"invernadero": Vector2(-13.0, -1.0),
	"antena": Vector2(13.0, -5.0),
	"paneles": Vector2(-13.0, -12.0),
	"laboratorio": Vector2(13.0, 5.0),
}

var _mats: Dictionary = {}


func construir(cimientos: bool = true, niveles: Dictionary = {}) -> void:
	for id in Colonia.ORDEN:
		var n: int = int(niveles[id]) if niveles.has(id) else Colonia.nivel(id)
		if n <= 0:
			continue
		var raiz := Node3D.new()
		raiz.name = id
		raiz.position = Vector3(POS[id].x, 0.0, POS[id].y)
		add_child(raiz)
		if cimientos:
			var losa := Vector3(6.4, 3.0, 6.4)
			var cz := 0.0
			match id:
				"invernadero": losa.z = 5.2 * float(n) + 1.6
				"paneles": losa = Vector3(9.4, 3.0, 2.6 * float(n) + 2.4)
				"laboratorio":
					losa.z = 6.4 + (4.7 if n >= 2 else 0.0)
					cz = 2.35 if n >= 2 else 0.0
			_caja(raiz, losa, Vector3(0, -1.35, cz), _m("losa", Color(0.2, 0.2, 0.22), 0.2, 0.8))
		match id:
			"invernadero": _invernadero(raiz, n)
			"antena": _antena(raiz, n)
			"paneles": _paneles(raiz, n)
			"laboratorio": _laboratorio(raiz, n)


static func huellas() -> Array:
	var r: Array = []
	for id in Colonia.ORDEN:
		var n := Colonia.nivel(id)
		if n <= 0:
			continue
		var p: Vector2 = POS[id]
		match id:
			"invernadero":
				for i in range(n):
					r.append([p.x, p.y + float(i) * 5.2 - float(n - 1) * 2.6, 2.7])
			"antena":
				r.append([p.x, p.y, 1.6])
			"paneles":
				r.append([p.x, p.y, 2.6 + 0.4 * float(n)])
			"laboratorio":
				r.append([p.x, p.y, 3.2])
	return r


func _m(clave: String, c: Color, metal: float = 0.1, rug: float = 0.7, brillo: float = 0.0, alfa: float = 1.0) -> StandardMaterial3D:
	if _mats.has(clave):
		return _mats[clave]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alfa)
	m.metallic = metal
	m.roughness = rug
	if brillo > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = brillo
	if alfa < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mats[clave] = m
	return m


func _caja(padre: Node3D, tam: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = tam
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	padre.add_child(mi)
	return mi


func _cil(padre: Node3D, r_sup: float, r_inf: float, alto: float, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r_sup
	cm.bottom_radius = r_inf
	cm.height = alto
	cm.radial_segments = 16
	cm.rings = 1
	mi.mesh = cm
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	padre.add_child(mi)
	return mi


func _esfera(padre: Node3D, radio: float, pos: Vector3, mat: Material, media: bool = false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radio
	sm.height = radio if media else radio * 2.0
	sm.is_hemisphere = media
	sm.radial_segments = 20
	sm.rings = 10
	mi.mesh = sm
	mi.material_override = mat
	mi.position = pos
	padre.add_child(mi)
	return mi


func _invernadero(raiz: Node3D, n: int) -> void:
	var verde: Color = Colonia.MODULOS["invernadero"]["c"]
	var vidrio := _m("vidrio", Color(0.6, 1.0, 0.8), 0.0, 0.1, 0.25, 0.30)
	var marco := _m("marco", Color(0.85, 0.88, 0.9), 0.5, 0.4)
	var planta := _m("planta", verde, 0.0, 0.8, 0.9)
	for i in range(n):
		var z: float = float(i) * 5.2 - float(n - 1) * 2.6
		var c := Node3D.new()
		c.position = Vector3(0, 0, z)
		raiz.add_child(c)
		_cil(c, 2.6, 2.6, 0.3, Vector3(0, 0.3, 0), marco)
		_esfera(c, 2.4, Vector3(0, 0.45, 0), vidrio, true)
		for j in range(7):
			var a := TAU * float(j) / 7.0
			var rr := 0.9 + 0.35 * float(j % 3)
			_esfera(c, 0.42 + 0.12 * float(j % 2), Vector3(cos(a) * rr, 0.75 + 0.2 * float(j % 2), sin(a) * rr), planta)
		_cil(c, 0.05, 0.05, 2.5, Vector3(0, 1.65, 0), marco)
		if i > 0:
			_cil(c, 0.5, 0.5, 2.8, Vector3(0, 0.9, -2.6), marco, Vector3(90, 0, 0))


func _antena(raiz: Node3D, n: int) -> void:
	var acento: Color = Colonia.MODULOS["antena"]["c"]
	var metal := _m("metal", Color(0.8, 0.82, 0.86), 0.6, 0.35)
	var blanco := _m("blanco", Color(0.93, 0.93, 0.96), 0.1, 0.5)
	var luz := _m("luz_ant", acento, 0.0, 0.5, 2.0)
	var alto: float = 6.0 + 3.0 * float(n)
	_cil(raiz, 0.28, 0.45, alto, Vector3(0, alto * 0.5 + 0.2, 0), metal)
	for i in range(n):
		var y: float = alto * (0.55 + 0.2 * float(i)) if n > 1 else alto * 0.85
		var giro: float = 40.0 + 80.0 * float(i)
		var plato := Node3D.new()
		plato.position = Vector3(0, y, 0)
		plato.rotation_degrees = Vector3(0, giro, 0)
		raiz.add_child(plato)
		_cil(plato, 1.5 - 0.15 * float(i), 0.2, 0.5, Vector3(0.9, 0, 0), blanco, Vector3(0, 0, 90))
		_cil(plato, 0.04, 0.04, 1.1, Vector3(1.3, 0, 0), metal, Vector3(0, 0, 90))
	_esfera(raiz, 0.25, Vector3(0, alto + 0.5, 0), luz)
	_caja(raiz, Vector3(2.0, 1.2, 1.6), Vector3(2.4, 0.8, 1.5), blanco)


func _paneles(raiz: Node3D, n: int) -> void:
	var azul := _m("panel", Color(0.1, 0.2, 0.55), 0.7, 0.2, 0.15)
	var marco := _m("marco_p", Color(0.8, 0.82, 0.86), 0.5, 0.4)
	for fila in range(n):
		for col in range(2):
			var x: float = -1.9 + 3.8 * float(col)
			var z: float = float(fila) * 2.6 - float(n - 1) * 1.3
			_caja(raiz, Vector3(3.4, 0.12, 2.2), Vector3(x, 1.5, z), azul, Vector3(-25, 0, 0))
			_cil(raiz, 0.07, 0.07, 1.4, Vector3(x, 0.8, z), marco)
			_caja(raiz, Vector3(3.5, 0.05, 0.05), Vector3(x, 1.52, z), marco, Vector3(-25, 0, 0))


func _laboratorio(raiz: Node3D, n: int) -> void:
	var morado: Color = Colonia.MODULOS["laboratorio"]["c"]
	var casco := _m("casco_lab", Color(0.88, 0.89, 0.92), 0.2, 0.55)
	var banda := _m("banda_lab", morado, 0.0, 0.5, 1.2)
	var vent := _m("vent_lab", Color(0.75, 0.95, 1.0), 0.0, 0.3, 1.6)
	var plato := _m("plato_lab", Color(0.95, 0.95, 0.98), 0.1, 0.4)
	var unidades: Array = [Vector3(0, 1.3, 0), Vector3(0, 1.3, 4.7), Vector3(0, 3.7, 2.35)]
	for i in range(n):
		var p: Vector3 = unidades[i]
		_caja(raiz, Vector3(4.4, 2.4, 4.4), p, casco)
		_caja(raiz, Vector3(4.45, 0.18, 4.45), p + Vector3(0, 0.9, 0), banda)
		for lado in [-1.0, 1.0]:
			_caja(raiz, Vector3(0.05, 0.7, 1.4), p + Vector3(lado * 2.22, 0.1, 0), vent)
	if n >= 2:
		_cil(raiz, 0.1, 0.1, 1.2, Vector3(-1.4, 2.9, 0), casco)
		_cil(raiz, 0.9, 0.1, 0.35, Vector3(-1.4, 3.7, 0), plato, Vector3(-30, 0, 0))
