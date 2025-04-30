extends GutTest

var Player = preload('res://characters/player/player.tscn')
var player: Player

func before_each() -> void:
	player = Player.instantiate()
	add_child(player)
	await get_tree().process_frame

func after_each() -> void:
	player.queue_free()

func test_initial_direction() -> void:
	assert_eq(player.player_direction, Vector2.DOWN, "Player is initially not facing downwards")
