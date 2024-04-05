extends ProgressBar

var total_break_time: float = 0
var start_time: float = 0
var active_time: float = 0
var active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.s_break_block_ui_begin.connect(_begin_break)
	Signals.s_break_block_ui_end.connect(_end_break)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not active:
		return

	active_time += delta
	value = int(round(100 * (active_time / total_break_time)))

func _begin_break(break_time: float):
	total_break_time = break_time
	active = true
	start_time = Time.get_unix_time_from_system()
	active_time = 0
	visible = true

func _end_break():
	total_break_time = 0
	active = false
	start_time = 0
	active_time = 0
	visible = false
