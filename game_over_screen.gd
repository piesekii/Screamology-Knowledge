extends CanvasLayer

@onready var fade: ColorRect = $Fade
@onready var label: Label = $GameOverLabel

func _ready() -> void:
	fade.modulate.a = 0.0
	label.modulate.a = 0.0
	GlobalScript.game_over_signal.connect(_on_game_over)

func _on_game_over() -> void:
	# Fase 1: fade preto entrando
	var tw_in := create_tween()
	tw_in.tween_property(fade, "modulate:a", 1.0, 1.2)
	
	# Fase 2: segura preto puro (cena recarrega no meio disso)
	await get_tree().create_timer(4.0).timeout
	
	# Fase 3: fade out revelando cena nova
	var tw_out := create_tween()
	tw_out.tween_property(fade, "modulate:a", 0.0, 1.0)
