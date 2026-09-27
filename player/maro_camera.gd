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

const BG_HALF_WIDTH := 5308.0 / 2.0   # 2654
const BG_HALF_HEIGHT := 3296.0 / 2.0  # 1648

func _ready() -> void:
	assert(target != null, "Missing target!")
	offset = global_position - target.global_position

	limit_left = -BG_HALF_WIDTH
	limit_right = BG_HALF_WIDTH
	limit_top = -BG_HALF_HEIGHT
	limit_bottom = BG_HALF_HEIGHT

	top_level = true

func _process(delta: float) -> void:
	global_position = lerp(global_position, Vector2(target.global_position.x + offset_x, target.global_position.y + offset_y), follow_speed * delta)
	
