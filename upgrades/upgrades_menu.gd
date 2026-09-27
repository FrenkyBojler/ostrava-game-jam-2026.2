extends CanvasLayer

@onready var money_label: Label = $HBoxContainer/Label
@onready var start_game_btn: Button = $BottomContainer/TextureRect/StartGame
@onready var cheat_btn: TextureRect = $HBoxContainer/TextureRect2

func _ready() -> void:
	Globals.upgrade_bought.connect(_on_upgrade_bought)
	start_game_btn.pressed.connect(_on_start_game_pressed)
	money_label.text = str(Globals.peniazky)
	cheat_btn.gui_input.connect(_on_cheat_pressed)

	

func _on_upgrade_bought(_upgrade) -> void:
	money_label.text = str(Globals.peniazky)

func _on_start_game_pressed() -> void:
	Globals.start_game()

func _on_cheat_pressed(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
		
	Globals.add_peniazky(1000)
	money_label.text = str(Globals.peniazky)
