extends Area2D

@onready var esteira: Area2D = $"../esteira"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var changed := false
var is_damaged := false

func _ready() -> void:
	rotation = randi_range(0, 360)
	GlobalScript.sleep_signal.connect(_reset_sleep)

func _reset_sleep() -> void:
	queue_free()

func _process(delta: float) -> void:
	if esteira.activated:
		position.x += 1.545

func change_form() -> void:
	if !changed:
		var chance = randi_range(0,100)
		if chance > GlobalScript.damaged_gear_chance:
			animation_player.play("change_form")
		else:
			animation_player.play("change_form_damaged")
			is_damaged = true
		changed = true
