class_name ScrapsIndicator extends CanvasLayer

@export var maro: Maro3D

@onready var arrow_base: TextureRect = $ArrowBase

var max_tracked_items: int = 5
var arrow_instances: Array[TextureRect] = []
var items_on_map: Array[Item] = []
var radius: float = 0

var tracked_items: Array[Item] = []
const SCREEN_EDGE_MARGIN := 16


func _ready() -> void:
	assert(maro != null, "Chybí ti Maroš")

	for i in range(max_tracked_items):
		var arrow_instance: TextureRect = arrow_base.duplicate() as TextureRect
		arrow_instances.append(arrow_instance)
		arrow_instance.visible = false
		add_child(arrow_instance)

	radius = Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.SCRAP_REVEAL_RADIUS)

	Globals.on_game_state_changed.connect(_on_game_state_changed)

	if Globals.current_game_state == Globals.GameState.Running:
		show()
	else:
		hide()

func set_items_on_map(items: Array[Item]) -> void:
	items_on_map = items

func _process(_delta: float) -> void:
	# get items in radius and sort them by distance to maro
	tracked_items = items_on_map.filter(func(item: Item) -> bool:
		return maro.global_transform.origin.distance_to(item.global_transform.origin) <= radius
	)

	tracked_items.sort_custom(_sort_items_by_distance)

	var viewport_rect := get_viewport().get_visible_rect()
	var edge_rect := viewport_rect.grow(-SCREEN_EDGE_MARGIN)

	var i: int = 0
	for item in tracked_items:
		if i >= arrow_instances.size():
			break

		# Update arrow position and rotation based on the item's position relative to maro
		var maro_screen_position: Vector2 = maro.get_global_transform_with_canvas().origin
		var item_screen_position: Vector2 = item.get_global_transform_with_canvas().origin
		if viewport_rect.has_point(item_screen_position):
			continue

		arrow_instances[i].visible = true
		var direction: Vector2 = (item_screen_position - maro_screen_position).normalized()
		var edge_position: Vector2 = maro_screen_position

		if direction != Vector2.ZERO:
			var distances := [
				(edge_rect.position.x - maro_screen_position.x) / direction.x if direction.x < 0 else INF,
				(edge_rect.end.x - maro_screen_position.x) / direction.x if direction.x > 0 else INF,
				(edge_rect.position.y - maro_screen_position.y) / direction.y if direction.y < 0 else INF,
				(edge_rect.end.y - maro_screen_position.y) / direction.y if direction.y > 0 else INF,
			]
			edge_position += direction * distances.min()

		arrow_instances[i].position = edge_position
		arrow_instances[i].rotation = direction.angle() + PI / 2.0

		i += 1

	# Hide unused arrow instances
	for j in range(i, arrow_instances.size()):
		arrow_instances[j].visible = false
	
func _sort_items_by_distance(a: Item, b: Item) -> int:
	var dist_a: float = maro.global_transform.origin.distance_to(a.global_transform.origin)
	var dist_b: float = maro.global_transform.origin.distance_to(b.global_transform.origin)

	if dist_a < dist_b:
		return -1
	elif dist_a > dist_b:
		return 1
	else:
		return 0

func _on_game_state_changed(new_game_state: Globals.GameState) -> void:
	if new_game_state == Globals.GameState.Running:
		show()
	else:
		hide()
