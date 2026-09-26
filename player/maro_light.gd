extends Node2D

@onready var light: Light2D = $PointLight2D
@export var rotation_speed: float = 10.0

var is_dying: bool = false

func _ready() -> void:
	light.scale.x = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.FLASHLIGHT_SIZE)
	light.scale.y = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.FLASHLIGHT_RANGE)

func _process(delta: float) -> void:
	if Globals.current_game_state != Globals.GameState.Running or is_dying:
		return
	var mouse_pos = get_global_mouse_position()
	var target_angle = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
