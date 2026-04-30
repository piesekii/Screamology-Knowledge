# DayRules.gd
# Autoload — nome: DayRules

extends Node

# ─────────────────────────────────────────────
#  SINAIS
# ─────────────────────────────────────────────
signal computer_crashed
signal computer_restored
signal special_item_sent
signal all_specials_sent

# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const ITEM_TIME : Dictionary = {
	1: 8.0,
	2: 6.0,
	3: 5.0,
	4: 4.5,
	5: 4.0,
	6: 3.5,
	7: 2.5,
}

const CRASH_CHANCE : Dictionary = {
	3: 8,
	4: 12,
	5: 16,
	6: 22,
	7: 26,
}

const ITEMS_PER_DAY : Dictionary = {
	1: 10,
	2: 12,
	3: 14,
	4: 16,
	5: 18,
	6: 20,
	7: 20,
}

const SPECIALS_NEEDED : int = 3

# ─────────────────────────────────────────────
#  ESTADO
# ─────────────────────────────────────────────
var is_crashed           : bool = false
var specials_sent_count  : int  = 0
var _special_item_indices : Array[int] = []
var _items_spawned_today : int  = 0

# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	GlobalScript.sleep_signal.connect(_on_sleep)
	GlobalScript.day_setup_signal.connect(_on_day_setup)

func _on_sleep() -> void:
	is_crashed           = false
	specials_sent_count  = 0
	_items_spawned_today = 0

func _on_day_setup(day: int) -> void:
	_items_spawned_today = 0
	if day == 7:
		_generate_special_slots()

func _generate_special_slots() -> void:
	var total : int = ITEMS_PER_DAY[7]
	var pool : Array[int] = []
	for i in range(total / 2, total):
		pool.append(i)
	pool.shuffle()
	_special_item_indices = pool.slice(0, SPECIALS_NEEDED)
	_special_item_indices.sort()

# ─────────────────────────────────────────────
#  TEMPO
# ─────────────────────────────────────────────
func get_item_time(is_flashing: bool = false) -> float:
	var base : float = ITEM_TIME.get(GlobalScript.current_day, 2.5)
	return base * 0.5 if is_flashing else base

# ─────────────────────────────────────────────
#  GERA DADOS DO ITEM
# ─────────────────────────────────────────────
func generate_item_data() -> Dictionary:
	var day    : int  = GlobalScript.current_day
	var index  : int  = _items_spawned_today
	_items_spawned_today += 1

	if day == 7 and _special_item_indices.has(index):
		return {
			"symbols":         [],
			"is_flashing":     false,
			"is_special":      true,
			"correct_is_send": true,
		}

	var is_flashing : bool = (day >= 5 and randi_range(0, 100) < 30)
	var symbols     : Array[Dictionary] = _generate_symbols(day)
	var correct     : bool = _evaluate_send(symbols, day)

	return {
		"symbols":         symbols,
		"is_flashing":     is_flashing,
		"is_special":      false,
		"correct_is_send": correct,
	}

# ─────────────────────────────────────────────
#  SÍMBOLOS
# ─────────────────────────────────────────────
func _generate_symbols(day: int) -> Array[Dictionary]:
	var count : int = randi_range(2, 5)
	var pool  : Array[String] = _get_pool(day)
	var syms  : Array[Dictionary] = []
	for i in count:
		syms.append({ "type": pool[randi_range(0, pool.size() - 1)] })
	return syms

func _get_pool(day: int) -> Array[String]:
	match day:
		1:       return ["normal"]
		2, 3:    return ["normal", "red", "strikethrough"]
		_:       return ["normal", "red", "strikethrough", "triangle"]

# ─────────────────────────────────────────────
#  AVALIAÇÃO
# ─────────────────────────────────────────────
func _evaluate_send(symbols: Array[Dictionary], day: int) -> bool:
	var has_triangle : bool = false
	for s in symbols:
		if s.type == "triangle":
			has_triangle = true
			break
	var value  : int  = _calculate_value(symbols, day)
	var result : bool = (value == 3)
	if day >= 4 and has_triangle:
		return !result
	return result

func _calculate_value(symbols: Array[Dictionary], day: int) -> int:
	if day == 1:
		return symbols.size()
	var total : int = 0
	for s in symbols:
		match s.type:
			"red":           total += 2
			"strikethrough": total -= 1
			_:               total += 1
	return total

# ─────────────────────────────────────────────
#  RESOLVE ESCOLHA
# ─────────────────────────────────────────────
func resolve_choice(player_sent: bool, item_data: Dictionary) -> void:
	if is_crashed:
		return

	if item_data.get("is_special", false):
		if player_sent:
			specials_sent_count += 1
			special_item_sent.emit()
			if specials_sent_count >= SPECIALS_NEEDED:
				all_specials_sent.emit()
		return

	var correct : bool = item_data.get("correct_is_send", false)
	if player_sent == correct:
		GlobalScript.add_quota()
	else:
		GlobalScript.add_x()

	_try_crash()

func resolve_expired(item_data: Dictionary) -> void:
	if item_data.get("is_special", false):
		return
	GlobalScript.add_x()
	_try_crash()

# ─────────────────────────────────────────────
#  CRASH
# ─────────────────────────────────────────────
func _try_crash() -> void:
	var day : int = GlobalScript.current_day
	if day < 3 or is_crashed:
		return
	var chance : int = CRASH_CHANCE.get(day, 0)
	if randi_range(0, 100) < chance:
		_trigger_crash()

func _trigger_crash() -> void:
	is_crashed = true
	computer_crashed.emit()

func restore_from_crash() -> void:
	if !is_crashed:
		return
	is_crashed = false
	computer_restored.emit()
