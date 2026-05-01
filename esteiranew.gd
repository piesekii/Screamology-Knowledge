extends Area2D

@export var item_scene: PackedScene
@export var spawn_point: Marker2D
@export var end_point: Marker2D
@export var esteira_sprite: Sprite2D
@export var spawn_interval: float = 6.0

@export var button_blue: Node
@export var button_red: Node
@export var lever_base: Node

var queue: Array = []
var _spawn_timer: float = 0.0
var activated: bool = false:
	set(value):
		activated = value
		_update_shader()
		if value:
			_spawn_timer = 0.0

func _ready() -> void:
	GlobalScript.sleep_signal.connect(_reset_sleep)
	
	if button_blue:
		button_blue.interacted.connect(_on_button_blue_interacted)
	if button_red:
		button_red.interacted.connect(_on_button_red_interacted)
	if lever_base:
		lever_base.interacted.connect(_on_lever_base_interacted)

func _process(delta: float) -> void:
	if not activated:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_spawn_item()

func _spawn_item() -> void:
	var item = item_scene.instantiate()
	add_child(item)
	item.global_position = spawn_point.global_position
	item.exited_belt.connect(_on_item_exited)
	item.travel_to(end_point.global_position)
	queue.append(item)
	_update_highlight()

func _on_item_exited(item) -> void:
	queue.erase(item)
	_update_highlight()

func _update_highlight() -> void:
	for i in queue.size():
		queue[i].set_highlighted(i == 0)

func _update_shader() -> void:
	var speed := Vector2(-0.075, 0.0) if activated else Vector2.ZERO
	esteira_sprite.material.set_shader_parameter("scroll_speed", speed)

func _on_button_blue_interacted() -> void:
	_resolve_first(true)

func _on_button_red_interacted() -> void:
	_resolve_first(false)

func _resolve_first(send: bool) -> void:
	if queue.is_empty():
		return
	var first = queue.pop_front()
	first.resolve(send)
	_update_highlight()

func _on_lever_base_interacted() -> void:
	activated = true

# compat com chamadas antigas (ex: Computer.gd legado)
func activate() -> void:
	activated = true

func _reset_sleep() -> void:
	activated = false
	for item in queue:
		if is_instance_valid(item):
			item.queue_free()
	queue.clear()
