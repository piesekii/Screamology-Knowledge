extends Node

var current_day := 1

var label_interact := ""

var damaged_gear_chance = 0
var validator_text : String
var amount_error := 0

var quota_finished := false

signal quota_finished_signal 
signal sleep_signal

var quota_amount_needed := 1
var quota_amount_reached := 0

var lamp_ap : AnimationPlayer

func sleep() -> void:
	current_day += 1
	sleep_signal.emit()
	match current_day:
		1:
			pass
		2:
			damaged_gear_chance = 25
			quota_amount_needed = 15
			quota_amount_reached = 0
			amount_error = 0

func add_quota() -> void:
	quota_amount_reached += 1
	if quota_amount_reached >= quota_amount_needed:
		quota_finished_signal.emit()
		quota_finished = true
	lamp_ap.play("green")
func add_x() -> void:
	if amount_error == 0:
		validator_text = "X"
	elif amount_error == 1:
		validator_text = "X X"
	elif amount_error == 2:
		validator_text = "X X X"
	amount_error += 1
	lamp_ap.play("red")
