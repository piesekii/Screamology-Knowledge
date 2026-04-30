extends Area2D

func _ready() -> void:
	var btn_blue := get_node_or_null("/root/Game/Interactable/button_blue")
	var btn_red  := get_node_or_null("/root/Game/Interactable/button_red")

	if btn_blue:
		btn_blue.interacted.connect(_on_button_blue_interacted)
	else:
		push_error("prensa: button_blue não encontrado!")

	if btn_red:
		btn_red.interacted.connect(_on_button_red_interacted)
	else:
		push_error("prensa: button_red não encontrado!")

func _get_first_item() -> Node:
	var subviewport := get_node_or_null("/root/Game/Computer/SubViewport")
	if !subviewport:
		push_error("prensa: SubViewport não encontrado!")
		return null

	for child in subviewport.get_children():
		if child.has_method("resolve_send") and !child.resolved:
			return child
	return null

func _on_button_blue_interacted() -> void:
	var item := _get_first_item()
	if item:
		item.resolve_send()
	else:
		print("nenhum item disponivel")

func _on_button_red_interacted() -> void:
	var item := _get_first_item()
	if item:
		item.resolve_discard()
	else:
		print("nenhum item disponivel")
