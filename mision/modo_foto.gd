extends RefCounted


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Partidas := preload("res://nucleo/partidas.gd")
const Idioma := preload("res://nucleo/idioma.gd")

const FILTROS := ["SIN FILTRO", "CÁLIDO", "BLANCO Y NEGRO", "CINE", "CONTRASTE"]
const MARCOS := ["SIN MARCO", "POLAROID", "PELÍCULA", "FICHA CIENTÍFICA"]
const MAX_ALBUM := 60

static var filtro: int = 0
static var marco: int = 0
static var cuadricula: bool = false

const SHADER := """
shader_type canvas_item;
uniform sampler2D tex : hint_screen_texture, filter_linear;
uniform int modo = 0;
uniform float vineta = 0.0;
void fragment() {
	vec3 c = texture(tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	if (modo == 1) {
		c = mix(c, vec3(l) * vec3(1.12, 0.96, 0.74), 0.4);
		c *= vec3(1.08, 1.0, 0.86);
	} else if (modo == 2) {
		float g = (l - 0.5) * 1.12 + 0.5;
		c = vec3(g);
	} else if (modo == 3) {
		c = (c - 0.5) * 1.16 + 0.5;
		c = mix(c * vec3(0.84, 0.98, 1.12), c * vec3(1.12, 1.0, 0.82), smoothstep(0.25, 0.75, l));
	} else if (modo == 4) {
		c = (c - 0.5) * 1.5 + 0.5;
		float g2 = dot(c, vec3(0.299, 0.587, 0.114));
		c = mix(vec3(g2), c, 1.3);
	}
	vec2 uv = SCREEN_UV - 0.5;
	float v = smoothstep(0.28, 0.86, length(uv * vec2(1.25, 1.0)));
	c *= 1.0 - vineta * v;
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
"""


static func siguiente_filtro() -> String:
	filtro = (filtro + 1) % FILTROS.size()
	return FILTROS[filtro]


static func siguiente_marco() -> String:
	marco = (marco + 1) % MARCOS.size()
	return MARCOS[marco]


static func carpeta() -> String:
	return Partidas.subcarpeta("capturas")


static func guardar(img: Image) -> String:
	var dir := carpeta()
	DirAccess.make_dir_recursive_absolute(dir)
	var f := Time.get_datetime_dict_from_system()
	var ruta := "%s/spartans_%04d%02d%02d_%02d%02d%02d.png" % [dir, f["year"], f["month"], f["day"], f["hour"], f["minute"], f["second"]]
	if img.save_png(ruta) != OK:
		return ""
	return ProjectSettings.globalize_path(ruta)


static func listar() -> Array[String]:
	var l: Array[String] = []
	var dir := DirAccess.open(carpeta())
	if dir == null:
		return l
	for n in dir.get_files():
		if n.to_lower().ends_with(".png"):
			l.append(n)
	l.sort()
	l.reverse()
	var r: Array[String] = []
	for n in l:
		r.append(carpeta() + "/" + n)
		if r.size() >= MAX_ALBUM:
			break
	return r


static func total() -> int:
	return listar().size()


class Capa extends CanvasLayer:
	var _rect: ColorRect
	var _mat: ShaderMaterial
	var _marco: MarcoFoto
	var _grid: Control
	var _filtro: int = 0
	var _marco_i: int = 0
	var datos: Dictionary = {}

	func _ready() -> void:
		layer = 59
		_rect = ColorRect.new()
		_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sh := Shader.new()
		sh.code = SHADER
		_mat = ShaderMaterial.new()
		_mat.shader = sh
		_rect.material = _mat
		add_child(_rect)
		_marco = MarcoFoto.new()
		_marco.capa = self
		_marco.set_anchors_preset(Control.PRESET_FULL_RECT)
		_marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_marco)
		_grid = Cuadricula.new()
		_grid.set_anchors_preset(Control.PRESET_FULL_RECT)
		_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grid.visible = false
		add_child(_grid)

	func aplicar(f: int, m: int, g: bool) -> void:
		_filtro = f
		_marco_i = m
		_rect.visible = f != 0
		_mat.set_shader_parameter("modo", f)
		_mat.set_shader_parameter("vineta", 0.55 if f == 3 else (0.28 if f == 1 else 0.0))
		_marco.queue_redraw()
		_grid.visible = g


	func guias(ver: bool, g: bool) -> void:
		_grid.visible = ver and g

	func filtro_actual() -> int:
		return _filtro

	func marco_actual() -> int:
		return _marco_i


