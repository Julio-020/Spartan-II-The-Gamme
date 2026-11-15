extends Area3D

# Definimos una señal que le avisará al GameManager las coordenadas elegidas
signal location_selected(coordinates: Vector3)

func _ready() -> void:
	# Conectamos la señal nativa de Godot para detectar interacciones del ratón
	input_event.connect(_on_input_event)

# Función corregida sin parámetros duplicados
func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# Comprobamos si el usuario hizo clic izquierdo y soltó/pulsó el botón
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Emitimos la posición tridimensional global de este cono hacia el GameManager
		location_selected.emit(global_position)
		print("¡Coordenadas de aterrizaje registradas en: ", global_position, "!")
