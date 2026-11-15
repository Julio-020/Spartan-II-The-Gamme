extends Node3D


signal aviso(titulo: String, texto: String, color: Color, radio: String)
signal golpe(energia: float)
signal sensor_averiado(segundos: float)
signal sonido(nombre: String, dist_gm: float)
signal hito()
signal bonus(energia: float)
signal datos(cantidad: int)

const AmbienteMision := preload("res://mision/ambiente_mision.gd")
const Muestras := preload("res://mision/muestras.gd")
const Idioma := preload("res://nucleo/idioma.gd")

const TIPOS := ["meteoritos", "remolino", "sensor", "derrumbe", "senal", "rover_viejo", "tormenta", "rescate"]
const PRIMER_EVENTO := [70.0, 110.0]
const ENTRE_EVENTOS := [95.0, 165.0]
const FACTOR_DIF := [1.4, 1.0, 0.75]
const DANO_METEORITO := 8.0
const RADIO_PELIGRO := 6.0
const MAX_CRATERES := 14

var mision: Node3D = null
var k: float = 0.1
var tipos: Dictionary = {}
var rescatado: bool = false
var vividos: int = 0
var lento: float = 0.0
var evento_actual: String = ""

var _rng := RandomNumberGenerator.new()
var _dif: int = 1
var _prox: float = 80.0
var _ult: String = ""
var _t: float = 0.0
var _imp: Array = []
var _craters: Array[Node3D] = []
var _rem: Dictionary = {}
var _mat_rem: ShaderMaterial
var _dentro_rem: bool = false
var poi_dir: Vector3 = Vector3.ZERO
var poi_tipo: String = ""
var _poi: Node3D = null
var _poi_luz: OmniLight3D = null
var _der: Dictionary = {}
var _pilas: int = 0
var rescate_cerca: bool = false
var _resc_ayudado: bool = false
var _resc_t: float = -1.0
var _resc_mat: StandardMaterial3D


func configurar(m: Node3D, escala: float, semilla: int, dificultad: int) -> void:
	mision = m
	k = escala
	_dif = clampi(dificultad, 0, 2)
	_rng.seed = semilla * 7919 + 13
	_prox = _rng.randf_range(PRIMER_EVENTO[0], PRIMER_EVENTO[1]) * float(FACTOR_DIF[_dif])


func actualizar(delta: float, tiempo: float, up: Vector3, permitido: bool) -> void:
	if evento_actual == "":
		lento = move_toward(lento, 0.0, delta * 1.5)
		if tiempo >= _prox:
			if permitido:
				_empezar(up)
			else:
				_prox = tiempo + 8.0
		return
	_t += delta
	match evento_actual:
		"meteoritos": _paso_meteoritos(delta, up)
		"remolino": _paso_remolino(delta, up)
		"derrumbe": _paso_derrumbe(delta, up)
		"senal", "rover_viejo": _paso_poi(delta, up)
		"rescate": _paso_rescate(delta, up)
	if evento_actual == "":
		_prox = tiempo + _rng.randf_range(ENTRE_EVENTOS[0], ENTRE_EVENTOS[1]) * float(FACTOR_DIF[_dif])


func forzar(tipo: String, up: Vector3) -> void:
	if evento_actual == "":
		_iniciar(tipo, up)


func _empezar(up: Vector3) -> void:
	var opciones: Array = []
	for t in TIPOS:
		if t != _ult:
			opciones.append(t)
	var tipo: String = opciones[_rng.randi() % opciones.size()]

	if _ult != "meteoritos" and _rng.randf() < 0.3:
		tipo = "meteoritos"
	_iniciar(tipo, up)


