extends CanvasLayer


const EstiloUI := preload("res://interfaz/estilo_ui.gd")
const Idioma := preload("res://nucleo/idioma.gd")

signal preguntar(jefe: String)
signal cerrada

const JEFES := ["KELLY", "JULIO", "REYZER", "GERALD", "DAID"]
const TEMAS := {
	"KELLY": "seguridad: batería y tormentas",
	"JULIO": "ciencia: la muestra más cercana",
	"REYZER": "el robot: sistemas y bodega",
	"GERALD": "ruta: hacia la base",
	"DAID": "corazonada: lo inesperado",
}
const COLORES := {
	"KELLY": Color(0.45, 0.8, 1.0), "JULIO": Color(0.55, 0.95, 0.6), "REYZER": Color(1.0, 0.72, 0.3),
	"GERALD": Color(0.8, 0.65, 1.0), "DAID": Color(1.0, 0.5, 0.65),
}
const ENFRIAMIENTO := 35.0
const MAX_PENDIENTES := 3

var retraso: float = 30.0
var min_luz: float = 12.0

var _panel: PanelContainer
var _botones: Dictionary = {}
var _info: Label
var _aviso: Label
var _abierta: bool = false


func _ready() -> void:
	layer = 55
	_aviso = EstiloUI.etiqueta_contorno("", 15, Color(0.7, 0.9, 1.0), false)
	_aviso.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_aviso.anchor_left = 0.5
	_aviso.anchor_right = 0.5
	_aviso.offset_left = -220.0
	_aviso.offset_right = 220.0
	_aviso.offset_top = 92.0
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aviso.visible = false
	add_child(_aviso)

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", EstiloUI.panel(Color(0.55, 0.85, 1.0), 18.0))
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -220.0
	_panel.offset_right = 220.0
	_panel.offset_top = -200.0
	_panel.offset_bottom = 170.0
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_panel.visible = false
	add_child(_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 7)
	_panel.add_child(v)
	v.add_child(EstiloUI.etiqueta("RADIO A LA TIERRA", 24, Color(0.55, 0.85, 1.0), true))
	_info = EstiloUI.etiqueta("", 14, EstiloUI.COL_TENUE)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.custom_minimum_size = Vector2(400, 0)
	v.add_child(_info)
	v.add_child(EstiloUI.linea())
	for i in range(JEFES.size()):
		var j: String = JEFES[i]
		var b := EstiloUI.boton("", 16)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): preguntar.emit(j))
		v.add_child(b)
		_botones[j] = b
	var pie := EstiloUI.etiqueta("1-5: preguntar  ·  C o ESC: cerrar. El juego no se detiene.", 13, EstiloUI.COL_TENUE)
	pie.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pie.custom_minimum_size = Vector2(400, 0)
	v.add_child(pie)
	refrescar({})


func abierta() -> bool:
	return _abierta


func abrir() -> void:
	_abierta = true
	_panel.visible = true


func cerrar() -> void:
	if not _abierta:
		return
	_abierta = false
	_panel.visible = false
	cerrada.emit()


func refrescar(estados: Dictionary) -> void:
	_info.text = Idioma.t("Marte está a %d minutos-luz de la Tierra. Tu consulta tarda unos %d s en volver." % [int(round(min_luz)), int(round(retraso))])
	var pendientes := 0
	for i in range(JEFES.size()):
		var j: String = JEFES[i]
		var e: Dictionary = estados.get(j, {})
		var pend := float(e.get("pend", -1.0))
		var cd := float(e.get("cd", 0.0))
		var b: Button = _botones[j]
		var txt := "%d · %s  —  %s" % [i + 1, j, Idioma.t(str(TEMAS[j]))]
		if pend >= 0.0:
			pendientes += 1
			txt = "%d · %s  —  %s (%d s)" % [i + 1, j, Idioma.t("esperando respuesta"), int(ceil(pend))]
			b.disabled = true
		elif cd > 0.0:
			txt = "%d · %s  —  %s (%d s)" % [i + 1, j, Idioma.t("descansando"), int(ceil(cd))]
			b.disabled = true
		else:
			b.disabled = false
		b.text = txt
		b.add_theme_color_override("font_color", COLORES[j])
	_aviso.visible = pendientes > 0
	if pendientes > 0:
		_aviso.text = Idioma.t(("Radio: %d respuesta en camino" if pendientes == 1 else "Radio: %d respuestas en camino") % pendientes)


func _input(event: InputEvent) -> void:
	if not _abierta:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_C, KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				cerrar()
			KEY_1, KEY_KP_1: _tecla(0)
			KEY_2, KEY_KP_2: _tecla(1)
			KEY_3, KEY_KP_3: _tecla(2)
			KEY_4, KEY_KP_4: _tecla(3)
			KEY_5, KEY_KP_5: _tecla(4)


func _tecla(i: int) -> void:
	get_viewport().set_input_as_handled()
	var b: Button = _botones[JEFES[i]]
	if not b.disabled:
		preguntar.emit(JEFES[i])


static func retraso_de(id_mision: String) -> Dictionary:
	var h := 0
	for i in range(id_mision.length()):
		h = (h * 31 + id_mision.unicode_at(i)) % 100003
	var f := float(h % 1000) / 999.0
	return {"seg": 20.0 + 25.0 * f, "min_luz": 4.0 + 20.0 * f}


