extends Node3D


const DatosMarte := preload("res://datos/datos_marte.gd")
const AmbienteMision := preload("res://mision/ambiente_mision.gd")

const COLOR_FOTO := Color(0.78, 0.55, 1.0)
const COLOR_LISTO := Color(0.4, 1.0, 0.55)
const DIST_CIELO := 20.0
const ALCANCE_MAX := 260.0
const LLENADO_MIN := 0.08
const LLENADO_BUENO := 0.2
const LLENADO_MAX := 1.6
const CENTRADO_BUENO := 0.35
const ENCUADRE_MAX := 0.95
const Partidas := preload("res://nucleo/partidas.gd")

var mision: Node3D
var k: float = 0.1
var blancos: Array[Dictionary] = []
var _t: float = 0.0
var _rng := RandomNumberGenerator.new()
var _mat_marca: StandardMaterial3D
var _mat_marca_ok: StandardMaterial3D
var _mat_remolino: ShaderMaterial


func configurar(m: Node3D, k_: float, semilla: int) -> void:
	mision = m
	k = k_
	_rng.seed = semilla * 17 + 5


func crear(ids: Array, dirs: Dictionary) -> void:
	_mat_marca = _material(COLOR_FOTO, 0.3)
	_mat_marca_ok = _material(COLOR_LISTO, 0.3)
	for id in ids:
		var info: Dictionary = DatosMarte.BLANCOS_FOTO[str(id)]
		var b := {"id": str(id), "nombre": str(info["nombre"]), "tipo": str(info["tipo"]),
				"pista": str(info["pista"]), "dato": str(info["dato"]),
				"dir": dirs[str(id)] as Vector3, "radio": float(info.get("radio", 4.0)),
				"ang": deg_to_rad(float(info.get("ang", 1.0))), "dmin": float(info.get("dmin", 0.0)),
				"hecho": false, "transmitido": false, "estrellas": 0, "tex": null, "ruta": "",
				"nodo": null, "marca": null, "marca_mat": null, "centro_alto": 0.0, "gema": null}
		match str(info["tipo"]):
			"cielo":
				_crear_astro(b)
			_:
				match str(id):
					"estratos": _crear_estratos(b)
					"remolino": _crear_remolino(b)
					_: pass
		blancos.append(b)


func _material(c: Color, alfa: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alfa)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _pbr(c: Color, rugosidad: float = 0.92) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rugosidad
	return m


func _anclar(dir: Vector3) -> Node3D:
	var n := Node3D.new()
	n.transform = Transform3D(mision.base_en(dir) * Basis.from_scale(Vector3.ONE * k), mision.punto_suelo(dir))
	add_child(n)
	return n


func _crear_estratos(b: Dictionary) -> void:
	var raiz := _anclar(b["dir"])
	var capas: Array[Color] = [Color(0.46, 0.3, 0.22), Color(0.7, 0.52, 0.36), Color(0.5, 0.33, 0.24),
			Color(0.76, 0.6, 0.42), Color(0.55, 0.38, 0.27), Color(0.68, 0.5, 0.34)]
	var y := 0.0
	var ancho := 9.0
	var fondo := 6.0
	for i in range(capas.size()):
		var alto := _rng.randf_range(0.55, 0.9)
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(ancho, alto, fondo)
		mi.mesh = bm
		mi.material_override = _pbr(capas[i])
		mi.position = Vector3(_rng.randf_range(-0.35, 0.35), y + alto * 0.5 - 0.3, _rng.randf_range(-0.3, 0.3))
		mi.rotation = Vector3(_rng.randf_range(-0.03, 0.03), _rng.randf_range(-0.1, 0.1), _rng.randf_range(-0.04, 0.04))
		raiz.add_child(mi)
		y += alto
		ancho *= _rng.randf_range(0.82, 0.93)
		fondo *= _rng.randf_range(0.82, 0.93)

	for i in range(5):
		var a := _rng.randf() * TAU
		var r := _rng.randf_range(0.5, 1.1)
		var mi2 := MeshInstance3D.new()
		var bm2 := BoxMesh.new()
		bm2.size = Vector3(r * 1.5, r, r * 1.2)
		mi2.mesh = bm2
		mi2.material_override = _pbr(capas[i % capas.size()].darkened(0.1))
		mi2.position = Vector3(cos(a) * 4.8, r * 0.3 - 0.2, sin(a) * 3.6)
		mi2.rotation = Vector3(_rng.randf() * 0.5, _rng.randf() * TAU, _rng.randf() * 0.5)
		raiz.add_child(mi2)
	b["nodo"] = raiz
	b["centro_alto"] = 2.2
	mision.registrar_obstaculo(b["dir"], 3.6 * k)
	_crear_marca(b, raiz, 9.0)


