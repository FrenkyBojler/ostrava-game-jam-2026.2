extends Node2D

@onready var light: Light2D = $PointLight2D
@export var rotation_speed: float = 10.0


func _ready() -> void:
	light.scale.x = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.FLASHLIGHT_RANGE)
	light.scale.y = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.FLASHLIGHT_SIZE)

func _process(delta: float) -> void:
	if Globals.current_game_state != Globals.GameState.Running:
		return
	var mouse_pos = get_global_mouse_position()
	var target_angle = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
