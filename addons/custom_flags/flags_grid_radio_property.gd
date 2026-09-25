@tool
extends EditorProperty

var checkboxes: Array[CheckBox] = []
var flag_values: Array[int] = []
var updating := false
var button_group := ButtonGroup.new()

func _init(names: Array, columns: int) -> void:
	var container := GridContainer.new()
	container.columns = columns

	for i in names.size():
		var entry: String = names[i]
		var flag_name := entry
		var value := 1 << i

		if ":" in entry:
			var parts := entry.split(":")
			flag_name = parts[0]
			value = int(parts[1])

		flag_values.append(value)

		var cb := CheckBox.new()
		cb.text = flag_name if flag_name != "" else ("Bit %d" % i)
		cb.button_group = button_group  # makes the whole grid mutually exclusive
		cb.toggled.connect(_on_flag_toggled.bind(i))
		checkboxes.append(cb)
		container.add_child(cb)

	add_child(container)
	add_focusable(container)

func _on_flag_toggled(pressed: bool, index: int) -> void:
	if updating or not pressed:
		return
	# ButtonGroup already unchecked every other box; just store this one's value.
	emit_changed(get_edited_property(), flag_values[index])

func _update_property() -> void:
	var current: int = get_edited_object().get(get_edited_property())
	updating = true
	for i in checkboxes.size():
		checkboxes[i].button_pressed = (current == flag_values[i])
	updating = false
