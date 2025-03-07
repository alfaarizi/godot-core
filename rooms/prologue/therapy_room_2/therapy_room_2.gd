extends Room

@onready var cutscene_player: CutscenePlayer = %CutscenePlayer
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera

#func cutscene_01():
	#
	#await play("RESET")
	#await delay(1.5)
	#await do(start_dialogue, ["Entering the Therapist room the sequel 1"])
	#await delay(1.5)
	#await do(start_dialogue, ["Entering the Therapist room the sequel 2"])
	#await delay(0.5)
	#
## After interacting with the machine cutscene:
#func cutscene_02():
	#
	#await do(start_dialogue, ["Entering the Therapist room the sequel's sequel 1"])
	#await delay(1.5)
	#await do(start_dialogue, ["Entering the Therapist room the sequel's sequel 2"])
	#

func debug_scene() -> void:
	GameState.change_state(GameState.State.CUTSCENE)

	CameraTransition.switch_camera(player.dynamic_bounds_camera, dynamic_bounds_camera)
	
	#await cutscene_01()
	#await cutscene_02()
	#await cutscene_03()

	#CameraTransition.transition_camera(dynamic_bounds_camera, player.dynamic_bounds_camera)
	
	print("player can move")
	
	GameState.change_state(GameState.State.EXPLORING)

func start_dialogue(dialogue_id: String) -> Signal:
	Global.dialogue.start_dialogue(dialogue_id)
	return Global.dialogue.next_dialogue
