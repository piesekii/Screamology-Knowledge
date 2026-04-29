extends Area2D

@onready var esteira: Sprite2D = $esteira


func _ready() -> void:
	GlobalScript.sleep_signal.connect(_reset_sleep)

func _reset_sleep() -> void:
	activated = false

var activated: bool = false:
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
