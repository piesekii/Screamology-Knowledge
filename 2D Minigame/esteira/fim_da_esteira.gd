extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if GlobalScript.quota_finished:
		return
	if area.has_method("resolve_send") and !area.resolved:
		area.resolved = true
		GlobalScript.add_x()
		area.queue_free()
