extends Area2D

@onready var animation_player: AnimationPlayer = $prensa/AnimationPlayer



func _on_button_blue_interacted() -> void:
	animation_player.play("prensa")

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("change_form"):
		area.change_form()
