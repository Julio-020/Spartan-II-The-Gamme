extends CanvasLayer


signal terminada

const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Historia := preload("res://historia/historia.gd")
const Comite := preload("res://historia/comite.gd")
const Ajustes := preload("res://nucleo/ajustes.gd")

const MusicaFinal := preload("res://sonido/musica_final.gd")

const DURACION := 34.0
const BUS_FINAL := "MusicaFinal"

var sitio_id: String = ""
var tipo: int = 0
var t: float = 0.0

var _escena: Control
var _tarjetas_datos: Array = []
var _lbl: Label
var _lbl_peq: Label
var _fin: bool = false
var _mus_gen: MusicaFinal = null
var _mus_wav: AudioStreamWAV = null
var _mus_player: AudioStreamPlayer
var _mus_sonando: bool = false


func configurar(id: String) -> void:
	sitio_id = id
	tipo = Comite.final_tipo(id)


func _ready() -> void:
	layer = 60
	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(raiz)
	_escena = Escena.new()
	_escena.set_anchors_preset(Control.PRESET_FULL_RECT)
	_escena.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_escena)

	for arriba in [true, false]:
		var b := ColorRect.new()
		b.color = Color.BLACK
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.set_anchors_preset(Control.PRESET_TOP_WIDE if arriba else Control.PRESET_BOTTOM_WIDE)
		b.custom_minimum_size = Vector2(0.0, 70.0)
		b.size = Vector2(1280.0, 70.0)
		if not arriba:
			b.position.y = -70.0
		raiz.add_child(b)
	_lbl = EstiloUI.etiqueta_contorno("", 34, Color.WHITE, true)
	_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_lbl.offset_top = 120.0
	_lbl.offset_left = 120.0
	_lbl.offset_right = -120.0
	_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_lbl)
	_lbl_peq = EstiloUI.etiqueta("Esc / Espacio para saltar", 13, EstiloUI.COL_TENUE)
	_lbl_peq.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_lbl_peq.position = Vector2(-220.0, -100.0)
	_lbl_peq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_lbl_peq)
	_tarjetas_datos = _tarjetas()
	_escena.set("seed_sitio", sitio_id.hash())
	_escena.set("tono", tipo)
	_preparar_musica()


func _preparar_musica() -> void:
	Ajustes.asegurar_buses()
	Ajustes._crear_bus(BUS_FINAL)
	var ib := AudioServer.get_bus_index(BUS_FINAL)
	AudioServer.set_bus_volume_db(ib, Ajustes._db(Ajustes.vol_musica))
	var im := AudioServer.get_bus_index(Ajustes.BUS_MUSICA)
	var actual := AudioServer.get_bus_volume_db(im)
	create_tween().tween_method(func(v: float): AudioServer.set_bus_volume_db(im, v), actual, actual - 30.0, 1.5)
	_mus_player = AudioStreamPlayer.new()
	_mus_player.bus = BUS_FINAL
	_mus_player.volume_db = -3.0
	add_child(_mus_player)
	_mus_wav = MusicaFinal.obtener(tipo)
	if _mus_wav == null:
		_mus_gen = MusicaFinal.new(tipo)


func _tarjetas() -> Array:
	var m := Comite.mision(sitio_id)
	var nombre := str(m.get("nombre", "Marte")).to_upper()
	var piloto := Ajustes.nombre_visible()
	return [
		[1.0, 5.0, "158 DÍAS DESPUÉS", 56],
		[5.6, 10.6, "La Tierra recibió todos tus informes y rutas.\nEl comité por fin tomó una decisión.", 32],
		[11.2, 16.0, nombre, 52],
		[16.4, 22.6, str((Comite.SITIOS.get(sitio_id, {}) as Dictionary).get("final", "")), 26],
		[23.0, 27.4, _texto_jefes(), 30],
		[27.8, 31.8, ("Y un piloto, %s,\nrecorrió los caminos que lo hicieron posible." % piloto) if piloto.to_lower() != "piloto" else "Y un piloto\nrecorrió los caminos que lo hicieron posible.", 30],
		[32.0, 34.0, "SPARTANS II", 64],
	]


func _actualizar_musica() -> void:
	if _mus_gen != null and _mus_gen.avanzar(12000):
		_mus_wav = _mus_gen.resultado
		_mus_gen = null
	if _mus_wav != null and not _mus_sonando and t < DURACION - 1.0:
		_mus_sonando = true
		_mus_player.stream = _mus_wav
		_mus_player.play(minf(t, MusicaFinal.DURACION - 0.5))


func _texto_jefes() -> String:
	var p := Comite.problema(sitio_id)
	match tipo:
		1:
			return "No fue perfecto: %s.\nPero la base resistió y creció." % p
		2:
			return "Fue una apuesta dura: %s.\nPero allí sigue la base, y nadie se rinde." % p
	return "Kelly, Julio, Reyzer, Gerald y Daid\nlo prepararon todo desde la Tierra."


func _unhandled_input(event: InputEvent) -> void:
	if _fin:
		return
	var salta := false
	if event is InputEventKey and event.pressed and not event.echo:
		salta = event.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]
	elif event is InputEventMouseButton and event.pressed:
		salta = true
	if salta:
		get_viewport().set_input_as_handled()
		_terminar()


