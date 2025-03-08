extends Room
@onready var cutscene_player: CutscenePlayer = %CutscenePlayer
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera

func debug_scene() -> void:
	#CameraTransition.transition_camera(player.dynamic_bounds_camera, dynamic_bounds_camera)
	await cutscene_player.play_cutscene("cutscene_01")
	await cutscene_player.play_cutscene("cutscene_02")
	await cutscene_player.play_cutscene("cutscene_03")
