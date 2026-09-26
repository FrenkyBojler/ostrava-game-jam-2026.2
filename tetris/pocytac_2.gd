class_name Pocytac2 extends Sprite2D

func add_penizky(value: float) -> void:
	$Control/Number.text = "$" + str(value)

func reset_penizky() -> void:
	$Control/Number.text = "$0"
