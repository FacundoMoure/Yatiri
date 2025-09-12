extends CharacterBody2D
class_name Player

@export var speed: float = 200
@export var gravity: float = 900

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.ZERO
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento horizontal solo si NO está atacando
	if not is_attacking:
		direction.x = Input.get_axis("left", "right")
		velocity.x = direction.x * speed if direction.x != 0 else move_toward(velocity.x, 0, speed)
	else:
		velocity.x = 0  # bloqueamos el movimiento durante el ataque

	direction.y = 0

	# Animaciones
	if is_attacking:
		# Si la animación de ataque terminó, desbloquear
		if not animated_sprite.is_playing():
			is_attacking = false
	else:
		if Input.is_action_just_pressed("attack"):
			animated_sprite.play("attack")
			is_attacking = true
		elif direction.x != 0:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

	move_and_slide()
	update_facing_direction()

func update_facing_direction() -> void:
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
