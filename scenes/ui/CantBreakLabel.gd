extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.s_break_block_ui_invalid_selection_begin.connect(_begin_invalid)
	Signals.s_break_block_ui_invalid_selection_end.connect(_end_invalid)

func _begin_invalid():
	visible = true
	if PlayerStats.is_inventory_full():
		text = 'Inventory Full!'
	else:
		text = 'Can\'t Break Block!'

func _end_invalid():
	visible = false
