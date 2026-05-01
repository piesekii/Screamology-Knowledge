extends Area2D

const TEX_NORMAL = preload("uid://desgwy236ceh7")
const TEX_RED = preload("uid://cyac1jvakif3y")
const TEX_STRIKETHROUGH = preload("uid://bowqc4vv6nvcj")
const TEX_TRIANGLE = preload("uid://bdpj2kk017pk0")

@export var symbol_sprite_scene: PackedScene
@export var symbols_container: Node2D
@export var travel_time: float = 8.0
@export var symbol_size: float = 32.0
@export var symbol_spacing: float = 36.0

var amount_value: int = 0
var inverted: bool = false
var processed: bool = false

signal exited_belt(item)

func _ready() -> void:
	_generate_symbols()

func _generate_symbols() -> void:
	if symbol_sprite_scene == null:
		push_error("[Item] symbol_sprite_scene NAO foi setado no inspector!")
		return
	if symbols_container == null:
		push_error("[Item] symbols_container NAO foi setado no inspector!")
		return
	
	var count := randi_range(1, 4)
	var positions := _get_grid_positions(count)
	var triangle_used := false
	
	for i in count:
		var instance = symbol_sprite_scene.instantiate()
		if not instance is Sprite2D:
			push_error("[Item] root de symbol.tscn precisa ser Sprite2D")
			instance.queue_free()
			return
		var s: Sprite2D = instance
		symbols_container.add_child(s)
		s.position = positions[i]
		
		# sorteia um simbolo, mas se ja tem triangulo neste item,
		# resorteia ate cair em outro
		var pick: int
		while true:
			pick = randi_range(1, 4)
			if pick == 4 and triangle_used:
				continue  # tenta de novo
			break
		
		match pick:
			1:
				s.texture = TEX_NORMAL
				amount_value += 1
			2:
				s.texture = TEX_RED
				amount_value += 2
			3:
				s.texture = TEX_STRIKETHROUGH
				amount_value -= 1
			4:
				s.texture = TEX_TRIANGLE
				inverted = true
				triangle_used = true
		
		if s.texture:
			var tex_size: Vector2 = s.texture.get_size()
			var max_side: float = max(tex_size.x, tex_size.y)
			s.scale = Vector2.ONE * (symbol_size / max_side)

func _get_grid_positions(count: int) -> Array:
	# offset dos simbolos dentro do quadrado, em grade 2x2
	var d := symbol_spacing / 2.0
	match count:
		1:
			# 1 simbolo = centro
			return [Vector2.ZERO]
		2:
			# 2 simbolos = lado a lado, no meio vertical
			return [Vector2(-d, 0), Vector2(d, 0)]
		3:
			# 3 simbolos = 2 em cima, 1 embaixo centralizado (triangulo)
			return [Vector2(-d, -d), Vector2(d, -d), Vector2(0, d)]
		4:
			# 4 simbolos = grade 2x2
			return [
				Vector2(-d, -d), Vector2(d, -d),
				Vector2(-d, d), Vector2(d, d)
			]
	return []
func travel_to(end_pos: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position:x", end_pos.x, travel_time)
	tween.tween_callback(_on_exit_belt)

func _on_exit_belt() -> void:
	if processed:
		return
	exited_belt.emit(self)
	if not GlobalScript.quota_finished:
		GlobalScript.add_x()
	queue_free()

func resolve(player_chose_send: bool) -> void:
	if processed:
		return
	if GlobalScript.quota_finished:
		return
	processed = true
	
	var should_send := (amount_value == 3)
	if inverted:
		should_send = not should_send
	
	if player_chose_send == should_send:
		GlobalScript.add_quota()
		_feedback_correct()
	else:
		GlobalScript.add_x()
		_feedback_wrong()

func set_highlighted(on: bool) -> void:
	modulate = Color(1.3, 1.3, 1.3) if on else Color.WHITE

func _feedback_correct() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(0.3, 1.5, 0.3), 0.08)
	tw.parallel().tween_property(self, "scale", scale * 1.2, 0.08)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)

func _feedback_wrong() -> void:
	var original_pos := position
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(1.5, 0.3, 0.3), 0.08)
	for i in 4:
		tw.tween_property(self, "position:y", original_pos.y + 6, 0.04)
		tw.tween_property(self, "position:y", original_pos.y - 6, 0.04)
	tw.tween_property(self, "modulate", Color.WHITE, 0.1)
	tw.tween_callback(queue_free)
