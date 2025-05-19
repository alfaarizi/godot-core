class_name StatusContainer extends HBoxContainer

const PLAYER_STATUS_MAX := 10

@export var player_status: Array[Texture] = []
@onready var _player_status_container: Array[TextureRect] = [
	%Status1Texture, %Status2Texture, %Status3Texture,
	%Status4Texture, %Status5Texture, %Status6Texture,
	%Status7Texture, %Status8Texture, %Status9Texture,
	%Status10Texture
]

func _ready() -> void:
	for status in _player_status_container:
		status.visible = false

func add_status(_status_texture: Texture2D) -> void:
	if player_status.size() < PLAYER_STATUS_MAX:
		player_status.append(_status_texture)
		_update_status_textures()

func remove_status(_status_texture: Texture2D) -> void:
	if _status_texture in player_status:
		player_status.erase(_status_texture)
		_update_status_textures()

func _update_status_textures() -> void:
	for idx in range(_player_status_container.size()):
		if idx < player_status.size():
			_player_status_container[idx].texture = player_status[idx]
			_player_status_container[idx].visible = true
		else:
			_player_status_container[idx].texture = null
			_player_status_container[idx].visible = true
