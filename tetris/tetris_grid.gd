class_name TetrisGrid extends Node2D

@export
var game_state: SpaceGameState

@onready var piece: Sprite2D = $Piece
@onready var container: Node2D = $Container
@onready var entry_trigger: EntryTrigger = $EntryTrigger
@onready var entry_collider: EntryCollider = $EntryCollider

# Borders
@onready var border_top: Node2D = $BorderT
@onready var border_top_right: Node2D = $BorderTR
@onready var border_top_left: Node2D = $BorderTL
@onready var border_bottom: Node2D = $BorderB
@onready var border_bottom_right: Node2D = $BorderBR
@onready var border_bottom_left: Node2D = $BorderBL
@onready var border_right: Node2D = $BorderR
@onready var border_left: Node2D = $BorderL


@export var exit_border_padding: int = 12
@export var grid_size: int = 50
@export var grid_matrix_size: int = 5
@export var exits: Array[Vector2] = [] 

var entry_points: Array[Vector2] = []

var pieces: Dictionary[Vector2, Piece] = {}
var items_placed: Array[Item] = []

var maro: Maro3D

var combined_items_value := 0.0

func _ready() -> void:
	assert(game_state != null, "Missing Game State")
	grid_matrix_size = int(Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.GRID_SIZE) + 2)

	entry_trigger.area_entered.connect(_on_body_entered)
	entry_trigger.area_exited.connect(_on_body_exited)
	draw_grid()
	
func scrap_triggered() -> void:
	var value := 0.0
	var size_collected := 0

	for item: Item in items_placed:
		value += item.item_resource.value
		size_collected += item.get_size()
		item.queue_free()
	items_placed = []
	for piece in pieces.values():
		piece.occuppied = false
		
	game_state.add_peniazky(value * float(Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.SCRAP_VALUE)))
	var bonus_oxygen: float = size_collected * float(Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.OXYGEN_BONUS_PER_SCRAP))
	game_state.add_oxygen(bonus_oxygen)
	game_state.add_peniazky(combined_items_value * float(Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.MULTI_PARTS_SCRAPS)))
	combined_items_value = 0.0

func draw_grid() -> void:
	container.get_children().map(func(child: Node2D) -> void:
		child.queue_free()
	)

	for x in range(grid_matrix_size):
		for y in range(grid_matrix_size):
			#draw_border(x, y)

			if x == 0 or x == grid_matrix_size - 1 or y == 0 or y == grid_matrix_size - 1:
				continue

			var piece_instance: Piece = piece.duplicate() as Piece
			piece_instance.initialize(Vector2(x, y), grid_size)
			pieces[piece_instance.grid_position] = piece_instance
			container.add_child(piece_instance)

	var half_grid_size: int = grid_size / 2.0
	entry_trigger.resize_self(
		(grid_size * (grid_matrix_size - 2)) - exit_border_padding,
		grid_size + exit_border_padding
	)
	entry_collider.resize_self(
		(grid_size * (grid_matrix_size - 2)) - exit_border_padding,
		grid_size + exit_border_padding
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
	
func start_placing_item(item: Item) -> void:
	item.reparent(self)
	item.position = pieces[Vector2((grid_matrix_size - 2) / 2, (grid_matrix_size - 2) / 2)].position + item.get_item_first_cell_position_offset(false)
	item.start_placing(self, pieces[Vector2((grid_matrix_size - 2) / 2, (grid_matrix_size - 2) / 2)].grid_position)

func _on_body_entered(body: Area2D) -> void:
	if body.get_parent() is Maro3D:
		maro = body.get_parent() as Maro3D

		var nearest_piece = get_nearest_piece(maro.position)
		if nearest_piece != null:
			maro.to_tetris(nearest_piece.global_position, self)
			
func get_nearest_piece(position: Vector2) -> Piece:
	# Find nearest piece from container to maro's position
	var nearest_piece: Piece = null
	var nearest_distance: float = INF
	for child in container.get_children():
		if child is Piece:
			var child_piece: Piece = child as Piece
			var distance: float = position.distance_to(child_piece.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_piece = child_piece

	return nearest_piece

func toggle_highlight_all_pieces(value: bool) -> void:
	for piece in pieces.values():
		piece.toggle_highlight(value) 

func _on_body_exited(body: Node) -> void:
	if body.get_parent() is Maro3D:
		maro.to_space()
		
func is_inside(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.x < grid_matrix_size - 2 and coord.y >= 0 and coord.y < grid_matrix_size -2

func check_place_item(item: Item, at_position: Vector2) -> bool:
	if is_inside(at_position):
		toggle_highlight_all_pieces(false)
		pieces[at_position].toggle_highlight(true)
	var result = true
	var highlight_state: Dictionary[Vector2, bool] = {}
	for coord in item.get_coords():
		var coord_adjusted = item.get_coord_adjusted_by_first_cell(coord).rotated_coord + at_position
		if not is_inside(coord_adjusted):
			highlight_state[coord.rotated_coord] = false
			result = false
			continue
		highlight_state[coord.rotated_coord] = not pieces[coord_adjusted].occuppied
		if pieces[coord_adjusted].occuppied:
			result = false
			continue
	item.toggle_highlight(highlight_state)
	return result
	
func place_item(item: Item, at_position: Vector2) -> void:
	items_placed.push_back(item)
	item.has_been_placed = true

	maro.picked_item = null
	item.turn_off_highlight()
	item.is_being_placed = false
	
	for coord in item.get_coords_adjusted_by_first_cell():
		var coord_adjusted := coord.rotated_coord + at_position
		pieces[coord_adjusted].toggle_occupy(true)

	toggle_highlight_all_pieces(false)
	await get_tree().create_timer(0.1).timeout
	maro.is_in_tetris = false
	
	check_combinations()
	
func check_combinations() -> void:
	for item in items_placed:
		if item.item_resource.has_output:
			var rotated_output_coord := item.get_rotated_output()
			var target_output_coord := item.get_coord_adjusted_by_first_cell(rotated_output_coord).rotated_coord + item.current_grid_position_of_first_cell
			pieces[target_output_coord].toggle_highlight(true)
			
			var target_input_item_index := items_placed.find_custom(func(item_to_find: Item):
					return item_to_find.item_resource.id == item.item_resource.linked_item_id
			)
			
			if target_input_item_index != -1:
				var target_input_item := items_placed[target_input_item_index]
				var target_input_coord := target_input_item.get_coord_adjusted_by_first_cell(target_input_item.get_rotated_input()).rotated_coord + target_input_item.current_grid_position_of_first_cell
				pieces[target_input_coord].toggle_highlight(true)
				var success := target_input_coord == target_output_coord
				combined_items_value += item.item_resource.value + target_input_item.item_resource.value
			else:
				print_debug("No compatible items placed")