func _crear_remolino(b: Dictionary) -> void:
	var fn := FastNoiseLite.new()
	fn.seed = 91
	fn.frequency = 0.04
	fn.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.noise = fn
	tex.width = 256
	tex.height = 256
	tex.seamless = true
	var sh := Shader.new()
	sh.code = AmbienteMision.SHADER_REMOLINO
	_mat_remolino = ShaderMaterial.new()
	_mat_remolino.shader = sh
	_mat_remolino.set_shader_parameter("ruido", tex)
	_mat_remolino.set_shader_parameter("color", Color(0.86, 0.66, 0.5))
	_mat_remolino.set_shader_parameter("opacidad", 0.8)
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 0.22
	cm.height = 1.0
	cm.radial_segments = 28
	cm.rings = 16
	var mi := MeshInstance3D.new()
	mi.mesh = cm
	mi.material_override = _mat_remolino
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-2.0, -1.0, -2.0), Vector3(4.0, 3.0, 4.0))
	add_child(mi)
	b["nodo"] = mi
	b["ancla"] = b["dir"]
	b["rumbo"] = _rng.randf() * TAU
	b["alto"] = 34.0
	b["ancho"] = 4.6
	b["centro_alto"] = 14.0
	_colocar_remolino(b)
	var marca := Node3D.new()
	add_child(marca)
	b["marca_raiz"] = marca
	_crear_marca(b, marca, 40.0)
	_colocar_marca_remolino(b)


func _colocar_remolino(b: Dictionary) -> void:
	var dir: Vector3 = b["dir"]
	var alto: float = float(b["alto"]) * k
	var radio: float = float(b["ancho"]) * k
	var bas: Basis = mision.base_en(dir) * Basis.from_scale(Vector3(radio * 2.0, alto, radio * 2.0))
	(b["nodo"] as MeshInstance3D).transform = Transform3D(bas, mision.punto_suelo(dir) + dir * (alto * 0.5))


func _colocar_marca_remolino(b: Dictionary) -> void:
	var dir: Vector3 = b["dir"]
	(b["marca_raiz"] as Node3D).transform = Transform3D(
			mision.base_en(dir) * Basis.from_scale(Vector3.ONE * k), mision.punto_suelo(dir))


func _crear_marca(b: Dictionary, padre: Node3D, alto_haz: float) -> void:
	var haz := CylinderMesh.new()
	haz.top_radius = 0.3
	haz.bottom_radius = 0.3
	haz.height = alto_haz
	haz.radial_segments = 8
	haz.rings = 1
	var mi := MeshInstance3D.new()
	mi.mesh = haz
	mi.material_override = _mat_marca
	mi.position = Vector3(0.0, alto_haz * 0.5, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(mi)
	var sm := SphereMesh.new()
	sm.radial_segments = 4
	sm.rings = 2
	sm.radius = 0.6
	sm.height = 1.2
	var gema := MeshInstance3D.new()
	gema.mesh = sm
	var mg := StandardMaterial3D.new()
	mg.albedo_color = COLOR_FOTO
	mg.emission_enabled = true
	mg.emission = COLOR_FOTO
	mg.emission_energy_multiplier = 1.1
	gema.material_override = mg
	gema.scale = Vector3(0.8, 1.35, 0.8)
	gema.position = Vector3(0.0, alto_haz + 1.6, 0.0)
	gema.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(gema)
	b["marca"] = mi
	b["gema"] = gema
	b["marca_mat"] = mg
	b["alto_haz"] = alto_haz


func _crear_astro(b: Dictionary) -> void:
	var tex: ImageTexture = _textura_tierra() if str(b["id"]) == "tierra" else _textura_fobos()
	var cuerpo := 0.2 if str(b["id"]) == "tierra" else 0.62
	var mitad := DIST_CIELO * tan(float(b["ang"])) / cuerpo
	var qm := QuadMesh.new()
	qm.size = Vector2(mitad * 2.0, mitad * 2.0)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.disable_fog = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mi := MeshInstance3D.new()
	mi.mesh = qm
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-50.0, -50.0, -50.0), Vector3(100.0, 100.0, 100.0))
	add_child(mi)
	b["nodo"] = mi
	b["dir"] = (b["dir"] as Vector3).normalized()


