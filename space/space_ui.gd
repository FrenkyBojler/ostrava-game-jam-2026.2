extends CanvasLayer


@export var state: SpaceGameState

@onready var oxygen_label: Label = $Topbar/VBoxContainer/HBoxContainer/OxygenLabel
@onready var money_label: Label = $Topbar/VBoxContainer/HBoxContainer2/MoneyLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.on_game_state_changed.connect(_on_game_state_changed)

	if Globals.current_game_state == Globals.GameState.Running:
		show()
	else:
		hide()

func _on_game_state_changed(new_game_state: Globals.GameState) -> void:
	if new_game_state == Globals.GameState.Running:
		show()
	else:
		hide()

func _process(_delta: float) -> void:
	oxygen_label.text = str(round(state.oxygen_level))
	money_label.text = str(state.current_run_peniazky)
