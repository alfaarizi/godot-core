extends Room

@onready var cutscene_player: CutscenePlayer = %CutscenePlayer
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera
@onready var door: Door = %Door

func init_scene() -> void:
	CameraTransition.switch_camera(player.dynamic_bounds_camera, dynamic_bounds_camera)

func _on_triggerable_is_triggered() -> void:
	await cutscene_player.play_cutscene("cutscene_01")
	door.disable()

func _on_triggerable_2_is_triggered() -> void:
	await cutscene_player.play_cutscene("cutscene_02")
	door.enable()
