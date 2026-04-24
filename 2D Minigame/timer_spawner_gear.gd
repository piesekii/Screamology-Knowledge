extends Timer


const GEAR = preload("uid://bbht0t74ptp37")

@onready var sub_viewport: SubViewport = $"../SubViewport"

func start_timer() -> void:
	start()

func _on_timeout() -> void:
	var new_gear = GEAR.instantiate()
	sub_viewport.add_child(new_gear)
	new_gear.global_position = Vector2(-200, 480)