func _textura_tierra() -> ImageTexture:
	var n := 128
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in range(n):
		for x in range(n):
			var d := Vector2(float(x) + 0.5 - float(n) * 0.5, float(y) + 0.5 - float(n) * 0.5).length() / (float(n) * 0.5)
			var nucleo := 1.0 - smoothstep(0.17, 0.22, d)
			var halo := pow(clampf(1.0 - d, 0.0, 1.0), 3.0) * 0.8
			var a := clampf(nucleo + halo, 0.0, 1.0)
			var c := Color(0.55, 0.74, 1.0).lerp(Color(0.86, 0.94, 1.0), nucleo)
			img.set_pixel(x, y, Color(c.r, c.g, c.b, a))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func _textura_fobos() -> ImageTexture:
	var n := 192
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var ruido := FastNoiseLite.new()
	ruido.seed = 33
	ruido.frequency = 0.045
	ruido.fractal_octaves = 3
	var cr: Array[Vector3] = []
	for i in range(9):
		cr.append(Vector3(_rng.randf_range(-0.35, 0.35), _rng.randf_range(-0.25, 0.25), _rng.randf_range(0.05, 0.13)))
	var luz := Vector3(-0.6, -0.35, 0.72).normalized()
	for y in range(n):
		for x in range(n):
			var u := (float(x) + 0.5) / float(n) * 2.0 - 1.0
			var v := (float(y) + 0.5) / float(n) * 2.0 - 1.0
			var ang := atan2(v, u)
			var rr := Vector2(u * 1.0, v * 1.28).length()
			var borde := 0.78 + 0.1 * ruido.get_noise_2d(cos(ang) * 40.0 + 60.0, sin(ang) * 40.0 + 60.0)
			var a := 1.0 - smoothstep(borde - 0.02, borde + 0.01, rr)
			if a <= 0.0:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var z := sqrt(maxf(1.0 - rr * rr / (borde * borde), 0.0))
			var nrm := Vector3(u / borde, v * 1.28 / borde, z).normalized()
			var sombra := clampf(nrm.dot(luz) * 0.9 + 0.12, 0.05, 1.0)
			var base := 0.42 + 0.14 * ruido.get_noise_2d(float(x), float(y))
			var oscuro := 0.0
			for c in cr:
				var dc := Vector2(u - c.x, v - c.y).length()
				if dc < c.z:
					oscuro += (1.0 - dc / c.z) * 0.35
				elif dc < c.z * 1.25:
					oscuro -= 0.07
			var g := clampf((base - oscuro) * sombra * 1.5, 0.0, 1.0)
			img.set_pixel(x, y, Color(g * 1.04, g * 0.97, g * 0.9, a))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func actualizar(delta: float, pos_robot: Vector3) -> void:
	_t += delta
	for b in blancos:
		var tipo := str(b["tipo"])
		if tipo == "cielo":
			(b["nodo"] as Node3D).position = pos_robot + (b["dir"] as Vector3) * DIST_CIELO
			continue
		if str(b["id"]) == "remolino":
			_vagar(b, delta)
		var gema = b.get("gema")
		if gema != null and is_instance_valid(gema):
			(gema as Node3D).rotation.y += delta * 1.5
			var alto_haz: float = float(b["alto_haz"])
			(gema as Node3D).position.y = alto_haz + 1.6 + 0.4 * sin(_t * 2.0)


func _vagar(b: Dictionary, delta: float) -> void:
	var dir: Vector3 = b["dir"]
	var rumbo: float = float(b["rumbo"]) + _rng.randf_range(-0.7, 0.7) * delta
	var ancla: Vector3 = b["ancla"]
	if mision.distancia_gm(dir, ancla) > 40.0:
		var hacia: Vector3 = (ancla - dir).normalized()
		var t1: Vector3 = mision.tangente_en(dir, 0.0)
		var t2: Vector3 = dir.cross(t1)
		rumbo = atan2(hacia.dot(t2), hacia.dot(t1))
	b["rumbo"] = rumbo
	var nueva: Vector3 = mision.mover_dir(dir, mision.tangente_en(dir, rumbo), 2.2 * k * delta)
	b["dir"] = nueva
	_colocar_remolino(b)
	_colocar_marca_remolino(b)


func centro_de(b: Dictionary, desde: Vector3) -> Vector3:
	if str(b["tipo"]) == "cielo":
		return desde + (b["dir"] as Vector3) * DIST_CIELO
	var dir: Vector3 = b["dir"]
	var p: Vector3 = mision.punto_suelo(dir)
	if str(b["id"]) == "lander":
		return mision.punto_suelo(dir) + dir * (4.0 * k)
	return p + dir * (float(b["centro_alto"]) * k)


