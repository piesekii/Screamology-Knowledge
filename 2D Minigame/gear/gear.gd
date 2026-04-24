extends Area2D

@onready var esteira: Area2D = $"../esteira"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var changed := false

func _process(delta: float) -> void:
	if esteira.activated:
		position.x += 1.545

func change_form() -> void:
	if !changed:
		animation_player.play("change_form")
		changed = true
