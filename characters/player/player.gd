class_name Player 
extends CharacterBody2D

const DEFAULT_MAX_SPEED := 550.0
const UP_LEFT := Vector2.UP + Vector2.LEFT
const UP_RIGHT := Vector2.UP + Vector2.RIGHT
const DOWN_LEFT := Vector2.DOWN + Vector2.LEFT
const DOWN_RIGHT := Vector2.DOWN + Vector2.RIGHT

@export var max_speed := DEFAULT_MAX_SPEED
@export_range(0.0, 1.0) var diagonal_speed_percent := 0.85
@export_range(0.0, 1.0) var running_speed_percent := 0.8
@export var acceleration := 2800.0
@export var deceleration := 2800.0

@onready var _move_action := ""
@onready var _move_allowed := true
@onready var _current_max_speed := max_speed
@onready var player_direction: Vector2
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var animated_sprite_2d: CutsceneSprite = %AnimatedSprite2D
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera

#var is_animation_running: bool = false

func set_move_allowed(flag: bool) -> void:
	_move_allowed = flag
	gpu_particles_2d.emitting = flag
	if not _move_allowed and animated_sprite_2d.is_playing():
		animated_sprite_2d.stop()

func _ready() -> void:
	GameState.state_changed.connect(_on_state_change)
	_update_position(SceneManager.current_player_position)
	_update_player_direction(SceneManager.current_entry_door)
	player_direction = Vector2.DOWN

func _update_player_direction(_door: Door) -> void:
		if not _door:
			return
		player_direction = _door.get_entry_direction_vector()
		var anim_name := get_move_action(_door.get_entry_direction_vector())
		animated_sprite_2d.animation = anim_name
		animated_sprite_2d.frame = 1
	
func _update_position(_position: Vector2) -> void:
	if not _position:
		return
	self.position = _position

func _physics_process(_delta: float) -> void:		
	if animated_sprite_2d.is_animation_running:
		return
	
	#print("PLAYER IS MOVING")
	if not _move_allowed:
		_change_to_idle(_delta)
		move_and_slide()
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction_discrete := direction.sign()
	
	_current_max_speed = max_speed
	if not direction_discrete.is_normalized():
		_current_max_speed *= diagonal_speed_percent
		
	_move_action = get_move_action(direction_discrete)
	animated_sprite_2d.play(_move_action)
	
	if direction.length() > 0.0:	
		animated_sprite_2d.flip_h = direction.x < 0.0
		var current_speed_percent := velocity.length() / _current_max_speed
		animated_sprite_2d.speed_scale = 1.75 if current_speed_percent > running_speed_percent else 1.0


		var desired_velovity := direction * _current_max_speed
		velocity = velocity.move_toward(desired_velovity, acceleration * _delta)
		gpu_particles_2d.emitting = true
	else:
		_change_to_idle(_delta)
	move_and_slide()	

func get_move_action(direction_discrete: Vector2) -> String:
	var move_action: String = ""
	match direction_discrete:
		Vector2.RIGHT, Vector2.LEFT:
			move_action = "move_right" 
			player_direction = Vector2.RIGHT if direction_discrete == Vector2.RIGHT else Vector2.LEFT
		Vector2.UP:
			move_action = "move_up"
			player_direction = Vector2.UP
		Vector2.DOWN:
			move_action = "move_down"
			player_direction = Vector2.DOWN
		UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT:
			move_action = move_action
			player_direction = player_direction
	return move_action

func _change_to_idle(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * _delta)
	animated_sprite_2d.frame = 1
	gpu_particles_2d.emitting = false

func _on_state_change(new_state: GameState.State) -> void:
	match new_state:
		GameState.State.EXPLORING:
			self.set_move_allowed(true)
		GameState.State.UI_NAVIGATION, GameState.State.INTERACTING, GameState.State.CUTSCENE:
			self.set_move_allowed(false)

func play_animation(anim_name: String) -> void:
	animated_sprite_2d._play_animation(anim_name)

func stop_animation() -> void:
	animated_sprite_2d._stop_animation()

func change_animation_frame(anim_name: String, frame: int) -> void:
	animated_sprite_2d._change_animation_frame(anim_name, frame)
