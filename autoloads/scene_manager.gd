extends Node

signal tilemap_bounds_changed(bounds: Array[Vector2])
signal player_position_changed(position: Vector2)
signal entry_door_changed(entry_door: Door)

var current_tilemap_bounds: Array[Vector2]
var current_player_position: Vector2
var current_entry_door: Door

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit(bounds)

func change_player_position(position: Vector2) -> void:
	current_player_position = position
	player_position_changed.emit(position)

func change_entry_door(entry_door: Door) -> void:
	current_entry_door = entry_door
	entry_door_changed.emit(entry_door)
