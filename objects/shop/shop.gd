extends Control

@export var block_inventory_entry: PackedScene

@onready var sell_button = %SellButton
@onready var sell_value_label = %SellValueLabel
@onready var inventory_container = %InventoryContainer

var block_panels: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	update_inventory()
	PlayerStats.inventory_changed.connect(update_inventory)

func _exit_tree():
	PlayerStats.inventory_changed.disconnect(update_inventory)

func _on_sell_button_pressed():
	var gained_money = calculate_money_gain()
	PlayerStats.money += gained_money
	
	PlayerStats.clear_inventory()

func calculate_money_gain() -> int:
	var money: int = 0
	for block_type in PlayerStats.inventory.keys():
		var quantity = PlayerStats.inventory[block_type]
		money += Constants.BlockToResource[block_type].value * quantity

	return money

func update_sell_value_label():
	sell_value_label.text = 'Total Sell Value:\n$' + str(calculate_money_gain())

func update_inventory():
	update_sell_value_label()

	for block_panel in block_panels:
		block_panel.queue_free()
	block_panels = []

	for block in PlayerStats.inventory.keys():
		var new_panel = block_inventory_entry.instantiate()
		inventory_container.add_child(new_panel)
		new_panel.block_type = block
		block_panels.append(new_panel)

func get_x_button() -> Button:
	return %XButton
