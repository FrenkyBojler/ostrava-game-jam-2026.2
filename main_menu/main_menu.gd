class_name MainMenu extends CanvasLayer

@onready var play_game_button: Button = $MainMenu/VBoxContainer/PlayGameButton
@onready var restart_game_button: Button = $MainMenu/VBoxContainer/RestartGameButton
@onready var resume_game_button: Button = $MainMenu/VBoxContainer/ResumeGameButton
@onready var exit_game_button: Button = $MainMenu/VBoxContainer/ExitButton

func _ready() -> void:
	play_game_button.connect("pressed", _play_game)
	exit_game_button.connect("pressed", _exit_game)
	restart_game_button.connect("pressed", _restart_game)
	resume_game_button.connect("pressed", _resume_game)

	
	restart_game_button.visible = false
	resume_game_button.visible = false
	
	if Globals.current_game_state == Globals.GameState.Exited:
		play_game_button.visible = true
		resume_game_button.visible = false
		restart_game_button.visible = false
	elif Globals.current_game_state == Globals.GameState.Paused:
		play_game_button.visible = false
		resume_game_button.visible = true
		restart_game_button.visible = true

	if Globals.current_game_level == Globals.GameLevel.Upgrades:
		play_game_button.visible = true
		resume_game_button.visible = true
		restart_game_button.visible = false

func _play_game() -> void:
	Globals.start_game()

func _restart_game() -> void:
	Globals.restart_game()

func _resume_game() -> void:
	Globals.resume_game()

func _exit_game() -> void:
	get_tree().quit()
