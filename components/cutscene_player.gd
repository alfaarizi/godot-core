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

	GameState.change_state(GameState.State.CUTSCENE)
	for ac in cutscene.frames:
		await _execute(ac)
	GameState.change_state(GameState.State.EXPLORING)

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
		CutsceneAction.Type.CAMERA:
			var camera_from := _get_camera(action.camera_from, action.camera_from_property)
			var camera_to := _get_camera(action.camera_to, action.camera_to_property)
			await _camera_execute(camera_from, camera_to, action.smooth_transition)
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

func _camera_execute(camera_from: Camera2D, camera_to: Camera2D, smooth_transition: bool):
	if not (camera_from and camera_to): return
	if smooth_transition:
		CameraTransition.transition_camera(camera_from, camera_to)
		return
	CameraTransition.switch_camera(camera_from, camera_to)

func _do(fun: Callable, args: Array = []) -> Variant:
	var result = fun.callv(args)
	return result

func _get_camera(path: NodePath, property_name: String) -> Camera2D:
	var node = get_node_or_null(path)
	if node is Camera2D: return node
	return node.get(property_name) if node else null

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
