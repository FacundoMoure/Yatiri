extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var tilemap: TileMapLayer = $TileMap 

var segment_width: int
var tiles: Array = []

func _ready() -> void:
	# Medir ancho del tilemap
	var rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	segment_width = rect.size.x * tile_size.x

	# Lista de tilemaps que se están usando
	tiles.append(tilemap)

func _process(delta: float) -> void:
	var player_x = player.global_position.x

	# Chequear si hay que duplicar a la derecha
	var max_x = tiles[tiles.size()-1].position.x
	if player_x > max_x:
		var new_tile = tilemap.duplicate()  # duplicamos el tilemap base
		add_child(new_tile)
		new_tile.position.x = max_x + segment_width
		tiles.append(new_tile)

	# Chequear si hay que duplicar a la izquierda
	var min_x = tiles[0].position.x
	if player_x < min_x:
		var new_tile = tilemap.duplicate()
		add_child(new_tile)
		new_tile.position.x = min_x - segment_width
		tiles.insert(0, new_tile)
