extends Area2D

@export var fall_gravity: float = 1200.0
@export var damage: int = 1

var vel: Vector2 = Vector2.ZERO

func _ready() -> void:
	# activar monitoreo de colisiones
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	# aplicar gravedad
	vel.y += fall_gravity * delta

	# mover
	position += vel * delta

	# rotar sprite según dirección de movimiento
	if vel.length() > 0.1:
		rotation = vel.angle()

# detectar colisión con enemigos y suelo
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		# knockback solo horizontal, pequeño
		$Arrow_Impact.play()
		$Arrow.visible = false
		$CPUParticles2D.visible = false
		var knockback_dir = Vector2(sign(body.global_position.x - global_position.x) * 10, 0)
		# true = ataque de flecha
		body.take_damage(damage, knockback_dir, true)  # true = es ataque de flecha
		await get_tree().create_timer(0.2).timeout
		queue_free()
	elif body.is_in_group("Ground"):
		$Arrow_Impact.play()
		$Arrow.visible = false
		await get_tree().create_timer(0.3).timeout
		queue_free()


# ----------------------------
# LANZAR HACIA UN ENEMIGO
# ----------------------------
func launch_towards_enemy(enemy: Node2D, time_to_hit: float = 1.2) -> void:
	if not enemy or not enemy.is_inside_tree():
		return
	
	var distance = enemy.global_position - global_position
	vel.x = distance.x / time_to_hit
	vel.y = (distance.y - 0.5 * fall_gravity * time_to_hit * time_to_hit) / time_to_hit
