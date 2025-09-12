extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	$Arrow.play("default")

	# opcional: borrar la flecha si se va muy lejos
	if abs(position.x) > 2000:
		queue_free()
