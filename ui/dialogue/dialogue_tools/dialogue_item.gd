@tool
class_name DialogueItem extends DialogueResource

@export var name := ""
@export_multiline var text := ""
@export var next_line_idx: int = false
@export var is_player: bool = true

var _has_choices: bool = false
var choices: Array[DialogueChoice] = []: set = set_choices

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "Enable Choices",
		"type": TYPE_BOOL,
	})
	
	if _has_choices:
		properties.append({
			"name": "Choices/Choices",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_ARRAY_TYPE,
			"hint_string": "DialogueChoice"
		})
	return properties
	
func _set(property: StringName, value: Variant) -> bool:
	var retval: bool = true
	match property:
		"Enable Choices":
			_has_choices = value
			notify_property_list_changed()
		"Choices/Choices":
			choices = value
		_:
			retval = false
	return retval
	
func	 _get(property: StringName) -> Variant:
	match property:
		"Enable Choices":
			return _has_choices
		"Choices/Choices":
			return choices
	return null


func set_choices(choices_new: Array[DialogueChoice]) -> void:
	for idx in choices_new.size():
		if choices_new[idx] == null:
			choices_new[idx] = DialogueChoice.new()
	choices = choices_new
	if choices.size() == 0:
		push_warning("There are no items in the dialogue choice array")
	
