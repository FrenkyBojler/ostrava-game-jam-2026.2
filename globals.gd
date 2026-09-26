class_name GlobalsGlobal
extends Node

const main_menu = preload("res://main_menu/main_menu.tscn")
const upgrades_menu = preload("res://upgrades/upgrades_menu.tscn")

signal upgrade_bought(upgrade: Upgrades.UpgradeItemDTO)
signal on_game_state_changed(state: GameState)
signal on_game_level_changed(level: GameLevel)

var upgrades: Upgrades.UpgradesContainer = Upgrades.UpgradesContainer.new()
var peniazky: int = 0

var current_game_state := GameState.Exited 
var current_game_level := GameLevel.Level1

var main_menu_instance: MainMenu
var upgrades_menu_instance: CanvasLayer

enum GameState {
	Running,
	Upgrades,
	Exited,
	Paused,
}

enum GameLevel {
	Level1,
	Upgrades,	
}

func _ready() -> void:
	load_upgrades()
	reset()
	add_menu()

func add_menu() -> void:
	main_menu_instance = main_menu.instantiate()
	get_tree().root.add_child.call_deferred(main_menu_instance)

func remove_menu() -> void:
	main_menu_instance.queue_free()
	main_menu_instance = null

func add_upgrades_menu() -> void:
	upgrades_menu_instance = upgrades_menu.instantiate()
	get_tree().root.add_child.call_deferred(upgrades_menu_instance)

func remove_upgrades_menu() -> void:
	if upgrades_menu_instance != null:
		upgrades_menu_instance.queue_free()
		upgrades_menu_instance = null

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if current_game_state == GameState.Running || current_game_state == GameState.Upgrades:
			pause_game()
		else:
			resume_game()

func start_game() -> void:
	current_game_state = GameState.Running
	current_game_level = GameLevel.Level1

	get_tree().reload_current_scene()
	remove_menu()
	remove_upgrades_menu()

func pause_game() -> void:
	current_game_state = GameState.Paused
	on_game_state_changed.emit(current_game_state)
	
	add_menu()

func resume_game() -> void:
	current_game_state = GameState.Running
	on_game_state_changed.emit(current_game_state)

	remove_menu()

func restart_game() -> void:
	start_game()

func to_upgrades() -> void:
	current_game_level = GameLevel.Upgrades
	current_game_state = GameState.Upgrades
	emit_signal("on_game_level_changed", current_game_level)
	emit_signal("on_game_state_changed", current_game_state)
	add_upgrades_menu()

func is_paused() -> bool:
	return current_game_state == GameState.Paused

func is_running() -> bool:
	return current_game_state == GameState.Running

func reset() -> void:
	peniazky = 100000
	upgrades.reset()

func add_peniazky(amount: int) -> void:
	peniazky += amount

func buy_upgrade(upgrade_id: String) -> void:
	var upgrade: Upgrades.UpgradeItemDTO = upgrades.find_upgrade_by_id(upgrade_id)

	if upgrade == null:
		push_error("Upgrade with ID '%s' not found." % upgrade_id)
		return

	if upgrade.is_max_level() || peniazky < upgrade.get_next_level_price():
		return

	peniazky -= upgrade.get_next_level_price()
	upgrade.buy_upgrade()
	emit_signal("upgrade_bought", upgrade)


func load_upgrades() -> void:
	var file := FileAccess.open("res://upgrades/upgrades.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open upgrades.json: %s" % FileAccess.get_open_error())
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		push_error("Failed to parse upgrades.json: %s" % json.get_error_message())
		return

	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Upgrades JSON root must be an object.")
		return

	var parsed_dict: Dictionary = parsed
	var upgrade_data: Upgrades.UpgradeItemDTO = Upgrades.UpgradeItemDTO.from_dict(parsed_dict)
	upgrades.item = upgrade_data
