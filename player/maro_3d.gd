class_name Maro3D extends CharacterBody2D

@export var item: ItemResource
@onready var interact_area: Area2D = %InteractArea

@onready var sprite: Sprite2D = %Sprite
@onready var item_position_right: Node2D = %ItemPositionRight
@onready var item_position_left: Node2D = %ItemPositionLeft

var space_controller: MaroSpaceController = MaroSpaceController.new()
var tetris_controller: TetrisController = TetrisController.new()

var controller: MaroController = space_controller

var item_to_pick: Item
var picked_item: Item

var last_dir := Direction.Right

enum Direction {
	Left, Right
}

func _ready() -> void:
	controller = space_controller
	interact_area.body_entered.connect(_on_interact_area_enter)
	interact_area.body_exited.connect(_on_interact_area_exit)

func _process(delta: float) -> void:
	var movement_input: Vector2 = controller.get_movement_input(delta)
	
	if movement_input.x < 0:
		last_dir = Direction.Left
	else:
		last_dir = Direction.Right

	_handle_direction_change()
	move_and_collide(movement_input)

	if Input.is_action_just_pressed("interact_p1"):
		if item_to_pick == null and picked_item != null:
			_drop_item()
		elif item_to_pick != null and picked_item != null:
			_drop_item()
			_pick_item()
		else:
			_pick_item()

func _handle_direction_change() -> void:
	sprite.flip_h = last_dir == Direction.Left
	if picked_item != null:
		picked_item.position = item_position_left.position if last_dir == Direction.Left else item_position_right.position

func _pick_item() -> void:
	picked_item = item_to_pick
	picked_item.get_picked_up()
	picked_item.reparent(self)
	_handle_direction_change()
	item_to_pick = null

func _drop_item() -> void:
	picked_item.reparent(get_parent())
	picked_item.get_dropped()
	picked_item = null

func _on_interact_area_enter(body: Node2D) -> void:
	if body is Item and (body as Item) != picked_item:
		(body as Item).toggle_outline(true)
		item_to_pick = body

func _on_interact_area_exit(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(false)
		item_to_pick = null

func to_tetris(entry_pos: Vector2) -> void:
	controller = tetris_controller
	position = entry_pos

func to_space() -> void:
	controller = space_controller
