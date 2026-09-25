class_name EntryTrigger extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func resize_self(top_left: Vector2, bottom_right: Vector2) -> void:
    collision_polygon.set_polygon([
        top_left,
        Vector2(bottom_right.x, top_left.y),
        bottom_right,
        Vector2(top_left.x, bottom_right.y)
    ])

func _on_body_entered(body: Node) -> void:
    if body is Maro3D:
        var maro: Maro3D = body as Maro3D
        maro.to_tetris(global_position)

func _on_body_exited(body: Node) -> void:
    if body is Maro3D:
        var maro: Maro3D = body as Maro3D
        maro.to_space()