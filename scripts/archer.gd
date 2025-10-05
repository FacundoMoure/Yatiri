extends Player
class_name Archer

var attack_cooldown := false
var preloadArrow = preload("res://scenes/arrow.tscn")

func _ready() -> void:
	remove_from_group("Player")
	# Idle inicial con frame aleatorio
	animated_sprite.play("idle")
	animated_sprite.frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")

func _physics_process(delta: float) -> void:
	# -------------------- MIRAR AL ENEMIGO --------------------
	var enemies = get_tree().get_nodes_in_group("Enemy")
	enemies = enemies.filter(func(e): return e and e.is_inside_tree())

	if enemies.size() > 0:
		# elegimos el más cercano
		var closest_enemy = enemies[0]
		var min_dist = global_position.distance_to(closest_enemy.global_position)
		for e in enemies:
			var d = global_position.distance_to(e.global_position)
			if d < min_dist:
				min_dist = d
				closest_enemy = e

		# girar sprite hacia el enemigo
		if closest_enemy.global_position.x < global_position.x:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

	# -------------------- IDLE / ANIMACIÓN --------------------
	if attack_cooldown:
		if not animated_sprite.is_playing():
			attack_cooldown = false
			animated_sprite.play("idle")
			animated_sprite.frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

# -------------------- ATAQUE --------------------
func do_attack() -> void:
	# Si ya estamos en cooldown o el nodo no está en escena, salimos
	if attack_cooldown or not is_inside_tree():
		return

	# Buscar enemigos vivos en la escena
	var enemies = get_tree().get_nodes_in_group("Enemy")
	enemies = enemies.filter(func(e): return e and e.is_inside_tree())

	# Si no hay enemigos, no atacamos y reiniciamos cooldown por si acaso
	if enemies.size() == 0:
		attack_cooldown = false
		return

	# Activamos cooldown
	attack_cooldown = true

	# Reproducimos animación de ataque
	if is_inside_tree():
		animated_sprite.play("attack")

	# Esperamos un poco para sincronizar con la animación
	await get_tree().create_timer(0.5).timeout

	# Refiltramos enemigos por si alguno murió mientras esperábamos
	enemies = get_tree().get_nodes_in_group("Enemy")
	enemies = enemies.filter(func(e): return e and e.is_inside_tree())
	if enemies.size() == 0:
		attack_cooldown = false
		return

	# Elegimos el enemigo más cercano (puede cambiar a random si querés)
	var closest_enemy = enemies[0]
	var min_dist = global_position.distance_to(closest_enemy.global_position)
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			closest_enemy = e

	# Girar sprite hacia el enemigo antes de disparar
	if closest_enemy.global_position.x < global_position.x:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	# Instanciamos la flecha
	if not is_inside_tree():
		attack_cooldown = false
		return

	var arrow = preloadArrow.instantiate()
	arrow.global_position = $ArrowPosition.global_position
	get_parent().add_child(arrow)

	# Lanzamos flecha hacia el enemigo
	if closest_enemy and closest_enemy.is_inside_tree():
		arrow.launch_towards_enemy(closest_enemy)

	# Sonido de ataque con pitch aleatorio
	if $Attack and is_inside_tree():
		$Attack.pitch_scale = randf_range(0.8, 1.0)
		$Attack.play()

	# Esperamos cooldown antes de poder atacar de nuevo
	await get_tree().create_timer(10.0).timeout

	# Reiniciamos cooldown
	attack_cooldown = false