func evaluar(cam_pos: Vector3, fwd: Vector3, fov_v: float) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	var mitad := fov_v * 0.5
	for i in range(blancos.size()):
		var b: Dictionary = blancos[i]
		var cielo := str(b["tipo"]) == "cielo"
		var c := centro_de(b, cam_pos)
		var v := c - cam_pos
		var dist_gm := v.length() / k
		if v.length() < 0.00001:
			continue
		var rel := fwd.angle_to(v) / mitad
		if rel > ENCUADRE_MAX:
			continue
		var radio_ang: float = float(b["ang"]) if cielo else atan(float(b["radio"]) / maxf(dist_gm, 0.01))
		var llenado := radio_ang / mitad
		var r := {"i": i, "nombre": str(b["nombre"]), "ok": false, "estrellas": 0, "motivo": "", "rel": rel, "llenado": llenado}
		if not cielo and dist_gm > ALCANCE_MAX:
			r["motivo"] = "demasiado lejos"
		elif not cielo and dist_gm < float(b["dmin"]):
			r["motivo"] = "demasiado cerca" if str(b["id"]) != "lander" else "aléjate más del módulo"
		elif llenado < LLENADO_MIN:
			r["motivo"] = "se ve muy pequeño: usa el zoom (rueda del ratón)" if cielo else "se ve muy pequeño: acércate o usa el zoom"
		elif llenado > LLENADO_MAX:
			r["motivo"] = "queda cortado: reduce el zoom"
		else:
			var destino := (cam_pos + (b["dir"] as Vector3) * (300.0 * k)) if cielo else c
			if not mision.linea_libre(cam_pos, destino):
				r["motivo"] = "lo tapa el terreno"
			else:
				r["ok"] = true
				var e := 1
				if rel <= CENTRADO_BUENO:
					e += 1
				if llenado >= LLENADO_BUENO:
					e += 1
				r["estrellas"] = e
		res.append(r)
	return res


func hay_enfoque(cam_pos: Vector3, fwd: Vector3, fov_v: float) -> bool:
	for r in evaluar(cam_pos, fwd, fov_v):
		if bool(r["ok"]) and not bool(blancos[int(r["i"])]["hecho"]):
			return true
	return false


func registrar(i: int, estrellas: int, img: Image) -> bool:
	var b: Dictionary = blancos[i]
	if bool(b["hecho"]) and estrellas <= int(b["estrellas"]):
		return false
	b["hecho"] = true
	b["estrellas"] = estrellas
	b["transmitido"] = false
	if img != null and not img.is_empty():
		var mini_img: Image = img.duplicate()
		mini_img.resize(352, int(round(352.0 * float(img.get_height()) / float(maxi(img.get_width(), 1)))), Image.INTERPOLATE_LANCZOS)
		b["tex"] = ImageTexture.create_from_image(mini_img)
		DirAccess.make_dir_recursive_absolute(Partidas.subcarpeta("fotos"))
		var ruta := "%s/%s_%s.png" % [Partidas.subcarpeta("fotos"), str(mision.id_mision), str(b["id"])]
		if img.save_png(ruta) == OK:
			b["ruta"] = ruta
	_marcar_hecho(b)
	return true


func _marcar_hecho(b: Dictionary) -> void:
	var mg = b.get("marca_mat")
	if mg != null:
		(mg as StandardMaterial3D).albedo_color = COLOR_LISTO
		(mg as StandardMaterial3D).emission = COLOR_LISTO
	var haz = b.get("marca")
	if haz != null:
		(haz as MeshInstance3D).material_override = _mat_marca_ok


func total() -> int:
	return blancos.size()


func hechos() -> int:
	var n := 0
	for b in blancos:
		if bool(b["hecho"]):
			n += 1
	return n


func por_transmitir() -> int:
	var n := 0
	for b in blancos:
		if bool(b["hecho"]) and not bool(b["transmitido"]):
			n += 1
	return n


func transmitidos() -> int:
	var n := 0
	for b in blancos:
		if bool(b["transmitido"]):
			n += 1
	return n


func transmitir_uno() -> Dictionary:
	for b in blancos:
		if bool(b["hecho"]) and not bool(b["transmitido"]):
			b["transmitido"] = true
			return b
	return {}


func primer_pendiente() -> Dictionary:
	for b in blancos:
		if not bool(b["hecho"]):
			return b
	return {}


func estrellas_totales() -> int:
	var n := 0
	for b in blancos:
		n += int(b["estrellas"])
	return n


func estados() -> Array:
	var r: Array = []
	for b in blancos:
		var e := 0
		if bool(b["transmitido"]):
			e = 2
		elif bool(b["hecho"]):
			e = 1
		r.append({"nombre": str(b["nombre"]), "estado": e, "estrellas": int(b["estrellas"])})
	return r


func album() -> Array:
	var r: Array = []
	for b in blancos:
		r.append({"nombre": str(b["nombre"]), "estrellas": int(b["estrellas"]), "tex": b["tex"]})
	return r


func contactos_suelo(desde: Vector3, alcance_gm: float) -> Array:
	var r: Array = []
	for b in blancos:
		if str(b["tipo"]) != "suelo" or bool(b["hecho"]) or str(b["id"]) == "lander":
			continue
		var d: float = mision.distancia_gm(desde.normalized(), b["dir"])
		if d < alcance_gm:
			r.append({"dir": b["dir"], "nombre": str(b["nombre"]), "dist": d})
	r.sort_custom(func(x, y): return float(x["dist"]) < float(y["dist"]))
	return r
