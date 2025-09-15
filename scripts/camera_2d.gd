extends Camera2D

@export var shake_smoothness: float = 0.8  # suaviza el shake

var shake_amount: float = 0.0
var shake_duration: float = 0.0
var original_offset: Vector2

func _ready():
	# Guardamos la posición inicial relativa al Player
	original_offset = offset

func _process(delta):
	# Mantenemos la cámara siguiendo al Player
	if get_parent() != null:
		global_position = get_parent().global_position

	# Aplicamos shake si está activo
	if shake_duration > 0:
		shake_duration -= delta
		offset = original_offset + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		offset = original_offset

# Llamar para activar shake
func start_shake(duration: float, amount: float) -> void:
	shake_duration = duration
	shake_amount = amount
