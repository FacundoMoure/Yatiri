extends Player
class_name Archer

var attack_cooldown := false
var preloadArrow = preload("res://scenes/arrow.tscn")

func _ready() -> void:
	# Idle inicial con frame aleatorio
	animated_sprite.play("idle")
	animated_sprite.frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")


func _physics_process(delta: float) -> void:
	if attack_cooldown:
		# Si ya no se está reproduciendo el ataque → volver a idle (desincronizado)
		if not animated_sprite.is_playing():
			attack_cooldown = false
			animated_sprite.play("idle")
			animated_sprite.frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")


func do_attack() -> void:
	if attack_cooldown:
		return

	attack_cooldown = true
	animated_sprite.play("attack")

	# Esperamos un poco antes de lanzar la flecha para que coincida con la animación
	await get_tree().create_timer(0.5).timeout

	# Instanciamos la flecha
	var arrow = preloadArrow.instantiate()
	arrow.global_position = $ArrowPosition.global_position
	get_parent().add_child(arrow)

	# Elegimos el enemigo más cercano
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() > 0:
		var closest_enemy = enemies[0]
		var min_dist = global_position.distance_to(closest_enemy.global_position)
		for e in enemies:
			var d = global_position.distance_to(e.global_position)
			if d < min_dist:
				min_dist = d
				closest_enemy = e
		# Lanzamos flecha hacia la posición global actual del enemigo
		arrow.launch_towards_enemy(closest_enemy)

	# Sonido de ataque con pitch aleatorio
	$Attack.pitch_scale = randf_range(0.8, 1.0)
	$Attack.play()

	# Reiniciamos cooldown de ataque
	await get_tree().create_timer(3.0).timeout
	attack_cooldown = false
