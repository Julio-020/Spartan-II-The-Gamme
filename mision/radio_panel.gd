extends CanvasLayer


signal elegida(indice: int)
signal guardada

const Historia := preload("res://historia/historia.gd")
const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const ANCHO_COMPACTO := 500.0
const VEL_ESCRITURA := 0.028

var _jefe: String = ""
var _titulo: String = ""
var _texto_txt: String = ""
var _ops: Array = []
var _pie: String = ""
var _lbl_texto: Label
var _lbl_ops: VBoxContainer
var _escrito: bool = true
var _tw_texto: Tween = null


class Insignia extends Control:
	var codigo: String = ""
	var color: Color = Color.WHITE
	var fuente: Font = null
	var pulso: float = 0.0

	func _process(delta: float) -> void:
		pulso += delta
		queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5 - 3.0
		draw_circle(c, r, Color(color.r * 0.18, color.g * 0.18, color.b * 0.18, 0.95))
		draw_arc(c, r, 0.0, TAU, 48, color, 3.0, true)
		var a := 0.35 + 0.25 * sin(pulso * 3.0)
		draw_arc(c, r + 2.5, 0.0, TAU, 48, Color(color.r, color.g, color.b, a), 1.5, true)
		var f: Font = fuente if fuente != null else ThemeDB.fallback_font
		var tam := int(r * 0.78)
		var w := f.get_string_size(codigo, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		draw_string(f, Vector2(c.x - w * 0.5, c.y + tam * 0.34), codigo, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color.WHITE)


func configurar(jefe: String, titulo: String, texto: String, ops: Array, pie: String) -> void:
	_jefe = jefe
	_titulo = titulo
	_texto_txt = texto
	_ops = ops
	_pie = pie
	layer = 30


func _ready() -> void:
	_construir_compacto()


func _datos_jefe() -> Dictionary:
	return Historia.jefe(_jefe)


func _insignia(tam: float) -> Insignia:
	var inf := _datos_jefe()
	var ins := Insignia.new()
	ins.codigo = str(inf.get("cod", "???"))
	ins.color = inf.get("color", EstiloUI.COL_ACENTO)
	ins.fuente = EstiloUI.fuente_titulo()
	ins.custom_minimum_size = Vector2(tam, tam)
	ins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return ins


func _construir_compacto() -> void:
	var inf := _datos_jefe()
	var col: Color = inf.get("color", EstiloUI.COL_ACENTO)
	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", EstiloUI.panel(col, 12.0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.anchor_left = 0.5
	p.anchor_right = 0.5
	p.offset_left = -ANCHO_COMPACTO * 0.5
	p.offset_right = ANCHO_COMPACTO * 0.5
	p.offset_top = 74.0
	p.grow_vertical = Control.GROW_DIRECTION_END
	raiz.add_child(p)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(fila)
	fila.add_child(_insignia(58.0))
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 4)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(c)
	c.add_child(EstiloUI.etiqueta("%s  ·  %s" % [_titulo, Historia.titulo(_jefe)], 14, col, true))
	_lbl_texto = EstiloUI.etiqueta_sub("«%s»" % _texto_txt, 16, EstiloUI.COL_TEXTO)
	_lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_texto.custom_minimum_size = Vector2(ANCHO_COMPACTO - 120.0, 0.0)
	c.add_child(_lbl_texto)
	for i in range(_ops.size()):
		var l := EstiloUI.etiqueta_sub("[%d]  %s" % [i + 1, str(_ops[i])], 16, Color.WHITE, true)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(ANCHO_COMPACTO - 120.0, 0.0)
		c.add_child(l)
	c.add_child(EstiloUI.etiqueta(_pie, 12, EstiloUI.COL_TENUE))
	p.modulate.a = 0.0
	var y0 := p.offset_top
	p.offset_top = y0 - 24.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(p, "modulate:a", 1.0, 0.35)
	tw.tween_property(p, "offset_top", y0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _fin_escritura() -> void:
	_escrito = true
	if _lbl_texto != null:
		_lbl_texto.visible_ratio = 1.0
	if _lbl_ops != null:
		create_tween().tween_property(_lbl_ops, "modulate:a", 1.0, 0.4)


func intentar(i: int) -> bool:
	if not _escrito:
		if _tw_texto != null:
			_tw_texto.kill()
		_fin_escritura()
		return false
	if i < 0 or i >= _ops.size():
		return false
	elegida.emit(i)
	return true


func cerrar() -> void:
	queue_free()
