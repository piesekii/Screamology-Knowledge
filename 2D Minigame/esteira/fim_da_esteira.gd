extends Area2D


# Called when the node enters the scene tree for the first time.


func _on_area_entered(area: Area2D) -> void:
	if !GlobalScript.quota_finished:
		if area.has_method("change_form"):
			if area.is_damaged or area.changed == false:
				#print("AH")
				GlobalScript.add_x()
			else:
				GlobalScript.add_quota()
			#print("B")
			area.queue_free()
