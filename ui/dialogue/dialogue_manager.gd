class_name DialogueManager extends MarginContainer

signal dialogue_completed
@onready var dialogue: Dialogue = %Dialogue
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

# Main Dialogue Display
@onready var player_body: TextureRect = %PlayerBody
@onready var player_expression: TextureRect = %PlayerExpression
@onready var npc_body: TextureRect = %NPCBody
@onready var npc_expression: TextureRect = %NPCExpression
@onready var dialogue_title_texture: NinePatchRect = %DialogueTitleTexture
@onready var dialogue_title: Label = %DialogueTitle
@onready var dialogue_body_texture: NinePatchRect = %DialogueBodyTexture
@onready var dialogue_body: RichTextLabel = %DialogueBody
@onready var next_arrow: Label = %NextArrow

# Containers
@onready var player_container: MarginContainer = %PlayerMargin
@onready var npc_container: MarginContainer = %NPCMargin
@onready var dialogue_container: MarginContainer = %DialogueMargin
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var scrollbar = scroll_container.get_v_scroll_bar()

# Helper variables
const DEFAULT_TEXT_SPEED: float = 40.0
var text_speed: float = DEFAULT_TEXT_SPEED
var current_dialogue_idx := 0
var current_state = null

var keypress_enabled: bool = true
var keypress_recognized: bool = false
var skip_key_pressed: bool = false
var skip_timer: Timer = null
var skip_activated: bool = false

var dialogue_tween: Tween = null

class Profile:
	var body: TextureRect
	var expression: TextureRect
	var audio: AudioStreamPlayer
	var container: MarginContainer
	var has_entered: bool
	
	func _init(_body: TextureRect, _expression: TextureRect,  _audio: AudioStreamPlayer, _container: MarginContainer) -> void:
		body = _body
		expression = _expression
		audio = _audio
		container = _container
		has_entered = false
		
var player: Profile = null
var npc: Profile = null
var curr_character: Profile = null
var prev_character: Profile = null

enum State { READY, DISPLAYING, WAITING_FOR_INPUT, COMPLETED }
enum SlideDirection { SLIDE_IN, SLIDE_OUT }

func _ready() -> void:
	print("ready")
	_reset_text()
	#scrollbar.connect("changed", func(): scroll_container.scroll_vertical = scrollbar.max_value )
	current_state = State.READY


func start_dialogue(_dialogue: Dialogue = null) -> void:
	#print("start_dialogue")
	if current_state != State.READY:
		return
	if _dialogue:
		dialogue = _dialogue
	_reset_text()
	_initialize_text()
		
	await get_tree().create_timer(0.2).timeout
	_show_text(current_dialogue_idx)
	current_dialogue_idx += 1

# HANDLE INPUT AND STATES
func _unhandled_input(_event: InputEvent) -> void:
	if not keypress_enabled or current_state == null:
		return
		
	if Input.is_action_just_pressed("next_dialogue") and not skip_key_pressed:
		keypress_recognized = true
		skip_activated = false
	elif Input.is_action_just_pressed("skip_dialogue"):
		if skip_timer == null:
			skip_timer = Timer.new()
			skip_timer.one_shot = true
			skip_timer.timeout.connect(func(): 
				if not Input.is_action_pressed("skip_dialogue"):
					return
				keypress_recognized = true
				skip_activated = true
			)
			add_child(skip_timer)
		skip_key_pressed = true
		skip_timer.start(0.5)
	elif Input.is_action_just_released("skip_dialogue"):
		if skip_timer != null:
			skip_timer.stop()
		skip_key_pressed = false
		skip_activated = false

	if keypress_recognized:
		keypress_recognized = false
		match current_state:	
			State.DISPLAYING:
				_on_state_displaying()
			State.WAITING_FOR_INPUT:
				_on_state_waiting_for_input()
			State.COMPLETED:
				_on_state_completed()

func _on_state_displaying() -> void:
	text_speed = DEFAULT_TEXT_SPEED * 10
	dialogue_tween.set_speed_scale(10.0)
	audio_stream_player.volume_db = -80.0

func _on_state_waiting_for_input() -> void:
	_show_text(current_dialogue_idx)
	current_dialogue_idx += 1

