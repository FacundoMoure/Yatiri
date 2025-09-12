extends Node2D

@onready var button: Button = $CanvasLayer/Button



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
