extends Node3D

@onready var progress_bar: ProgressBar = $OkaynatorScreen/SubViewport/ProgressBar

func _process(delta: float) -> void:
	progress_bar.max_value = GlobalScript.quota_amount_needed
	progress_bar.value = GlobalScript.quota_amount_reached
