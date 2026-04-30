# ConveyorItem.gd
# Attach no Area2D da conveyor_item.tscn
# Adiciona um CollisionShape2D filho com RectangleShape2D de tamanho 80x80

extends Area2D

# ─────────────────────────────────────────────
#  ESTADO
# ─────────────────────────────────────────────
var item_data    : Dictionary = {}
var time_limit   : float      = 8.0
var time_elapsed : float      = 0.0
var resolved     : bool       = false

var _flash_t  : float = 0.0
var _vis      : bool  = true
const FLASH_INTERVAL : float = 0.15
const SPEED          : float = 1.545   # mesma velocidade dos gears existentes

# Cores
var _bg_color : Color = Color(0.9, 0.9, 0.9)

# ─────────────────────────────────────────────
#  SETUP
# ─────────────────────────────────────────────
func setup(data: Dictionary) -> void:
	item_data  = data
	time_limit = DayRules.get_item_time(data.get("is_flashing", false))

	if data.get("is_special", false):
		_bg_color = Color(0.55, 0.08, 0.08)

	queue_redraw()

# ─────────────────────────────────────────────
#  DRAW — desenha o quadrado e os símbolos
# ─────────────────────────────────────────────
func _draw() -> void:
	# Quadrado de fundo
	draw_rect(Rect2(-100, -100, 200, 200), _bg_color)
	draw_rect(Rect2(-100, -100, 200, 200), Color(0.3, 0.3, 0.3), false, 2.0)

	if item_data.get("is_special", false):
		draw_string(ThemeDB.fallback_font, Vector2(-8, 10), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1,1,1))
		return

	# Símbolos
	var symbols : Array = item_data.get("symbols", [])
	var total   : int   = symbols.size()
	if total == 0:
		return

	var spacing : float = 60.0 / max(total, 1)
	var start_x : float = -30.0 + spacing * 0.5

	for i in total:
		var sym  : Dictionary = symbols[i]
		var x    : float      = start_x + i * spacing
		var col  : Color
		var text : String

		match sym.get("type", "normal"):
			"normal":
				col  = Color(0.1, 0.1, 0.1)
				text = "●"
			"red":
				col  = Color(0.9, 0.1, 0.1)
				text = "●"
			"strikethrough":
				col  = Color(0.1, 0.1, 0.1)
				text = "✕"
			"triangle":
				col  = Color(0.1, 0.1, 0.8)
				text = "▲"

		draw_string(ThemeDB.fallback_font, Vector2(x - 8, 8), text,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 20, col)

# ─────────────────────────────────────────────
#  PROCESS — move + timer + piscar
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if resolved:
		return

	# Move igual ao gear existente
	position.x += SPEED

	if DayRules.is_crashed:
		return

	time_elapsed += delta

	# Escurece conforme o tempo passa
	if !item_data.get("is_special", false):
		var t : float = 1.0 - clampf(time_elapsed / time_limit, 0.0, 1.0)
		_bg_color = Color(0.4 + t * 0.5, 0.4 + t * 0.5, 0.4 + t * 0.5)
		queue_redraw()

	if time_elapsed >= time_limit:
		_expire()
		return

	if item_data.get("is_flashing", false):
		_flash_t += delta
		if _flash_t >= FLASH_INTERVAL:
			_flash_t = 0.0
			_vis     = !_vis
			modulate.a = 1.0 if _vis else 0.1

# ─────────────────────────────────────────────
#  RESOLUÇÃO
# ─────────────────────────────────────────────
func resolve_send() -> void:
	if resolved: return
	resolved = true
	DayRules.resolve_choice(true, item_data)
	_feedback(Color(0.2, 1.0, 0.4))

func resolve_discard() -> void:
	if resolved: return
	resolved = true
	DayRules.resolve_choice(false, item_data)
	_feedback(Color(1.0, 0.55, 0.1))

func _expire() -> void:
	if resolved: return
	resolved = true
	DayRules.resolve_expired(item_data)
	_feedback(Color(0.5, 0.5, 0.5, 0.5))

func _feedback(color: Color) -> void:
	modulate = color
	await get_tree().create_timer(0.22).timeout
	queue_free()
