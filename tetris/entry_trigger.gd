class_name EntryTrigger extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

# # draw itself for debugging purposes
# func _draw() -> void:
#     draw_polygon(collision_polygon.polygon, [Color(1, 0, 0, 0.5)])

func resize_self(top_left: Vector2, bottom_right: Vector2) -> void:
	collision_polygon.set_polygon([
		top_left,
		Vector2(bottom_right.x, top_left.y),
		bottom_right,
		Vector2(top_left.x, bottom_right.y)
	])
