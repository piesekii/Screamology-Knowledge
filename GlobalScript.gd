extends Node

# --- estado do jogo ---
var current_day := 1
var label_interact := ""
var damaged_gear_chance = 0
var validator_text : String
var amount_error := 0
var quota_finished := false
var quota_amount_needed := 10
var quota_amount_reached := 0
var lamp_ap : AnimationPlayer
var HasKey := true
# --- signals ---
signal quota_finished_signal
signal sleep_signal
signal enviar_pressed
signal descartar_pressed
signal game_over_signal

# --- inicializacao ---
func _ready() -> void:
	_setup_day(current_day)

# --- ciclo de dia ---
func sleep() -> void:
	current_day += 1
	sleep_signal.emit()
	_setup_day(current_day)

func _setup_day(day: int) -> void:
	# resets comuns a todo dia
	quota_amount_reached = 0
	amount_error = 0
	validator_text = ""
	quota_finished = false
	# config especifica do dia
	match day:
		1:
			damaged_gear_chance = 0
			quota_amount_needed = 10
		2:
			damaged_gear_chance = 25
			quota_amount_needed = 15

# --- pontuacao ---
func add_quota() -> void:
	quota_amount_reached += 1
	if quota_amount_reached >= quota_amount_needed:
		quota_finished_signal.emit()
		quota_finished = true
	if lamp_ap:
		lamp_ap.play("green")

func add_x() -> void:
	if amount_error == 0:
		validator_text = "X"
	elif amount_error == 1:
		validator_text = "X X"
	elif amount_error == 2:
		validator_text = "X X X"
	elif amount_error == 3:
		validator_text = "X X X X"
	amount_error += 1
	if lamp_ap:
		lamp_ap.play("red")
	
	if amount_error >= 4:
		_trigger_game_over()

# --- botoes do minigame ---
func on_enviar() -> void:
	enviar_pressed.emit()

func on_descartar() -> void:
	descartar_pressed.emit()

# --- game over / reset total ---
func _trigger_game_over() -> void:
	game_over_signal.emit()
	await get_tree().create_timer(2.0).timeout
	_full_reset()

func _full_reset() -> void:
	current_day = 1
	label_interact = ""
	lamp_ap = null
	_setup_day(1)
	get_tree().reload_current_scene()
