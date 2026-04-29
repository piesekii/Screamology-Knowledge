extends MeshInstance3D

@onready var computer_screen: MeshInstance3D = $ComputerScreen
@onready var ended_quota: AnimationPlayer = $EndedQuota

func _ready() -> void:
	GlobalScript.quota_finished_signal.connect(hide_screen)
	GlobalScript.sleep_signal.connect(_reset_sleep)

func _reset_sleep() -> void:
	ended_quota.play_backwards("dailyReset")

func hide_screen() -> void:
	ended_quota.play("okquotaEnded")

func _on_lever_green_interacted() -> void:
	computer_screen.visible = true
