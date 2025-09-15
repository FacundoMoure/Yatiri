extends CharacterBody2D
class_name Enemy

@export var health: int = 100
@export var knockback_force: float = 100.0
@export var attack_knockback: float = 400.0
@export var walk_speed: float = 170.0      # velocidad al caminar después de atacar
@export var walk_duration: float = 1.6    # tiempo (segundos) que camina antes de volver a idle
@export var steps_volume_db: float = -23.0  # volumen en dB, ajustable desde inspector

@onready var enemy: AnimatedSprite2D = $Enemy
@onready var attack_area: Area2D = $AttackArea
@onready var animated_sprite: AnimatedSprite2D = $Enemy

var flashing := false
var _original_modulate: Color = Color(1, 1, 1, 1)
var is_hurt := false        # bloquea animaciones y ataques mientras está herido
var can_attack_sound := true
var is_dead := false
var is_attacking := false
var is_walking := false     # flag para caminar luego de atacar

func _ready() -> void:
	_original_modulate = enemy.modulate
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si está herido o muerto, no hacemos lógica de ataque ni walk
	if is_hurt or is_dead:
		move_and_slide()
		attack_area.monitoring = false
		is_attacking = false
		return

	if not is_walking:
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)

	if is_walking:
		velocity.x = walk_speed               # movimiento hacia la derecha
		animated_sprite.flip_h = false        # mira a la derecha
		if animated_sprite.animation != "walk":
			$Steps.volume_db = steps_volume_db   # aplicar volumen desde inspector
			$Steps.play()
			animated_sprite.play("walk")      # reproducir animación "walk"

	move_and_slide()

	if not is_walking:
		var player_list = get_tree().get_nodes_in_group("Player")
		if player_list.size() == 0:
			if not is_attacking:
				animated_sprite.play("idle")
				$Steps.stop()
			attack_area.monitoring = false
			return

		var player = player_list.front()
		if player and global_position.distance_to(player.global_position) < 60 and not is_hurt:
			# iniciar ataque
			if not is_attacking:
				
				animated_sprite.play("attack")
				is_attacking = true
				
			attack_area.monitoring = animated_sprite.frame == 2

			if can_attack_sound:
				$Attack.play()
				can_attack_sound = false
				_reset_attack_sound_cooldown()
		else:
			if not is_attacking:
				animated_sprite.play("idle")
				$Steps.stop()
			attack_area.monitoring = false

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		# termina ataque
		is_attacking = false
		attack_area.monitoring = false

		# empieza a caminar hacia la derecha
		await get_tree().create_timer(0.4).timeout
		is_walking = true

		_return_to_idle()

func _return_to_idle() -> void:
	await get_tree().create_timer(walk_duration).timeout
	is_walking = false
	velocity = Vector2.ZERO
	animated_sprite.flip_h = true    # vuelve a mirar a la izquierda
	animated_sprite.play("idle")

func take_damage(amount: int, knockback_dir: Vector2, is_arrow_attack: bool = false) -> void:
	if health <= 0 or is_dead:
		return

	health -= amount
	is_hurt = true
	animated_sprite.play("hurt")

	# Aplicar knockback siempre
	velocity = knockback_dir

	# El sonido ya lo reproduce la flecha, no es necesario aquí
	# Solo reproducimos sonido si querés otro para ataques cuerpo a cuerpo
	if not is_arrow_attack:
		$AttackHit.play()

	flash_white()
	await get_tree().create_timer(0.3).timeout
	is_hurt = false

	if health > 0:
		animated_sprite.play("idle")
	else:
		die()

func die() -> void:
	is_dead = true
	$CollisionShape2D.disabled = true
	animated_sprite.play("death")
	velocity = Vector2.ZERO

func flash_white() -> void:
	if flashing:
		return
	flashing = true
	var original = enemy.modulate
	enemy.modulate = Color(2, 2, 2, 1)
	await get_tree().create_timer(0.1).timeout
	enemy.modulate = original
	flashing = false

func _on_attack_area_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.is_in_group("Player") and body.has_method("take_damage"):
		var dir = Vector2(sign(body.global_position.x - global_position.x), 0) * (attack_knockback / 2)
		var hit_from_right = body.global_position.x < global_position.x
		body.take_damage(dir, hit_from_right)

		# Pequeño delay para shake de cámara
		await get_tree().create_timer(0.1).timeout
		if body.has_method("camera_shake"):
			body.camera_shake(0.4, 3)

func _reset_attack_sound_cooldown() -> void:
	await get_tree().create_timer(3.0).timeout
	can_attack_sound = true
