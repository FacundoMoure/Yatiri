extends Control

@onready var coins_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Coins
@onready var potions_label: Label = $MarginContainer/VBoxContainer/HBoxContainer3/Potions
@onready var tribe_label: Label = $MarginContainer/HBoxContainer2/TribuNumber

func _ready() -> void:
	# Conectar señales del Global
	Global.coins_changed.connect(_on_coins_changed)
	Global.potions_changed.connect(_on_potions_changed)
	Global.tribe_changed.connect(_on_tribe_changed)
	

	# Inicializar visuales
	_on_coins_changed(Global.coins)
	_on_potions_changed(Global.potions)
	_on_tribe_changed(Global.tribe_count)
	
func _on_coins_changed(new_value: int) -> void:
	coins_label.text = str(new_value).pad_zeros(2)

func _on_potions_changed(new_value: int) -> void:
	potions_label.text = str(new_value).pad_zeros(2)

func _on_tribe_changed(new_value: int) -> void:
	tribe_label.text = str(new_value).pad_zeros(2)
