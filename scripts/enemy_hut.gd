extends Area2D

func _ready() -> void:
	if has_node("MurallaTribu"):
		get_node("MurallaTribu").queue_free()
