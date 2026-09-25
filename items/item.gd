class_name Item extends StaticBody2D

const collision_shape := preload("res://items/collision_shape_rect_64.tres")
const outline_material := preload("res://resources/outline_shader_mat.tres")

const CELL_SIZE := 8
const OUTLINE_WIDTH := 10.0

@export
var item_resource: ItemResource

var image : Sprite2D

var colliders: Array[CollisionShape2D] = []

func _ready() -> void:
	image = _find_image()
	assert(image != null, "Missing image")
	
	_add_outline_shader()
	_add_collision_shapes()

func _add_collision_shapes() -> void:
	var coords := FlagsGridUtils.get_set_coords(item_resource.colliders, 3)
	for coord: Vector2 in coords:
		var collision_shape_2d := CollisionShape2D.new()
		set_collision_layer_value(2, true)
		set_collision_mask_value(2, true)
		collision_shape_2d.name = "collider_" + str(coord)
		collision_shape_2d.shape = collision_shape
		
		add_child(collision_shape_2d)
		collision_shape_2d.position = Vector2(coord.x * CELL_SIZE - CELL_SIZE, coord.y * CELL_SIZE - CELL_SIZE)
		colliders.push_back(collision_shape_2d)

func _find_image() -> Sprite2D:
	for child in get_children():
		if child is Sprite2D:
			return child as Sprite2D
	return null

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
