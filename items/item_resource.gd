@tool
extends Resource

class_name ItemResource

@export
var value: float

@export_custom(PROPERTY_HINT_FLAGS, "grid:3:00,10,20,01,11,21,02,12,22")
var colliders: int = 0

@export_group("Input")
@export
var has_input: bool = false:
	set(value):
		has_input = value
		notify_property_list_changed()
		
@export_custom(PROPERTY_HINT_FLAGS, "radiogrid:3:00,10,20,01,11,21,02,12,22")
var input: int = 0

@export_group("Output")
@export
var has_output: bool = false:
	set(value):
		has_output = value
		notify_property_list_changed()
		
@export_custom(PROPERTY_HINT_FLAGS, "radiogrid:3:00,10,20,01,11,21,02,12,22")
var output: int = 0:
	set(value):
		output = value
		notify_property_list_changed()

@export
var linked_item: PackedScene

func _validate_property(property: Dictionary) -> void:
	if property.name == "linked_item" and output == 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "input" and has_input == false:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "output" and has_output == false:
		property.usage = PROPERTY_USAGE_NO_EDITOR
