extends Room

#@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera


#func debug_scene() -> void:
	#GameState.change_state(GameState.State.CUTSCENE)
#
	#CameraTransition.switch_camera(player.dynamic_bounds_camera, dynamic_bounds_camera)
	#
	#print("player cannot move")
	#
	#GameState.change_state(GameState.State.EXPLORING)
#
#func start_dialogue(dialogue_id: String) -> Signal:
	#Global.dialogue.start_dialogue(dialogue_id)
	#return Global.dialogue.next_dialogue
