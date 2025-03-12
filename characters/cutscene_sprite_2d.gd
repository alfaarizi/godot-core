class_name CutsceneSprite extends AnimatedSprite2D

var is_animation_running: bool = false

func _play_animation(anim_name: String) -> void:
	match anim_name:
		"move_left":
			anim_name = "move_right"
			flip_h = true
		_:			
			flip_h = false
	is_animation_running = true
	play(anim_name)

func _stop_animation() -> void:
	is_animation_running = false
	stop()

func _change_animation_frame(anim_name: String, _frame: int) -> void:
	match anim_name:
		"move_left":
			animation = "move_right"
			flip_h = true
		_:			
			animation = anim_name
			flip_h = false
	frame = _frame
