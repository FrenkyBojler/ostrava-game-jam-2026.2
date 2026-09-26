class_name SpaceGameState extends Node2D

@export var item_spawner_parent: Node2D
@export var items_to_spawn: Array[PackedScene]

var current_scrap: int
var max_oxygen: float
var oxygen_level: float
var oxygen_consumption_rate: float
var current_run_peniazky: float = 0.0

func _ready() -> void:
	assert(item_spawner_parent != null, "Missing item spawner parent")
	
	max_oxygen = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CAPACITY)
	oxygen_level = max_oxygen
	oxygen_consumption_rate = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CONSUMPTION_RATE)
	current_scrap = 0
	
	_spawn_items()

func _process(delta: float) -> void:
	if not Globals.is_running():
		return

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
	
func _spawn_items() -> void:
	for item in items_to_spawn:
		var item_instance := item.instantiate() as Item
		randomize()
		var target_spawn := item_spawner_parent.get_children().pick_random() as Node2D
		add_child(item_instance)
		item_instance.global_position = target_spawn.global_position
