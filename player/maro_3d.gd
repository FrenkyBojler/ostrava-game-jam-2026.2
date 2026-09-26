class_name Maro3D extends CharacterBody2D

@export var item: ItemResource
@onready var interact_area: Area2D = %InteractArea

@onready var sprite: Sprite2D = %Sprite
@onready var item_position_right: Node2D = %ItemPositionRight
@onready var item_position_left: Node2D = %ItemPositionLeft
@onready var light: PointLight2D = $MaroLightAmbient

@onready var maro_light_directional: Node2D = $MaroLightDirectional
@onready var dash_timer: Timer = $DashTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var dead_body: Sprite2D = $DeadBody
@onready var dead_head: Sprite2D = $DeadHead
@onready var death_label: Label = $Control/Label
@onready var death_label_light: Light2D = $DeathLabelLight

var space_controller: MaroSpaceController = MaroSpaceController.new()
var tetris_controller: TetrisController = TetrisController.new()

var controller: MaroController = space_controller

var item_to_pick: Item
var picked_item: Item

var last_dir := Direction.Right

var tetris: TetrisGrid
var is_near_tetris: bool = false
var is_in_tetris: bool = false
var is_dying: bool = false

var can_place_item_into_tetris := false

const DASH_BASE_FORCE = 10.0
const DASH_BASE_COOLDOWN_TIME = 5.0

var dash_cooldown := false

var dead_body_origin: Vector2
var dead_head_origin: Vector2
var light_directional_origin: Vector2

enum Direction {
	Left, Right
}

func _ready() -> void:
	controller = space_controller
	interact_area.body_entered.connect(_on_interact_area_enter)
	interact_area.body_exited.connect(_on_interact_area_exit)
	death_label.modulate.a = 0
	death_label_light.energy = 0

	dash_timer.timeout.connect(func():
		dash_cooldown = false
	)
	
	anim_player.play("idle")

func _process(delta: float) -> void:
	if Globals.current_game_state != Globals.GameState.Running or is_dying:
		return
		
	if Input.is_action_just_pressed("bail_interact_p1") and is_in_tetris:
		_bail_from_tetris()

	if is_in_tetris:
		return
		
	var move_speed := Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.MOVE_SPEED) as float
	
	var adjusted_move_speed := move_speed if picked_item == null else move_speed - (picked_item.get_weight() / Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.STRENGTH) as float)
	if adjusted_move_speed < 0:
		adjusted_move_speed = move_speed / 10

	var horizontal_input := Input.get_axis("move_left_p1", "move_right_p1")
	var vertical_input := Input.get_axis("move_up_p1", "move_down_p1")
	var dash := 1.0
	
	if Input.is_action_just_pressed("dash") and Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.DASH_ABILITY) != 0.0 and not dash_cooldown:
		dash = DASH_BASE_FORCE * Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.DASH_DISTANCE)
		velocity = Vector2.ZERO
		dash_timer.wait_time = DASH_BASE_COOLDOWN_TIME - Globals.upgrades.get_property_value(Upgrades.UpgradeProperty.DASH_COOLDOWN)
		dash_timer.start()
		dash_cooldown = true

	var movement_input := Vector2(horizontal_input, vertical_input) * adjusted_move_speed * delta * dash
	
	if movement_input.x < 0:
		last_dir = Direction.Left
	elif movement_input.x > 0:
		last_dir = Direction.Right
	
	if movement_input.length() != 0:
		anim_player.play("run")
	else:
		anim_player.play("idle")

	_handle_direction_change()
	
	if not is_in_tetris:
		move_and_collide(movement_input)

	if Input.is_action_just_pressed("interact_p1"):
		if is_near_tetris and picked_item != null and tetris != null and tetris.tlatko.number_of_interactions < tetris.tlatko.max_interactions:
			is_in_tetris = true
			tetris.start_placing_item(picked_item)
		elif (item_to_pick == null and picked_item != null) or picked_item != null and is_in_tetris:
			_drop_item()
		elif item_to_pick != null and picked_item != null and not is_in_tetris:
			_drop_item()
			_pick_item()
		elif item_to_pick != null and picked_item == null:
			_pick_item()
	
	if picked_item != null and is_in_tetris:
		var current_piece := tetris.get_nearest_piece(position)
		can_place_item_into_tetris = tetris.check_place_item(picked_item, current_piece.grid_position - Vector2.RIGHT * 2 if last_dir == Direction.Left else current_piece.grid_position + Vector2.RIGHT)
	if picked_item != null and not is_in_tetris:
		picked_item.turn_off_highlight()
		can_place_item_into_tetris = false
		
