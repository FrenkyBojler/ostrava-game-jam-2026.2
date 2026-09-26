extends StaticBody2D

@export var state: SpaceGameState
@onready var label: Label = $Control/Label
@onready var light: PointLight2D = $PointLight2D

var can_interact := false
var maros: Maro3D
var is_embarking := false

func _ready() -> void:
	assert(state != null, "Missing state")
	label.visible = false
	light.visible = false

	$Area2D.body_entered.connect(func(body):
		if body is Maro3D:
			maros = body
			can_interact = true
			label.visible = true
			light.visible = true
	)
	
	$Area2D.body_exited.connect(func(body):
		if body is Maro3D:
			if is_embarking:
				return

			maros = null
			can_interact = false
			label.visible = false
			light.visible = false
	)

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact_p1"):
		space_ship_embark()

func space_ship_embark() -> void:
	state.starting_to_embark = true
	label.visible = false
	light.visible = true
	can_interact = false
	is_embarking = true
	maros.hide()

	# tweens for animating the ship taking off
	var start_position := position
	var tween := get_tree().create_tween()

	# shake the ship slightly before takeoff, always returning to its start position
	const SHAKE_STRENGTH := 6.0
	const SHAKE_COUNT := 10
	for i in SHAKE_COUNT:
		var shake_offset := Vector2(randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH), randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH))
		tween.tween_property(self, "position", start_position + shake_offset, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_position, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# takeoff: move the ship upwards, gradually accelerating
	tween.tween_property(self, "position:y", position.y - 400, 2).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
	state.evacuate()
