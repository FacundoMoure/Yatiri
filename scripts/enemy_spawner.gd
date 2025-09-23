extends Node2D

# -------------------- EXPORTS --------------------
@export var enemy_hut: NodePath                # referencia al nodo hut
@export var spawn_y: float = 333.0             # posición base Y
@export var spawn_y_range: float = 5.0         # variación en Y
@export var initial_delay: float = 15.0        # tiempo antes del primer spawn

@export var max_enemies_per_wave: int = 5      # cantidad máxima de enemigos por oleada
@export var spawn_interval: float = 3.0        # tiempo entre cada spawn de la misma oleada
@export var wave_interval: float = 10.0        # tiempo entre oleadas

@export var enemy_scenes: Array = [            # lista de enemigos posibles
	preload("res://scenes/enemy_1.tscn"),
	preload("res://scenes/enemy_2.tscn")
]

# -------------------- VARIABLES INTERNAS --------------------
var _hut_ref: Node2D
var _current_wave_enemies: int = 0
var _spawn_timer: Timer
var _is_wave_active: bool = false

func _ready() -> void:
	# Obtener referencia a la hut
	if enemy_hut != NodePath(""):
		_hut_ref = get_node(enemy_hut) as Node2D

	# Crear Timer
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Iniciar con delay inicial
	_spawn_timer.start(initial_delay)

# -------------------- SPAWNEO --------------------
func _on_spawn_timer_timeout() -> void:
	if _hut_ref == null or enemy_scenes.is_empty():
		push_warning("No hay referencia a enemy_hut o no hay enemigos cargados.")
		return

	if not _is_wave_active:
		# Inicia nueva oleada
		_current_wave_enemies = randi() % max_enemies_per_wave + 1  # random entre 1 y max
		_is_wave_active = true

	if _current_wave_enemies > 0:
		# Elegir enemigo random
		var scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]
		var enemy = scene.instantiate()
		add_child(enemy)

		# Posición spawn (X fijo, Y random)
		var spawn_x: float = _hut_ref.global_position.x
		var spawn_y_random: float = spawn_y + randf_range(-spawn_y_range, spawn_y_range)
		enemy.global_position = Vector2(spawn_x, spawn_y_random)

		_current_wave_enemies -= 1

		if _current_wave_enemies > 0:
			# spawn siguiente enemigo de la misma oleada
			_spawn_timer.start(spawn_interval)
		else:
			# oleada terminada, esperar para próxima
			_is_wave_active = false
			_spawn_timer.start(wave_interval)
