@tool
extends Panel

@export var slot_label_visibility := true
@onready var slot_label: MarginContainer = %SlotLabel

func _ready() -> void:
	if !slot_label_visibility:
		remove_child(slot_label)
