extends Area2D

@export
var is_metal := false

func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		if body is Maro3D:
			if is_metal:
				(body as Maro3D).is_na_metalu = true
			else:
				(body as Maro3D).is_na_polu = true
	)
	
	body_exited.connect(func(body: Node2D):
		if body is Maro3D:
			if is_metal:
				(body as Maro3D).is_na_metalu = false
			else:
				(body as Maro3D).is_na_polu = false
	)
