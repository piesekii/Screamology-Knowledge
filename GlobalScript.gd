extends Node

# ── Estado existente (não mudou) ──────────────────────────
var current_day           := 1
var label_interact        := ""
var damaged_gear_chance   := 0
var validator_text        : String
var amount_error          := 0
var quota_finished        := false
var quota_amount_needed   := 10
var quota_amount_reached  := 0
var lamp_ap               : AnimationPlayer

func _ready() -> void:
	randomize()

# ── Sinais existentes ─────────────────────────────────────
signal quota_finished_signal
signal sleep_signal

# ── Sinais novos ──────────────────────────────────────────
signal game_over_signal   # amount_error chegou em 3
signal day_setup_signal(day: int)   # avisa DayRules que o dia mudou

# ─────────────────────────────────────────────────────────
func sleep() -> void:
	quota_finished       = false
	quota_amount_reached = 0
	amount_error         = 0
	validator_text       = ""
	current_day         += 1
	sleep_signal.emit()

	match current_day:
		1:
			quota_amount_needed   = 10
			damaged_gear_chance   = 0
		2:
			quota_amount_needed   = 12
			damaged_gear_chance   = 25
		3:
			quota_amount_needed   = 14
			damaged_gear_chance   = 30
		4:
			quota_amount_needed   = 16
			damaged_gear_chance   = 35
		5:
			quota_amount_needed   = 18
			damaged_gear_chance   = 40
		6:
			quota_amount_needed   = 20
			damaged_gear_chance   = 45
		7:
			quota_amount_needed   = 20
			damaged_gear_chance   = 50

	day_setup_signal.emit(current_day)

# ─────────────────────────────────────────────────────────
func add_quota() -> void:
	quota_amount_reached += 1
	if quota_amount_reached >= quota_amount_needed:
		quota_finished = true
		quota_finished_signal.emit()
	lamp_ap.play("green")

# ─────────────────────────────────────────────────────────
func add_x() -> void:
	match amount_error:
		0: validator_text = "X"
		1: validator_text = "X X"
		2: validator_text = "X X X"
	amount_error += 1
	lamp_ap.play("red")

	# 3 erros = game over
	if amount_error >= 3:
		game_over_signal.emit()

# ─────────────────────────────────────────────────────────
func game_over() -> void:
	# Chama a tela de game over / Final C
	# Adapta pro flow de cena do teu projeto
	game_over_signal.emit()
	
	
