extends Node3D

@onready var progress_bar: ProgressBar = $OkaynatorScreen/SubViewport/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	progress_bar.max_value = GlobalScript.quota_amount_needed
	progress_bar.value = GlobalScript.quota_amount_reached
