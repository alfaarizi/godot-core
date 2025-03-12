extends Node


signal tilemap_bounds_changed(bounds: Array[Vector2])
signal player_position_changed(position: Vector2)
signal entry_door_changed(entry_door: Door)

var trigger_registry: Dictionary = {}
var door_registry: Dictionary = {}
var current_tilemap_bounds: Array[Vector2]
var current_player_position: Vector2
var current_entry_door: Door

func register_trigger(triggerable: Triggerable):
	if not trigger_registry.has(triggerable.trigger_key):
		trigger_registry[triggerable.trigger_key] = triggerable

func register_door(door: Door):
	if not door_registry.has(door.door_key):
		door_registry[door.door_key] = door

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit(bounds)

func change_player_position(position: Vector2) -> void:
	current_player_position = position
	player_position_changed.emit(position)

func change_entry_door(entry_door: Door) -> void:
	current_entry_door = entry_door
	entry_door_changed.emit(entry_door)