func _terminar() -> void:
	if _fin:
		return
	_fin = true
	terminada.emit()

	for h in get_children():
		if h is Control:
			(h as Control).visible = false
	var tw := create_tween()
	if _mus_player != null and _mus_player.playing:
		tw.tween_property(_mus_player, "volume_db", -60.0, 0.5)
	else:
		tw.tween_interval(0.05)
	tw.tween_callback(func():
		Ajustes.aplicar_audio()
		queue_free())


func _process(delta: float) -> void:
	if _fin:
		return
	t += delta
	_actualizar_musica()
	_escena.set("t", t)
	_escena.queue_redraw()
	var texto := ""
	var a := 0.0
	var tam := 32
	for c in _tarjetas_datos:
		if t >= float(c[0]) and t <= float(c[1]):
			texto = str(c[2])
			tam = int(c[3])
			a = clampf(minf(t - float(c[0]), float(c[1]) - t) / 0.6, 0.0, 1.0)
	_lbl.text = texto
	_lbl.add_theme_font_size_override("font_size", tam)
	_lbl.modulate.a = a
	if t >= DURACION:
		_terminar()


class Escena extends Control:
	var t: float = 0.0
	var seed_sitio: int = 0
	var tono: int = 0

	func _hash(i: int) -> float:
		return fposmod(sin(float(i) * 12.9898 + float(seed_sitio % 97) * 0.37) * 43758.5453, 1.0)

	func _suelo_y(x: float, hor: float) -> float:
		return hor + 16.0 * sin(x * 0.011) + 9.0 * sin(x * 0.029 + 1.0)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var alba := smoothstep(0.0, 1.0, clampf((t - 2.0) / 18.0, 0.0, 1.0)) * (1.0 if tono == 0 else (0.85 if tono == 1 else 0.6))
		var hor := h * 0.66

		var c_arr := Color(0.01, 0.01, 0.04).lerp(Color(0.2, 0.1, 0.15), alba)
		var c_abj := Color(0.04, 0.03, 0.07).lerp(Color(0.98, 0.56, 0.34), alba)
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, hor + 30.0), Vector2(0, hor + 30.0)]),
				PackedColorArray([c_arr, c_arr, c_abj, c_abj]))

		for i in range(110):
			var p := Vector2(_hash(i) * w, _hash(i + 500) * hor * 0.9)
			var br := (1.0 - alba) * (0.45 + 0.55 * sin(t * 2.0 + float(i)))
			if br > 0.02:
				draw_circle(p, 1.0 + _hash(i + 900) * 0.8, Color(1, 1, 1, br))

		var tierra := Vector2(w * 0.16, h * 0.17)
		draw_circle(tierra, 11.0, Color(0.5, 0.75, 1.0, 0.12 * (1.0 - alba * 0.7)))
		draw_circle(tierra, 5.0, Color(0.55, 0.8, 1.0, 1.0 - alba * 0.6))

		var sol := Vector2(w * 0.78, hor + 40.0 - 110.0 * alba)
		for r in [90.0, 62.0, 44.0]:
			draw_circle(sol, r, Color(1.0, 0.8, 0.5, 0.1 * alba))
		draw_circle(sol, 30.0, Color(1.0, 0.95, 0.8, alba))

		var lej := PackedVector2Array()
		lej.append(Vector2(0, h))
		var x := 0.0
		while x <= w + 20.0:
			lej.append(Vector2(x, hor - 6.0 + 22.0 * sin(x * 0.006 + 2.0) + 8.0 * sin(x * 0.02)))
			x += 20.0
		lej.append(Vector2(w, h))
		draw_colored_polygon(lej, Color(0.3, 0.14, 0.12).lerp(Color(0.62, 0.3, 0.2), alba * 0.8))

		var sue := PackedVector2Array()
		sue.append(Vector2(0, h))
		x = 0.0
		while x <= w + 20.0:
			sue.append(Vector2(x, _suelo_y(x, hor + 22.0)))
			x += 20.0
		sue.append(Vector2(w, h))
		draw_colored_polygon(sue, Color(0.14, 0.07, 0.07).lerp(Color(0.52, 0.24, 0.16), alba))

		var cx := w * 0.46
		var by := _suelo_y(cx, hor + 22.0) + 4.0
		var cupulas := [[-190.0, 44.0, 7.0], [0.0, 64.0, 9.0], [160.0, 40.0, 11.5]]
		var luz := clampf((t - 6.0) / 8.0, 0.0, 1.0)
		for c in cupulas:
			var e := smoothstep(0.0, 1.0, clampf((t - float(c[2])) / 2.0, 0.0, 1.0))
			if e < 0.05:
				continue
			var r := float(c[1]) * e
			var px := cx + float(c[0])
			var py := _suelo_y(px, hor + 22.0) + 4.0
			var pts := PackedVector2Array()
			for k in range(25):
				var a := PI + PI * float(k) / 24.0
				pts.append(Vector2(px + cos(a) * r, py + sin(a) * r * 0.85))
			draw_colored_polygon(pts, Color(0.85, 0.82, 0.8).lerp(Color(0.95, 0.88, 0.8), alba))
			draw_arc(Vector2(px, py), r, PI, TAU, 24, Color(0.4, 0.38, 0.4, 0.8), 2.0)

			for k in range(3):
				var wx := px + (float(k) - 1.0) * r * 0.5
				var lz := luz
				if tono == 1:
					lz *= 0.55 + 0.45 * sin(t * 5.0 + float(k) * 2.0 + float(c[0]))
				elif tono == 2 and absf(float(c[0])) > 1.0:
					lz *= 0.0
				elif tono == 2:
					lz *= 0.5 + 0.5 * sin(t * 4.0 + float(k))
				draw_rect(Rect2(wx - 5.0 * e, py - r * 0.45, 10.0 * e, 8.0 * e), Color(1.0, 0.85, 0.4, clampf(lz, 0.0, 1.0)))

		var et := smoothstep(0.0, 1.0, clampf((t - 12.5) / 2.0, 0.0, 1.0))
		if et > 0.0:
			var y1 := _suelo_y(cx, hor + 22.0) + 2.0
			draw_rect(Rect2(cx - 190.0 + 44.0, y1 - 9.0, (190.0 - 44.0 - 64.0) * et, 9.0), Color(0.6, 0.58, 0.58))
			draw_rect(Rect2(cx + 64.0, y1 - 9.0, (160.0 - 40.0 - 64.0) * et, 9.0), Color(0.6, 0.58, 0.58))

		var ea := smoothstep(0.0, 1.0, clampf((t - 13.5) / 2.5, 0.0, 1.0))
		if ea > 0.0:
			var ax := cx + 270.0
			var ay := _suelo_y(ax, hor + 22.0) + 3.0
			var inc := 0.0 if tono < 2 else 34.0
			var punta := Vector2(ax + inc * ea, ay - 110.0 * ea)
			draw_line(Vector2(ax, ay), punta, Color(0.75, 0.75, 0.78), 3.0)
			draw_circle(punta, 9.0 * ea, Color(0.85, 0.85, 0.88))
			if ea >= 1.0 and tono < 2:
				draw_circle(Vector2(ax, ay - 122.0), 3.0, Color(1, 0.3, 0.25, 0.5 + 0.5 * sin(t * 4.0)))

		var es := smoothstep(0.0, 1.0, clampf((t - 15.0) / 3.0, 0.0, 1.0))
		if es > 0.0:
			for k in range(4 if tono == 0 else (3 if tono == 1 else 2)):
				var px2 := cx - 330.0 + float(k) * 36.0
				var py2 := _suelo_y(px2, hor + 22.0) + 3.0
				var hh := 20.0 * es
				draw_colored_polygon(PackedVector2Array([Vector2(px2, py2), Vector2(px2 + 30.0, py2), Vector2(px2 + 26.0, py2 - hh), Vector2(px2 - 4.0, py2 - hh)]),
						Color(0.15, 0.22, 0.55))
				draw_line(Vector2(px2 + 13.0, py2), Vector2(px2 + 11.0, py2 - hh), Color(0.5, 0.6, 0.9, 0.7), 1.0)

		if t > 16.0:
			var rx := -60.0 + (t - 16.0) * 40.0
			var ry := _suelo_y(rx, hor + 70.0) + 56.0
			draw_rect(Rect2(rx, ry - 20.0, 44.0, 14.0), Color(0.92, 0.92, 0.94))
			draw_rect(Rect2(rx + 6.0, ry - 25.0, 18.0, 5.0), Color(0.2, 0.2, 0.25))
			draw_line(Vector2(rx + 34.0, ry - 20.0), Vector2(rx + 34.0, ry - 36.0), Color(0.7, 0.7, 0.72), 2.0)
			draw_rect(Rect2(rx + 30.0, ry - 40.0, 10.0, 5.0), Color(0.95, 0.95, 0.97))
			for k in range(3):
				draw_circle(Vector2(rx + 7.0 + float(k) * 15.0, ry - 5.0), 5.0, Color(0.25, 0.25, 0.28))

		if tono > 0:
			var vel := clampf((t - 3.0) / 6.0, 0.0, 1.0)
			draw_rect(Rect2(0, 0, w, h), Color(0.62, 0.36, 0.22, (0.14 if tono == 1 else 0.3) * vel))
			for i in range(40):
				var yy := hor - 150.0 + _hash(i + 77) * 260.0
				var xx := fposmod(_hash(i + 31) * w + t * (140.0 + 120.0 * _hash(i + 5)), w + 80.0) - 40.0
				draw_line(Vector2(xx, yy), Vector2(xx + 46.0, yy + 3.0), Color(0.86, 0.6, 0.42, 0.28 * vel), 2.0)

		draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.12))
		var negro := clampf(1.0 - t / 1.2, 0.0, 1.0)
		if negro > 0.0:
			draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, negro))
		var fin := clampf((t - 32.8) / 1.2, 0.0, 1.0)
		if fin > 0.0:
			draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, fin * 0.85))