func _iniciar(tipo: String, up: Vector3) -> void:
	_ult = tipo
	tipos[tipo] = true
	_t = 0.0
	hito.emit()
	match tipo:
		"meteoritos":
			evento_actual = tipo
			_preparar_meteoritos(up)
			aviso.emit("Lluvia de meteoritos", "Alerta: vienen impactos. Sal de los círculos rojos antes de que caigan.",
					Color(1.0, 0.4, 0.3), "meteoritos")
		"remolino":
			evento_actual = tipo
			_preparar_remolino(up)
			aviso.emit("Remolino de polvo", "Un remolino enorme se acerca. Apártate de su camino: dentro vas lento y gastas más batería.",
					Color(1.0, 0.72, 0.25), "remolino")
		"sensor":
			vividos += 1
			aviso.emit("Fallo del escáner", "El sensor se bloqueó. Quédate quieto 5 segundos para reiniciarlo.",
					Color(0.45, 0.82, 1.0), "sensor")
			sensor_averiado.emit(22.0)
		"derrumbe":
			evento_actual = tipo
			_preparar_derrumbe(up)
			aviso.emit(Idioma.t("Derrumbe"), Idioma.t("Se oyen rocas caer delante de ti. Mira el círculo rojo y apártate de él."),
					Color(1.0, 0.55, 0.3), "")
		"senal", "rover_viejo":
			evento_actual = tipo
			_preparar_poi(tipo, up)
			if tipo == "senal":
				aviso.emit(Idioma.t("Señal desconocida"), Idioma.t("La radio capta una señal que no está en ningún catálogo. Sale de un punto del radar (?): %s.") % _pista(poi_dir, up),
						Color(0.5, 0.9, 1.0), "")
			else:
				aviso.emit(Idioma.t("Restos de un rover"), Idioma.t("El escáner detecta metal viejo semienterrado (?): %s.") % _pista(poi_dir, up),
						Color(1.0, 0.8, 0.4), "")
		"rescate":
			evento_actual = tipo
			_preparar_poi(tipo, up)
			aviso.emit(Idioma.t("Un rover pide ayuda"), Idioma.t("Un rover hermano se quedó sin batería y manda una baliza de socorro (SOS en el radar): %s. Junto a él, pulsa E para pasarle un poco de la tuya.") % _pista(poi_dir, up),
					Color(1.0, 0.45, 0.35), "")
		"tormenta":
			if mision.tormenta_repentina():
				vividos += 1
				aviso.emit(Idioma.t("Tormenta repentina"), Idioma.t("Un muro de polvo se echa encima. Busca refugio: dentro de la tormenta no se recarga."),
						Color(1.0, 0.72, 0.25), "")
			else:
				_iniciar("derrumbe", up)


func _preparar_meteoritos(up: Vector3) -> void:
	_imp.clear()
	var n := _rng.randi_range(5, 7)
	var t := 3.5
	for i in range(n):
		var dist := _rng.randf_range(4.0, 9.0) if i == 0 else _rng.randf_range(5.0, 30.0)
		var dir: Vector3 = mision.dir_lejana(dist, _rng.randf() * TAU)
		_imp.append({"dir": dir, "t": t, "ring": null, "mat": null, "estela": null, "estado": 0})
		t += _rng.randf_range(1.0, 1.6)


func _paso_meteoritos(delta: float, up: Vector3) -> void:
	var quedan := 0
	for im in _imp:
		var estado: int = im["estado"]
		if estado == 3:
			continue
		quedan += 1
		var ti: float = im["t"]
		var dir: Vector3 = im["dir"]
		if estado == 0 and _t >= ti - 2.5:
			_crear_aviso_suelo(im)
			im["estado"] = 1
		if im["estado"] == 1:

			var mat: StandardMaterial3D = im["mat"]
			mat.albedo_color.a = 0.2 + 0.18 * sin(_t * 12.0)
			if _t >= ti - 0.55:
				_crear_estela(im)
				im["estado"] = 2
		if im["estado"] == 2:
			var f := clampf((_t - (ti - 0.55)) / 0.55, 0.0, 1.0)
			var e: MeshInstance3D = im["estela"]
			var desde: Vector3 = im["desde"]
			var hasta: Vector3 = im["hasta"]
			e.position = desde.lerp(hasta, f)
			if f >= 1.0:
				_impactar(im, up)
				im["estado"] = 3
	if quedan == 0 and _t > 2.0:
		vividos += 1
		evento_actual = ""


