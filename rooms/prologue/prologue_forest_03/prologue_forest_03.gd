extends Room
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera
@onready var door: Door = %Door

func init_scene() -> void:
	CameraTransition.switch_camera(player.dynamic_bounds_camera, dynamic_bounds_camera)
