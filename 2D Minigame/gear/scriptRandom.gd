extends Sprite2D



const TEX_NORMAL = preload("uid://desgwy236ceh7")
const TEX_RED = preload("uid://cyac1jvakif3y")
const TEX_STRIKETHROUGH = preload("uid://bowqc4vv6nvcj")
const TEX_TRIANGLE = preload("uid://bdpj2kk017pk0")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match randi_range(1,4):
		1:
			texture = TEX_NORMAL
			get_parent().amount_value += 10
		2: 
			texture =  TEX_RED
			get_parent().amount_value -= 10
		3:
			texture = TEX_STRIKETHROUGH
			get_parent().amount_value *= 2
		4:
			texture = TEX_TRIANGLE
			get_parent().amount_value %= 2 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