func _crear_aviso_suelo(im: Dictionary) -> void:
	var dir: Vector3 = im["dir"]
	var disco := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 1.0
	cm.height = 0.01
	cm.radial_segments = 40
	disco.mesh = cm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.18, 0.1, 0.3)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	disco.material_override = mat
	disco.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var r := RADIO_PELIGRO * k
	disco.transform = Transform3D(mision.base_en(dir) * Basis.from_scale(Vector3(r, 1.0, r)),
			mision.punto_suelo(dir) + dir * (0.004 * k * 10.0))
	mision.add_child(disco)
	im["ring"] = disco
	im["mat"] = mat


func _crear_estela(im: Dictionary) -> void:
	var dir: Vector3 = im["dir"]
	var suelo: Vector3 = mision.punto_suelo(dir)
	var t1: Vector3 = mision.tangente_en(dir, _rng.randf() * TAU)
	var desde := suelo + dir * (70.0 * k) + t1 * (35.0 * k)
	var largo := 9.0 * k
	var e := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.35 * k, 0.35 * k, largo)
	e.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.7, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.5, 0.15)
	mat.emission_energy_multiplier = 3.0
	e.material_override = mat
	e.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var camino := (suelo - desde).normalized()
	e.basis = Basis.looking_at(camino, dir)
	e.position = desde
	mision.add_child(e)
	im["estela"] = e
	im["desde"] = desde
	im["hasta"] = suelo


func _impactar(im: Dictionary, up: Vector3) -> void:
	var dir: Vector3 = im["dir"]
	var suelo: Vector3 = mision.punto_suelo(dir)
	var dist: float = mision.distancia_gm(dir, up)
	for n in [im["ring"], im["estela"]]:
		if n != null:
			(n as Node).queue_free()
	_crear_crater(dir, suelo)

	var luz := OmniLight3D.new()
	luz.light_color = Color(1.0, 0.7, 0.4)
	luz.light_energy = 6.0
	luz.omni_range = 30.0 * k
	luz.position = suelo + dir * (1.0 * k)
	mision.add_child(luz)
	var tw := luz.create_tween()
	tw.tween_property(luz, "light_energy", 0.0, 0.4)
	tw.tween_callback(luz.queue_free)
	_nube_polvo(dir, suelo)
	sonido.emit("boom", dist)
	if dist <= RADIO_PELIGRO:
		golpe.emit(DANO_METEORITO)
		aviso.emit("¡Impacto cerca!", "Un meteorito cayó junto al robot: -%d %% de batería." % int(DANO_METEORITO),
				Color(1.0, 0.4, 0.3), "")


func _crear_crater(dir: Vector3, suelo: Vector3) -> void:
	var c := Node3D.new()
	for par in [[3.4, Color(0.55, 0.36, 0.26, 0.45), 0.006], [2.1, Color(0.1, 0.06, 0.05, 0.9), 0.008]]:
		var d := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 1.0
		cm.bottom_radius = 1.0
		cm.height = 0.01
		cm.radial_segments = 24
		d.mesh = cm
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = par[1]
		d.material_override = mat
		d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var r: float = float(par[0]) * k
		d.transform = Transform3D(mision.base_en(dir) * Basis.from_scale(Vector3(r, 1.0, r)),
				suelo + dir * (float(par[2]) * k * 6.0))
		c.add_child(d)
	mision.add_child(c)
	_craters.append(c)
	if _craters.size() > MAX_CRATERES:
		var viejo: Node3D = _craters.pop_front()
		viejo.queue_free()


