extends StaticBody3D

@onready var outline: MeshInstance3D = $Bed/outline



func interact(player : CharacterBody3D):
	if !GlobalScript.quota_finished:
		GlobalScript.label_interact = "I cant sleep yet. I need to reach my daily quota."
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.start(3)
		new_timer.timeout.connect(func RemoveGlobalText(): GlobalScript.label_interact = "")
		new_timer.timeout.connect(func RemoveTimer(): new_timer.queue_free())
	else:
		GlobalScript.sleep()
func hover_activate():
		if !outline.visible:
			outline.visible = true
		else:
			outline.visible = true

func hover_deactivate():
	outline.visible = false
