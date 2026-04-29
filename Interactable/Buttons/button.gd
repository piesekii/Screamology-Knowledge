extends Area3D

# valores exportados
@export var deactivate_after_quota := false
@export var is_lever := false
@export var is_enabled := true
@export var outline: MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal interacted

const ANIM_PRESSED := "pressed"

var already_played := false
var last_animation := ""

# snapshot do estado inicial
var _initial_enabled := true

func _ready() -> void:
	_initial_enabled = is_enabled  # salva estado original
	if not is_enabled:
		_play_pressed()
	GlobalScript.sleep_signal.connect(_reset_sleep)

func activate() -> void:
	is_enabled = true

func hover_activate() -> void:
	if not is_enabled:
		return
	if is_lever and already_played:
		return
	outline.visible = true

func hover_deactivate() -> void:
	outline.visible = false

func interact(body: CharacterBody3D) -> void:
	if not is_enabled:
		return

	if is_lever:
		_handle_lever()
	else:
		_handle_button()

func _handle_lever() -> void:
	if already_played:
		return

	if last_animation == ANIM_PRESSED:
		animation_player.play_backwards(ANIM_PRESSED)
		last_animation = ""
	else:
		animation_player.play(ANIM_PRESSED)
		last_animation = ANIM_PRESSED
		already_played = true
		animation_player.animation_finished.connect(
			func(_anim_name: StringName) -> void: interacted.emit(),
			CONNECT_ONE_SHOT
		)

func _handle_button() -> void:
	interacted.emit()
	animation_player.play(ANIM_PRESSED)

func _play_pressed() -> void:
	animation_player.play(ANIM_PRESSED)
	last_animation = ANIM_PRESSED

func _reset_sleep() -> void:
	# restaura exatamente o estado de quando foi instanciado
	already_played = false
	last_animation = ""
	is_enabled = _initial_enabled

	if not is_enabled:
		_play_pressed()
	else:
		animation_player.play_backwards(ANIM_PRESSED)
