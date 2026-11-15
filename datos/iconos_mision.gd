extends RefCounted


const TAM := 256
const SS := 2
const FONDO := Color(0.09, 0.07, 0.08)
const BLANCO := Color(1.0, 1.0, 1.0)


const TIPOS := {
	"chryse_viking": "viking",
	"ares_pathfinder": "sojourner",
	"polar_lander": "restos",
	"pancam_husband": "camara",
	"llanura_utopia": "phoenix",
	"endeavour_opportunity": "mer",
	"gale_curiosity": "curiosity",
	"insight_elysium": "phoenix",
	"zhurong_utopia": "mer",
	"jezero_perseverance": "perseverance",
}

static var _cache: Dictionary = {}


static func tipo_de(id: String) -> String:
	return str(TIPOS.get(id, "colonia"))


static func textura(tipo: String) -> ImageTexture:
	if _cache.has(tipo):
		return _cache[tipo] as ImageTexture
	var n := TAM * SS
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 0.0))
	var centro := Vector2(0.5, 0.5)
	_disco(img, centro, 0.49, BLANCO)
	_disco(img, centro, 0.425, FONDO)
	match tipo:
		"viking": _viking(img)
		"sojourner": _sojourner(img)
		"mer": _mer(img)
		"phoenix": _phoenix(img)
		"curiosity": _curiosity(img, false)
		"perseverance": _curiosity(img, true)
		"camara": _camara(img)
		"restos": _restos(img)
		_: _colonia(img)
	img.resize(TAM, TAM, Image.INTERPOLATE_LANCZOS)
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_cache[tipo] = t
	return t


static func _ruedas(img: Image, xs: Array, y: float, r: float) -> void:
	for x: float in xs:
		_disco(img, Vector2(x, y), r, BLANCO)
		_disco(img, Vector2(x, y), r * 0.38, FONDO)


static func _viking(img: Image) -> void:

	_poli(img, [Vector2(0.33, 0.50), Vector2(0.67, 0.50), Vector2(0.63, 0.60), Vector2(0.37, 0.60)], BLANCO)
	_linea(img, Vector2(0.39, 0.60), Vector2(0.27, 0.73), 0.022, BLANCO)
	_linea(img, Vector2(0.61, 0.60), Vector2(0.73, 0.73), 0.022, BLANCO)
	_linea(img, Vector2(0.50, 0.60), Vector2(0.50, 0.73), 0.022, BLANCO)
	for x: float in [0.25, 0.75, 0.50]:
		_rect(img, x - 0.045, 0.725, x + 0.045, 0.745, BLANCO)
	_linea(img, Vector2(0.41, 0.50), Vector2(0.41, 0.33), 0.02, BLANCO)
	_rect(img, 0.37, 0.29, 0.45, 0.34, BLANCO)
	_poli(img, [Vector2(0.60, 0.50), Vector2(0.69, 0.36), Vector2(0.74, 0.40), Vector2(0.66, 0.50)], BLANCO)
	_poli(img, [Vector2(0.40, 0.53), Vector2(0.60, 0.53), Vector2(0.58, 0.57), Vector2(0.42, 0.57)], FONDO)


static func _sojourner(img: Image) -> void:

	_poli(img, [Vector2(0.30, 0.50), Vector2(0.70, 0.50), Vector2(0.67, 0.60), Vector2(0.33, 0.60)], BLANCO)
	_poli(img, [Vector2(0.33, 0.40), Vector2(0.67, 0.40), Vector2(0.71, 0.49), Vector2(0.29, 0.49)], BLANCO)
	_poli(img, [Vector2(0.36, 0.43), Vector2(0.64, 0.43), Vector2(0.66, 0.47), Vector2(0.34, 0.47)], FONDO)
	_linea(img, Vector2(0.64, 0.40), Vector2(0.69, 0.28), 0.014, BLANCO)
	_linea(img, Vector2(0.33, 0.60), Vector2(0.33, 0.66), 0.02, BLANCO)
	_linea(img, Vector2(0.67, 0.60), Vector2(0.67, 0.66), 0.02, BLANCO)
	_ruedas(img, [0.33, 0.50, 0.67], 0.68, 0.062)


