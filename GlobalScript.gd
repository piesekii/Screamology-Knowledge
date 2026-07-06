extends Node

var counter_camera := 2
# --- estado do jogo ---
var current_day := 1
var label_interact := ""
var validator_text : String
var amount_error := 0
var quota_finished := false
var quota_amount_needed := 10
var quota_amount_reached := 0
var lamp_ap : AnimationPlayer
var endComputerAnim : AnimationPlayer
# --- signals ---
signal quota_finished_signal
signal sleep_signal
signal enviar_pressed
signal descartar_pressed
signal game_over_signal

var esteira
var minigame_activated :bool = false:
	set(new_value):
		minigame_activated = new_value
		esteira.update_status()
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
			quota_amount_needed = 3
		2:
			quota_amount_needed = 9
		3:
			quota_amount_needed = 9
		4:
			quota_amount_needed = 9
		5:
			quota_amount_needed = 12
		6:
			quota_amount_needed = 14
		7:
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
	minigame_activated = false
	game_over_signal.emit()
	endComputerAnim.play("red_failing")
	await get_tree().create_timer(14.0).timeout
	_full_reset()

func _full_reset() -> void:
	current_day = 1
	label_interact = ""
	lamp_ap = null
	_setup_day(1)
	get_tree().change_scene_to_file("res://Finals/CFinal.tscn")
