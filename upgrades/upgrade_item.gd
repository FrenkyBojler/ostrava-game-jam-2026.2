class_name UpgradeItem extends Control

@export var item_spacing: float = 32

@onready var title: Label = $MarginContainer/VBoxContainer/Title
@onready var effects: RichTextLabel = $MarginContainer/VBoxContainer/Effects
@onready var levels_container: Control = $MarginContainer/VBoxContainer/ActiveLevels

const upgrade_item = preload("res://upgrades/upgrade_item.tscn")

func initialize(start_position: Vector2, upgrade_data: Upgrades.UpgradeItemDTO) -> void:
	position = start_position
	title.text = upgrade_data.title
	effects.text = upgrade_data.description

	var i := 0
	for item: TextureRect in levels_container.get_children():
		if i > upgrade_data.upgrades.size() - 1:
			item.visible = false

		if i < upgrade_data.active_level:
			item.self_modulate = Color.YELLOW
		else:
			item.self_modulate = Color.WHITE

		i += 1

	var margin: float = size.x + item_spacing
	if upgrade_data.left:
		spawn_child(Vector2.LEFT * margin, upgrade_data.left)
	if upgrade_data.right:
		spawn_child(Vector2.RIGHT * margin, upgrade_data.right)
	if upgrade_data.top:
		spawn_child(Vector2.UP * margin, upgrade_data.top)
	if upgrade_data.bottom:
		spawn_child(Vector2.DOWN * margin, upgrade_data.bottom)


func spawn_child(spawn_pos: Vector2, upgrade_data: Upgrades.UpgradeItemDTO) -> void:
	var upgrade_child: UpgradeItem = upgrade_item.instantiate() as UpgradeItem
	add_child(upgrade_child)
	upgrade_child.initialize(spawn_pos, upgrade_data)