func _on_state_completed() -> void:
	call_deferred("_disable_keypress")
	_character_slide(SlideDirection.SLIDE_OUT, player, 0.4)
	_character_slide(SlideDirection.SLIDE_OUT, npc, 0.4)
	_dialogue_slide(SlideDirection.SLIDE_OUT, 0.6)
	await get_tree().create_timer(0.4).timeout
	call_deferred("_enable_keypress")
	current_state = State.READY
	dialogue_completed.emit()

# DIALOGUE DISPLAY	
func _reset_text() -> void:
	for container in [player_container, npc_container]:
		container.add_theme_constant_override("margin_left", 0)
		container.add_theme_constant_override("margin_right", 0)
		container.modulate.a = 1.0
	dialogue_container.add_theme_constant_override("margin_top", 320)
	dialogue_container.add_theme_constant_override("margin_bottom", 25)
	dialogue_container.modulate.a = 1.0
	for node in [player_body, player_expression, npc_body, npc_expression]:
		node.texture = null
		node.modulate = Color(1.0, 1.0, 1.0)
	dialogue_title.text = ""
	dialogue_body.text = ""
	next_arrow.text = ""
	audio_stream_player.stream = null
	dialogue_title_texture.modulate.a = 0.0
	dialogue_body_texture.modulate.a = 0.0
	skip_activated = false
	
func _initialize_text() -> void:
	player = Profile.new(player_body, player_expression, audio_stream_player, player_container)
	npc = Profile.new(npc_body, npc_expression, audio_stream_player, npc_container)
	prev_character = null
	current_dialogue_idx = 0
	dialogue_title_texture.modulate.a = 1.0
	dialogue_body_texture.modulate.a = 1.0
	_dialogue_slide(SlideDirection.SLIDE_IN, 0.4)
		
func _show_text(dialogue_item_idx: int) -> void:	
	current_state = State.DISPLAYING
	var current_dialogue := dialogue.dialogue_items[dialogue_item_idx]
	
	# Assign character
	curr_character = player if current_dialogue.is_player else npc
	curr_character.body.texture = current_dialogue.character
	curr_character.expression.texture = current_dialogue.expression
	curr_character.audio.stream = current_dialogue.audio
	audio_stream_player.volume_db = 0.0
		
	# Set text
	dialogue_title.text = current_dialogue.name
	dialogue_body.visible_ratio = 0.0	
	dialogue_body.text = current_dialogue.text
	next_arrow.visible_ratio = 0.0
	next_arrow.text = "..."
	
	# Animate text appearance
	text_speed = DEFAULT_TEXT_SPEED
	dialogue_tween = create_tween().set_parallel()
	if skip_activated:
		_on_state_displaying()

	if prev_character == null or prev_character != curr_character:
		dialogue_tween.tween_property(curr_character.body, "modulate", Color(1.0, 1.0, 1.0), 0.1).from(Color(0.25, 0.25, 0.25))
		if prev_character:
			dialogue_tween.tween_property(prev_character.body, "modulate", Color(0.25, 0.25, 0.25), 0.2).from(Color(1.0, 1.0, 1.0))
	prev_character = curr_character
	
	if not curr_character.has_entered:
		_character_slide(SlideDirection.SLIDE_IN, curr_character, 0.6)
		curr_character.has_entered = true
	
	# Elipsis anumation
	var elipsis_appearing_duration : float = 0.2
	var elipsis_tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	elipsis_tween.tween_property(next_arrow, "visible_ratio", 1.0, elipsis_appearing_duration)
	elipsis_tween.tween_interval(elipsis_appearing_duration)
	elipsis_tween.tween_property(next_arrow, "visible_ratio", 0.0, elipsis_appearing_duration)
	elipsis_tween.tween_interval(elipsis_appearing_duration/2)
	elipsis_tween.set_loops()
	
	# Play sound effect
	var text_appearing_duration : float = dialogue_body.text.length() / text_speed 
	var sound_max_length = curr_character.audio.stream.get_length() - text_appearing_duration
	var sound_start_position = randf() * sound_max_length
	curr_character.audio.play(sound_start_position)
	dialogue_tween.finished.connect(curr_character.audio.stop)
			
	dialogue_tween.finished.connect(func() -> void:
		elipsis_tween.kill()
		
		# Next arrow animatino
		var arrow_tween := create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
		arrow_tween.tween_property(next_arrow, "text", "v", 0.05).from("...")
		arrow_tween.tween_property(next_arrow, "visible_ratio", 1.0, 0.1).from(0.0)
		arrow_tween.tween_property(next_arrow, "modulate:a", 1.0, 0.15).from(0.0)
		arrow_tween.finished.connect(func(): 
			if current_dialogue.next_line_idx == -1:
				current_state = State.COMPLETED
				if skip_activated:
					_on_state_completed()
				return			
			current_state = State.WAITING_FOR_INPUT
			if skip_activated:
				_on_state_waiting_for_input()
		)
	)
	
	### Text appearing animation
	var regex = RegEx.new()
	regex.compile(r"\.{3,}|[^.,]+[.,]?")
	var matches = regex.search_all(current_dialogue.text)

	var prev_visible_ratio := dialogue_body.visible_ratio
	var total_visible_ratio := prev_visible_ratio
	
	dialogue_tween.set_parallel(false)
	
	for m in matches:
		var segment := m.get_string()
		var curr_visible_ratio: float = float(segment.length()) / current_dialogue.text.length()
		var curr_appearing_duration: float = segment.length() / text_speed
		
		prev_visible_ratio = total_visible_ratio
		total_visible_ratio += curr_visible_ratio
		
		dialogue_tween.tween_property(dialogue_body, "visible_ratio", total_visible_ratio, curr_appearing_duration).from(prev_visible_ratio)
		dialogue_tween.tween_callback(curr_character.audio.stop)
		dialogue_tween.tween_interval(0.2)
		dialogue_tween.tween_callback(curr_character.audio.play)