func _handle_tetris_grid() -> void:
	if not is_in_tetris:
		return
	pass
	
func _handle_direction_change() -> void:
	sprite.flip_h = last_dir == Direction.Left
	if picked_item != null:
		picked_item.position = item_position_right.position
	#if picked_item != null:
	#	var target_pos := item_position_left.position - picked_item.get_item_first_cell_position_offset(true) * -1 if last_dir == Direction.Left else item_position_right.position + picked_item.get_item_first_cell_position_offset(false)
	#	picked_item.position = target_pos

func _pick_item() -> void:
	picked_item = item_to_pick
	picked_item.get_picked_up()
	picked_item.reparent(self)
	_handle_direction_change()
	item_to_pick = null

func _drop_item() -> void:
	if is_in_tetris and can_place_item_into_tetris:
		tetris.place_item(picked_item, tetris.get_nearest_piece(position).grid_position - Vector2.RIGHT if last_dir == Direction.Left else tetris.get_nearest_piece(position).grid_position + Vector2.RIGHT)
	elif is_in_tetris and not can_place_item_into_tetris:
		return

	picked_item.reparent(get_parent())
	picked_item.get_dropped()
	picked_item = null

func _bail_from_tetris() -> void:
	if not is_in_tetris:
		return

	is_near_tetris = false
	picked_item.is_being_placed = false
	picked_item.reparent(self)
	is_in_tetris = false
	tetris.toggle_highlight_all_pieces(false)
	_handle_direction_change()

func _on_interact_area_enter(body: Node2D) -> void:
	if body is Item and (body as Item) != picked_item:
		if not is_in_tetris or (is_in_tetris and picked_item == null):
			(body as Item).toggle_outline(true)
		item_to_pick = body

func _on_interact_area_exit(body: Node2D) -> void:
	if body is Item:
		(body as Item).toggle_outline(false)
		item_to_pick = null

func to_tetris(_entry_pos: Vector2, tetris_grid: TetrisGrid) -> void:
	#controller = tetris_controller
	#position = entry_pos
	tetris = tetris_grid
	is_near_tetris = true

func to_space() -> void:
	controller = space_controller

func play_death() -> void:
	sprite.visible = false
	dead_body.visible = true
	dead_head.visible = true
	maro_light_directional.is_dying = true
	is_dying = true

	dead_body_origin = dead_body.position
	dead_head_origin = dead_head.position
	light_directional_origin = maro_light_directional.position

	dead_body.scale = Vector2.ZERO
	dead_head.scale = Vector2.ZERO
	dead_head.rotation = 0
	maro_light_directional.rotation = 0
	maro_light_directional.light.energy = 1.0

	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(death_label, "modulate:a", 1.0, 2.0)
	tween.tween_property(death_label_light, "energy", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)

	var explode_tween := get_tree().create_tween()
	explode_tween.set_parallel(true)

	# --- explode outward, all at once ---
	explode_tween.tween_property(dead_body, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(dead_head, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(dead_head, "position", dead_head_origin + Vector2(0, -48), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(dead_head, "rotation", deg_to_rad(360), 0.4).set_trans(Tween.TRANS_LINEAR)
	explode_tween.tween_property(maro_light_directional, "position", light_directional_origin + Vector2(-120, -90), 0.2).set_trans(Tween.TRANS_QUAD)
	explode_tween.tween_property(maro_light_directional, "rotation", deg_to_rad(360), 0.4).set_trans(Tween.TRANS_LINEAR)
	explode_tween.tween_property(maro_light_directional.light, "energy", 0.0, 1).set_trans(Tween.TRANS_BOUNCE)

	# --- settle back into place ---
	explode_tween.chain().tween_property(dead_body, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(dead_head, "position", dead_head_origin + Vector2(10, 48), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(maro_light_directional, "position", light_directional_origin + Vector2(-120, 10), 0.3).set_trans(Tween.TRANS_BOUNCE)
	explode_tween.tween_property(maro_light_directional, "rotation", deg_to_rad(405), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(maro_light_directional.light, "energy", 1.0, 0.5).set_trans(Tween.TRANS_BOUNCE)
