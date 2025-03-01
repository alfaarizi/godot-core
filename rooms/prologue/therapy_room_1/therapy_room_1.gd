extends Room

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera

func cutscene_01():
	await delay(1.0)
	await play("01_therapist_turning")
	await delay(1.0)
	await do(start_dialogue, ["Entering the Therapist room 1"])
	await play("02_therapist_to_sofa")
	await delay(1.0)
	
func cutscene_02():
	await play("03_after_sesh")
	await delay(1.0)
	await do(start_dialogue, ["Entering the Therapist room 2"]) 
	await delay(2.0)
	await do(start_dialogue, ["Entering the Therapist room 3"])
	await delay(2.0)
	await do(start_dialogue, ["Entering the Therapist room 4"])
	
func cutscene_03():	
	await play("03_after_sesh")
	await delay(1.0)
	await do(start_dialogue, ["Entering the Therapist room 5"])
	await play("04_therapist_exiting")
	await delay(1.0)

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
