@tool
extends EditorInspectorPlugin

const FlagsGridProperty = preload("res://addons/custom_flags/flags_grid_property.gd")
const FlagsGridRadioProperty = preload("res://addons/custom_flags/flags_grid_radio_property.gd")

func _can_handle(object: Object) -> bool:
	return true

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if type != TYPE_INT or hint_type != PROPERTY_HINT_FLAGS:
		return false

	# Expected format: "grid:<columns>:name,name,name,..."
	if hint_string.begins_with("grid:"):
		var parts := hint_string.split(":", true, 2)
		var columns := int(parts[1])
		var names := parts[2].split(",")
		add_property_editor(name, FlagsGridProperty.new(names, columns))
		return true

	# Expected format: "radiogrid:<columns>:name,name,name,..."
	if hint_string.begins_with("radiogrid:"):
		var parts := hint_string.split(":", true, 2)
		var columns := int(parts[1])
		var names := parts[2].split(",")
		add_property_editor(name, FlagsGridRadioProperty.new(names, columns))
		return true

	# Anything else (plain @export_flags(...)) keeps the default dropdown.
	return false