class MarcoFoto extends Control:
	var capa: Capa

	func _draw() -> void:
		if capa == null:
			return
		var s := size
		var f: Font = EstiloUI.fuente_titulo()
		var ft: Font = EstiloUI.fuente_texto()
		var d: Dictionary = capa.datos
		var nombre := Idioma.t(str(d.get("nombre", "Marte")))
		var sol := int(d.get("sol", 1))
		var hora := str(d.get("hora", ""))
		var cap := "SOL %d%s" % [sol, ("  ·  " + hora) if hora != "" else ""]

		if capa.filtro_actual() == 3:
			var b := roundf(s.y * 0.1)
			draw_rect(Rect2(0, 0, s.x, b), Color.BLACK)
			draw_rect(Rect2(0, s.y - b, s.x, b), Color.BLACK)
		match capa.marco_actual():
			1:
				var papel := Color(0.95, 0.93, 0.88)
				var lado := 30.0
				var bajo := 118.0
				draw_rect(Rect2(0, 0, s.x, lado), papel)
				draw_rect(Rect2(0, 0, lado, s.y), papel)
				draw_rect(Rect2(s.x - lado, 0, lado, s.y), papel)
				draw_rect(Rect2(0, s.y - bajo, s.x, bajo), papel)
				draw_rect(Rect2(lado, lado, s.x - 2.0 * lado, s.y - bajo - lado), Color(0, 0, 0, 0.35), false, 2.0)
				draw_string(f, Vector2(lado + 6.0, s.y - bajo + 50.0), nombre, HORIZONTAL_ALIGNMENT_LEFT, s.x - 2.0 * lado - 12.0, 30, Color(0.16, 0.12, 0.1))
				draw_string(ft, Vector2(lado + 6.0, s.y - bajo + 84.0), cap + "   ·   SPARTANS II", HORIZONTAL_ALIGNMENT_LEFT, s.x - 2.0 * lado - 12.0, 20, Color(0.42, 0.3, 0.24))
			2:
				var b2 := 58.0
				draw_rect(Rect2(0, 0, s.x, b2), Color(0.03, 0.03, 0.03))
				draw_rect(Rect2(0, s.y - b2, s.x, b2), Color(0.03, 0.03, 0.03))
				var x := 14.0
				while x < s.x:
					draw_rect(Rect2(x, 10.0, 26.0, 16.0), Color(0.92, 0.9, 0.84), true)
					draw_rect(Rect2(x, s.y - 26.0, 26.0, 16.0), Color(0.92, 0.9, 0.84), true)
					x += 50.0
				draw_string(ft, Vector2(18.0, s.y - 31.0), "SPARTANS II 400   ▶  %s" % nombre.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, s.x - 36.0, 17, Color(1.0, 0.62, 0.2))
				draw_string(ft, Vector2(18.0, 46.0), cap, HORIZONTAL_ALIGNMENT_RIGHT, s.x - 36.0, 17, Color(1.0, 0.62, 0.2))
			3:
				var c := Color(1, 1, 1, 0.9)
				var e := 40.0
				var m := 26.0
				for p in [Vector2(m, m), Vector2(s.x - m, m), Vector2(m, s.y - m), Vector2(s.x - m, s.y - m)]:
					var sx := 1.0 if p.x < s.x * 0.5 else -1.0
					var sy := 1.0 if p.y < s.y * 0.5 else -1.0
					draw_line(p, p + Vector2(e * sx, 0), c, 2.0)
					draw_line(p, p + Vector2(0, e * sy), c, 2.0)
				var r := Rect2(46.0, s.y - 206.0, 520.0, 98.0)
				draw_rect(r, Color(0.03, 0.025, 0.02, 0.78))
				draw_rect(Rect2(r.position, Vector2(5.0, r.size.y)), Color(0.99, 0.24, 0.13))
				draw_string(f, r.position + Vector2(20.0, 28.0), Idioma.t("SPARTANS II  ·  ROBOT EXPLORADOR"), HORIZONTAL_ALIGNMENT_LEFT, 490.0, 17, Color(0.99, 0.24, 0.13))
				draw_string(f, r.position + Vector2(20.0, 56.0), "%s  ·  %s" % [nombre.to_upper(), cap], HORIZONTAL_ALIGNMENT_LEFT, 490.0, 18, Color(0.95, 0.92, 0.87))
				draw_string(ft, r.position + Vector2(20.0, 82.0), "LAT %.2f°   LON %.2f°   ·   %d °C" % [float(d.get("lat", 0.0)), float(d.get("lon", 0.0)), roundi(float(d.get("temp", -60.0)))], HORIZONTAL_ALIGNMENT_LEFT, 490.0, 16, Color(1, 1, 1, 0.7))


