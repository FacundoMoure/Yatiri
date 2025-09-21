extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3           
@export var spawn_interval: float = 10.0   
@export var spawn_y: float = 333.0         
@export var spawn_y_range: float = 5.0     
@export var enemy_hut: NodePath          

var _spawn_timer: Timer
var _hut_ref: Node2D

func _ready() -> void:
	if enemy_hut != NodePath(""):
		_hut_ref = get_node(enemy_hut) as Node2D

	# Timer
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.one_shot = false
	_spawn_timer.autostart = true
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if _hut_ref == null:
		push_warning("No hay referencia a enemy_hut, no se pueden spawnear enemigos.")
		return

	for i in range(spawn_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)

		var spawn_x: float = _hut_ref.global_position.x
		var spawn_y_random = spawn_y + randf_range(-spawn_y_range, spawn_y_range)

		enemy.global_position = Vector2(spawn_x, spawn_y_random)