func _nube_polvo(dir: Vector3, suelo: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 36
	p.lifetime = 1.8
	p.local_coords = false
	p.direction = dir
	p.spread = 70.0
	p.initial_velocity_min = 5.0 * k
	p.initial_velocity_max = 14.0 * k
	p.gravity = -dir * (2.0 * k)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.4
	var sm := SphereMesh.new()
	sm.radius = 0.5 * k
	sm.height = 1.0 * k
	sm.radial_segments = 6
	sm.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.72, 0.45, 0.3, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.material = mat
	p.mesh = sm
	p.position = suelo + dir * (0.5 * k)
	mision.add_child(p)
	p.emitting = true
	get_tree().create_timer(3.0).timeout.connect(func(): if is_instance_valid(p): p.queue_free())


func _preparar_remolino(up: Vector3) -> void:
	if _mat_rem == null:
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
		_mat_rem = ShaderMaterial.new()
		_mat_rem.shader = sh
		_mat_rem.set_shader_parameter("ruido", tex)
		_mat_rem.set_shader_parameter("color", Color(0.62, 0.38, 0.24, 1.0))
	var dir: Vector3 = mision.dir_lejana(60.0, _rng.randf() * TAU)

	var t1: Vector3 = mision.tangente_en(dir, 0.0)
	var hacia: Vector3 = (up - dir * up.dot(dir)).normalized()
	var rumbo := atan2(hacia.dot(dir.cross(t1)), hacia.dot(t1))
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 0.22
	cm.height = 1.0
	cm.radial_segments = 28
	cm.rings = 16
	mi.mesh = cm
	mi.material_override = _mat_rem
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-2.0, -1.0, -2.0), Vector3(4.0, 3.0, 4.0))
	mision.add_child(mi)
	_rem = {"nodo": mi, "dir": dir, "rumbo": rumbo, "vel": 5.5, "alto": 70.0, "radio": 7.0}
	_dentro_rem = false
	_colocar_remolino()


func _colocar_remolino() -> void:
	var dir: Vector3 = _rem["dir"]
	var mi: MeshInstance3D = _rem["nodo"]
	var alto: float = float(_rem["alto"]) * k
	var radio: float = float(_rem["radio"]) * k
	mi.transform = Transform3D(mision.base_en(dir) * Basis.from_scale(Vector3(radio * 2.0, alto, radio * 2.0)),
			mision.punto_suelo(dir) + dir * (alto * 0.5))


func _paso_remolino(delta: float, up: Vector3) -> void:
	if _rem.is_empty():
		evento_actual = ""
		return
	var dir: Vector3 = _rem["dir"]
	var rumbo: float = float(_rem["rumbo"]) + _rng.randf_range(-0.25, 0.25) * delta
	_rem["rumbo"] = rumbo
	var tang: Vector3 = mision.tangente_en(dir, rumbo)
	_rem["dir"] = mision.mover_dir(dir, tang, float(_rem["vel"]) * k * delta)
	_colocar_remolino()
	var d: float = mision.distancia_gm(_rem["dir"], up)
	var radio: float = _rem["radio"]
	var dentro := d < radio * 0.95
	lento = move_toward(lento, 1.0 if dentro else 0.0, delta * 3.0)
	if dentro:
		golpe.emit(1.3 * delta)
		if not _dentro_rem:
			_dentro_rem = true
			aviso.emit("¡Dentro del remolino!", "El polvo te frena y te gasta batería. Sal de él cuanto antes.",
					Color(1.0, 0.72, 0.25), "")
	else:
		_dentro_rem = false
	if _t > 30.0 or d > 140.0 and _t > 8.0:
		(_rem["nodo"] as Node).queue_free()
		_rem = {}
		vividos += 1
		evento_actual = ""


func _disco(dir: Vector3, radio_gm: float, col: Color) -> Dictionary:
	var disco := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.0
	cm.bottom_radius = 1.0
	cm.height = 0.01
	cm.radial_segments = 40
	disco.mesh = cm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = col
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	disco.material_override = mat
	disco.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var r := radio_gm * k
	disco.transform = Transform3D(mision.base_en(dir) * Basis.from_scale(Vector3(r, 1.0, r)),
			mision.punto_suelo(dir) + dir * (0.04 * k))
	mision.add_child(disco)
	return {"nodo": disco, "mat": mat}


func _preparar_derrumbe(up: Vector3) -> void:
	var rumbo: Vector3 = mision.fwd_robot().rotated(up, _rng.randf_range(-0.5, 0.5))
	var centro: Vector3 = mision.mover_dir(up, rumbo, _rng.randf_range(13.0, 22.0) * k)
	var rocas: Array = []
	for i in range(8):
		var d: Vector3 = mision.mover_dir(centro, mision.tangente_en(centro, _rng.randf() * TAU), _rng.randf_range(0.0, 3.8) * k)
		var r := _rng.randf_range(0.6, 1.5)
		var nodo := Muestras.roca_escenario(_rng, r * k)
		nodo.visible = false
		mision.add_child(nodo)
		rocas.append({"nodo": nodo, "dir": d, "t": 3.0 + float(i) * 0.22 + _rng.randf_range(0.0, 0.12), "estado": 0,
				"giro": Basis(Vector3.UP, _rng.randf() * TAU)})
	_der = {"centro": centro, "aviso": _disco(centro, 5.6, Color(1.0, 0.3, 0.1, 0.3)), "rocas": rocas}
	mision.registrar_obstaculo(centro, 3.6 * k)


