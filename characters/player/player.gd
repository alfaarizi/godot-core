class_name Player extends CharacterBody2D

const UP_LEFT := Vector2.UP + Vector2.LEFT
const UP_RIGHT := Vector2.UP + Vector2.RIGHT
const DOWN_LEFT := Vector2.DOWN + Vector2.LEFT
const DOWN_RIGHT := Vector2.DOWN + Vector2.RIGHT

@export var max_speed := 550.0
@export_range(0.0, 1.0) var diagonal_speed_percent := 0.85
@export_range(0.0, 1.0) var running_speed_percent := 0.8
@export var acceleration := 2800.0
@export var deceleration := 2800.0
@export var player_direction: Vector2 = Vector2.DOWN:
	set = set_player_direction

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var cutscene_sprite_2d: CutsceneSprite = %CutsceneSprite2D
@onready var interaction_area: Area2D = %InteractionArea
@onready var dynamic_bounds_camera: DynamicBoundsCamera = %DynamicBoundsCamera
@onready var _move_allowed := true: set = set_move_allowed
@onready var _current_max_speed := max_speed

func _ready() -> void:
	var entry_position = func(_position: Vector2) -> void:
		if not _position:return
		self.position = _position
	var entry_direction = func(_door: Door) -> void:
		if not _door: return
		self.player_direction = _door.get_entry_direction_vector()
		cutscene_sprite_2d.frame = 1

	GameState.state_changed.connect(_on_state_change)
	entry_position.call(SceneManager.current_player_position)
	entry_direction.call(SceneManager.current_entry_door)

func move_to_idle(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * _delta)
	cutscene_sprite_2d.frame = 1
	gpu_particles_2d.emitting = false

func get_move_action(direction_discrete: Vector2) -> String:
	var move_action: String = ""
	match direction_discrete:
		Vector2.RIGHT, Vector2.LEFT:
			move_action = "move_right"
		Vector2.UP:
			move_action = "move_up"
		Vector2.DOWN:
			move_action = "move_down"
		UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT:
			move_action = move_action
	return move_action

func _physics_process(_delta: float) -> void:
	if cutscene_sprite_2d.is_animation_running: return

	if not self._move_allowed:
		move_to_idle(_delta)
		move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction_discrete := direction.sign()

	self._current_max_speed = max_speed
	if not direction_discrete.is_normalized():
		self._current_max_speed *= diagonal_speed_percent

	if direction.length() > 0.0:
		player_direction = direction_discrete
		cutscene_sprite_2d.play(get_move_action(player_direction))
		cutscene_sprite_2d.flip_h = direction.x < 0.0

		var speed_percent := velocity.length() / self._current_max_speed
		cutscene_sprite_2d.speed_scale = 1.75 if speed_percent > running_speed_percent else 1.0

		velocity = velocity.move_toward(direction * self._current_max_speed, acceleration * _delta)
		gpu_particles_2d.emitting = true
	else:
		move_to_idle(_delta)
	move_and_slide()

func set_move_allowed(flag: bool) -> void:
	_move_allowed = flag
	gpu_particles_2d.emitting = flag
	if not _move_allowed and cutscene_sprite_2d.is_playing():
		cutscene_sprite_2d.stop()

func set_player_direction(direction: Vector2) -> void:
	if player_direction == direction: return
	player_direction = direction

	var move_action = get_move_action(player_direction)
	if move_action != "": cutscene_sprite_2d.animation = move_action

func _on_state_change(new_state: GameState.State) -> void:
	match new_state:
		GameState.State.EXPLORING:
			self._move_allowed = true
		GameState.State.UI_NAVIGATION, GameState.State.INTERACTING, GameState.State.CUTSCENE:
			self._move_allowed = false

# Helper Methods for Cutscene
func play_animation(anim_name: String) -> void:
	cutscene_sprite_2d._play_animation(anim_name)

func stop_animation() -> void:
	cutscene_sprite_2d._stop_animation()

func change_animation_frame(anim_name: String, frame: int) -> void:
	cutscene_sprite_2d._change_animation_frame(anim_name, frame)
