class_name GlobalsGlobal
extends Node

signal upgrade_bought(upgrade: Upgrades.UpgradeItemDTO)

var upgrades: Upgrades.UpgradesContainer = Upgrades.UpgradesContainer.new()
var peniazky: int = 0

func _ready() -> void:
	load_upgrades()
	reset()

func reset() -> void:
	peniazky = 100000
	upgrades.reset()

func buy_upgrade(upgrade_id: String) -> void:
	var upgrade: Upgrades.UpgradeItemDTO = upgrades.find_upgrade_by_id(upgrade_id)

	if upgrade == null:
		push_error("Upgrade with ID '%s' not found." % upgrade_id)
		return

	if upgrade.is_max_level() || peniazky < upgrade.get_next_level_price():
		return

	peniazky -= upgrade.get_next_level_price()
	upgrade.buy_upgrade()
	emit_signal("upgrade_bought", upgrade)


func load_upgrades() -> void:
	var file := FileAccess.open("res://upgrades/upgrades.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open upgrades.json: %s" % FileAccess.get_open_error())
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		push_error("Failed to parse upgrades.json: %s" % json.get_error_message())
		return

	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Upgrades JSON root must be an object.")
		return

	var parsed_dict: Dictionary = parsed
	var upgrade_data: Upgrades.UpgradeItemDTO = Upgrades.UpgradeItemDTO.from_dict(parsed_dict)
	upgrades.item = upgrade_data