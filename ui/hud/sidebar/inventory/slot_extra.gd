class_name SlotExtra extends HBoxContainer

@export var label: String = "0"
@onready var default_label: Label = %DefaultLabel

func	 _ready() -> void:
	default_label.text = label
