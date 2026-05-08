extends Area3D

# valores exportados
@export var deactivate_after_quota := false
@export var is_lever := false
@export var is_enabled := true
@export var lever_starts_up := false  # true: nasce em cima | false: nasce embaixo
@export var outline: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal interacted

const ANIM_PRESSED := "pressed"

var already_played := false
var last_animation := ""
var _initial_enabled := true

func _ready() -> void:
	_initial_enabled = is_enabled
	
	# AJUSTE: Se a alavanca nasce embaixo, forçamos a animação no frame final
	if not lever_starts_up:
		animation_player.play(ANIM_PRESSED)
		animation_player.advance(10.0) # Avança a animação para o fim instantaneamente
		last_animation = ANIM_PRESSED
	
	GlobalScript.sleep_signal.connect(_reset_sleep)

func activate() -> void:
	is_enabled = true

func hover_activate() -> void:
	if not is_enabled or (is_lever and already_played):
		return
	outline.visible = true

func hover_deactivate() -> void:
	outline.visible = false

func interact(_body: CharacterBody3D) -> void:
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
		# ESTADO: ESTAVA EM CIMA -> VAI PARA BAIXO
		animation_player.play(ANIM_PRESSED)
		last_animation = ANIM_PRESSED
		
		# Se ela começou embaixo (false), voltar para baixo é o SEGUNDO movimento
		if not lever_starts_up:
			_emit_interacted_on_finish()
	else:
		# ESTADO: ESTAVA EM BAIXO -> VAI PARA CIMA
		animation_player.play_backwards(ANIM_PRESSED)
		last_animation = ""
		
		# Se ela começou em cima (true), voltar para cima é o SEGUNDO movimento
		if lever_starts_up:
			_emit_interacted_on_finish()

func _emit_interacted_on_finish() -> void:
	already_played = true
	animation_player.animation_finished.connect(
		func(_anim_name: StringName) -> void: interacted.emit(),
		CONNECT_ONE_SHOT
	)

func _handle_button() -> void:
	interacted.emit()
	animation_player.play(ANIM_PRESSED)

func reset_lever() -> void:
	already_played = false
	# Se precisar resetar a posição física também, chame o _ready ou force a posição
	_reset_sleep()

func _reset_sleep() -> void:
	already_played = false
	is_enabled = _initial_enabled
	
	if not lever_starts_up:
		animation_player.play(ANIM_PRESSED)
		animation_player.advance(10.0)
		last_animation = ANIM_PRESSED
	else:
		animation_player.play_backwards(ANIM_PRESSED)
		last_animation = ""
