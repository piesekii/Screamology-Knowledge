extends Timer

@export var item_scene   : PackedScene
@export var sub_viewport : SubViewport
@export var spawn_pos    : Vector2 = Vector2(-300, 480)

var _spawned_today : int  = 0
var _active        : bool = false

func _ready() -> void:
	GlobalScript.sleep_signal.connect(_on_sleep)
	GlobalScript.quota_finished_signal.connect(_on_quota_done)
	# NAO conecta timeout aqui — conectar via editor no painel Sinais

func _on_sleep() -> void:
	_active        = false
	_spawned_today = 0
	stop()

func _on_quota_done() -> void:
	_active = false
	stop()

func start_spawning() -> void:
	_active        = true
	_spawned_today = 0
	wait_time      = 3.0
	start()

func _on_timeout() -> void:
	if !_active:
		return
	if _spawned_today >= 15:
		_active = false
		stop()
		if !GlobalScript.quota_finished:
			GlobalScript.quota_finished = true
			GlobalScript.quota_finished_signal.emit()
		return
	_spawn_item()

func _spawn_item() -> void:
	if !item_scene or !sub_viewport:
		push_error("ItemSpawner: item_scene ou sub_viewport não atribuído!")
		return
	var item := item_scene.instantiate() as Area2D
	sub_viewport.add_child(item)
	item.position = spawn_pos
	_spawned_today += 1
