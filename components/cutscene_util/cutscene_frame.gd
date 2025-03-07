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
			action = CutsceneAction.DelayAction.new()
			action.resource_name = "DelayAction"
		CutsceneAction.Type.PLAY:
			action = CutsceneAction.PlayAction.new()
			action.resource_name = "PlayAction"
		CutsceneAction.Type.DIALOGUE:
			action = CutsceneAction.DialogueAction.new()
			action.resource_name = "DialogueAction"
		CutsceneAction.Type.EVENT:
			action = CutsceneAction.EventAction.new()
			action.resource_name = "EventAction"
		CutsceneAction.Type.Nil:
			action = null
	notify_property_list_changed()

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "Action Type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",DELAY,PLAY,DIALOGUE,EVENT"
	})
	if action_type:
		properties.append({
			"name": "Action",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "CutsceneAction"
		})
	return properties


func _set(property: StringName, value: Variant) -> bool:
	var retval: bool = true
	match property:
		"Action Type":
			action_type = value
		"Action":
			action = value as CutsceneAction
		_:
			retval = false
	return retval

func _get(property: StringName) -> Variant:
	match property:
		"Action Type":
			return action_type
		"Action":
			return action
	return null
