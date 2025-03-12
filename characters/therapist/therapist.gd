extends CharacterBody2D

@onready var cutscene_sprite_2d: CutsceneSprite = %CutsceneSprite2D

func play_animation(anim_name: String) -> void:
	cutscene_sprite_2d._play_animation(anim_name)

func stop_animation() -> void:
	cutscene_sprite_2d._stop_animation()

func change_animation_frame(anim_name: String, frame: int) -> void:
	cutscene_sprite_2d._change_animation_frame(anim_name, frame)
	
