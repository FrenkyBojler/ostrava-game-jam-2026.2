class_name Walls extends Sprite2D

@onready var image := texture.get_image()

func _ready() -> void:
	# Put this sprite on its own light layer (bit 2) so it can still be lit
	# normally, while excluding that layer from the light's shadow test —
	# otherwise the wall permanently self-shadows against its own occluders.
	light_mask = 1 << 1

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)

	var polygons := bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))

	# Bitmap coords are always top-left origin; Sprite2D may draw centered
	# and/or with its own `offset` property, so compensate for both.
	var body_offset := offset
	if centered:
		body_offset -= Vector2(image.get_size()) / 2.0

	var static_body := StaticBody2D.new()
	static_body.position = body_offset
	add_child(static_body)

	var occluders := Node2D.new()
	occluders.position = body_offset
	add_child(occluders)

	for polygon in polygons:
		if polygon.size() < 3:
			continue

		var collider := CollisionPolygon2D.new()
		collider.polygon = polygon
		collider.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
		static_body.add_child(collider)

		var occluder_polygon := OccluderPolygon2D.new()
		occluder_polygon.polygon = polygon
		occluder_polygon.closed = true

		var occluder := LightOccluder2D.new()
		occluder.occluder = occluder_polygon
		occluders.add_child(occluder)
