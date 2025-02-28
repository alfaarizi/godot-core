extends CharacterBody2D

@onready var animated_sprite_2d: CutsceneSprite = %AnimatedSprite2D

func play_animation(anim_name: String) -> void:
	animated_sprite_2d._play_animation(anim_name)

func stop_animation() -> void:
	animated_sprite_2d._stop_animation()

func change_animation_frame(anim_name: String, frame: int) -> void:
	animated_sprite_2d._change_animation_frame(anim_name, frame)
	
