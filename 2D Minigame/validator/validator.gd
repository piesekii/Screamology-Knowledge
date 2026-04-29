extends MeshInstance3D


@onready var label: Label = $ValidatorScreen/SubViewport/Label

func _process(delta: float) -> void:
	label.text = GlobalScript.validator_text
