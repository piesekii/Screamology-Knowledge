extends Timer


const GEAR = preload("uid://bbht0t74ptp37")

@export var sub_viewport: SubViewport
func _ready() -> void:
	GlobalScript.sleep_signal.connect(_reset_sleep)

func _reset_sleep() -> void:
	stop()
func start_timer() -> void:
	start()

func _on_timeout() -> void:
	var new_gear = GEAR.instantiate()
	sub_viewport.add_child(new_gear)
	new_gear.global_position = Vector2(-200, 480)
