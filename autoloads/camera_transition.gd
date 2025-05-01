extends Node

var tween: Tween
var is_transitioning: bool = false

func switch_camera(from: Camera2D, to: Camera2D) -> void:
	to.enabled = true
	from.enabled = false

func transition_camera(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if is_transitioning:
		return

	var initial_state = {
		"zoom" : from.zoom,
		"offset" : from.offset,
		"light_mask" : from.light_mask,
		"global_transform": from.global_transform
	}

	from.enabled = true
	is_transitioning = true

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(from, "global_transform", to.global_transform, duration).from(from.global_transform)
	tween.tween_property(from, "zoom", to.zoom, duration).from(from.zoom)
	tween.tween_property(from, "offset", to.offset, duration).from(from.offset)

	await tween.finished

	to.enabled = true
	from.enabled = false

	from.zoom = initial_state["zoom"]
	from.offset = initial_state["offset"]
	from.light_mask = initial_state["light_mask"]
	from.global_transform = initial_state["global_transform"]

	is_transitioning = false