class Cuadricula extends Control:
	func _draw() -> void:
		var c := Color(1, 1, 1, 0.38)
		for i in [1, 2]:
			draw_line(Vector2(size.x * i / 3.0, 0), Vector2(size.x * i / 3.0, size.y), c, 1.0)
			draw_line(Vector2(0, size.y * i / 3.0), Vector2(size.x, size.y * i / 3.0), c, 1.0)


class Album extends CanvasLayer:
	signal cerrada
	var _rutas: Array[String] = []
	var _grid: GridContainer
	var _vista: Control
	var _tex_grande: TextureRect
	var _lbl_pie: Label
	var _actual: int = -1
	var _btn_borrar: Button
	var _confirmar: bool = false
	var _lbl_vacio: Label

	func _ready() -> void:
		layer = 45
		add_to_group("modal")
		process_mode = Node.PROCESS_MODE_ALWAYS
		var fondo := ColorRect.new()
		fondo.color = Color(0.02, 0.012, 0.01, 0.99)
		fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
		fondo.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(fondo)
		var col := VBoxContainer.new()
		col.set_anchors_preset(Control.PRESET_FULL_RECT)
		col.offset_left = 50.0
		col.offset_right = -50.0
		col.offset_top = 36.0
		col.offset_bottom = -30.0
		col.add_theme_constant_override("separation", 12)
		fondo.add_child(col)
		var cab := HBoxContainer.new()
		cab.add_theme_constant_override("separation", 16)
		col.add_child(cab)
		var titulo := EstiloUI.etiqueta("ÁLBUM DE FOTOS", 34, EstiloUI.COL_ACENTO, true)
		titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cab.add_child(titulo)
		var b_dir := EstiloUI.boton("ABRIR CARPETA", 16)
		b_dir.custom_minimum_size = Vector2(210.0, 40.0)
		b_dir.pressed.connect(func(): OS.shell_open(ProjectSettings.globalize_path(ModoFoto_carpeta())))
		cab.add_child(b_dir)
		var b_cerrar := EstiloUI.boton("CERRAR", 16)
		b_cerrar.custom_minimum_size = Vector2(150.0, 40.0)
		b_cerrar.pressed.connect(_cerrar)
		cab.add_child(b_cerrar)
		col.add_child(EstiloUI.etiqueta("Se hacen con la tecla P durante una misión (modo foto). F cambia el filtro y M el marco.", 16, EstiloUI.COL_TENUE))
		var sc := ScrollContainer.new()
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		col.add_child(sc)
		_grid = GridContainer.new()
		_grid.columns = 4
		_grid.add_theme_constant_override("h_separation", 12)
		_grid.add_theme_constant_override("v_separation", 12)
		sc.add_child(_grid)
		_lbl_vacio = EstiloUI.etiqueta("Todavía no hay fotos. Entra en una misión y pulsa P para abrir el modo foto; ENTER hace la captura.", 20, EstiloUI.COL_TEXTO)
		_lbl_vacio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_lbl_vacio.custom_minimum_size = Vector2(900.0, 0.0)
		col.add_child(_lbl_vacio)
		_construir_vista(fondo)
		_cargar()

	func ModoFoto_carpeta() -> String:
		return Partidas.subcarpeta("capturas")

	func _construir_vista(padre: Control) -> void:
		_vista = ColorRect.new()
		(_vista as ColorRect).color = Color(0, 0, 0, 0.96)
		_vista.set_anchors_preset(Control.PRESET_FULL_RECT)
		_vista.mouse_filter = Control.MOUSE_FILTER_STOP
		_vista.visible = false
		padre.add_child(_vista)
		_tex_grande = TextureRect.new()
		_tex_grande.set_anchors_preset(Control.PRESET_FULL_RECT)
		_tex_grande.offset_top = 20.0
		_tex_grande.offset_bottom = -80.0
		_tex_grande.offset_left = 20.0
		_tex_grande.offset_right = -20.0
		_tex_grande.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_tex_grande.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_vista.add_child(_tex_grande)
		var barra := HBoxContainer.new()
		barra.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		barra.offset_top = -64.0
		barra.offset_bottom = -16.0
		barra.offset_left = 40.0
		barra.offset_right = -40.0
		barra.add_theme_constant_override("separation", 12)
		_vista.add_child(barra)
		var b_ant := EstiloUI.boton("◀", 18)
		b_ant.custom_minimum_size = Vector2(70.0, 44.0)
		b_ant.pressed.connect(_mover.bind(-1))
		barra.add_child(b_ant)
		var b_sig := EstiloUI.boton("▶", 18)
		b_sig.custom_minimum_size = Vector2(70.0, 44.0)
		b_sig.pressed.connect(_mover.bind(1))
		barra.add_child(b_sig)
		_lbl_pie = EstiloUI.etiqueta("", 16, EstiloUI.COL_TENUE)
		_lbl_pie.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_lbl_pie.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		barra.add_child(_lbl_pie)
		_btn_borrar = EstiloUI.boton("BORRAR", 16)
		_btn_borrar.custom_minimum_size = Vector2(170.0, 44.0)
		_btn_borrar.pressed.connect(_borrar)
		barra.add_child(_btn_borrar)
		var b_vol := EstiloUI.boton("VOLVER", 16)
		b_vol.custom_minimum_size = Vector2(150.0, 44.0)
		b_vol.pressed.connect(_cerrar_vista)
		barra.add_child(b_vol)

	func _cargar() -> void:
		for c in _grid.get_children():
			c.queue_free()
		_rutas = ModoFoto_listar()
		_lbl_vacio.visible = _rutas.is_empty()
		for i in _rutas.size():
			var img := Image.load_from_file(_rutas[i])
			if img == null or img.is_empty():
				continue
			img.resize(272, 153, Image.INTERPOLATE_BILINEAR)
			var b := Button.new()
			b.icon = ImageTexture.create_from_image(img)
			b.expand_icon = false
			b.custom_minimum_size = Vector2(284.0, 165.0)
			b.add_theme_stylebox_override("normal", EstiloUI.caja(Color(1, 1, 1, 0.05)))
			b.add_theme_stylebox_override("hover", EstiloUI.caja(Color(1.0, 0.45, 0.18, 0.25)))
			b.add_theme_stylebox_override("focus", EstiloUI.caja(Color(1.0, 0.45, 0.18, 0.25)))
			b.add_theme_stylebox_override("pressed", EstiloUI.caja(Color(1.0, 0.45, 0.18, 0.35)))
			b.pressed.connect(_ver.bind(i))
			_grid.add_child(b)
		if _grid.get_child_count() > 0:
			(_grid.get_child(0) as Control).call_deferred("grab_focus")

	func ModoFoto_listar() -> Array[String]:
		var l: Array[String] = []
		var dir := DirAccess.open(ModoFoto_carpeta())
		if dir == null:
			return l
		for n in dir.get_files():
			if n.to_lower().ends_with(".png"):
				l.append(n)
		l.sort()
		l.reverse()
		var r: Array[String] = []
		for n in l:
			r.append(ModoFoto_carpeta() + "/" + n)
			if r.size() >= MAX_ALBUM:
				break
		return r

	func _ver(i: int) -> void:
		if i < 0 or i >= _rutas.size():
			return
		_actual = i
		_confirmar = false
		_btn_borrar.text = "BORRAR"
		var img := Image.load_from_file(_rutas[i])
		if img == null or img.is_empty():
			return
		_tex_grande.texture = ImageTexture.create_from_image(img)
		_lbl_pie.text = "%d / %d   ·   %s" % [i + 1, _rutas.size(), _rutas[i].get_file()]
		_vista.visible = true

	func _mover(d: int) -> void:
		if _rutas.is_empty():
			return
		_ver((_actual + d + _rutas.size()) % _rutas.size())

	func _borrar() -> void:
		if _actual < 0 or _actual >= _rutas.size():
			return
		if not _confirmar:
			_confirmar = true
			_btn_borrar.text = "¿SEGURO?"
			return
		DirAccess.remove_absolute(_rutas[_actual])
		_cerrar_vista()
		_cargar()

	func _cerrar_vista() -> void:
		_vista.visible = false
		_actual = -1
		_confirmar = false

	func _input(event: InputEvent) -> void:
		if not (event is InputEventKey) or not event.pressed or event.echo:
			return
		var k: int = event.keycode
		if k == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			if _vista.visible:
				_cerrar_vista()
			else:
				_cerrar()
		elif _vista.visible and k == KEY_RIGHT:
			get_viewport().set_input_as_handled()
			_mover(1)
		elif _vista.visible and k == KEY_LEFT:
			get_viewport().set_input_as_handled()
			_mover(-1)

	func _cerrar() -> void:
		cerrada.emit()
		queue_free()
