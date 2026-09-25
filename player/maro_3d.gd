class_name Maro3D extends CharacterBody2D

@export var item: ItemResource
@onready var interact_area: Area2D = %InteractArea

var space_controller: MaroSpaceController = MaroSpaceController.new()
var tetris_controller: TetrisController = TetrisController.new()

var controller: MaroController = space_controller

func _ready() -> void:
	controller = space_controller
	interact_area.body_entered.connect(_on_interact_area_enter)
	interact_area.body_exited.connect(_on_interact_area_exit)

func _process(delta: float) -> void:
	var movement_input: Vector2 = controller.get_movement_input(delta)
	move_and_collide(movement_input)

func _on_interact_area_enter(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(true)

func _on_interact_area_exit(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(false)

func to_tetris(entry_pos: Vector2) -> void:
	controller = tetris_controller
	position = entry_pos

func to_space() -> void:
	controller = space_controller
