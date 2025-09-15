extends Node

var coins: int = 5 # vida inicial del jugador

signal coins_changed(new_value)

func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)
	emit_signal("coins_changed", coins)

func set_coins(value: int) -> void:
	coins = max(0, value)
	emit_signal("coins_changed", coins)
