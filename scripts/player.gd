extends CharacterBody2D
class_name Player

@export var speed: float = 200
@export var walk_slow_speed: float = 100.0
@export var walk_slowdown_after: float = 6.0
@export var attack_knockback: float = 25.0
@export var health: int = 100
@export var flash_duration: float = 0.4
@export var knockback_friction: float = 500.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var steps: AudioStreamPlayer2D = $Steps
@onready var attack_sound: AudioStreamPlayer2D = $Attack
@onready var camera: Camera2D = $Camera2D
@onready var coin_scene: PackedScene = preload("res://scenes/dropped_coin.tscn")

var direction: Vector2 = Vector2.ZERO
var is_attacking: bool = false
var is_hurt: bool = false
var flashing: bool = false
var is_dead := false

var walk_timer: float = 0.0
var knockback_timer: float = 0.0
var knockback_duration: float = 0.2

func _ready() -> void:
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_shape.disabled = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- Movimiento ---
	direction.x = Input.get_axis("left", "right")

	# Contar tiempo caminando solo si el jugador se mueve
	if direction.x != 0 and not is_attacking and not is_hurt:
		walk_timer += delta
	else:
		walk_timer = 0.0

	# Reducir velocidad si supera los 6 segundos caminando
	var current_speed = speed
	if walk_timer >= walk_slowdown_after:
		current_speed = walk_slow_speed

	# Movimiento horizontal
	if not is_attacking and not is_hurt:
		if direction.x != 0:
			velocity.x = direction.x * current_speed
		else:
			velocity.x = 0
	elif is_hurt:
		# aplicar freno solo durante knockback
		if knockback_timer > 0:
			knockback_timer -= delta
			velocity.x = move_toward(velocity.x, 0, knockback_friction * delta)
		else:
			is_hurt = false

	# --- Animaciones y ataque ---
	if is_attacking:
		if animated_sprite.animation == "attack" and animated_sprite.frame == 2:
			attack_shape.disabled = false
		else:
			attack_shape.disabled = true
	elif not is_hurt:
		if Input.is_action_just_pressed("attack") and not is_attacking:
			_start_attack()
		elif direction.x != 0:
			if animated_sprite.animation != "run":
				steps.pitch_scale = randf_range(0.8, 1.0)
				steps.play()
				animated_sprite.play("run")
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
			if steps.playing:
				steps.stop()

	move_and_slide()
	update_facing_direction()

func update_facing_direction() -> void:
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	animated_sprite.play("attack")
	if steps.playing:
		steps.stop()
	attack_sound.play()

	await animated_sprite.animation_finished
	is_attacking = false
	attack_shape.disabled = true

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var dir = Vector2(sign(body.global_position.x - global_position.x), 0) * attack_knockback
		body.take_damage(5, dir)

func take_damage(knockback_dir: Vector2, hit_from_right: bool) -> void:
	if is_dead:
		return

	$AttackHit.play()
	flash_white()
	_drop_coin(hit_from_right)

	var knockback_strength = 250
	velocity = knockback_dir.normalized() * knockback_strength
	is_hurt = true
	knockback_timer = knockback_duration

	# reproducir animación hurt solo si no estás atacando
	if not is_attacking:
		animated_sprite.play("hurt")

	await get_tree().create_timer(0.1).timeout

	if direction.x == 0 and not is_attacking:
		animated_sprite.play("idle")
	elif direction.x != 0 and not is_attacking:
		animated_sprite.play("run")

	if Global.coins <= 0:
		die()

func flash_white() -> void:
	if flashing:
		return
	flashing = true
	var original = animated_sprite.modulate
	animated_sprite.modulate = Color(2,2,2,1)

	var t = Timer.new()
	t.wait_time = flash_duration
	t.one_shot = true
	add_child(t)
	t.start()
	t.timeout.connect(func():
		animated_sprite.modulate = original
		flashing = false
		t.queue_free()
	)

func die() -> void:
	is_dead = true
	$CollisionShape2D.disabled = true
	animated_sprite.play("death")
	velocity = Vector2.ZERO
	animated_sprite.position.y += 6

	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")

func camera_shake(duration: float, amount: float) -> void:
	if $Camera2D != null:
		$Camera2D.start_shake(duration, amount)

func _drop_coin(hit_from_right: bool):
	if Global.coins <= 0:
		return

	Global.remove_coins(1)
	var coin = coin_scene.instantiate()
	get_tree().current_scene.add_child(coin)
	coin.global_position = global_position + Vector2(0, -10)

	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() == 0:
		return

	var enemy_node = enemies[randi() % enemies.size()]
	# Lanzar la moneda hacia atrás y luego hacia el enemigo
	coin.launch(hit_from_right, enemy_node)
