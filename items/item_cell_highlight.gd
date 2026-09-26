class_name ItemCellHighlight extends Sprite2D

func _ready() -> void:
	turn_off_highlight()

func make_green() -> void:
	modulate = Color(Color.GREEN, 0.4)

func make_red() -> void:
	modulate = Color(Color.RED, 0.4)

func toggle_highlight(value: bool) -> void:
	visible = true
	if value:
		make_green()
	else:
		make_red()

func turn_off_highlight() -> void:
	visible = false
	modulate = Color.WHITE
