extends Area3D

# valores exportados
@export var is_enabled := true
@export var outline: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal interacted

# Estados da alavanca
var key_turned := false
var lever_pulled := false
var _initial_enabled := true

func _ready() -> void:
	_initial_enabled = is_enabled
	GlobalScript.sleep_signal.connect(_reset_lever_state)

func activate() -> void:
	is_enabled = true

func hover_activate() -> void:
	if not is_enabled or lever_pulled:
		return
	outline.visible = true

func hover_deactivate() -> void:
	outline.visible = false

func interact(_body: CharacterBody3D) -> void:
	if not is_enabled or lever_pulled:
		return

	# PASSO 1: Girar a Chave
	if not key_turned:
		_handle_turn_key()
	# PASSO 2: Puxar a Alavanca (Só se a chave já foi girada)
	else:
		_handle_pull_lever()

func _handle_turn_key() -> void:
	# Checa no seu GlobalScript se o jogador tem a chave
	if GlobalScript.get("HasKey"): # Usando get para evitar erro caso a variável mude
		key_turned = true
		animation_player.play("TurnKey")
		print("Chave girada!")
	else:
		print("Trancado. Você precisa de uma chave.")
		# Aqui você poderia tocar um som de "trancado" ou feedback visual

func _handle_pull_lever() -> void:
	lever_pulled = true
	animation_player.play("PullLever")
	
	# Conecta o sinal para emitir quando a animação terminar
	animation_player.animation_finished.connect(
		func(_anim_name: StringName):
			if _anim_name == "PullLever":
				interacted.emit()
				outline.visible = false # Esconde o outline pois não pode mais interagir
	, CONNECT_ONE_SHOT)

# Função para resetar (útil para o seu sistema de sleep/respawn)
func _reset_lever_state() -> void:
	key_turned = false
	lever_pulled = false
	is_enabled = _initial_enabled
	animation_player.play("RESET") # Garante que volta para a pose inicial
