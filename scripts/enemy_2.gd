extends CharacterBody2D
class_name Enemy2

enum State { WALK_FORWARD, ATTACK, WALK_BACK, IDLE, HURT, DEAD }

@export var health: int = 100
@export var walk_speed: float = 170.0
@export var walk_duration: float = 1.6
@export var attack_knockback: float = 400.0
@export var steps_volume_db: float = -23.0
@export var attack_range: float = 200.0   # distancia hasta muralla
@export var idle_duration: float = 5.0

@onready var animated_sprite: AnimatedSprite2D = $Enemy2
@onready var attack_area: Area2D = $AttackArea
@onready var spear_position: Node2D = $SpearPosition

var base_attack_area_position: Vector2
var state: State = State.WALK_FORWARD
var walk_direction: int = 1
var can_attack_sound := true
var is_dead := false
var flashing := false
var hurt_cooldown := false
var idle_timer_active := false
var walk_back_variation: float

var preloadSpear = preload("res://scenes/spear.tscn")

func _ready() -> void:
	base_attack_area_position = attack_area.position
	attack_area.monitoring = false
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	walk_back_variation = randf_range(0.5, 5.0)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		

	var walls = get_tree().get_nodes_in_group("Muralla")

	# Si NO hay murallas, queda en idle siempre
	if walls.is_empty():
		if state != State.IDLE:
			set_state(State.IDLE)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if state == State.WALK_FORWARD:
		if not walls.is_empty():
			var wall = walls.front()
			var new_direction = sign(wall.global_position.x - global_position.x)
			if new_direction == 0:
				new_direction = 1
			walk_direction = new_direction
			_update_sprite_flip()
			_update_attack_area_direction()

			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
			# 🔊 Arranca pasos bajito
				$Steps.volume_db = -30.0  
				if not $Steps.playing:
					$Steps.play()

			if global_position.distance_to(wall.global_position) <= attack_range:
				set_state(State.ATTACK)

	# Movimiento
	if state == State.WALK_FORWARD:
		velocity.x = walk_speed * walk_direction
	elif state == State.WALK_BACK:
		velocity.x = -walk_speed * walk_direction
	else:
		velocity.x = 0

	move_and_slide()

# -------------------- ESTADOS --------------------
func set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state

	match state:
		State.WALK_FORWARD:
			var walls = get_tree().get_nodes_in_group("Muralla")
			if not walls.is_empty():
				var wall = walls.front()
				var new_direction = sign(wall.global_position.x - global_position.x)
				if new_direction == 0:
					new_direction = 1
				walk_direction = new_direction
				_update_sprite_flip()
				_update_attack_area_direction()
				animated_sprite.play("walk")
				$Steps.volume_db = steps_volume_db
				$Steps.play()

		State.ATTACK:
			velocity = Vector2.ZERO
			$Steps.stop()
			animated_sprite.play("attack")
			if can_attack_sound:
				await get_tree().create_timer(0.3).timeout
				$Attack.play()
				can_attack_sound = false
				_reset_attack_sound_cooldown()

		State.WALK_BACK:
			velocity.x = -walk_speed * walk_direction
			_update_sprite_flip()
			_update_attack_area_direction()
			animated_sprite.play("walk")
			$Steps.volume_db = steps_volume_db
			$Steps.play()
			_start_walk_back_timer()

		State.IDLE:
			velocity = Vector2.ZERO
			$Steps.stop()
			animated_sprite.play("idle")
			var walls = get_tree().get_nodes_in_group("Muralla")
			if not walls.is_empty():
				var wall = walls.front()
				var dir = sign(wall.global_position.x - global_position.x)
				if dir != 0:
					walk_direction = dir
					_update_sprite_flip()
					_update_attack_area_direction()

		State.HURT:
			velocity = Vector2.ZERO
			animated_sprite.play("hurt")
			$Steps.stop()
			attack_area.monitoring = false

		State.DEAD:
			is_dead = true
			velocity = Vector2.ZERO
			animated_sprite.play("death")
			$CollisionShape2D.disabled = true
			$Steps.stop()
			attack_area.monitoring = false
			remove_from_group("Enemy")

# -------------------- ATAQUE --------------------
func _on_frame_changed() -> void:
	# Cuando la animación llegue al frame del disparo
	if state == State.ATTACK and animated_sprite.frame == 3:
		_throw_spear()

func _throw_spear() -> void:
	var walls = get_tree().get_nodes_in_group("Muralla")
	if walls.is_empty():
		return

	var wall = walls.front()

	var spear = preloadSpear.instantiate()
	spear.global_position = spear_position.global_position
	get_parent().add_child(spear)

	# Randomizamos altura al lanzar
	spear.launch_towards_wall(wall)

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack" and state == State.ATTACK:
		set_state(State.WALK_BACK)
	elif animated_sprite.animation == "hurt" and state == State.HURT:
		if health <= 0:
			set_state(State.DEAD)
		elif idle_timer_active:
			set_state(State.IDLE)
		else:
			set_state(State.WALK_FORWARD)

# -------------------- WALK BACK --------------------
func _start_walk_back_timer() -> void:
	await get_tree().create_timer(walk_duration + walk_back_variation).timeout
	if not is_dead:
		set_state(State.IDLE)
		
		# Esperar 2 segundos en idle y después caminar hacia adelante
		await get_tree().create_timer(2.0).timeout
		if not is_dead and state == State.IDLE:
			set_state(State.WALK_FORWARD)

# -------------------- IDLE --------------------
func _start_idle_timer() -> void:
	idle_timer_active = true
	await get_tree().create_timer(idle_duration).timeout
	idle_timer_active = false
	if not is_dead and state == State.IDLE:
		set_state(State.WALK_FORWARD)

# -------------------- DAMAGE --------------------
func take_damage(amount: int, knockback_dir: Vector2, is_arrow_attack: bool = false) -> void:
	if health <= 0 or is_dead or hurt_cooldown:
		return
	health -= amount
	hurt_cooldown = true
	set_state(State.HURT)
	velocity = knockback_dir
	if not is_arrow_attack:
		$AttackHit.play()
	flash_white()
	await get_tree().create_timer(0.3).timeout
	hurt_cooldown = false

func flash_white() -> void:
	if flashing:
		return
	flashing = true
	var original = animated_sprite.modulate
	animated_sprite.modulate = Color(2, 2, 2, 1)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = original
	flashing = false

func _reset_attack_sound_cooldown() -> void:
	await get_tree().create_timer(3.0).timeout
	can_attack_sound = true

# -------------------- SPRITE & ATTACK AREA --------------------
func _update_sprite_flip() -> void:
	match state:
		State.WALK_FORWARD, State.IDLE:
			animated_sprite.flip_h = walk_direction > 0
		State.WALK_BACK:
			animated_sprite.flip_h = walk_direction < 0

func _update_attack_area_direction() -> void:
	var offset = 50.0
	attack_area.position = base_attack_area_position + Vector2(offset * walk_direction, 0)
