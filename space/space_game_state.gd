class_name SpaceGameState extends Node2D

@export var item_spawner_parent: Node2D
@export var scraps_indicator: ScrapsIndicator
@export var items_to_spawn: Array[PackedScene]

var max_oxygen: float
var oxygen_level: float
var oxygen_consumption_rate: float
var current_run_peniazky: float = 0.0
var emergency_reserve_used: bool = false

var used_spawn_points : Array[Node2D] = []
var spawned_items: Array[Item] = []

func _ready() -> void:
	assert(item_spawner_parent != null, "Missing item spawner parent")
	assert(scraps_indicator != null, "Missing scraps indicator")
	
	max_oxygen = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CAPACITY)
	oxygen_level = max_oxygen
	oxygen_consumption_rate = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_CONSUMPTION_RATE)
	current_run_peniazky = 0
	
	spawned_items += _spawn_items()
	spawned_items += _spawn_items()
	spawned_items += _spawn_items()
	spawned_items += _spawn_items()
	spawned_items += _spawn_items()

	scraps_indicator.set_items_on_map(spawned_items)

func _process(delta: float) -> void:
	if not Globals.is_running():
		return


	oxygen_level -= oxygen_consumption_rate * delta
	if oxygen_level < 0:
		oxygen_level = 0
	if oxygen_level == 0:
		if Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_EMERGENCY_RESERVE) > 0 and not emergency_reserve_used:
			oxygen_level = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_EMERGENCY_RESERVE)
			emergency_reserve_used = true
		else:
			_die()

func _die() -> void:
	var penalty: float = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.DEATH_PENALTY_SCRAP_LOSS)
	var obtained_scrap: int = current_run_peniazky - round(current_run_peniazky * penalty)

	Globals.add_peniazky(obtained_scrap)
	Globals.to_upgrades()

func evacuate() -> void:
	Globals.add_peniazky(current_run_peniazky)
	Globals.to_upgrades()

func add_peniazky(value: float) -> void:
	current_run_peniazky += value

func add_oxygen(value: float) -> void:
	if value <= 0:
		return

	oxygen_level += value
	if oxygen_level > max_oxygen:
		oxygen_level = max_oxygen
	
func _spawn_items() -> Array[Item]:
	var spawned_items: Array[Item] = []

	for item in items_to_spawn:
		var item_instance := item.instantiate() as Item
		randomize()
		
		var available_spawners = item_spawner_parent.get_children().filter(func(spawner):
			return used_spawn_points.find(spawner) == -1
		)
		
		if available_spawners.size() == 0:
			return spawned_items
		
		var target_spawn := available_spawners.pick_random() as Node2D
		used_spawn_points.push_back(target_spawn)
		add_child(item_instance)
		item_instance.global_position = target_spawn.global_position
		spawned_items.append(item_instance)

	return spawned_items
