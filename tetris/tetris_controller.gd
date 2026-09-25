class_name TetrisController extends MaroController

var grid_size: int = 16

func get_movement_input(_delta: float) -> Vector2:
    # Handle input and movement
    var input_vector: Vector2 = Vector2.ZERO
 
    if Input.is_action_just_pressed("move_left_p1"):
        input_vector.x -= grid_size
    elif Input.is_action_just_pressed("move_right_p1"):
        input_vector.x += grid_size
    elif Input.is_action_just_pressed("move_up_p1"):
        input_vector.y -= grid_size
    elif Input.is_action_just_pressed("move_down_p1"):
        input_vector.y += grid_size
    
    return input_vector