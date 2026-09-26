class_name Piece extends Sprite2D

var grid_position: Vector2 = Vector2.ZERO
var occuppied: bool

func initialize(grid_pos: Vector2, grid_size: int) -> void:
	grid_position = Vector2(grid_pos.x - 1, grid_pos.y - 1)
	position = Vector2(grid_pos.x * grid_size, grid_pos.y * grid_size)
	visible = true

func toggle_highlight(value: bool) -> void:
	self_modulate = Color.AQUA if value else Color.WHITE
	z_index = 120 if value else 0
	
func toggle_occupy(value: bool) -> void:
	toggle_highlight(value)
	occuppied = value
