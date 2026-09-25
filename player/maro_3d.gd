extends CharacterBody2D

@export
var move_speed := 100.0

func _process(delta: float) -> void:
	var horizontal_input := Input.get_axis("move_left_p1", "move_right_p1")
	var vertical_input := Input.get_axis("move_up_p1", "move_down_p1")
	
	print_debug(horizontal_input)
	print_debug(vertical_input)
	
	move_and_collide(Vector2(horizontal_input, vertical_input) * move_speed * delta)
