extends Area2D
class_name Lightning

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Dirección que le pasa el Player (1 = derecha, -1 = izquierda)
var direction: int = 1

func _ready() -> void:
	# Conectar señales
	body_entered.connect(_on_body_entered)  # ⚡ Area2D sí emite body_entered
	anim.animation_finished.connect(_on_animation_finished)

	# Voltear sprite según dirección
	anim.flip_h = direction < 0

	# Reproducir animación al aparecer
	anim.play("default")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var knockback_dir = Vector2(direction, 0) * 200
		body.take_damage(99, knockback_dir)


func _on_animation_finished() -> void:
	queue_free()
