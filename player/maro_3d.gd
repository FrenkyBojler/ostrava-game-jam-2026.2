extends CharacterBody2D

@export
var move_speed := 100.0
@export
var item: ItemResource

@onready
var interact_area := %InteractArea

func _ready() -> void:
	interact_area.body_entered.connect(_on_interact_area_enter)
	interact_area.body_exited.connect(_on_interact_area_exit)

func _process(delta: float) -> void:
	var horizontal_input := Input.get_axis("move_left_p1", "move_right_p1")
	var vertical_input := Input.get_axis("move_up_p1", "move_down_p1")
	
	move_and_collide(Vector2(horizontal_input, vertical_input) * move_speed * delta)

func _on_interact_area_enter(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(true)

func _on_interact_area_exit(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(false)
