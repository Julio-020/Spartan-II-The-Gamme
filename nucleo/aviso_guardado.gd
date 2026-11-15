extends RefCounted


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")

static var _capa: CanvasLayer = null
static var _etiqueta: Label = null
static var _panel: PanelContainer = null
static var _tween: Tween = null


static func mostrar(texto: String = "GUARDADO") -> void:
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null or arbol.root == null:
		return
	if _capa == null or not is_instance_valid(_capa):
		_crear(arbol)
	_etiqueta.text = "●  " + Idioma.t(texto)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_panel.modulate.a = 0.0
	_tween = _panel.create_tween()
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.18)
	_tween.tween_interval(1.6)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.7)


static func _crear(arbol: SceneTree) -> void:
	_capa = CanvasLayer.new()
	_capa.layer = 95
	_capa.process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = PanelContainer.new()
	var e := EstiloUI.panel(EstiloUI.COL_OK, 8.0)
	e.bg_color = Color(0.02, 0.05, 0.03, 0.82)
	_panel.add_theme_stylebox_override("panel", e)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.modulate.a = 0.0
	_etiqueta = EstiloUI.etiqueta("", 15, EstiloUI.COL_OK, true)
	_etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_etiqueta)
	_capa.add_child(_panel)
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.offset_right = -24.0
	_panel.offset_bottom = -56.0
	arbol.root.add_child.call_deferred(_capa)
