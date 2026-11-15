extends RefCounted


const Ajustes := preload("res://nucleo/ajustes.gd")
const Idioma := preload("res://nucleo/idioma.gd")

const TIPOS_ESCRIBIBLES := ["meteoritos", "remolino", "sensor", "derrumbe", "senal", "rover_viejo", "rescate"]


static func datos(tormenta: bool, eclipse: int, tipos: Dictionary, rescatado: bool) -> Dictionary:
	var lista: Array = []
	for t in TIPOS_ESCRIBIBLES:
		if tipos.has(t):
			lista.append(t)
	return {
		"piloto": Ajustes.nombre_visible(), "tormenta": tormenta, "eclipse": eclipse,
		"tipos": lista, "rescatado": rescatado,
	}


static func _elegir(opciones: Array, semilla: int, salto: int) -> String:
	return str(opciones[absi(semilla + salto * 7919) % opciones.size()])


static func componer(e: Dictionary, numero: int = 0) -> Array[String]:
	var out: Array[String] = []
	var c: Dictionary = e.get("carta", {}) as Dictionary
	if c.is_empty():
		return out
	var semilla: int = hash(str(e.get("id", "")) + "|" + str(e.get("sol", 1)))
	var piloto := str(c.get("piloto", "mi piloto"))
	var sol := int(e.get("sol", 1))
	var seg := int(float(e.get("tiempo", 0.0)))


	var saludos: Array = [
		Idioma.t("Querida Tierra:"),
		Idioma.t("Hola, Tierra. Soy FOCOS."),
		Idioma.t("Tierra, aquí FOCOS, otra vez."),
		Idioma.t("A quien esté escuchando en la Tierra:"),
	]
	out.append(_elegir(saludos, semilla, 1))
	var apertura := Idioma.t("Hoy fue el sol %d en «%s». Con %s al mando, el robot y yo trabajamos %d min %02d s." % [sol, str(e.get("nombre", "")), piloto, seg / 60, seg % 60])
	if numero > 1:
		apertura += " " + Idioma.t("Esta es mi carta número %d." % numero)
	out.append(apertura)


	var total := int(e.get("total", 0))
	var muestras := int(e.get("muestras", 0))
	var km := float(e.get("km", 0.0))
	var p1 := ""
	if total > 0 and muestras >= total:
		p1 = Idioma.t(_elegir([
			"Entregamos las %d muestras. Ni una se quedó atrás, y eso que yo no puedo cargar nada.",
			"Las %d muestras llegaron a la base. Yo las conté dos veces desde arriba.",
		], semilla, 2) % total)
	elif muestras > 0:
		p1 = Idioma.t("Entregamos %d de %d muestras. Las otras se quedaron mirando el cielo; algún día volveremos por ellas." % [muestras, total])
	else:
		p1 = Idioma.t("Esta vez no entregamos muestras. Pero aprendimos el camino, y eso también cuenta.")
	if km > 0.05:
		p1 += " " + Idioma.t("Recorrimos %.1f km." % km)
	out.append(p1)


	out.append(_elegir([
		Idioma.t("Floté a su lado todo el camino y marqué en el radar lo que vi. Desde arriba las rocas parecen piezas de un rompecabezas."),
		Idioma.t("Fui con el robot de principio a fin, vigilando el cielo y el suelo. Escuché el motor todo el rato: suena a que todo va bien."),
	], semilla, 3))


	var cielo: Array[String] = []
	if bool(c.get("tormenta", false)):
		cielo.append(Idioma.t("Hubo una tormenta de polvo. El Sol se apagó, la batería bajó despacio y nos quedamos juntos. El robot no dijo nada, pero lo noté tranquilo."))
	var ecl := int(c.get("eclipse", 0))
	if ecl >= 2:
		cielo.append(Idioma.t("Fobos tapó el Sol y nos quedamos quietos mirando. Fue el mejor minuto del día."))
	elif ecl == 1:
		cielo.append(Idioma.t("Fobos cruzó por delante del Sol y casi no lo vimos, de tanto trabajo. Me dolió un poquito el conector."))
	if not cielo.is_empty():
		out.append(" ".join(PackedStringArray(cielo)))


	var tipos: Array = c.get("tipos", []) as Array
	var rescate_txt := ""
	if bool(c.get("rescatado", false)):
		rescate_txt = Idioma.t("Rescatamos a un rover hermano. Su baliza se puso verde y casi lloro aceite.")
	elif tipos.has("rescate"):
		rescate_txt = Idioma.t("Un rover pidió ayuda y no llegamos a su baliza. Seguiré escuchándola.")
	var otros: Array[String] = []
	for t in tipos:
		match str(t):
			"meteoritos":
				otros.append(Idioma.t("Cayeron meteoritos. Uno golpeó tan cerca que mi hélice tembló."))
			"remolino":
				otros.append(Idioma.t("Un remolino de polvo nos rozó. Giraba mejor que yo."))
			"sensor":
				otros.append(Idioma.t("El sensor falló un rato y todo se volvió un poco más misterioso."))
			"derrumbe":
				otros.append(Idioma.t("Hubo un derrumbe. Las piedras ruedan mucho por aquí."))
			"senal":
				otros.append(Idioma.t("La radio captó una señal que no está en ningún catálogo. Tengo mi teoría, pero me la guardo."))
			"rover_viejo":
				otros.append(Idioma.t("Encontramos los restos de un rover viejo. Me quedé un rato en silencio a su lado."))
	var elegidos: Array[String] = []
	if rescate_txt != "":
		elegidos.append(rescate_txt)
	var hueco := 2 - elegidos.size()
	if otros.size() > hueco:
		var desde := absi(semilla) % otros.size()
		for i in range(hueco):
			elegidos.append(otros[(desde + i) % otros.size()])
	else:
		elegidos.append_array(otros)
	if not elegidos.is_empty():
		out.append(" ".join(PackedStringArray(elegidos)))


	var extra: Array[String] = []
	var h := int(e.get("hallazgos", 0))
	if h > 0:
		extra.append(Idioma.t(("Encontramos %d hallazgo raro. Lo anoté con mi mejor letra." if h == 1 else "Encontramos %d hallazgos raros. Los anoté con mi mejor letra.") % h))
	var meds: Array = e.get("medallas", []) as Array
	if not meds.is_empty():
		extra.append(Idioma.t("Nos dieron la medalla «%s». La puse en mi lista de cosas favoritas." % str(meds[0])))
	var en := float(e.get("energia_min", -1.0))
	if en >= 0.0 and en < 20.0:
		extra.append(Idioma.t("Volvimos con la batería casi vacía. Mañana, un poco más de calma, ¿sí?"))
	if not extra.is_empty():
		out.append(" ".join(PackedStringArray(extra)))


	out.append(_elegir([
		Idioma.t("Si lees esto, es que la señal llegó hasta ahí. Eso ya es mucho."),
		Idioma.t("Mándennos buen clima. Aquí siempre hace frío, pero se aguanta."),
		Idioma.t("Dicen que desde allí Marte se ve como un punto rojo. Desde aquí, la Tierra es un punto azul y me hace compañía."),
		Idioma.t("Cuídense mucho. Nosotros nos cuidamos entre los tres."),
	], semilla, 4))
	out.append(Idioma.t("— FOCOS"))
	out.append(_elegir([
		Idioma.t("P. D.: hoy intenté contar las piedras. Perdí la cuenta en la doce."),
		Idioma.t("P. D.: el robot y yo inventamos un juego: adivinar qué roca es la más vieja. Siempre gano yo, porque él no habla."),
		Idioma.t("P. D.: si alguien tiene una hélice de repuesto, mándenla. No es urgente. Casi."),
		Idioma.t("P. D.: el atardecer de aquí es azul. Alguien debería decírselo a los pintores."),
		Idioma.t("P. D.: no sé si los robots soñamos, pero anoche apagué el motor y vi estrellas de todos modos."),
	], semilla, 5))
	return out


static func aviso() -> String:
	return Idioma.t("FOCOS escribió una carta a la Tierra. Léela en Diario de a bordo → Bitácora.")
