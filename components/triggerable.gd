@tool
class_name Triggerable 
extends Area2D

var has_access: bool = false
signal is_triggered

@export var area_shape: Shape2D: set = _set_area_shape
@export_enum("north", "south", "east", "west") var trigger_direction: int: set = _set_trigger_direction

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var trigger_key: String # {parent_node_name}_{triggerable_name}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	trigger_key = get_parent().name + "_" + self.name
	if has_triggered(): _disconnect_trigger_signal()

func has_triggered() -> bool:
	return trigger_key and SceneManager.trigger_registry.has(trigger_key)

func get_entry_direction_vector() -> Vector2:
	return [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT][trigger_direction]

func _disconnect_trigger_signal():
	for conn in is_triggered.get_connections():
		is_triggered.disconnect(conn["callable"])
	queue_free()

func _on_body_entered(body: Node2D) -> void:	
	if has_triggered(): return
	if body is Player:
		has_access = true
		while has_access:
			if body.player_direction == get_entry_direction_vector():
				SceneManager.register_trigger(self)
				is_triggered.emit()
				_disconnect_trigger_signal()
				break
			await get_tree().create_timer(0.1).timeout

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		has_access = false

func _set_area_shape(_area_shape: Shape2D):
	if not _area_shape: return
	area_shape = _area_shape
	if collision_shape_2d:
		collision_shape_2d.shape = area_shape

func _set_trigger_direction(_trigger_direction: int) -> void:
	trigger_direction = _trigger_direction

#func _set_precondition(_precondition: Array[Triggerable]) -> void:
	#for idx in _precondition.size():
		#if _precondition[idx] == null:
			#_precondition[idx] = Triggerable.new()
	#precondition = _precondition
#
#func _set_postcondition(_postcondition: Array[Triggerable]) -> void:
	#for idx in _postcondition.size():
		#if _postcondition[idx] == null:
			#_postcondition[idx] = Triggerable.new()
	#postcondition = _postcondition
