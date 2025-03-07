@tool
class_name CutsceneAction extends Resource

enum Type { Nil, DELAY, PLAY, DIALOGUE, EVENT }

func _init() -> void:
	if Engine.is_editor_hint():
		return

class DelayAction extends CutsceneAction:
	@export var time: float = 1.0

class PlayAction extends CutsceneAction:
	@export var animation_name: String = ""#: set = _set_animation_name
	#func _set_animation_name(_animation_name: String):
		#animation_name = _animation_name

class DialogueAction extends CutsceneAction:
	@export var dialogue_id: String = ""

class EventAction extends CutsceneAction:
	@export var target_node: NodePath
	@export var method_name: String
	@export var method_args: Array[Variant] = []
	
