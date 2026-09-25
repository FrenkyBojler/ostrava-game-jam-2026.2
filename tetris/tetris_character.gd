class_name TetrisCharacter extends CharacterBody2D

var grid_size: int = 16
var local_scale: int = 3

func initialize(size: int) -> void:
    grid_size = size

func _input(event: InputEvent) -> void:
    var input_vector: Vector2 = Vector2.ZERO

    if event.is_action_pressed("ui_left"):
        input_vector.x -= grid_size * local_scale
    elif event.is_action_pressed("ui_right"):
        input_vector.x += grid_size * local_scale
    elif event.is_action_pressed("ui_up"):
        input_vector.y -= grid_size * local_scale
    elif event.is_action_pressed("ui_down"):
        input_vector.y += grid_size * local_scale

    move_and_collide(input_vector)