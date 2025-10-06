extends Control

func _ready():
	$MarginContainer/Label.text = Global.game_result_text

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()
