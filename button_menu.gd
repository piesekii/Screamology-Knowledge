extends Button

@export var hover_scale := Vector2(1.08, 1.08)
@export var float_strength := 3.0
@export var float_speed := 2.0
@export var slide_distance := 250.0

var base_position : Vector2
var base_scale : Vector2

var time := 0.0
var selected := false

func _ready():
	base_position = position
	base_scale = scale
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_pressed)


func _on_hover():
	if selected:
		return
	
	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(self, "scale", hover_scale, 0.12)


func _on_unhover():
	if selected:
		return
	
	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(self, "scale", base_scale, 0.12)


func _on_pressed():
	selected = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	# desliza totalmente para esquerda
	tween.parallel().tween_property(
		self,
		"position:x",
		base_position.x - slide_distance,
		0.18
	)
	
	# pequeno impacto visual
	tween.parallel().tween_property(
		self,
		"scale",
		Vector2(1.12, 1.12),
		0.08
	)
