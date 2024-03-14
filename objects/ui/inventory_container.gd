extends VBoxContainer

@export var block_inventory_entry: PackedScene

var block_panels: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.inventory_changed.connect(update_inventory)

func _exit_tree():
	PlayerStats.inventory_changed.disconnect(update_inventory)

func update_inventory():
	for block_panel in block_panels:
		block_panel.queue_free()
	block_panels = []

	for block in PlayerStats.inventory.keys():
		var new_panel = block_inventory_entry.instantiate()
		add_child(new_panel)
		new_panel.block_type = block
		# Make sure this panel is at the top so that the ordering is correct
		move_child(new_panel, 0)
		block_panels.append(new_panel)