static func _mer(img: Image) -> void:

	_poli(img, [Vector2(0.36, 0.51), Vector2(0.64, 0.51), Vector2(0.62, 0.60), Vector2(0.38, 0.60)], BLANCO)
	_poli(img, [Vector2(0.22, 0.45), Vector2(0.78, 0.45), Vector2(0.74, 0.51), Vector2(0.26, 0.51)], BLANCO)
	_linea(img, Vector2(0.30, 0.48), Vector2(0.70, 0.48), 0.012, FONDO)
	_linea(img, Vector2(0.50, 0.45), Vector2(0.50, 0.28), 0.02, BLANCO)
	_rect(img, 0.44, 0.23, 0.56, 0.29, BLANCO)
	_disco(img, Vector2(0.47, 0.26), 0.014, FONDO)
	_disco(img, Vector2(0.53, 0.26), 0.014, FONDO)
	_linea(img, Vector2(0.38, 0.60), Vector2(0.34, 0.67), 0.02, BLANCO)
	_linea(img, Vector2(0.62, 0.60), Vector2(0.66, 0.67), 0.02, BLANCO)
	_ruedas(img, [0.34, 0.50, 0.66], 0.69, 0.065)


static func _phoenix(img: Image) -> void:

	_rect(img, 0.38, 0.50, 0.62, 0.56, BLANCO)
	_disco(img, Vector2(0.25, 0.47), 0.10, BLANCO)
	_disco(img, Vector2(0.75, 0.47), 0.10, BLANCO)
	_disco(img, Vector2(0.25, 0.47), 0.055, FONDO)
	_disco(img, Vector2(0.75, 0.47), 0.055, FONDO)
	_linea(img, Vector2(0.40, 0.56), Vector2(0.32, 0.72), 0.02, BLANCO)
	_linea(img, Vector2(0.60, 0.56), Vector2(0.68, 0.72), 0.02, BLANCO)
	_linea(img, Vector2(0.50, 0.56), Vector2(0.50, 0.72), 0.02, BLANCO)
	for x: float in [0.31, 0.69, 0.50]:
		_rect(img, x - 0.04, 0.715, x + 0.04, 0.735, BLANCO)
	_linea(img, Vector2(0.50, 0.50), Vector2(0.55, 0.37), 0.02, BLANCO)
	_linea(img, Vector2(0.55, 0.37), Vector2(0.66, 0.41), 0.02, BLANCO)
	_disco(img, Vector2(0.67, 0.415), 0.024, BLANCO)


static func _curiosity(img: Image, con_helicoptero: bool) -> void:

	_poli(img, [Vector2(0.30, 0.48), Vector2(0.68, 0.48), Vector2(0.66, 0.60), Vector2(0.32, 0.60)], BLANCO)
	_poli(img, [Vector2(0.34, 0.51), Vector2(0.52, 0.51), Vector2(0.52, 0.56), Vector2(0.34, 0.56)], FONDO)
	_poli(img, [Vector2(0.66, 0.50), Vector2(0.76, 0.46), Vector2(0.77, 0.53), Vector2(0.67, 0.57)], BLANCO)
	_linea(img, Vector2(0.58, 0.48), Vector2(0.58, 0.29), 0.022, BLANCO)
	_rect(img, 0.52, 0.23, 0.65, 0.30, BLANCO)
	_disco(img, Vector2(0.565, 0.265), 0.016, FONDO)
	_disco(img, Vector2(0.615, 0.265), 0.016, FONDO)
	_linea(img, Vector2(0.32, 0.54), Vector2(0.24, 0.62), 0.024, BLANCO)
	_disco(img, Vector2(0.235, 0.63), 0.032, BLANCO)
	_linea(img, Vector2(0.34, 0.60), Vector2(0.30, 0.68), 0.022, BLANCO)
	_linea(img, Vector2(0.66, 0.60), Vector2(0.70, 0.68), 0.022, BLANCO)
	_ruedas(img, [0.31, 0.50, 0.69], 0.70, 0.07)
	if con_helicoptero:

		_linea(img, Vector2(0.38, 0.35), Vector2(0.38, 0.40), 0.012, BLANCO)
		_rect(img, 0.355, 0.40, 0.405, 0.44, BLANCO)
		_linea(img, Vector2(0.27, 0.345), Vector2(0.49, 0.345), 0.016, BLANCO)


static func _camara(img: Image) -> void:

	_rect(img, 0.30, 0.58, 0.70, 0.66, BLANCO)
	_ruedas(img, [0.34, 0.50, 0.66], 0.72, 0.045)
	_linea(img, Vector2(0.50, 0.58), Vector2(0.50, 0.40), 0.026, BLANCO)
	_rect(img, 0.34, 0.27, 0.66, 0.40, BLANCO)
	for x: float in [0.42, 0.58]:
		_disco(img, Vector2(x, 0.335), 0.04, FONDO)
		_disco(img, Vector2(x, 0.335), 0.019, BLANCO)
	_linea(img, Vector2(0.34, 0.60), Vector2(0.26, 0.52), 0.02, BLANCO)
	_disco(img, Vector2(0.255, 0.515), 0.022, BLANCO)


