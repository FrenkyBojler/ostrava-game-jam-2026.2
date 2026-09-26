class_name Item extends StaticBody2D

const collision_shape := preload("res://items/collision_shape_rect_64.tres")
const outline_material := preload("res://resources/outline_shader_mat.tres")
const item_cell_highlight = preload("res://items/item_cell_highlight.tscn")

const CELL_SIZE := 16
const OUTLINE_WIDTH := 10.0

@export
var item_resource: ItemResource

var image : Sprite2D

var colliders: Array[CollisionShape2D] = []
var coords: Array[Vector2]
var cell_highlights: Dictionary[Vector2, ItemCellHighlight] = {}

func _ready() -> void:
	image = _find_image()
	assert(image != null, "Missing image")
	
	_add_outline_shader()
	_add_collision_shapes()
	
	coords = FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	
func toggle_highlight(coord: Vector2, value: bool) -> void:
	image.visible = false
	cell_highlights[coord].toggle_highlight(value)

func _add_collision_shapes() -> void:
	var coords := FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	for coord: Vector2 in coords:
		var collision_shape_2d := CollisionShape2D.new()
		collision_shape_2d.name = "collider_" + str(coord)
		collision_shape_2d.shape = collision_shape
		
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
	
func _get_item_first_cell_coord() -> Vector2:
	var coords := FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	var leftest_topest_coord := coords[0]
	for coord in coords:
		if coord.length() < leftest_topest_coord.length():
			leftest_topest_coord = coord
		elif coord.length() == leftest_topest_coord.length() and coord.x < leftest_topest_coord.x:
			leftest_topest_coord = coord
	return leftest_topest_coord

func _get_item_last_cell_coord() -> Vector2:
	var coords := FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	var leftest_topest_coord := coords[0]
	for coord in coords:
		if coord.length() > leftest_topest_coord.length():
			leftest_topest_coord = coord
		elif coord.length() == leftest_topest_coord.length() and coord.x > leftest_topest_coord.x:
			leftest_topest_coord = coord
	return leftest_topest_coord

func get_item_first_cell_position_offset(is_left: bool) -> Vector2:
	var offset = Vector2(1, 1) - (_get_item_first_cell_coord() if not is_left else _get_item_last_cell_coord())
	return offset * CELL_SIZE
	
func get_coords_adjusted_by_first_cell() -> Array[Vector2]:
	return coords.map(get_coord_adjusted_by_first_cell)
	
func get_coord_adjusted_by_first_cell(coord: Vector2) -> Vector2:
	return coord - _get_item_first_cell_coord()
