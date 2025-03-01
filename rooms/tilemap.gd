@tool
extends Node2D
class_name TileMapScene

@export var tile_map_rect: TileMapLayer: set = set_tile_map_rect
@export var interactable_layers: Array[TileMapLayer] = []: set = set_interactable_layers

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SceneManager.change_tilemap_bounds(get_tilemap_bounds())
	if not interactable_layers.is_empty():
		for layer in interactable_layers: setup_interaction_areas(layer) 
	else:
		for layer in find_children("*", "TileMapLayer", true, true): setup_interaction_areas(layer) 
	
func setup_interaction_areas(layer: TileMapLayer):
	if not (layer and layer.tile_set):
		return

	var tile_set = layer.tile_set
	
	for cell in layer.get_used_cells():
		var tile_data = layer.get_cell_tile_data(cell)
		if not (tile_data and tile_data.material):
			continue
		
		var tile_id = layer.get_cell_source_id(cell)
		if tile_id == -1:
			continue

		var atlas_coords = layer.get_cell_atlas_coords(cell)
		if atlas_coords == Vector2i(-1, -1):
			continue
		
		var atlas_source = tile_set.get_source(tile_id) as TileSetAtlasSource
		if not atlas_source:
			continue
			
		var cell_pos = layer.map_to_local(cell)  # Convert map coordinates to local coordinates
		var text_region_size = atlas_source.texture_region_size
		var size_in_atlas = atlas_source.get_tile_size_in_atlas(atlas_coords)
		var texture_origin = tile_data.texture_origin
		
		## Create the Area2D for interaction
		var area = Area2D.new()
		area.name = "InteractionArea"
		area.position = cell_pos - 1 * Vector2(texture_origin)
		area.monitoring = true

		## Create and set the RectangleShape2D with the final size
		var collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = (text_region_size * size_in_atlas) + Vector2i(8, 8)
		collision_shape.shape = shape
		area.add_child(collision_shape)
		
		## Connect signals for player entering or exiting the interaction area
		var shader_material = tile_data.material
		shader_material.set_shader_parameter("width", 0.0)
		area.connect("body_entered", Callable(self, "_on_interaction_area_entered").bind(shader_material))
		area.connect("body_exited", Callable(self, "_on_interaction_area_exited").bind(shader_material))
		layer.add_child(area)

func _on_interaction_area_entered(body, _material):
	if body is Player:	
		var tween := create_tween()
		tween.tween_method(func(value): _material.set_shader_parameter("width", value), 
		0.0, 1.3, 0.08
		)
	
func _on_interaction_area_exited(body, _material):
	if body is Player:
		var tween := create_tween()
		tween.tween_method(func(value): _material.set_shader_parameter("width", value), 
		1.3, 0.0, 0.08
		)

func set_tile_map_rect(_tile_map_rect: TileMapLayer):
	tile_map_rect = _tile_map_rect
	update_configuration_warnings() 

func set_interactable_layers(_interactable_layers: Array[TileMapLayer]) -> void:
	interactable_layers = []
	for layer in _interactable_layers:
		interactable_layers.append(layer)
	
func _get_configuration_warnings() -> PackedStringArray:
	if not tile_map_rect:
		return ["a tile map layer must be given to calculate camera bounding rectangle"]
	return []

func get_tilemap_bounds() -> Array[Vector2]:
	if not tile_map_rect:
		return []
	return [
		tile_map_rect.to_global(Vector2(tile_map_rect.get_used_rect().position * tile_map_rect.rendering_quadrant_size)),
		tile_map_rect.to_global(Vector2(tile_map_rect.get_used_rect().end * tile_map_rect.rendering_quadrant_size))
	]
