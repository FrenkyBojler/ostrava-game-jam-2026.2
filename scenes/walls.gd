class_name Walls extends Sprite2D

@onready var image := texture.get_image()

func _ready() -> void:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)

	var polygons := bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))
	var static_body := StaticBody2D.new()

	var body_offset := offset
	if centered:
		body_offset -= Vector2(image.get_size()) / 2.0
	static_body.position = body_offset

	add_child(static_body)

	for polygon in polygons:
		if polygon.size() < 3:
			continue
		var collider := CollisionPolygon2D.new()
		collider.polygon = polygon
		collider.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
		static_body.add_child(collider)
