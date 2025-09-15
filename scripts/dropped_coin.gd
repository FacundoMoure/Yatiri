extends Area2D

# --------------------
# CONFIGURACIÓN
# --------------------
@export var fall_gravity: float = 500        # gravedad al caer
@export var floor_offset: float = 5.0       # altura sobre el piso
@export var homing_delay: float = 1.5     # tiempo antes de ir al enemigo
@export var homing_speed: float = 500.0     # velocidad de homing
@export var knockback_force: float = 100.0  # fuerza del knockback al enemigo

var start_delay = 0.05
var timer: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var target_enemy: Node2D
var homing_active: bool = false
var impacted: bool = false   # flag para que el sonido y destrucción ocurran UNA sola vez

# --------------------
# REFERENCIAS
# --------------------
@onready var floor_ray: RayCast2D = $FloorRay
@onready var coin_hit_sound: AudioStreamPlayer2D = $CoinDrop  # AudioStreamPlayer2D hijo de la moneda

# --------------------
# PROCESO FÍSICO
# --------------------
func _physics_process(delta):
	timer += delta

	if not homing_active:
		# caída normal con gravedad
		velocity.y += fall_gravity * delta
		position += velocity * delta

		if timer > start_delay and floor_ray.is_colliding():
			velocity.y = 0
			var floor_y = floor_ray.get_collision_point().y
			global_position.y = floor_y - floor_offset
			velocity.x *= 0.9
	else:
		# homing hacia el enemigo
		if target_enemy:
			var direction = (target_enemy.global_position - global_position).normalized()
			velocity = direction * homing_speed
			position += velocity * delta

			# detectar si llegó al enemigo y no se había impactado antes
			if global_position.distance_to(target_enemy.global_position) < 10 and not impacted:
				impacted = true             # marcar que ya impactó
				coin_hit_sound.play()       # reproducir sonido
				await get_tree().create_timer(0.1).timeout  # pequeño delay para que suene
				queue_free()                # destruir la moneda

	# activar homing después de homing_delay
	if timer >= homing_delay and target_enemy and not homing_active:
		homing_active = true

# --------------------
# LANZAR LA MONEDA
# --------------------
func launch(hit_from_right: bool, enemy: Node2D):
	var dir_x = -1 if hit_from_right else 1
	velocity = Vector2(randf_range(150, 250) * dir_x, -300)
	target_enemy = enemy
	homing_active = false
	timer = 0.0
	impacted = false  # resetear flag en cada lanzamiento
