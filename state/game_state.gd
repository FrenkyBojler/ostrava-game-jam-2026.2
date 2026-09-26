extends Node2D

signal oxygen_depleted

var current_scrap: int
var max_oxygen: float
var oxygen_level: float
var oxygen_consumption_rate: float

func _ready() -> void:
	max_oxygen = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CAPACITY)
	oxygen_level = max_oxygen
	oxygen_consumption_rate = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CONSUMPTION_RATE)
	current_scrap = 0

func _process(delta: float) -> void:
	oxygen_level -= oxygen_consumption_rate * delta
	if oxygen_level < 0:
		oxygen_level = 0
	if oxygen_level == 0:
		# Handle oxygen depletion (e.g., player takes damage or game over)
		emit_signal("oxygen_depleted")
