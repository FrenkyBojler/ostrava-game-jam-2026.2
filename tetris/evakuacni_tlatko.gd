extends StaticBody2D

@export var state: SpaceGameState
@onready var label = $Control/Label

var can_interact := false

func _ready() -> void:
	assert(state != null, "Missing state")
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

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact_p1"):
		state.evacuate()
