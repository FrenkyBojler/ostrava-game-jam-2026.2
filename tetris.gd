extends Node2D

@export var grid_size: int = 16
@export var grid_matrix_size: int = 5
@export var exits: Array[Vector2] = []

@onready var tetris_character: TetrisCharacter = $TetrisCharacter
@onready var tetris_grid: TetrisGrid = $TetrisGrid

func _ready() -> void:
    tetris_character.initialize(grid_size)
    tetris_grid.initialize(grid_size, grid_matrix_size, exits)