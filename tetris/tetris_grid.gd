class_name TetrisGrid extends Node2D

@onready var piece: Sprite2D = $Piece
@onready var container: Node2D = $Container
@onready var entry_trigger: EntryTrigger = $EntryTrigger

# Borders
@onready var border_top: Node2D = $BorderT
@onready var border_top_right: Node2D = $BorderTR
@onready var border_top_left: Node2D = $BorderTL
@onready var border_bottom: Node2D = $BorderB
@onready var border_bottom_right: Node2D = $BorderBR
@onready var border_bottom_left: Node2D = $BorderBL
@onready var border_right: Node2D = $BorderR
@onready var border_left: Node2D = $BorderL

@export var exit_border_padding: int = 2
@export var grid_size: int = 16
@export var grid_matrix_size: int = 5
@export var exits: Array[Vector2] = [] 

func initialize(size: int, matrix_size: int, exits_arr: Array[Vector2]) -> void:
	grid_size = size
	grid_matrix_size = matrix_size
	exits = exits_arr
	draw_grid()

func _ready() -> void:
	draw_grid()

func draw_grid() -> void:
	container.get_children().map(func(child: Node2D) -> void:
		child.queue_free()
	)

	for x in range(grid_matrix_size):
		for y in range(grid_matrix_size):
			draw_border(x, y)

			if x == 0 or x == grid_matrix_size - 1 or y == 0 or y == grid_matrix_size - 1:
				continue

			var piece_instance: Sprite2D = piece.duplicate() as Sprite2D
			piece_instance.position = Vector2(x * grid_size, y * grid_size)
			piece_instance.visible = true
			container.add_child(piece_instance)	

	entry_trigger.resize_self(
		Vector2(exit_border_padding, exit_border_padding),
		Vector2(grid_matrix_size * grid_size - exit_border_padding, grid_matrix_size * grid_size - exit_border_padding)
	)


func draw_border(x: int, y: int) -> void:
	var is_exit: bool = exits.has(Vector2(x, y))
	if is_exit:
		return

	var node: Node2D = null
	if x == 0 and y == 0:
		node = border_top_left
	elif x == 0 and y == grid_matrix_size - 1:
		node = border_bottom_left
	elif x == grid_matrix_size - 1 and y == 0:
		node = border_top_right
	elif x == grid_matrix_size - 1 and y == grid_matrix_size - 1:
		node = border_bottom_right
	elif x == 0:
		node = border_left
	elif x == grid_matrix_size - 1:
		node = border_right
	elif y == 0:
		node = border_top
	elif y == grid_matrix_size - 1:
		node = border_bottom

	if node == null:
		return
	
	var border_instance: Node2D = node.duplicate() as Node2D
	border_instance.position = Vector2(x * grid_size, y * grid_size)
	border_instance.visible = true
	container.add_child(border_instance)
