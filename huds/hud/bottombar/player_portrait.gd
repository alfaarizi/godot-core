class_name PlayerPortrait extends MarginContainer

const HEALTH_LENGTH_MAX = 1165
const ENERGY_LENGTH_MAX = HEALTH_LENGTH_MAX*0.85

@onready var player_profile_texture: TextureRect = %PlayerProfileTexture
@onready var player_health_length: HBoxContainer = %PlayerHealthLength
@onready var player_health_slider: HSlider = %PlayerHealthSlider
@onready var player_energy_length: HBoxContainer = %PlayerEnergyLength
@onready var player_energy_slider: HSlider = %PlayerEnergySlider
@onready var status_container: StatusContainer = %StatusContainer

@onready var player_name: Label = %PlayerName
@onready var player_health_label: RichTextLabel = %PlayerHealthLabel
@onready var player_energy_label: RichTextLabel = %PlayerEnergyLabel
