class_name Item extends StaticBody2D

const collision_shape := preload("res://items/collision_shape_rect_64.tres")
const outline_material := preload("res://resources/outline_shader_mat.tres")
const item_cell_highlight = preload("res://items/item_cell_highlight.tscn")

const CELL_SIZE := 50
const OUTLINE_WIDTH := 5.0

const BASE_CELL_WEIGHT = 1.0

@export
var item_resource: ItemResource

var image : Sprite2D

var colliders: Array[CollisionShape2D] = []
var original_coords: Array[Vector2]
var cell_highlights: Dictionary[Vector2, ItemCellHighlight] = {}

# number of rotations applied to the right e.g: 2 would mean twice to the right, -1 would mean once to the left
var rotations_applied := 0

var is_being_placed := false

var tetris: TetrisGrid
var current_grid_position_of_first_cell: Vector2

func _ready() -> void:
	image = _find_image()
	assert(image != null, "Missing image")
	
	_add_outline_shader()
	_add_collision_shapes()
	
	original_coords = FlagsGridUtils.get_set_coords(item_resource.colliders, 3)

func _process(delta: float) -> void:
	if Globals.current_game_state != Globals.GameState.Running:
		return
	#image.visible = not is_being_placed
	if is_being_placed:
		var target_pos: Vector2
		var target_grid_pos: Vector2 = Vector2(-1000, -1000)
		if Input.is_action_just_pressed("move_left_p1"):
			target_pos = Vector2.LEFT * CELL_SIZE
			target_grid_pos = current_grid_position_of_first_cell + Vector2.LEFT
		elif Input.is_action_just_pressed("move_right_p1"):
			target_pos = Vector2.RIGHT * CELL_SIZE
			target_grid_pos = current_grid_position_of_first_cell + Vector2.RIGHT
		elif Input.is_action_just_pressed("move_up_p1"):
			target_pos = Vector2.UP * CELL_SIZE
			target_grid_pos = current_grid_position_of_first_cell + Vector2.UP
		elif Input.is_action_just_pressed("move_down_p1"):
			target_pos = Vector2.DOWN * CELL_SIZE
			target_grid_pos = current_grid_position_of_first_cell + Vector2.DOWN
		elif Input.is_action_just_pressed("rotate_item_p1"):
			rotate_right()
			position = tetris.pieces[current_grid_position_of_first_cell].position + get_item_first_cell_position_offset(false)
		
		if target_grid_pos != Vector2(-1000, -1000):
			var result := true
			for coord in get_coords():
				var coord_adjusted := get_coord_adjusted_by_first_cell(coord).rotated_coord + target_grid_pos
				if not tetris.is_inside(coord_adjusted):
					result = false

			if result:
				position += target_pos
				current_grid_position_of_first_cell = target_grid_pos

		var can_place := tetris.check_place_item(self, current_grid_position_of_first_cell)
		
		if can_place and Input.is_action_just_pressed("interact_p1"):
			tetris.place_item(self, current_grid_position_of_first_cell)

func get_weight() -> float:
	return original_coords.size() * BASE_CELL_WEIGHT

func start_placing(tetris: TetrisGrid, start_position: Vector2) -> void:
	self.tetris = tetris
	current_grid_position_of_first_cell = start_position
	is_being_placed = true

func toggle_highlight(highlight_state: Dictionary[Vector2, bool]) -> void:
	for highlight: Node2D in cell_highlights.values():
		highlight.queue_free()
	cell_highlights = {}
	
	for item_coord in get_coords():
		var cell_highlight_instance = item_cell_highlight.instantiate() as ItemCellHighlight
		add_child(cell_highlight_instance)
		cell_highlight_instance.position = Vector2(item_coord.rotated_coord.x * CELL_SIZE - CELL_SIZE,item_coord.rotated_coord.y * CELL_SIZE - CELL_SIZE)
		cell_highlights[item_coord.rotated_coord] = cell_highlight_instance
		cell_highlight_instance.toggle_highlight(highlight_state[item_coord.rotated_coord])

func _add_collision_shapes() -> void:
	var coords := FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	for coord: Vector2 in coords:
		var collision_shape_2d := CollisionShape2D.new()
		collision_shape_2d.name = "collider_" + str(coord)
		collision_shape_2d.shape = collision_shape
		
		set_collision_layer_value(1, 4)
		set_collision_mask_value(1, 4)
		
		add_child(collision_shape_2d)
		collision_shape_2d.position = Vector2(coord.x * CELL_SIZE - CELL_SIZE, coord.y * CELL_SIZE - CELL_SIZE)
		colliders.push_back(collision_shape_2d)
		
		var cell_highlight_instance = item_cell_highlight.instantiate()
		add_child(cell_highlight_instance)
		cell_highlight_instance.position = Vector2(coord.x * CELL_SIZE - CELL_SIZE, coord.y * CELL_SIZE - CELL_SIZE)
		cell_highlights[coord] = cell_highlight_instance