static func _restos(img: Image) -> void:

	_poli(img, [Vector2(0.28, 0.56), Vector2(0.60, 0.45), Vector2(0.68, 0.57), Vector2(0.36, 0.67)], BLANCO)
	_poli(img, [Vector2(0.36, 0.57), Vector2(0.56, 0.50), Vector2(0.60, 0.56), Vector2(0.40, 0.62)], FONDO)
	_linea(img, Vector2(0.38, 0.66), Vector2(0.31, 0.77), 0.022, BLANCO)
	_linea(img, Vector2(0.62, 0.62), Vector2(0.77, 0.72), 0.022, BLANCO)
	_linea(img, Vector2(0.60, 0.46), Vector2(0.52, 0.31), 0.018, BLANCO)
	_linea(img, Vector2(0.52, 0.31), Vector2(0.60, 0.28), 0.018, BLANCO)
	_disco(img, Vector2(0.27, 0.43), 0.07, BLANCO)
	_disco(img, Vector2(0.27, 0.43), 0.038, FONDO)
	_poli(img, [Vector2(0.70, 0.45), Vector2(0.78, 0.43), Vector2(0.76, 0.51)], BLANCO)
	_poli(img, [Vector2(0.20, 0.64), Vector2(0.26, 0.62), Vector2(0.25, 0.69)], BLANCO)


static func _colonia(img: Image) -> void:

	_semi(img, Vector2(0.44, 0.66), 0.25, BLANCO)
	_semi(img, Vector2(0.73, 0.66), 0.11, BLANCO)
	_rect(img, 0.17, 0.66, 0.84, 0.71, BLANCO)
	_rect(img, 0.40, 0.57, 0.48, 0.66, FONDO)
	_semi(img, Vector2(0.44, 0.66), 0.20, FONDO)
	_semi(img, Vector2(0.44, 0.66), 0.17, BLANCO)
	_rect(img, 0.40, 0.57, 0.48, 0.66, FONDO)
	_linea(img, Vector2(0.44, 0.41), Vector2(0.44, 0.28), 0.018, BLANCO)
	_disco(img, Vector2(0.44, 0.265), 0.026, BLANCO)
	_linea(img, Vector2(0.73, 0.55), Vector2(0.73, 0.46), 0.014, BLANCO)


static func _poli(img: Image, pts: Array, col: Color) -> void:
	var n := img.get_width()
	var fn := float(n)
	var min_y: float = 1.0e9
	var max_y: float = -1.0e9
	for p: Vector2 in pts:
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)
	var y0 := maxi(int(floor(min_y * fn)), 0)
	var y1 := mini(int(ceil(max_y * fn)), n - 1)
	var cuenta := pts.size()
	for y in range(y0, y1 + 1):
		var fy := (float(y) + 0.5) / fn
		var xs: Array[float] = []
		for i in range(cuenta):
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[(i + 1) % cuenta]
			if (a.y <= fy and b.y > fy) or (b.y <= fy and a.y > fy):
				var t := (fy - a.y) / (b.y - a.y)
				xs.append(a.x + t * (b.x - a.x))
		xs.sort()
		for k in range(0, xs.size() - 1, 2):
			var xa := clampi(int(round(xs[k] * fn)), 0, n)
			var xb := clampi(int(round(xs[k + 1] * fn)), 0, n)
			if xb > xa:
				img.fill_rect(Rect2i(xa, y, xb - xa, 1), col)


static func _rect(img: Image, x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	_poli(img, [Vector2(x0, y0), Vector2(x1, y0), Vector2(x1, y1), Vector2(x0, y1)], col)


static func _disco(img: Image, c: Vector2, r: float, col: Color) -> void:
	var pts: Array = []
	for i in range(64):
		var a := TAU * float(i) / 64.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	_poli(img, pts, col)


static func _semi(img: Image, c: Vector2, r: float, col: Color) -> void:
	var pts: Array = []
	for i in range(0, 33):
		var a := PI + PI * float(i) / 32.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	_poli(img, pts, col)


static func _linea(img: Image, a: Vector2, b: Vector2, w: float, col: Color) -> void:
	var d := (b - a).normalized()
	var nrm := Vector2(-d.y, d.x) * (w * 0.5)
	_poli(img, [a + nrm, b + nrm, b - nrm, a - nrm], col)
	_disco(img, a, w * 0.5, col)
	_disco(img, b, w * 0.5, col)
