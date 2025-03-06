@tool
class_name CutscenePlayer extends AnimationPlayer

@export var cutscene_animations: Array[CutsceneAnimation] = []: set = set_cutscene_animations
var cutscene_animations_dict: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for ca in cutscene_animations:
		if ca and ca.cutscene_name:
			cutscene_animations_dict[ca.cutscene_name] = ca

func play_cutscene(cutscene_name: String):
	if cutscene_animations_dict.is_empty(): return

	var cutscene = cutscene_animations_dict.get(cutscene_name, null)
	if not cutscene: return

	for ac in cutscene.actions:
		await execute(ac)

func execute(cutscene_action: CutsceneAction):
	if not cutscene_action: return
	
	var action := cutscene_action.action
	var action_type := cutscene_action.action_type
	
	match action_type:
		CutsceneAction.ActionType.DELAY:
			await _delay(action.time)
			print("delay")
		CutsceneAction.ActionType.PLAY:
			await _play_anim(action.animation_name)
			print("anim")
		CutsceneAction.ActionType.DIALOGUE:
			await _start_dialogue(action.dialogue_id)
			print("dialogue")
		CutsceneAction.ActionType.EVENT:
			if action.target_node and action.has_method(action.method_name):
				await _do(action.target_node, [action.method_args])
				print("event")

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
	
func set_cutscene_animations(_cutscene_animations: Array[CutsceneAnimation]):
	for idx in _cutscene_animations.size():
		if _cutscene_animations[idx] == null:
			_cutscene_animations[idx] = CutsceneAnimation.new()
	cutscene_animations = _cutscene_animations
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if cutscene_animations.is_empty():
		return ["at least one cutscene animation is required"]
	return []
