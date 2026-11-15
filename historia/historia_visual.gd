extends RefCounted


const BaseSalida := preload("res://mision/base_salida.gd")

const ROVERS := ["Sojourner", "Spirit", "Opportunity", "Curiosity", "Perseverance", "Zhurong", "Pancam"]
const CHOQUES := ["polar_lander"]


static func tipo(m: Dictionary) -> String:
	if str(m.get("tipo", "")) == "restos":
		return "restos"
	var nave := str(m.get("nave", ""))
	for r in ROVERS:
		if nave.contains(r):
			return "rover"
	return "aterrizaje"


static func modo(id: String) -> String:
	return "choque" if CHOQUES.has(id) else "silencio"


static func estilo(m: Dictionary) -> String:
	return BaseSalida.estilo_de(m)


static func aplica(m: Dictionary) -> bool:
	return str(m.get("era", "")) != "" and str(m.get("id", "")) != "" and int(str(m.get("era", "0"))) > 0
