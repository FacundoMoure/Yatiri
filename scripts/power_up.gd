extends Area2D

@export var value: int = 1 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Global.add_potions(value)
		$PowerUp.play()
		$Sprite2D.visible = false
		$CollisionShape2D.queue_free() 
		await get_tree().create_timer(2.5).timeout
		queue_free()
		
