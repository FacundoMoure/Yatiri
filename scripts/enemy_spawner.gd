extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3             # cantidad de enemigos por spawn
@export var spawn_interval: float = 10.0    # segundos entre cada spawn
@export var spawn_y: float = 333.0          # altura base
@export var spawn_y_range: float = 5.0      # +/- para randomizar Y entre 330-335
@export var spawn_from_left: bool = true
@export var spawn_from_right: bool = true
@export var left_x: float = -50.0
@export var right_x: float = 1250.0         # ajustar según tamaño del nivel

var _spawn_timer: Timer

func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.one_shot = false
	_spawn_timer.autostart = true
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if not spawn_from_left and not spawn_from_right:
		return

	for i in range(spawn_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)

		# Elegir lado al azar
		var spawn_x: float
		var looking_right: bool
		if spawn_from_left and spawn_from_right:
			if randf() < 0.5:
				spawn_x = left_x
				looking_right = true
			else:
				spawn_x = right_x
				looking_right = false
		elif spawn_from_left:
			spawn_x = left_x
			looking_right = true
		else:
			spawn_x = right_x
			looking_right = false

		# Posición aleatoria en Y
		var spawn_y_random = spawn_y + randf_range(-spawn_y_range, spawn_y_range)

		enemy.position = Vector2(spawn_x, spawn_y_random)

		# Hacer que mire hacia el jugador desde el spawn
		if enemy.has_method("face_direction"):
			enemy.face_direction(looking_right)
