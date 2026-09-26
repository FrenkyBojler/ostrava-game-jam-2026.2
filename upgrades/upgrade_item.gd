class_name UpgradeItem extends Control

@export var item_spacing: float = 32

@onready var title: Label = $MarginContainer/VBoxContainer/Title
@onready var price: Label = $MarginContainer/VBoxContainer/Price
@onready var effects: RichTextLabel = $MarginContainer/VBoxContainer/Effects
@onready var levels_container: Control = $MarginContainer/VBoxContainer/ActiveLevels
@onready var disabled_panel: Panel = $DisabledPanel

# Connectors
@onready var top_connector: MarginContainer = $Connectors/Top
@onready var right_connector: MarginContainer = $Connectors/Right
@onready var bottom_connector: MarginContainer = $Connectors/Bot
@onready var left_connector: MarginContainer = $Connectors/Left

# Children
@onready var children_container: Control = $ChildrenContainer

const upgrade_item = preload("res://upgrades/upgrade_item.tscn")

var upgrade_data: Upgrades.UpgradeItemDTO

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	Globals.upgrade_bought.connect(_on_upgrade_bought)

func initialize(start_position: Vector2, upgrade_data: Upgrades.UpgradeItemDTO) -> void:
	self.upgrade_data = upgrade_data
	position = start_position

	draw_item()

func draw_item() -> void:
	title.text = upgrade_data.title
	price.text = "$" + str(upgrade_data.get_next_level_price())
	effects.text = upgrade_data.description

	if upgrade_data.is_max_level():
		price.text = "MAX"

	var i := 0
	for item: TextureRect in levels_container.get_children():
		if i > upgrade_data.upgrades.size() - 1:
			item.visible = false

		if i < upgrade_data.active_level:
			item.self_modulate = Color.YELLOW
		else:
			item.self_modulate = Color.WHITE

		i += 1

	if upgrade_data.active_level > 0:
		spawn_children()

func spawn_children() -> void:
	if children_container.get_child_count() > 0:
		return

	if upgrade_data.left:
		spawn_child(Vector2.LEFT, upgrade_data.left)
		left_connector.visible = true
	if upgrade_data.right:
		spawn_child(Vector2.RIGHT, upgrade_data.right)
		if upgrade_data.right.offset == 0:
			right_connector.visible = true
	if upgrade_data.top:
		spawn_child(Vector2.UP, upgrade_data.top)
		top_connector.visible = true
	if upgrade_data.bottom:
		spawn_child(Vector2.DOWN, upgrade_data.bottom)
		bottom_connector.visible = true

func spawn_child(direction: Vector2, child_data: Upgrades.UpgradeItemDTO) -> void:
	var position: Vector2 = direction * (size.x + item_spacing)
	if child_data.offset:
		position += direction * (child_data.offset * (size.x + item_spacing))

	var upgrade_child: UpgradeItem = upgrade_item.instantiate() as UpgradeItem
	children_container.add_child(upgrade_child)
	upgrade_child.initialize(position, child_data)

	if upgrade_data.active_level > 0:
		upgrade_child.enable()

func enable() -> void:
	disabled_panel.visible = false

## Bounding rect (relative to this item's own top-left) covering this item and all spawned children.
func get_subtree_rect() -> Rect2:
	var rect := Rect2(Vector2.ZERO, size)
	for child: UpgradeItem in children_container.get_children():
		var child_rect: Rect2 = child.get_subtree_rect()
		child_rect.position += child.position
		rect = rect.merge(child_rect)
	return rect

func find_item(id: String) -> UpgradeItem:
	if upgrade_data.id == id:
		return self
	for child: UpgradeItem in children_container.get_children():
		var found: UpgradeItem = child.find_item(id)
		if found:
			return found
	return null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Globals.buy_upgrade(upgrade_data.id)

func _on_upgrade_bought(upgrade: Upgrades.UpgradeItemDTO) -> void:
	if upgrade_data.id == upgrade.id:
		upgrade_data = upgrade
		draw_item()
