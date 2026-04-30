extends Area2D

const SPEED : float = 0.8

@export var tex_normal        : Texture2D
@export var tex_red           : Texture2D
@export var tex_strikethrough : Texture2D
@export var tex_triangle      : Texture2D

var resolved     : bool = false
var correct_send : bool = false
var symbols      : Array[Dictionary] = []

func _ready() -> void:
	
	GlobalScript.sleep_signal.connect(queue_free)
	_generate()
	_build_visuals()

func _generate() -> void:
	var day : int = GlobalScript.current_day
	symbols      = _make_symbols(day)
	correct_send = _evaluate(symbols, day)

func _make_symbols(day: int) -> Array[Dictionary]:
	var pool : Array[String] = []
	match day:
		1:    pool = ["normal"]
		2, 3: pool = ["normal", "red", "strikethrough"]
		_:    pool = ["normal", "red", "strikethrough", "triangle"]

	var count  : int = randi_range(1, 4)
	var result : Array[Dictionary] = []
	for i in count:
		result.append({"type": pool[randi_range(0, pool.size() - 1)]})
	return result

func _evaluate(syms: Array[Dictionary], day: int) -> bool:
	var has_triangle : bool = false
	var total        : int  = 0
	for s in syms:
		match s.type:
			"triangle":
				has_triangle = true
				total += 1
			"red":           total += 2
			"strikethrough": total -= 1
			_:               total += 1
	if day == 1:
		total = syms.size()
	var result : bool = (total == 3)
	if day >= 4 and has_triangle:
		return !result
	return result

func _build_visuals() -> void:
	var total : int = symbols.size()
	if total == 0:
		return

	var spacing : float = 80.0 / float(max(total, 1))
	var start_x : float = -40.0 + spacing * 0.5

	for i in total:
		var s   : Dictionary = symbols[i]
		var spr := Sprite2D.new()
		spr.position = Vector2(start_x + float(i) * spacing, 0.0)
		spr.z_index  = 1

		match s.type:
			"normal":        spr.texture = tex_normal
			"red":           spr.texture = tex_red
			"strikethrough": spr.texture = tex_strikethrough
			"triangle":      spr.texture = tex_triangle

		add_child(spr)

func _process(_delta: float) -> void:
	if !resolved:
		position.x += SPEED

func resolve_send() -> void:
	if resolved: return
	resolved = true
	if correct_send:
		GlobalScript.add_quota()
	else:
		GlobalScript.add_x()
	_feedback(Color(0.2, 1.0, 0.4) if correct_send else Color(1.0, 0.2, 0.2))

func resolve_discard() -> void:
	if resolved: return
	resolved = true
	if !correct_send:
		GlobalScript.add_quota()
	else:
		GlobalScript.add_x()
	_feedback(Color(0.2, 1.0, 0.4) if !correct_send else Color(1.0, 0.2, 0.2))

func _feedback(col: Color) -> void:
	modulate = col
	await get_tree().create_timer(0.25).timeout
	queue_free()