# SLIDE ANIMATIONS
func _slide(slideType: SlideDirection, container: MarginContainer, margin_front: String, margin_behind: String, distance: int, duration: float) -> void:
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	var initial_margin_front := container.get_theme_constant(margin_front)
	var initial_margin_behind := container.get_theme_constant(margin_behind)
	
	var front_margins : Array[int] = []
	var behind_margins : Array[int] = []
	var visibility := 1.0
	match slideType:
		SlideDirection.SLIDE_IN:
			front_margins = [initial_margin_front+distance, initial_margin_front]
			behind_margins = [initial_margin_behind-distance, initial_margin_behind]
		SlideDirection.SLIDE_OUT:
			front_margins = [initial_margin_front, initial_margin_front-distance]
			behind_margins = [initial_margin_behind, initial_margin_behind+distance]
			visibility = 0.0
		
	container.add_theme_constant_override(margin_front, front_margins[0])
	container.add_theme_constant_override(margin_behind, behind_margins[0])
	
	tween.tween_method(func(value: int): container.add_theme_constant_override(margin_front, value),
		front_margins[0], front_margins[1], duration
	)
	tween.tween_method(func(value: int): container.add_theme_constant_override(margin_behind, value),
		behind_margins[0], behind_margins[1], duration
	)
	tween.tween_property(container, "modulate:a", visibility, duration/2)

func _character_slide(slideType: SlideDirection, character: Profile, duration: float) -> void:
	var margins: Array[String] = []
	match slideType:
		SlideDirection.SLIDE_IN:
			margins = ["margin_right", "margin_left"]
		SlideDirection.SLIDE_OUT:
			margins = ["margin_left", "margin_right"]
	if character == player:
		_slide(slideType, character.container, margins[0], margins[1], 100, duration)
	elif character == npc:
		_slide(slideType, character.container, margins[1], margins[0], 100, duration)
		
func _dialogue_slide(slideType: SlideDirection, duration: float) -> void:
	var margins: Array[String] = []
	match slideType:
		SlideDirection.SLIDE_IN:
			margins = ["margin_top", "margin_bottom"]
		SlideDirection.SLIDE_OUT:
			margins = ["margin_bottom", "margin_top"]
	_slide(slideType, dialogue_container, margins[0], margins[1], 250, duration)

# KEY PRESS
func _disable_keypress() -> void:
	keypress_enabled = false

func _enable_keypress() -> void:
	keypress_enabled = true
