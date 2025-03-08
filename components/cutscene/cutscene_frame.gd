@tool
class_name CutsceneFrame extends Resource

@export var action_type: CutsceneAction.Type: set = _set_action_type
@export var action: CutsceneAction: set = _set_action

func _set_action(_action: CutsceneAction):
	if not _action: return
	action = _action
	
func _set_action_type(value: CutsceneAction.Type) -> void:
	if action_type == value: return
	action_type = value
	match action_type:
		CutsceneAction.Type.DELAY:
			action = DelayAction.new()
		CutsceneAction.Type.PLAY:
			action = PlayAction.new()
		CutsceneAction.Type.DIALOGUE:
			action = DialogueAction.new()
		CutsceneAction.Type.CAMERA:
			action = CameraAction.new()	
		CutsceneAction.Type.EVENT:
			action = EventAction.new()
		CutsceneAction.Type.Nil:
			action = CutsceneAction.new()
