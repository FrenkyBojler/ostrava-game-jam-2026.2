class_name EntryCollider extends StaticBody2D

@onready var collision_polygon: CollisionShape2D = $CollisionShape2D

func resize_self(size: float, cell_size: float) -> void:
	(collision_polygon.shape as RectangleShape2D).size = Vector2(size, size)
	collision_polygon.position += Vector2(size / 2, size / 2) + Vector2(cell_size / 2, cell_size / 2)
