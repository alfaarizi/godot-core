@tool
class_name Dialogue extends Node

@export var dialogue_id: String = "entering_therapist_room"
@export var dialogue_items: Array[DialogueItem] = []: set = set_dialogue_items

func _ready() -> void:
	if Engine.is_editor_hint():
		return

func set_dialogue_items(_dialogue_items: Array[DialogueItem]) -> void:
	for idx in _dialogue_items.size():
		if _dialogue_items[idx] == null:
			_dialogue_items[idx] = DialogueItem.new()
	dialogue_items = _dialogue_items
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if dialogue_items.is_empty():
		return ["at least one dialogue item is required"]
	return []
