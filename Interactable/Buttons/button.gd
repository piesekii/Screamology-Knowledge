extends Area3D

# valores exportados
@export var deactivate_after_quota := false
@export var is_lever := false
@export var is_enabled := true
@export var lever_starts_up := false  # se true, lever nasce pra cima E precisa de 2 puxadas
@export var outline: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal interacted

const ANIM_PRESSED := "pressed"

var already_played := false
var last_animation := ""
var _initial_enabled := true

func _ready() -> void:
	_initial_enabled = is_enabled
	# lever nasce pressed apenas se nao for "starts_up"
	if not is_enabled and not lever_starts_up:
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
	if last_animation == "":
		# nunca foi puxada nesse ciclo — DESCE
		animation_player.play(ANIM_PRESSED)
		last_animation = ANIM_PRESSED
		# pra lever que comeca pressed (red), DESCER eh o segundo movimento
		# pra lever que comeca pra cima (yellow), DESCER eh o primeiro
		if not lever_starts_up:
			already_played = true
			animation_player.animation_finished.connect(
				func(_anim_name: StringName) -> void: interacted.emit(),
				CONNECT_ONE_SHOT
			)
	else:
		# ja desceu, agora SOBE
		animation_player.play_backwards(ANIM_PRESSED)
		last_animation = ""
		# pra lever starts_up, SUBIR eh o segundo movimento — emite signal
		if lever_starts_up:
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

# permite reusar a lever multiplas vezes (ex: lever amarela em cada glitch)
func reset_lever() -> void:
	already_played = false
	last_animation = ""

# forca lever a voltar visualmente pra cima e zera flags
func force_reset_visual() -> void:
	if last_animation == ANIM_PRESSED:
		animation_player.play_backwards(ANIM_PRESSED)
	already_played = false
	last_animation = ""

func _reset_sleep() -> void:
	already_played = false
	last_animation = ""
	is_enabled = _initial_enabled
	if not is_enabled and not lever_starts_up:
		_play_pressed()
	else:
		animation_player.play_backwards(ANIM_PRESSED)
