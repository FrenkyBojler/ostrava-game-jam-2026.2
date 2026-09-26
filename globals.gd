class_name GlobalsGlobal
extends Node

var upgrades: Upgrades.UpgradesContainer = Upgrades.UpgradesContainer.new()

func _ready() -> void:
	load_upgrades()

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