@tool
extends Node2D
class_name TileMapScene

@export var tile_map_rect: TileMapLayer: set = set_tile_map_rect

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SceneManager.change_tilemap_bounds(get_tilemap_bounds())

func set_tile_map_rect(_tile_map_rect: TileMapLayer):
	tile_map_rect = _tile_map_rect

func get_tilemap_bounds() -> Array[Vector2]:
	if not tile_map_rect:
		return []
	return [
		tile_map_rect.to_global(Vector2(tile_map_rect.get_used_rect().position * tile_map_rect.rendering_quadrant_size)),
		tile_map_rect.to_global(Vector2(tile_map_rect.get_used_rect().end * tile_map_rect.rendering_quadrant_size))
	]
