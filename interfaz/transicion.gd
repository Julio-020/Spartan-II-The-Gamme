extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")

const CONSEJOS := [
	"Pulsa ESPACIO para escanear: las muestras cercanas se revelan con un destello.",
	"Las tormentas de polvo tapan el Sol: mientras duran, la batería no se recarga.",
	"Pulsa J en plena misión para abrir el diario: ahí ves tu progreso, la confianza con los jefes y tus decisiones.",
	"Cuando un jefe te consulte por radio, responde con 1, 2 o 3. Tus decisiones tienen consecuencias.",
	"Si un jefe confía mucho en ti, te da una ventaja en cada misión. Mira la pestaña EQUIPO del diario.",
	"Un punto «!» en el radar marca una misión secundaria. Cumplirla da confianza y batería.",
	"Entregar las muestras en la base te acerca a la medalla «Batería de sobra».",
	"Al final de la campaña elegirás dónde aterrizan los primeros humanos. Cada decisión suma puntos a un lugar.",
	"Los datos curiosos azules enseñan cosas reales de Marte. Léelos con E.",
	"Repetir una misión es buena idea: puedes ganar medallas nuevas y mejorar tu ruta.",
]

var _raiz: Control
var _lbl_acc: Label
var _lbl_nombre: Label
var _lbl_sub: Label
var _lbl_consejo: Label
var _barra: ProgressBar
var _tween: Tween
var _n_consejo: int = 0


func _ready() -> void:
	layer = 55
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.modulate.a = 0.0
	_raiz.visible = false
	add_child(_raiz)

	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.0))
	g.set_color(1, Color(0.02, 0.01, 0.01, 0.88))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(0.0, 1.0)
	tex.width = 8
	tex.height = 256
	var fondo := TextureRect.new()
	fondo.texture = tex
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.anchor_top = 0.62
	fondo.anchor_right = 1.0
	fondo.anchor_bottom = 1.0
	_raiz.add_child(fondo)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.anchor_left = 0.5
	caja.anchor_right = 0.5
	caja.anchor_top = 1.0
	caja.anchor_bottom = 1.0
	caja.offset_left = -420.0
	caja.offset_right = 420.0
	caja.offset_top = -190.0
	caja.offset_bottom = -52.0
	_raiz.add_child(caja)
	_lbl_acc = EstiloUI.etiqueta("", 16, EstiloUI.COL_ACENTO, true)
	_lbl_acc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_lbl_acc)
	_lbl_nombre = EstiloUI.etiqueta("", 38, EstiloUI.COL_TEXTO, true)
	_lbl_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_lbl_nombre)
	_lbl_sub = EstiloUI.etiqueta("", 16, EstiloUI.COL_FRIO)
	_lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_lbl_sub)
	_barra = EstiloUI.barra(EstiloUI.COL_ACENTO, 5.0)
	_barra.min_value = 0.0
	_barra.max_value = 1.0
	_barra.custom_minimum_size = Vector2(0.0, 5.0)
	caja.add_child(_barra)
	_lbl_consejo = EstiloUI.etiqueta("", 16, EstiloUI.COL_TENUE)
	_lbl_consejo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_consejo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_consejo.custom_minimum_size = Vector2(840.0, 0.0)
	caja.add_child(_lbl_consejo)


func mostrar(accion: String, nombre: String, sub: String, consejo: String = "") -> void:
	_lbl_acc.text = accion
	_lbl_nombre.text = nombre
	_lbl_sub.text = sub
	_n_consejo = (_n_consejo + 1 + randi() % 3) % CONSEJOS.size()
	_lbl_consejo.text = ("CONSEJO  ·  " + CONSEJOS[_n_consejo]) if consejo == "" else consejo
	_barra.value = 0.0
	_raiz.visible = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_raiz, "modulate:a", 1.0, 0.6)


func progreso(t: float) -> void:
	_barra.value = clampf(t, 0.0, 1.0)


func ocultar() -> void:
	if not _raiz.visible:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_raiz, "modulate:a", 0.0, 0.8)
	_tween.tween_callback(func(): _raiz.visible = false)
