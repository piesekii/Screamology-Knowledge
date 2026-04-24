extends MeshInstance3D

@onready var computer_screen: MeshInstance3D = $ComputerScreen

func _on_lever_green_interacted() -> void:
	computer_screen.visible = true
