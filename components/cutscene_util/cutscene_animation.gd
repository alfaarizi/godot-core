@tool
class_name CutsceneAnimation extends Resource

@export var cutscene_name: String = ""
@export var actions: Array[CutsceneAction] = []: set = set_actions

func _ready() -> void:
	if Engine.is_editor_hint():
		return	

func set_actions(_actions: Array[CutsceneAction]) -> void:
	for idx in _actions.size():
		if _actions[idx] == null:
			_actions[idx] = CutsceneAction.new()
	actions = _actions
