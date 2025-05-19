extends Node

@export_file("*.json") var dialogue_file_path: String = "res://story/prologue_cutscenes.json"
@export var dialogues: Array[Dialogue] = []

#func _ready() -> void:
	#load_dialogue(dialogue_file_path)

func load_dialogue(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		print("File does not exist!")
		return

	var file_data := FileAccess.open(file_path, FileAccess.READ)
	var json_data = JSON.parse_string(file_data.get_as_text())

	if json_data == null or not (json_data is Dictionary):
		print("Error: Failed to parse JSON or incorrect format.")
		return

	for dialogue_dict in json_data["dialogues"]:
		var dialogue_obj := Dialogue.new()
		dialogue_obj.dialogue_id = dialogue_dict["dialogue_id"]

		var starting_indexes: Array[int] = _calculate_starting_indexes(dialogue_dict["dialogue"])

		for dialogue_item_idx in dialogue_dict["dialogue"].size():
			var dialogue_item_dict = dialogue_dict["dialogue"][dialogue_item_idx]

			var character_image_path = "res://assets/" + dialogue_item_dict["name"] + ".png"
			var character = load(character_image_path)
			var expression = load(character_image_path)
			var audio = load("res://assets/blah blah.ogg")

			for line_idx in dialogue_item_dict["line"].size():
				var line = dialogue_item_dict["line"][line_idx]

				# Assign choices only to the last dialogue item
				var dialogue_item_obj := DialogueItem.new()
				dialogue_item_obj.name = dialogue_item_dict["name"]
				dialogue_item_obj.text = line["text"]
				dialogue_item_obj.character = character
				dialogue_item_obj.expression = expression
				dialogue_item_obj.audio = audio
				dialogue_item_obj.is_player = dialogue_item_dict["is_player"]

				if line_idx < dialogue_item_dict["line"].size() - 1:
					dialogue_item_obj.next_line_idx = _sum(starting_indexes.slice(0, dialogue_item_idx)) + line_idx + 1
					dialogue_item_obj._has_choices = false
				else:
					var next_line_idx := _parse_next_line_index(dialogue_item_dict["next_line_index"])
					if 	next_line_idx >= 0:
						dialogue_item_obj.next_line_idx = _sum(starting_indexes.slice(0, next_line_idx))
					else:
						dialogue_item_obj.next_line_idx = next_line_idx
					dialogue_item_obj._has_choices = not dialogue_item_dict["choices"].is_empty()

				dialogue_obj.dialogue_items.append(dialogue_item_obj)
		dialogues.append(dialogue_obj)

func retrieve_dialogue_by_id(dialogue_id: String) -> Dialogue:
	if dialogues.is_empty():
		print("[Warning] No dialogues loaded! Cannot retrieve dialogue by ID.")
		return null
	var dialogue_idx := -1
	for idx in dialogues.size():
		if dialogues[idx].dialogue_id == dialogue_id:
			dialogue_idx = idx
			break
	if dialogue_idx == -1:
		print("[Warning] Dialogue with ID %s is not found!" % dialogue_id)
		return null
	return dialogues[dialogue_idx]

func retrieve_dialogue_by_index(dialogue_index: int) -> Dialogue:
	if dialogues.is_empty():
		print("[Warning] No dialogues loaded! Cannot retrieve dialogue by INDEX.")
		return null
	if dialogue_index < 0 or dialogue_index >= dialogues.size():
		print("[Warning] No dialogues found! Index out of bound.")
		return null
	return dialogues[dialogue_index]

func _parse_next_line_index(next_line_index) -> int:
	if next_line_index == null:
		return -1
	return next_line_index.strip_edges().split("_")[1].to_int()

func _calculate_starting_indexes(dialogue_items: Array) -> Array[int]:
	var starting_indexes: Array[int] = []
	for dialogue_item_idx in dialogue_items.size():
		starting_indexes.append(dialogue_items[dialogue_item_idx]["line"].size())
	return starting_indexes

func _sum(numbers: Array[int]) -> int:
	return numbers.reduce(func(accum, number): return accum + number, 0)
