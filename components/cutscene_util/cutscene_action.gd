@tool
class_name CutsceneAction extends Resource

enum ActionType { Nil, DELAY, PLAY, DIALOGUE, EVENT }
var action_type: ActionType: set = set_action_type
var action: CutsceneResource: set = set_action

func set_action(_action: CutsceneResource):
	if not _action:
		return
	action = _action
	
func set_action_type(value: ActionType) -> void:
	if action_type == value:
		return
	action_type = value
	match action_type:
		ActionType.DELAY:
			action = DelayAction.new()
		ActionType.PLAY:
			action = PlayAction.new()
		ActionType.DIALOGUE:
			action = DialogueAction.new()
		ActionType.EVENT:
			action = EventAction.new()
		ActionType.Nil:
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

	match action_type:
		ActionType.DELAY:
			properties.append({
				"name": "Action",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "DelayAction"
			})
		ActionType.PLAY:
			properties.append({
				"name": "Action",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "PlayAction"
			})
		ActionType.DIALOGUE:
			properties.append({
				"name": "Action",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "DialogueAction"
			})
		ActionType.EVENT:
			properties.append({
				"name": "Action",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "EventAction"
			})
	return properties


func _set(property: StringName, value: Variant) -> bool:
	var retval: bool = true
	match property:
		"Action Type":
			action_type = value
		"Action":
			action = value
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
