extends CanvasLayer

@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel

func _ready() -> void:
	Globals.upgrade_bought.connect(_on_upgrade_bought)
	money_label.text = str(Globals.peniazky)

func _on_upgrade_bought(_upgrade) -> void:
	money_label.text = str(Globals.peniazky)
