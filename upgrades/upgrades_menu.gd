extends Control

const upgrade_item = preload("res://upgrades/upgrade_item.tscn")

func _ready() -> void:
	draw_upgrades()

func draw_upgrades() -> void:
	var item_instance: UpgradeItem = upgrade_item.instantiate() as UpgradeItem
	add_child(item_instance)
	item_instance.initialize(get_viewport().get_window().size / 2, Globals.upgrades.item)

	print_debug(Globals.upgrades.get_upgrade_value(Upgrades.UpgradeProperty.FLASHLIGHT_RANGE))
