extends StaticBody2D

@export var tetris: TetrisGrid
@export var cooldown_time := 1.0

@onready var label = $Control/Label

var can_interact := false
var number_of_interactions := 0
var max_interactions := 0
var cooldown := 0

func _ready() -> void:
	assert(tetris != null, "Missing tetris")
	label.visible = false

	max_interactions = int(Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.SCRAPPER_USES))
	
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
	if cooldown > 0:
		cooldown -= delta
		return

	if number_of_interactions >= max_interactions:
		return

	if can_interact and Input.is_action_just_pressed("interact_p1"):
		tetris.scrap_triggered()
		cooldown = cooldown_time
	
		number_of_interactions += 1

		if number_of_interactions >= max_interactions:
			label.text = "Max interactions reached"