func _find_image() -> Sprite2D:
	for child in get_children():
		if child is Sprite2D:
			return child as Sprite2D
	return null
	
func turn_off_highlight() -> void:
	image.visible = true
	for highlight: ItemCellHighlight in cell_highlights.values():
		highlight.turn_off_highlight()

func _add_outline_shader() -> void:
	var material = outline_material.duplicate() as ShaderMaterial
	image.material = material
	
func toggle_outline(value: bool) -> void:
	(image.material as ShaderMaterial).set_shader_parameter("width", OUTLINE_WIDTH if value else 0.0)
	
func _toggle_colliders(value: bool) -> void:
	for collider in colliders:
		collider.disabled = value

func get_picked_up() -> void:
	toggle_outline(false)
	_toggle_colliders(true)

func get_dropped() -> void:
	await get_tree().create_timer(0.3).timeout
	_toggle_colliders(false)

func get_image() -> Sprite2D:
	return image
	
func _get_item_first_cell_coord() -> GlobalTypesGlobal.ItemCell:
	var coords := get_coords()
	var leftest_topest_coord := coords[0]
	for coord in coords:
		if coord.rotated_coord.length() < leftest_topest_coord.rotated_coord.length():
			leftest_topest_coord = coord
		elif coord.rotated_coord.length() == leftest_topest_coord.rotated_coord.length() and coord.rotated_coord.x < leftest_topest_coord.rotated_coord.x:
			leftest_topest_coord = coord
	return leftest_topest_coord

func _get_item_last_cell_coord() -> GlobalTypesGlobal.ItemCell:
	var coords := get_coords()
	var leftest_topest_coord := coords[0]
	for coord in coords:
		if coord.rotated_coord.length() > leftest_topest_coord.rotated_coord.length():
			leftest_topest_coord = coord
		elif coord.rotated_coord.length() == leftest_topest_coord.rotated_coord.length() and coord.rotated_coord.x > leftest_topest_coord.rotated_coord.x:
			leftest_topest_coord = coord
	return leftest_topest_coord

func get_item_first_cell_position_offset(is_left: bool) -> Vector2:
	var offset = Vector2(1, 1) - (_get_item_first_cell_coord().rotated_coord if not is_left else _get_item_last_cell_coord().rotated_coord)
	return offset * CELL_SIZE
	
func get_coords() -> Array[GlobalTypesGlobal.ItemCell]:
	var coords_mask := item_resource.colliders
	var result_arry: Array[GlobalTypesGlobal.ItemCell] = []
	
	for i: int in abs(rotations_applied):
		if rotations_applied > 0:
			coords_mask = FlagsGridUtils.rotate_mask_cw(coords_mask, 3)
		else:
			coords_mask = FlagsGridUtils.rotate_mask_ccw(coords_mask, 3)
			
	var rotated_coords := FlagsGridUtils.get_set_coords(coords_mask, 3)
	
	for i in len(rotated_coords):
		var item_cell = GlobalTypesGlobal.ItemCell.new()
		item_cell.original_coord = original_coords.get(i)
		item_cell.rotated_coord = rotated_coords.get(i)
		
		result_arry.push_back(item_cell)

	return result_arry

func get_coords_adjusted_by_first_cell() -> Array[GlobalTypesGlobal.ItemCell]:
	return get_coords().map(get_coord_adjusted_by_first_cell)
	
func get_coord_adjusted_by_first_cell(coord: GlobalTypesGlobal.ItemCell) -> GlobalTypesGlobal.ItemCell:
	var result_item_cell := GlobalTypesGlobal.ItemCell.new()
	result_item_cell.original_coord = coord.original_coord - _get_item_first_cell_coord().original_coord
	result_item_cell.rotated_coord = coord.rotated_coord - _get_item_first_cell_coord().rotated_coord
	
	return result_item_cell

func _handle_image_rotation() -> void:
	image.rotation_degrees = 90 * rotations_applied
	
func rotate_right() -> void:
	rotations_applied += 1
	
	if rotations_applied == 4:
		rotations_applied = 0
		
	_handle_image_rotation()
	
func rotate_left() -> void:
	rotations_applied -= 1
	
	if rotations_applied == -4:
		rotations_applied = 0
	
	_handle_image_rotation()
