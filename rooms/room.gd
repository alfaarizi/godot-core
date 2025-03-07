@tool
extends Node2D
class_name Room

@export var player: Player: set = _set_player
@export var doors: Array[Door]: set = _set_doors
var cutscene_animation: CutscenePlayer = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Global.player = player
	debug_scene()

func debug_scene() -> void:
	pass
	
func get_entered_door() -> Door:
	for door in doors:
		if door.entry_door_name == SceneManager.current_entry_door.entry_door_name:
			return door
	return null

func _set_player(_player: Player) -> void:
	player = _player
	update_configuration_warnings()

func _set_doors(_doors: Array[Door]) -> void:
	doors = _doors
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if player == null:
		return ["A player must be assigned"]
	if doors.is_empty():
		return ["at least one door is required"]
	return []
