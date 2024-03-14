extends Node

signal inventory_changed
signal money_changed

var inventory: Dictionary = {}
var money: int = 0:
	set(x):
		money = x
		money_changed.emit()


func add_block_to_inventory(block_type: Constants.BlockType, quantity: int) -> void:
	if quantity < 1:
		print('Invalid quantity to add block to inventory. Type: ' + str(block_type) + '. Quantity: ' + str(quantity))
		return

	if block_type in inventory.keys():
		inventory[block_type] = inventory[block_type] + quantity
	else:
		inventory[block_type] = quantity
	inventory_changed.emit()

func remove_block_from_inventory(block_type: Constants.BlockType, quantity: int) -> void:
	if quantity < 1:
		print('Invalid quantity to remove block from inventory. Type: ' + str(block_type) + '. Quantity: ' + str(quantity))
		return
	if not block_type in inventory.keys():
		print('Block type ' + str(block_type) + ' is not in inventory!')
		return

	inventory.erase(block_type)
	inventory_changed.emit()

func clear_inventory() -> void:
	inventory = {}
	inventory_changed.emit()

func get_inventory_quantity(block_type: Constants.BlockType) -> int:
	return inventory.get(block_type, 0)
