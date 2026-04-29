extends CharacterBody3D

var speed
const WALK_SPEED = 1.0
const SPRINT_SPEED = 3.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 5.4
const BOB_AMP = 0.04
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var ray_cast_3d: RayCast3D = $Head/Camera3D/RayCast3D
@onready var label_interact: Label = $CanvasLayer/LabelInteract
@onready var label_text: Label = $CanvasLayer/LabelText
@onready var color_rect_no_bg: ColorRect = $CanvasLayer/ColorRectNoBG
@onready var animation_player_screen: AnimationPlayer = $CanvasLayer/ColorRectNoBG/LabelText/AnimationPlayerScreen

var is_reading := true
@onready var label_each_day: RichTextLabel = $CanvasLayer/ColorRectNoBG/LabelEachDay


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalScript.sleep_signal.connect(play_sleep)
func play_sleep():
	animation_player_screen.play("rest")
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(60))

var last_collider: Object = null

func _process(_delta: float) -> void:
	if label_each_day.visible:
		if Input.is_action_just_pressed("interact"):
			label_each_day._next()
		return
	label_interact.text = GlobalScript.label_interact
	
	var collider = ray_cast_3d.get_collider() if ray_cast_3d.is_colliding() else null
	
	if Input.is_action_just_pressed("interact") and collider != null and collider.is_in_group("interactable"):
		collider.interact(self)
	if collider != last_collider:
		if last_collider:
			last_collider.hover_deactivate()
		if collider and collider.is_in_group("interactable"):
			last_collider = collider
			last_collider.hover_activate()
		else:
			last_collider = null
	
	if is_reading:
		if Input.is_action_just_pressed("F"):
			animation_player_screen.play("hide")
			is_reading = false
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
