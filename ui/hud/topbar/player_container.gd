class_name PlayerContainer extends VBoxContainer

const HEALTH_LENGTH = 363
const ENERGY_LENGTH = HEALTH_LENGTH*0.85

@onready var player_profile_texture: TextureRect = %PlayerProfileTexture
@onready var player_health_slider: HSlider = %PlayerHealthSlider
@onready var player_energy_slider: HSlider = %PlayerEnergySlider
@onready var status_container: StatusContainer = %StatusContainer
