extends Area3D

@export var is_lever := false
@export var is_enabled := true
@export var outline: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal interacted

var already_played : bool = false

var last_animation := ""

func _ready() -> void:
	if !is_enabled:
		animation_player.play("pressed")
		last_animation = "pressed"
func hover_activate():
	if is_enabled:
		if is_lever:
			if !already_played:
				outline.visible = true
		else:
			outline.visible = true

func hover_deactivate():
	outline.visible = false

func activate():
	is_enabled = true

func interact():
	if is_enabled:
		if is_lever:
			if !already_played:
				if last_animation == "pressed":
					animation_player.play_backwards("pressed")
					last_animation = ""
				else:
					animation_player.play("pressed")
					animation_player.animation_finished.connect(func(_anim_name): interacted.emit())
					already_played = true
		else:
				print("button")
				interacted.emit()
				animation_player.play("pressed")
