extends ScrollContainer

@onready var content: Control = $FlowContainer

const upgrade_item = preload("res://upgrades/upgrade_item.tscn")

var item_instance: UpgradeItem

func _ready() -> void:
	Globals.upgrade_bought.connect(_on_upgrade_bought)
	draw_upgrades()
	_update_scroll_region()

func draw_upgrades() -> void:
	item_instance = upgrade_item.instantiate() as UpgradeItem
	content.add_child(item_instance)
	item_instance.initialize(Vector2.ZERO, Globals.upgrades.item)
	item_instance.enable()

func _on_upgrade_bought(_upgrade: Upgrades.UpgradeItemDTO) -> void:
	# Wait for the newly spawned children to be added and laid out before measuring bounds.
	await get_tree().process_frame
	await get_tree().process_frame

	var delta: Vector2 = _update_scroll_region()

	# The scroll range only updates after the content's new min size is laid out.
	await get_tree().process_frame
	scroll_horizontal += int(delta.x)
	scroll_vertical += int(delta.y)

func _update_scroll_region() -> Vector2:
	var subtree_rect: Rect2 = item_instance.get_subtree_rect()
	var full_rect := Rect2(item_instance.position + subtree_rect.position, subtree_rect.size)

	# Shift everything so the bounding box starts at (0, 0), then size the content to match.
	var delta: Vector2 = -full_rect.position
	item_instance.position += delta
	content.custom_minimum_size = full_rect.size
	return delta					
