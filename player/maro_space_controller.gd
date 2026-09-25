class_name MaroSpaceController extends MaroController

@export
var move_speed := 100.0

func get_movement_input(delta: float) -> Vector2:
    var horizontal_input := Input.get_axis("move_left_p1", "move_right_p1")
    var vertical_input := Input.get_axis("move_up_p1", "move_down_p1")

    return Vector2(horizontal_input, vertical_input) * move_speed * delta