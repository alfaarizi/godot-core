@tool
class_name Cutscene extends Resource

@export var cutscene_name: String = ""
@export var frames: Array[CutsceneFrame] = []: set = _set_frames

func _ready() -> void:
	if Engine.is_editor_hint(): return	

func _set_frames(_frames: Array[CutsceneFrame]) -> void:
	for idx in _frames.size():
		if _frames[idx] == null:
			_frames[idx] = CutsceneFrame.new()
	frames = _frames
