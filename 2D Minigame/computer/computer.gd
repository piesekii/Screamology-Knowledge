extends MeshInstance3D

@onready var computer_screen: MeshInstance3D = $ComputerScreen
@onready var ended_quota: AnimationPlayer = $EndedQuota
@onready var lever_red = $"../Interactable/lever_red"
@onready var lever_yellow = $"../Interactable/lever_yellow"
@onready var glitch_overlay: Sprite2D = $SubViewport/GlitchOverlay
@onready var lamp_ap: AnimationPlayer = $"../lampAP"
@onready var lightroof_ap: AnimationPlayer = $"../rooflamp/lightroofAP"
@onready var end_screen: AnimationPlayer = $"../EndScreen"

# --- config da trava ---
@export var glitch_check_interval: float = 10.0
@export var glitch_chance: float = 0.25
@export var cooldown_after_fix: float = 15.0


# --- estado ---
var minigame_active: bool = false
var is_screen_glitched: bool = false
var yellow_pulls_needed: int = 1  # 1 ciclo (desce + sobe) = 2 puxadas fisicas
var yellow_pulls_done: int = 0
var _check_timer: float = 0.0
var _cooldown_timer: float = 0.0

func _ready() -> void:
	GlobalScript.endComputerAnim = lamp_ap
	GlobalScript.quota_finished_signal.connect(hide_screen)
	GlobalScript.game_over_signal.connect(failure_screen)
	GlobalScript.sleep_signal.connect(_reset_sleep)
	if glitch_overlay:
		glitch_overlay.modulate.a = 0.0
	if lever_yellow:
		lever_yellow.interacted.connect(_on_lever_yellow_interacted)
		lever_yellow.is_enabled = false

func _process(delta: float) -> void:
	if not minigame_active or is_screen_glitched:
		return
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		return
	
	_check_timer += delta
	if _check_timer >= glitch_check_interval:
		_check_timer = 0.0
		if randf() < glitch_chance:
			_start_glitch()

func _reset_sleep() -> void:
	ended_quota.play_backwards("dailyReset")
	minigame_active = false
	is_screen_glitched = false
	glitch_overlay.modulate.a = 0.0
	yellow_pulls_done = 0
	_check_timer = 0.0
	_cooldown_timer = 0.0
	if lever_yellow:
		lever_yellow.force_reset_visual()
		lever_yellow.is_enabled = false

func hide_screen() -> void:
	ended_quota.play("okquotaEnded")
	
func failure_screen() -> void:
	ended_quota.play("notokquotaEnded")
	lightroof_ap.play("rooflamp_off")
	await get_tree().create_timer(14.0).timeout
	end_screen.play("end_screen")
func _on_lever_green_interacted() -> void:
	computer_screen.visible = true
	lever_red.activate()

# conectar no editor: lever_red.interacted -> Computer._on_lever_red_interacted
func _on_lever_red_interacted() -> void:
	minigame_active = true
	_check_timer = 0.0

# --- glitch / trava ---
func _start_glitch() -> void:
	is_screen_glitched = true
	yellow_pulls_done = 0
	# habilita a alavanca amarela pro player consertar
	if lever_yellow:
		lever_yellow.reset_lever()
		lever_yellow.activate()
	# aviso: 3 piscadas rapidas e depois trava de vez
	var tw := create_tween()
	tw.set_loops(3)
	tw.tween_property(glitch_overlay, "modulate:a", 0.5, 0.15)
	tw.tween_property(glitch_overlay, "modulate:a", 0.0, 0.15)
	tw.chain().tween_property(glitch_overlay, "modulate:a", 1.0, 0.4)

func _on_lever_yellow_interacted() -> void:
	if not is_screen_glitched:
		return
	yellow_pulls_done += 1
	if yellow_pulls_done >= yellow_pulls_needed:
		_end_glitch()

func _end_glitch() -> void:
	is_screen_glitched = false
	yellow_pulls_done = 0
	_cooldown_timer = cooldown_after_fix
	_check_timer = 0.0
	if lever_yellow:
		lever_yellow.force_reset_visual()
		lever_yellow.is_enabled = false
	var tw := create_tween()
	tw.tween_property(glitch_overlay, "modulate:a", 0.0, 0.5)
