class_name GameController extends Node

@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var world_2d: Node2D = %World2D
var current_2d_scene: Room
enum SceneTransition { FREE, HIDE, DETACH }

func _ready() -> void:
	Global.game_controller = self
	current_2d_scene = %Lobby
	Global.dialogue = %DialogueHud
	SceneManager.entry_door_changed.connect(_on_entry_door_changed)
	loading_screen.animation_player.animation_finished.connect(func(anim_name): _on_animation_finished(anim_name))

func _on_entry_door_changed(_entry_door: Door) -> void:
	#print("curret scene is it null?" + str(current_2d_scene == null))
	#print("is it null?" + str(current_2d_scene.get_entered_door() == null))
	#print(SceneManager.current_entry_door.entry_door_name)
	SceneManager.change_player_position(current_2d_scene.get_entered_door().get_entry_position())
	
func change_2d_scene(new_scene: String, scene_transition: SceneTransition) -> void:
	if current_2d_scene == null:
		return
	
	loading_screen.animation_player.play("fade_in")	
	var new_2d = load(new_scene).instantiate() as Room
	new_2d.z_index = -1
	
	match scene_transition:
		SceneTransition.FREE:
			current_2d_scene.queue_free()
		SceneTransition.HIDE:
			current_2d_scene.visible = false
		SceneTransition.DETACH:
			world_2d.remove_child(current_2d_scene)
	
	current_2d_scene = new_2d

func _on_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			current_2d_scene.z_index = 0
			world_2d.add_child(current_2d_scene)
			loading_screen.animation_player.play("fade_out")
	
