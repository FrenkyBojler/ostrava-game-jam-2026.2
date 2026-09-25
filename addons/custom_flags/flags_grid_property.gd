@tool
extends EditorProperty

var checkboxes: Array[CheckBox] = []
var flag_values: Array[int] = []
var updating := false

func _init(names: Array, columns: int) -> void:
	var container := GridContainer.new()
	container.columns = columns

	for i in names.size():
		var entry: String = names[i]
		var flag_name := entry
		var value := 1 << i

		# Optional "Name:Value" override, same as plain @export_flags allows.
		if ":" in entry:
			var parts := entry.split(":")
			flag_name = parts[0]
			value = int(parts[1])

		flag_values.append(value)

		var cb := CheckBox.new()
		cb.text = flag_name if flag_name != "" else ("Bit %d" % i)
		cb.toggled.connect(_on_flag_toggled.bind(i))
		checkboxes.append(cb)
		container.add_child(cb)

	add_child(container)
	add_focusable(container)

func _on_flag_toggled(pressed: bool, index: int) -> void:
	if updating:
		return
	var current: int = get_edited_object().get(get_edited_property())
	var bit: int = flag_values[index]
	if pressed:
		current |= bit
	else:
		current &= ~bit
	emit_changed(get_edited_property(), current)

func _update_property() -> void:
	var current: int = get_edited_object().get(get_edited_property())
	updating = true
	for i in checkboxes.size():
		checkboxes[i].button_pressed = (current & flag_values[i]) != 0
	updating = false
