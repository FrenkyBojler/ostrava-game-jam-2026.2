extends Camera2D

@export
var target: Node2D
@export
var follow_speed: float = 10.0

var offset_x: float
var offset_y: float

var min_y := -1104.794
var max_y := 1090.448

var min_x := -1667.455
var max_x := 1678.668

func _ready() -> void:
	assert(target != null, "Missing target!")
	offset_x = global_position.x - target.global_position.x
	offset_y = global_position.y - target.global_position.y
	
	top_level = true

func _process(delta: float) -> void:
	global_position = lerp(global_position, Vector2(target.global_position.x + offset_x, target.global_position.y + offset_y), follow_speed * delta)
	
	if global_position.y < min_y:
		global_position.y = min_y
	if global_position.y > max_y:
		global_position.y = max_y
	if global_position.x > max_x:
		global_position.x = max_x
	if global_position.x < min_x:
		global_position.x = min_x
