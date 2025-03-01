@tool
extends Node2D
class_name Room

var has_entered: bool = false

@export var player: Player: set = set_player
@export var doors: Array[Door]: set = set_doors
var cutscene_animation: AnimationPlayer = null

var character_references: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Global.player = player
	cutscene_animation = find_child("AnimationPlayer", true, false)
	if cutscene_animation:
		#cutscene_animation.animation_finished.connect(_on_animation_finished)
		populate_character_references()
	print(character_references)
	debug_scene()
#
func populate_character_references() -> void:
	var characters := get_children().filter(func(e): return e is CharacterBody2D)
	var animated_sprites := cutscene_animation.get_children().filter(func(e): return e is AnimatedSprite2D)
	if not (animated_sprites and characters):
		return
	
	for sprite in animated_sprites:
		for character in characters:
			print(sprite.name + ", " + character.name)
			if ("Cut_" + character.name) == sprite.name:
				character_references[sprite] = character
				break

func debug_scene() -> void:
	#print("no scene has started")
	pass

func do(fun: Callable, args: Array = []) -> Variant:
	var result = fun.callv(args)
	return result
	
func play(anim_name: String) -> Signal:
	cutscene_animation.play(anim_name)
	return cutscene_animation.animation_finished
	
func delay(timeout: float) -> Signal:
	return get_tree().create_timer(timeout).timeout
	
func get_entered_door() -> Door:
	for door in doors:
		if door.entry_door_name == SceneManager.current_entry_door.entry_door_name:
			return door
	return null

func set_player(_player: Player) -> void:
	player = _player
	update_configuration_warnings()

func set_doors(_doors: Array[Door]) -> void:
	doors = _doors
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if player == null:
		return ["A player must be assigned"]
	if doors.is_empty():
		return ["at least one door is required"]
	return []
