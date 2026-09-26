extends CanvasLayer

@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel
@onready var start_game_btn: Button = $BottomContainer/StartGame

func _ready() -> void:
	Globals.upgrade_bought.connect(_on_upgrade_bought)
	start_game_btn.pressed.connect(_on_start_game_pressed)
	money_label.text = str(Globals.peniazky)

func _on_upgrade_bought(_upgrade) -> void:
	money_label.text = str(Globals.peniazky)

func _on_start_game_pressed() -> void:
	Globals.start_game()