func _paso_derrumbe(delta: float, up: Vector3) -> void:
	if _der.is_empty():
		evento_actual = ""
		return
	var av: Dictionary = _der["aviso"]
	if is_instance_valid(av["nodo"]):
		(av["mat"] as StandardMaterial3D).albedo_color.a = 0.2 + 0.16 * sin(_t * 11.0)
	var quedan := 0
	for ro in _der["rocas"]:
		if ro["estado"] == 2:
			continue
		quedan += 1
		var ti: float = ro["t"]
		var nodo: MeshInstance3D = ro["nodo"]
		var dir: Vector3 = ro["dir"]
		if _t >= ti - 0.8:
			nodo.visible = true
			var f := clampf((_t - (ti - 0.8)) / 0.8, 0.0, 1.0)
			var alto := 38.0 * (1.0 - f * f) * k
			var giro: Basis = ro["giro"]
			nodo.transform = Transform3D(mision.base_en(dir) * giro * Basis.from_scale(nodo.scale),
					mision.punto_suelo(dir) + dir * (alto + 0.35 * k))
			if f >= 1.0:
				ro["estado"] = 2
				var dist: float = mision.distancia_gm(dir, up)
				_nube_polvo(dir, mision.punto_suelo(dir))
				sonido.emit("boom", dist + 20.0)
				if dist < 3.0:
					golpe.emit(6.0)
					aviso.emit(Idioma.t("¡Te alcanzó una roca!"), Idioma.t("Un golpe del derrumbe: -6 % de batería."), Color(1.0, 0.4, 0.3), "")
	if quedan == 0:
		if is_instance_valid(av["nodo"]):
			(av["nodo"] as Node).queue_free()
		_der = {}
		_pilas += 1
		vividos += 1
		evento_actual = ""


func _pista(dir: Vector3, up: Vector3) -> String:
	var d: float = mision.distancia_gm(dir, up)
	var t: Vector3 = (dir - up * dir.dot(up)).normalized()
	var f: Vector3 = mision.fwd_robot()
	var ang := rad_to_deg(atan2(t.dot(up.cross(f)), t.dot(f)))
	var lado := Idioma.t("delante")
	if absf(ang) > 145.0:
		lado = Idioma.t("detrás")
	elif absf(ang) > 35.0:
		lado = Idioma.t("a tu izquierda") if ang > 0.0 else Idioma.t("a tu derecha")
	return Idioma.t("unos %d m, %s") % [int(round(d / 5.0) * 5.0), lado]


