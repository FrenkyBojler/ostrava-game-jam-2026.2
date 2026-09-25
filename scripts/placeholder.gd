extends Node2D

func _ready() -> void:
	$Sprite2D/AnimationPlayer.play("Jump")
