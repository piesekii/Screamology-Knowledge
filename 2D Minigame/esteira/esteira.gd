extends Area2D

@onready var esteira : Sprite2D = $esteira

func _ready() -> void:
	GlobalScript.sleep_signal.connect(_reset_sleep)

func _reset_sleep() -> void:
	activated = false

var activated : bool = false:
	set(value):
		activated = value
		monitorable = value
		switch_esteira()

func switch_esteira() -> void:
	if activated:
		esteira.material.set_shader_parameter("scroll_speed", Vector2(-0.075, 0.0))
	else:
		esteira.material.set_shader_parameter("scroll_speed", Vector2(0.0, 0.0))

func _on_lever_base_interacted() -> void:
	activated = true
	get_node("/root/Game/Computer/Timer").start_spawning()

# ── Botões ────────────────────────────────────
func _on_button_blue_interacted() -> void:
	var item := _get_active_item()
	if item:
		item.resolve_send()

func _on_button_red_interacted() -> void:
	var item := _get_active_item()
	if item:
		item.resolve_discard()

# Pega o item mais à frente (maior x) que ainda não foi resolvido
func _get_active_item() -> Node:
	var best   : Node  = null
	var best_x : float = -INF
	for area in get_overlapping_areas():
		if area.has_method("resolve_send") and !area.resolved:
			if area.position.x > best_x:
				best   = area
				best_x = area.position.x
	return best
