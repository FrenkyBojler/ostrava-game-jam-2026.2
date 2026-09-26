extends StaticBody2D

@export
var tetris: TetrisGrid
@onready var label = $Control/Label

var can_interact := true

func _ready() -> void:
	assert(tetris != null, "Missing tetris")
	label.visible = false
	
	$Area2D.body_entered.connect(func(body):
		if body is Maro3D:
			can_interact = true
			label.visible = true
	)
	
	$Area2D.body_exited.connect(func(body):
		if body is Maro3D:
			can_interact = false
			label.visible = false
	)

func _process(delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact_p1"):
		tetris.scrap_triggered()
