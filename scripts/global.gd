extends Node

var coins: int = 5
var potions: int = 5
var tribe_count: int = 0   # 👈 miembros de la tribu actuales

signal coins_changed(new_value)
signal potions_changed(new_value)
signal tribe_changed(new_value)   # 👈 señal nueva

# --- MONEDAS ---
func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)
	emit_signal("coins_changed", coins)

func set_coins(value: int) -> void:
	coins = max(0, value)
	emit_signal("coins_changed", coins)

# --- POCIONES ---
func add_potions(amount: int) -> void:
	potions += amount
	emit_signal("potions_changed", potions)

func remove_potions(amount: int) -> void:
	potions = max(0, potions - amount)
	emit_signal("potions_changed", potions)

func set_potions(value: int) -> void:
	potions = max(0, value)
	emit_signal("potions_changed", potions)

# --- TRIBU ---
func add_tribe_member() -> void:
	tribe_count += 1
	emit_signal("tribe_changed", tribe_count)

func remove_tribe_member() -> void:
	tribe_count = max(0, tribe_count - 1)
	emit_signal("tribe_changed", tribe_count)

func set_tribe_count(value: int) -> void:
	tribe_count = max(0, value)
	emit_signal("tribe_changed", tribe_count)
