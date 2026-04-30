# SendDiscardHandler.gd
extends Node

@export var item_spawner   : Timer
@export var button_send    : Area3D
@export var button_discard : Area3D
const GEAR = preload("uid://bbht0t74ptp37")



func _ready() -> void:
	if button_send:
		button_send.interacted.connect(send)
	if button_discard:
		button_discard.interacted.connect(discard)

func send() -> void:
	var item := _get_item()
	if item:
		item.resolve_send()
	else:
		print("send: nenhum item ativo")

func discard() -> void:
	var item := _get_item()
	if item:
		item.resolve_discard()
	else:
		print("discard: nenhum item ativo")

func _get_item() -> Node:
	if !item_spawner:
		push_error("SendDiscardHandler: item_spawner não atribuído!")
		return null
	var item : Node = item_spawner.current_item
	if item == null or !is_instance_valid(item) or item.resolved:
		return null
	return item
