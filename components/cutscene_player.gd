@tool
class_name CutscenePlayer extends AnimationPlayer

@export var cutscenes: Array[Cutscene] = []: set = _set_cutscenes
var cutscenes_dict: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for ca in cutscenes:
		if ca and ca.cutscene_name:
			cutscenes_dict[ca.cutscene_name] = ca

func play_cutscene(cutscene_name: String):
	if cutscenes_dict.is_empty(): return

	var cutscene = cutscenes_dict.get(cutscene_name, null)
	if not cutscene: return

	for ac in cutscene.frames:
		await _execute(ac)

func _execute(cutscene_action: CutsceneFrame):
	if not cutscene_action: return
	
	var action := cutscene_action.action
	var action_type := cutscene_action.action_type
	
	match action_type:
		CutsceneAction.Type.DELAY:
			await _delay(action.time)
		CutsceneAction.Type.PLAY:
			await _play_anim(action.animation_name)
		CutsceneAction.Type.DIALOGUE:
			await _start_dialogue(action.dialogue_id)
		CutsceneAction.Type.EVENT:
			if action.target_node and action.has_method(action.method_name):
				await _do(action.target_node, [action.method_args])

func _delay(timeout: float) -> Signal:
	return get_tree().create_timer(timeout).timeout

func _play_anim(anim_name: String) -> Signal:
	self.play(anim_name)
	return self.animation_finished

func _start_dialogue(dialogue_id: String) -> Signal:
	Global.dialogue.start_dialogue(dialogue_id)
	return Global.dialogue.next_dialogue
	
func _do(fun: Callable, args: Array = []) -> Variant:
	var result = fun.callv(args)
	return result
	
func _set_cutscenes(_cutscenes: Array[Cutscene]):
	for idx in _cutscenes.size():
		if _cutscenes[idx] == null:
			_cutscenes[idx] = Cutscene.new()
	cutscenes = _cutscenes
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if cutscenes.is_empty():
		return ["at least one cutscene animation is required"]
	return []
