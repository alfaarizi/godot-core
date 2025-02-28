class_name DialogueHud extends CanvasLayer

signal next_dialogue

const file_path: String = "res://story/prologue_cutscenes.json"
@onready var _dialogue_manager: DialogueManager = %DialogueManager

func _ready() -> void:	
	DialogueLoader.load_dialogue(file_path)
	_dialogue_manager.dialogue_completed.connect(_on_dialogue_completed)

func start_dialogue(dialogue_id: String) -> void:
	if GameState.current_state not in [GameState.State.EXPLORING, GameState.State.CUTSCENE]:
		return
	match GameState.current_state:
		GameState.State.EXPLORING:
			GameState.change_state(GameState.State.INTERACTING)	
	_dialogue_manager.start_dialogue(DialogueLoader.retrieve_dialogue_by_id(dialogue_id))

func _on_dialogue_completed() -> void:
	next_dialogue.emit()
	match GameState.current_state:
		GameState.State.INTERACTING:
			GameState.change_state(GameState.State.EXPLORING)	
