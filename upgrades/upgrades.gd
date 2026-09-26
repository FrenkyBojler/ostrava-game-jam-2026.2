class_name Upgrades
extends Node

enum UpgradeProperty {
	GRID_SIZE,
	MOVE_OVER_GRID_OBSTACLES,
	SCRAP_PROCESSING_SPEED,
	SCRAP_VALUE,
	MULTI_PARTS_SCRAPS,
	SCRAP_ROTATION,
	SCRAP_INDICATORS,
	UNLOCKING_DOORS_SPEED,
	MOVE_SPEED,
	OXYGEN_CAPACITY,
	FLASHLIGHT_SIZE,
	FLASHLIGHT_BRIGHTNESS,
	FLASHLIGHT_RANGE,
	FLASHLIGHT_BURN_DAMAGE
}
	
class UpgradesContainer:
	var item: UpgradeItemDTO

	func reset() -> void:
		item.reset()

	func get_upgrade_value(property: UpgradeProperty) -> float:
		if item.active_level == 0:
			return 0

		var value: float = 0
		var effects: Array[EffectDTO] = get_upgrade_effects(property)

		for effect: EffectDTO in effects:
			if effect.operation == "add":
				value += effect.value
			elif effect.operation == "multiply":
				value = value * effect.value if value != 0 else effect.value

		return value

	func get_upgrade_effects(property: UpgradeProperty) -> Array[EffectDTO]:
		var effects: Array[EffectDTO] = []

		for effect: EffectDTO in item.get_active_effects():
			if effect.get_property_enum() == property:
				effects.append(effect)

		return effects

class UpgradeItemDTO:
	var title: String
	var description: String
	var icon: String
	var upgrades: Array[UpgradeDTO]
	var active_level: int
	var left: UpgradeItemDTO
	var right: UpgradeItemDTO
	var top: UpgradeItemDTO
	var bottom: UpgradeItemDTO


	func reset() -> void:
		active_level = 0
		for child: UpgradeItemDTO in get_children():
			child.active_level = 0

	func get_active_effects() -> Array[EffectDTO]:
		if active_level == 0:
			return []

		var active_effects: Array[EffectDTO] = upgrades[active_level - 1].effects
		for child: UpgradeItemDTO in get_children():
			active_effects += child.get_active_effects()

		return active_effects

	func get_children() -> Array[UpgradeItemDTO]:
		var children: Array[UpgradeItemDTO] = []
		if left:
			children.append(left)
		if right:
			children.append(right)
		if top:
			children.append(top)
		if bottom:
			children.append(bottom)

		return children

	static func from_dict(data: Dictionary) -> UpgradeItemDTO:
		var item := UpgradeItemDTO.new()
		item.title = _string_value(data.get("title", ""))
		item.description = _string_value(data.get("description", ""))
		item.icon = _string_value(data.get("icon", ""))
		item.active_level = _int_value(data.get("active_level", 0))
		item.upgrades = []

		var upgrades_variant: Variant = data.get("upgrades", [])
		if upgrades_variant is Array:
			var upgrades_array: Array = upgrades_variant
			for upgrade_data_variant: Variant in upgrades_array:
				if upgrade_data_variant is Dictionary:
					var upgrade_data: Dictionary = upgrade_data_variant
					item.upgrades.append(UpgradeDTO.from_dict(upgrade_data))

		item.left = _from_child_dict(data.get("left"))
		item.right = _from_child_dict(data.get("right"))
		item.top = _from_child_dict(data.get("top"))
		item.bottom = _from_child_dict(data.get("bottom"))
		return item

	static func _from_child_dict(data: Variant) -> UpgradeItemDTO:
		if data is Dictionary:
			return UpgradeItemDTO.from_dict(data as Dictionary)
		return null

	static func _string_value(value: Variant) -> String:
		if value is String:
			return value as String
		if value is StringName:
			return String(value)
		return str(value)

	static func _int_value(value: Variant) -> int:
		if value is int:
			return value as int
		if value is float:
			return int(value as float)
		if value is bool:
			if value as bool:
				return 1
			return 0
		return 0

class UpgradeDTO:
	var price: int
	var effects: Array[EffectDTO]

	static func from_dict(data: Dictionary) -> UpgradeDTO:
		var upgrade := UpgradeDTO.new()
		upgrade.price = UpgradeItemDTO._int_value(data.get("price", 0))
		upgrade.effects = []

		var effects_variant: Variant = data.get("effects", [])
		if effects_variant is Array:
			var effects_array: Array = effects_variant
			for effect_data_variant: Variant in effects_array:
				if effect_data_variant is Dictionary:
					var effect_data: Dictionary = effect_data_variant
					upgrade.effects.append(EffectDTO.from_dict(effect_data))

		return upgrade

class EffectDTO:
	var property: String
	var operation: String
	var value: float

	func get_property_enum() -> UpgradeProperty:
		return UpgradeProperty.get(property.to_upper())

	static func from_dict(data: Dictionary) -> EffectDTO:
		var effect := EffectDTO.new()
		effect.property = UpgradeItemDTO._string_value(data.get("property", ""))
		effect.operation = UpgradeItemDTO._string_value(data.get("operation", ""))

		var effect_value: Variant = data.get("value", 0.0)
		if effect_value is float:
			effect.value = effect_value as float
		elif effect_value is int:
			effect.value = float(effect_value as int)
		elif effect_value is bool:
			if effect_value as bool:
				effect.value = 1.0
			else:
				effect.value = 0.0
		else:
			effect.value = 0.0

		return effect
