extends Control

@onready var coins_label: Label = $MarginContainer/HBoxContainer/Coins

func _ready():
	# Conectar señal del Global
	Global.coins_changed.connect(_on_coins_changed)
	# Inicializar visualmente
	_on_coins_changed(Global.coins)

func _on_coins_changed(new_value: int) -> void:
	coins_label.text = str(new_value)
