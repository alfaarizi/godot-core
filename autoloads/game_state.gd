extends Node

enum State { EXPLORING, UI_NAVIGATION, INTERACTING, CUTSCENE }

signal state_changed(new_state: State)
var current_state: State = State.EXPLORING

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	print(State.keys()[current_state])
	state_changed.emit(new_state)

func _unhandled_input(event: InputEvent) -> void:	
	if event.is_action_pressed("player_selection"):
		match current_state:
			GameState.State.UI_NAVIGATION:
				change_state(GameState.State.EXPLORING)
			GameState.State.EXPLORING:
				change_state(GameState.State.UI_NAVIGATION)
	#DEBUGGING PURPOSES
	#elif event.is_action_pressed("skip_dialogue"):
		#Global.dialogue.start_dialogue("Small_cutscene_after_entering_lobby")
		#match current_state:
			#GameState.State.EXPLORING:
				#change_state(GameState.State.INTERACTING)
