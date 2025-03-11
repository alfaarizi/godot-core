@tool
class_name Door
extends Area2D

var has_access: bool = false
var correct_direction: bool = false

@export var press_required: bool = true: set = _set_press_required
@export var area_shape: Shape2D: set = _set_area_shape
@export_enum("north", "south", "east", "west") var entry_direction: int: set = _set_entry_direction
@export var push_dist: float = 16.0: set = _set_push_dist
@export var path_to_new_scene: String: set = _set_path_to_new_scene
@export var entry_door_name:String: set = _set_entry_door_name

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	SceneManager.change_entry_door(self)

func _process(_delta: float) -> void:
	if not (has_access and correct_direction): return
	if not press_required or Input.is_action_just_pressed("interact"):
		Global.game_controller.change_2d_scene(path_to_new_scene, Global.game_controller.SceneTransition.DETACH)
		SceneManager.change_entry_door(self)

func get_entry_position() -> Vector2:
	return get_entry_direction_vector_inverted() * push_dist + self.position

func get_entry_direction_vector() -> Vector2:
	return [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT][entry_direction]

func get_entry_direction_vector_inverted() -> Vector2:
	return [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT][entry_direction]

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		has_access = true
		while has_access:
			correct_direction = body.player_direction == self.get_entry_direction_vector()
			await get_tree().create_timer(0.1).timeout

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		has_access = false

func _set_press_required(_press_required: bool) -> void:
	press_required = _press_required

func _set_area_shape(_area_shape: Shape2D):
	if not _area_shape: return
	area_shape = _area_shape
	if collision_shape_2d:
		collision_shape_2d.shape = area_shape

func _set_entry_direction(_entry_direction: int) -> void:
	entry_direction = _entry_direction

func _set_push_dist(_push_dist: float) -> void:
	push_dist = _push_dist

func _set_path_to_new_scene(_path_to_new_scene: String) -> void:
	path_to_new_scene = _path_to_new_scene
	update_configuration_warnings()
	
func _set_entry_door_name(_entry_door_name: String) -> void:
	entry_door_name = _entry_door_name
	
func _get_configuration_warnings() -> PackedStringArray:
	if not path_to_new_scene or path_to_new_scene == "":
		return ["a path to new scene is required"]
	return []
