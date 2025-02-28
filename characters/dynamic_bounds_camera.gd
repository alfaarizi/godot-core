@tool
class_name DynamicBoundsCamera extends Camera2D

@export var is_centered: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SceneManager.tilemap_bounds_changed.connect(_update_limits)
	_update_limits(SceneManager.current_tilemap_bounds)

func _update_limits(bounds: Array[Vector2]) -> void:
	if bounds == []:
		return
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)

	if is_centered:
		var center_x = (limit_left + limit_right) / 2.0
		var center_y = (limit_top + limit_bottom) / 2.0
		position = Vector2(center_x, center_y)
	
