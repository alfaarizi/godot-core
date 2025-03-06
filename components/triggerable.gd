@tool
extends Area2D

@export var area_shape: Shape2D: set = set_area_shape
@export var callable: Callable: set = set_callable

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	callable = foo()

func set_area_shape(_area_shape: Shape2D):
	if not _area_shape: return
	area_shape = _area_shape
	if collision_shape_2d:
		collision_shape_2d.shape = area_shape

func set_callable(_callable: Callable):
	_callable.call()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		pass

func foo():
	print("bar")
	