static func reloj(ang: float) -> String:
	var hora := int(round(rad_to_deg(ang) / 30.0))
	hora = ((hora % 12) + 12) % 12
	match hora:
		0: return Idioma.t("justo al frente")
		3: return Idioma.t("a tu derecha")
		6: return Idioma.t("justo detrás")
		9: return Idioma.t("a tu izquierda")
	return Idioma.t("a tus %d en punto" % hora)


static func respuesta(jefe: String, s: Dictionary, a: Dictionary, semilla: int) -> Dictionary:
	var res := {"texto": "", "dir": Vector3.ZERO, "color": COLORES.get(jefe, Color.WHITE), "seg": 40.0}
	var t := ""
	match jefe:
		"KELLY":
			var bat := int(round(float(a.get("energia", 100.0))))
			if int(s.get("storm", 0)) == 0 and int(a.get("storm", 0)) >= 1:
				t = Idioma.t("Cuando miré no había nada, pero la tormenta ya está encima. Quédate quieto y cuida la batería.")
			elif int(a.get("storm", 0)) == 2:
				t = Idioma.t("Hay tormenta sobre ti. Para y espera: batería al %d %%." % bat)
			elif int(a.get("storm", 0)) == 1:
				t = Idioma.t("Viene una tormenta de polvo. Busca un sitio abrigado y no gastes batería.")
			elif bat < 25:
				t = Idioma.t("Cuidado con la batería: %d %%. Ve despacio y no te alejes de la base." % bat)
			elif float(a.get("storm_en", -1.0)) > 0.0:
				t = Idioma.t("Sin tormentas ahora. La próxima la espero en unos %d min." % maxi(1, int(round(float(a["storm_en"]) / 60.0))))
			else:
				t = Idioma.t("Batería al %d %%. No veo tormentas cerca. Cuídate, que esto lo vi hace un momento." % bat)
		"JULIO":
			if bool(a.get("obj_vivo", false)):
				t = Idioma.t("La muestra más cercana desde donde estabas es %s: %s. Estaba a unos %d m, %s. Te la marco con una luz." % [
						Idioma.t(str(s.get("obj_nombre", ""))), Idioma.t(str(s.get("obj_pista", ""))), int(s.get("obj_dist", 0.0)), reloj(float(s.get("obj_ang", 0.0)))])
				res["dir"] = s.get("obj_dir", Vector3.ZERO)
			elif a.has("obj2_dir"):
				t = Idioma.t("La que te iba a señalar ya la recogiste. Te marco la siguiente: %s, a unos %d m." % [
						Idioma.t(str(a.get("obj2_nombre", ""))), int(a.get("obj2_dist", 0.0))])
				res["dir"] = a["obj2_dir"]
			elif int(a.get("bodega", 0)) > 0:
				t = Idioma.t("Ya no quedan muestras: lo que falta es entregar. Ve a la base.")
			else:
				t = Idioma.t("Aquí no hay muestras que marcar. Revisa el diario: el objetivo de esta misión es otro.")
		"REYZER":
			var bat := int(round(float(a.get("energia", 100.0))))
			if bool(a.get("sin_energia", false)):
				t = Idioma.t("Estás sin batería. Espera al Sol y no le pidas más al motor.")
			elif float(a.get("escaner_roto", 0.0)) > 0.0:
				t = Idioma.t("El escáner está fallando; se arregla solo en unos segundos. No lo uses mientras tanto.")
			elif int(a.get("bodega", 0)) >= int(a.get("cap", 3)) and int(a.get("cap", 3)) > 0:
				t = Idioma.t("Llevas la bodega llena: no cabe nada más. Entrega en la base.")
			elif bat < 40 and float(s.get("base_dist", 0.0)) > 250.0:
				t = Idioma.t("Con esa batería la base queda a %d m. Yo que tú, vuelvo ya." % int(s.get("base_dist", 0.0)))
			else:
				t = Idioma.t("Todo en orden. Batería al %d %%, bodega %d de %d." % [bat, int(a.get("bodega", 0)), int(a.get("cap", 3))])
		"GERALD":
			var d := int(s.get("base_dist", 0.0))
			if d < 60:
				t = Idioma.t("Ya estás casi en la base. Entrega y sigue.")
			else:
				var llena := int(a.get("bodega", 0)) >= int(a.get("cap", 3)) and int(a.get("cap", 3)) > 0
				t = (Idioma.t("Bodega llena: ruta directa a la base, %s, a unos %d m. Te la marco.") if llena
						else Idioma.t("La base queda %s, a unos %d m. Te la marco.")) % [reloj(float(s.get("base_ang", 0.0))), d]
				res["dir"] = a.get("base_dir", Vector3.ZERO)
		"DAID":
			if s.has("hall_dir") and semilla % 5 < 3:
				t = Idioma.t("Tengo una corazonada... Hay algo escondido %s, a unos %d m. No me preguntes cómo lo sé." % [
						reloj(float(s.get("hall_ang", 0.0))), int(s.get("hall_dist", 0.0))])
				res["dir"] = s["hall_dir"]
				res["color"] = Color(1.0, 0.82, 0.25)
			else:
				var raras := [
					"No sé por qué, pero hoy el polvo huele a tormenta.",
					"Mira hacia donde las sombras son más largas.",
					"Si Marte pudiera hablar, diría que vayas despacio.",
					"Esa roca de allá te está mirando. No me hagas caso.",
					"Tengo un presentimiento. ¿Ya tomaste agua? Ah, no: tú eres un robot.",
					"A veces la mejor ruta es la que no está en el mapa.",
				]
				t = Idioma.t(str(raras[semilla % raras.size()]))
	res["texto"] = t
	return res
