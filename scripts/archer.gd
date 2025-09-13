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


func do_attack():
	if not attack_cooldown:
		attack_cooldown = true
		animated_sprite.play("attack")
		await get_tree().create_timer(0.5).timeout
		var arrow = preloadArrow.instantiate()
		arrow.set_position($ArrowPosition.global_position)
		get_parent().add_child(arrow)
		$Arrow.pitch_scale = randf_range(0.8, 1.0)
		$Arrow.play()
