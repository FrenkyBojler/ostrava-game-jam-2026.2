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

var tetris: TetrisGrid
var is_near_tetris: bool = false
var is_in_tetris: bool = false

var can_place_item_into_tetris := false

enum Direction {
	Left, Right
}

func _ready() -> void:
	controller = space_controller
	interact_area.body_entered.connect(_on_interact_area_enter)
	interact_area.body_exited.connect(_on_interact_area_exit)

func _process(delta: float) -> void:
	if is_in_tetris or Globals.current_game_state != Globals.GameState.Running:
		return
		
	if Input.is_action_just_pressed("bail_interact_p1") and is_in_tetris:
		_bail_from_tetris()

	if is_in_tetris:
		return

	var movement_input: Vector2 = controller.get_movement_input(delta)
	
	var prev_dir := last_dir
	
	if movement_input.x < 0:
		last_dir = Direction.Left
	elif movement_input.x > 0:
		last_dir = Direction.Right

	_handle_direction_change()
	
	if not is_in_tetris:
		move_and_collide(movement_input)

	if Input.is_action_just_pressed("interact_p1"):
		if is_near_tetris and picked_item != null:
			is_in_tetris = true
			tetris.start_placing_item(picked_item)
		elif (item_to_pick == null and picked_item != null) or picked_item != null and is_in_tetris:
			_drop_item()
		elif item_to_pick != null and picked_item != null and not is_in_tetris:
			_drop_item()
			_pick_item()
		elif item_to_pick != null and picked_item == null:
			_pick_item()
			
	if Input.is_action_just_pressed("rotate_item_p1") and picked_item != null:
		picked_item.rotate_right()
	
	_handle_tetris_grid()
	
	if picked_item != null and is_in_tetris:
		var current_piece := tetris.get_nearest_piece(position)
		can_place_item_into_tetris = tetris.check_place_item(picked_item, current_piece.grid_position - Vector2.RIGHT * 2 if last_dir == Direction.Left else current_piece.grid_position + Vector2.RIGHT)
	if picked_item != null and not is_in_tetris:
		picked_item.turn_off_highlight()
		can_place_item_into_tetris = false
		
	visible = not is_in_tetris
		
func _handle_tetris_grid() -> void:
	if not is_in_tetris:
		return
	pass
	
func _handle_direction_change() -> void:
	sprite.flip_h = last_dir == Direction.Left
	if picked_item != null:
		picked_item.position = item_position_right.position + picked_item.get_item_first_cell_position_offset(false)
	#if picked_item != null:
	#	var target_pos := item_position_left.position - picked_item.get_item_first_cell_position_offset(true) * -1 if last_dir == Direction.Left else item_position_right.position + picked_item.get_item_first_cell_position_offset(false)
	#	picked_item.position = target_pos

func _pick_item() -> void:
	picked_item = item_to_pick
	picked_item.get_picked_up()
	picked_item.reparent(self)
	_handle_direction_change()
	item_to_pick = null

func _drop_item() -> void:
	if is_in_tetris and can_place_item_into_tetris:
		tetris.place_item(picked_item, tetris.get_nearest_piece(position).grid_position - Vector2.RIGHT if last_dir == Direction.Left else tetris.get_nearest_piece(position).grid_position + Vector2.RIGHT)
	elif is_in_tetris and not can_place_item_into_tetris:
		return

	picked_item.reparent(get_parent())
	picked_item.get_dropped()
	picked_item = null

func _bail_from_tetris() -> void:
	if not is_in_tetris:
		return

	is_near_tetris = false
	picked_item.is_being_placed = false
	picked_item.reparent(self)
	is_in_tetris = false
	tetris.toggle_highlight_all_pieces(false)
	_handle_direction_change()

func _on_interact_area_enter(body: Node2D) -> void:
	if body is Item and (body as Item) != picked_item:
		if not is_in_tetris or (is_in_tetris and picked_item == null):
			(body as Item).toggle_outline(true)
		item_to_pick = body

func _on_interact_area_exit(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(false)
		item_to_pick = null

func to_tetris(entry_pos: Vector2, tetris_grid: TetrisGrid) -> void:
	#controller = tetris_controller
	#position = entry_pos
	tetris = tetris_grid
	is_near_tetris = true

func to_space() -> void:
	controller = space_controller