func _pieza(padre: Node3D, malla: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = malla
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(mi)
	return mi


func _modelo_rover_viejo(raiz: Node3D, limpio: bool = false) -> void:
	var gris := Muestras.mat_liso(Color(0.62, 0.58, 0.52), 0.25, 0.9)
	var polvo := Muestras.mat_liso(Color(0.74, 0.52, 0.38), 0.0, 1.0)
	var oscuro := Muestras.mat_liso(Color(0.12, 0.12, 0.13), 0.1, 0.8)
	var panel := Muestras.mat_liso(Color(0.1, 0.14, 0.3), 0.6, 0.35)
	var bm := BoxMesh.new()
	bm.size = Vector3(2.3, 0.7, 1.5)
	_pieza(raiz, bm, gris, Vector3(0, 0.55, 0), Vector3(0, 0, 9))
	var cil := CylinderMesh.new()
	cil.top_radius = 0.38
	cil.bottom_radius = 0.38
	cil.height = 0.3
	cil.radial_segments = 10
	for i in range(6):
		if i == 4 and not limpio:
			continue
		var x := -0.85 + 0.85 * float(i % 3)
		var z := 0.9 if i < 3 else -0.9
		_pieza(raiz, cil, oscuro, Vector3(x, 0.32 - (0.14 if i == 2 else 0.0), z), Vector3(90, 0, 0))
	var pm := BoxMesh.new()
	pm.size = Vector3(1.9, 0.05, 1.2)
	_pieza(raiz, pm, panel, Vector3(-0.3, 1.2, 0.4), Vector3(0, 12, 38))
	var mast := CylinderMesh.new()
	mast.top_radius = 0.05
	mast.bottom_radius = 0.07
	mast.height = 1.3
	_pieza(raiz, mast, gris, Vector3(0.8, 1.35, -0.2), Vector3(0, 0, -24))
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	if limpio:
		return
	var duna := _pieza(raiz, sm, polvo, Vector3(0.9, 0.05, 0.8))
	duna.scale = Vector3(1.8, 0.45, 1.2)


func _modelo_monolito(raiz: Node3D) -> void:
	var neg := Muestras.mat_liso(Color(0.03, 0.03, 0.04), 0.8, 0.12)
	var luz := StandardMaterial3D.new()
	luz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	luz.albedo_color = Color(0.5, 0.95, 1.0)
	var bm := BoxMesh.new()
	bm.size = Vector3(1.0, 3.4, 0.35)
	_pieza(raiz, bm, neg, Vector3(0, 1.6, 0), Vector3(0, 0, 2))
	var vm := BoxMesh.new()
	vm.size = Vector3(0.06, 2.6, 0.38)
	_pieza(raiz, vm, luz, Vector3(0.0, 1.7, 0.0), Vector3(0, 0, 2))


func _preparar_poi(tipo: String, up: Vector3) -> void:
	var rumbo: Vector3 = mision.fwd_robot().rotated(up, _rng.randf_range(-1.1, 1.1))
	poi_dir = mision.mover_dir(up, rumbo, _rng.randf_range(38.0, 58.0) * k)
	poi_tipo = tipo
	_poi = Node3D.new()
	_poi.transform = Transform3D(mision.base_en(poi_dir) * Basis(Vector3.UP, _rng.randf() * TAU) * Basis.from_scale(Vector3.ONE * k),
			mision.punto_suelo(poi_dir))
	mision.add_child(_poi)
	var col := Color(0.5, 0.95, 1.0) if tipo == "senal" else Color(1.0, 0.8, 0.4)
	_resc_ayudado = false
	_resc_t = -1.0
	rescate_cerca = false
	_resc_mat = null
	if tipo == "senal":
		_modelo_monolito(_poi)
	elif tipo == "rescate":
		col = Color(1.0, 0.4, 0.3)
		_modelo_rover_viejo(_poi, true)
		_resc_mat = StandardMaterial3D.new()
		_resc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_resc_mat.albedo_color = Color(1.0, 0.2, 0.12)
		var bal := SphereMesh.new()
		bal.radius = 0.16
		bal.height = 0.32
		_pieza(_poi, bal, _resc_mat, Vector3(1.06, 2.0, -0.2))
	else:
		_modelo_rover_viejo(_poi)

	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.28
	cm.height = 38.0
	cm.radial_segments = 8
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(col.r, col.g, col.b, 0.28)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_pieza(_poi, cm, mat, Vector3(0, 19.0, 0))
	_poi_luz = OmniLight3D.new()
	_poi_luz.light_color = col
	_poi_luz.omni_range = 14.0 * k
	_poi_luz.light_energy = 1.2
	_poi_luz.shadow_enabled = false
	_poi_luz.position = mision.punto_suelo(poi_dir) + poi_dir * (2.2 * k)
	mision.add_child(_poi_luz)


func _quitar_poi(dejar_modelo: bool) -> void:
	if _poi_luz != null and is_instance_valid(_poi_luz):
		_poi_luz.queue_free()
	_poi_luz = null
	if _poi != null and is_instance_valid(_poi):
		if dejar_modelo:
			_poi.get_child(_poi.get_child_count() - 1).queue_free()
		else:
			_poi.queue_free()
	_poi = null
	poi_dir = Vector3.ZERO
	poi_tipo = ""
	rescate_cerca = false


func _paso_poi(delta: float, up: Vector3) -> void:
	if _poi == null:
		evento_actual = ""
		return
	if _poi_luz != null:
		_poi_luz.light_energy = 1.0 + 0.5 * sin(_t * 3.0)
	var d: float = mision.distancia_gm(poi_dir, up)
	if d < 5.0:
		if poi_tipo == "senal":
			bonus.emit(14.0)
			aviso.emit(Idioma.t("El monolito"), Idioma.t("Un bloque negro, liso, sin polvo encima. La señal se apaga y tu batería sube un 14 %. Nadie lo puso ahí."),
					Color(0.5, 0.95, 1.0), "")
		else:
			bonus.emit(10.0)
			aviso.emit(Idioma.t("Un rover olvidado"), Idioma.t("Un rover de hace décadas, cubierto de polvo. Aprovechas sus celdas: la batería sube un 10 %."),
					Color(1.0, 0.8, 0.4), "")
		_quitar_poi(poi_tipo == "rover_viejo")
		vividos += 1
		evento_actual = ""
	elif _t > 85.0:
		aviso.emit(Idioma.t("Se perdió la pista"), Idioma.t("No lo encuentras a tiempo. Quizá aparezca otro día."), Color(0.7, 0.7, 0.75), "")
		_quitar_poi(false)
		evento_actual = ""


func _exit_tree() -> void:
	for c in _craters:
		if is_instance_valid(c):
			c.queue_free()


const COSTE_RESCATE := 12.0
const MIN_RESCATE := 25.0


func compartir() -> bool:
	if not rescate_cerca or _resc_t >= 0.0:
		return false
	if mision._riesgos and float(mision._energia) < MIN_RESCATE:
		aviso.emit(Idioma.t("Poca batería"), Idioma.t("Necesitas al menos un 25 % para poder compartirla."), Color(1.0, 0.72, 0.25), "")
		return true
	bonus.emit(-COSTE_RESCATE)
	_resc_t = 0.0
	_resc_ayudado = true
	aviso.emit(Idioma.t("Compartiendo batería"), Idioma.t("Le pasas un 12 % de la tuya. Su baliza se apaga y su radio vuelve a funcionar…"), Color(0.55, 0.95, 0.6), "")
	return true


func _paso_rescate(delta: float, up: Vector3) -> void:
	if _poi == null:
		evento_actual = ""
		rescate_cerca = false
		return
	if _resc_t < 0.0:
		var d: float = mision.distancia_gm(poi_dir, up)
		rescate_cerca = d < 5.0
		var on: float = 1.0 if fposmod(_t * 1.4, 1.0) >= 0.5 else 0.0
		if _resc_mat != null:
			_resc_mat.albedo_color = Color(1.0, 0.2, 0.12) * (0.25 + 0.75 * on)
		if _poi_luz != null:
			_poi_luz.light_energy = 0.4 + 1.6 * on
		if _t > 100.0:
			aviso.emit(Idioma.t("El rover se apagó"), Idioma.t("No llegaste a tiempo. Su baliza se apagó: se queda ahí, esperando a otra misión."), Color(0.7, 0.7, 0.75), "")
			if _resc_mat != null:
				_resc_mat.albedo_color = Color(0.1, 0.02, 0.02)
			_quitar_poi(true)
			vividos += 1
			evento_actual = ""
		return
	rescate_cerca = false
	_resc_t += delta
	if _resc_mat != null:
		_resc_mat.albedo_color = Color(1.0, 0.2, 0.12).lerp(Color(0.3, 1.0, 0.45), clampf(_resc_t / 1.5, 0.0, 1.0))
	if _poi_luz != null:
		_poi_luz.light_color = Color(1.0, 0.4, 0.3).lerp(Color(0.4, 1.0, 0.55), clampf(_resc_t / 1.5, 0.0, 1.0))
	if _resc_t >= 3.0:
		rescatado = true
		datos.emit(2)
		aviso.emit(Idioma.t("Rover rescatado"), Idioma.t("Vuelve a la vida y te manda lo que había medido y no pudo enviar: +2 datos de ciencia. Su baliza queda en verde."),
				Color(0.4, 1.0, 0.55), "rescate")
		_quitar_poi(true)
		vividos += 1
		evento_actual = ""
