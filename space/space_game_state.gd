class_name SpaceGameState extends Node2D

var current_scrap: int
var max_oxygen: float
var oxygen_level: float
var oxygen_consumption_rate: float
var current_run_peniazky: float = 0.0

func _ready() -> void:
	max_oxygen = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CAPACITY)
	# oxygen_level = max_oxygen
	oxygen_level = 5
	oxygen_consumption_rate = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CONSUMPTION_RATE)
	current_scrap = 0

func _process(delta: float) -> void:
	oxygen_level -= oxygen_consumption_rate * delta
	if oxygen_level < 0:
		oxygen_level = 0
	if oxygen_level == 0:
		_die()

func _die() -> void:
	var penalty: float = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.DEATH_PENALTY_SCRAP_LOSS)
	var obtained_scrap: int = current_scrap - round(current_scrap * penalty)

	Globals.add_peniazky(obtained_scrap)
	Globals.to_upgrades()

func add_peniazky(value: float) -> void:
	current_run_peniazky += value
