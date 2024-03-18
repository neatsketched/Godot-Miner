extends Control

@export var block_inventory_entry: PackedScene
@export var shop_item_entry: PackedScene

@onready var sell_button = %SellButton
@onready var sell_value_label = %SellValueLabel
@onready var inventory_container = %InventoryContainer

@onready var upgrade_buy_button = %SelectedUpgradeButton
@onready var upgrade_title_label = %SelectedUpgradeTitle
@onready var upgrade_desc_label = %SelectedUpgradeDesc
@onready var upgrade_icon = %UpgradeIcon
@onready var upgrade_cost_label = %SelectedUpgradeCost
@onready var upgrade_container = %UpgradesContainer

var block_panels: Array = []
var upgrade_panels: Array = []

var selected_upgrade = null:
	set(x):
		selected_upgrade = x

		upgrade_title_label.text = selected_upgrade.name
		upgrade_desc_label.text = selected_upgrade.desc
		upgrade_cost_label.text = 'Cost: $' + str(selected_upgrade.cost)
		upgrade_icon.texture = selected_upgrade.image

		if x.shop_item_type in PlayerStats.items:
			upgrade_buy_button.text = 'Purchased!'
		elif selected_upgrade.cost > PlayerStats.money:
			upgrade_buy_button.text = 'Too Expensive!'
		else:
			upgrade_buy_button.text = 'Purchase'


# Called when the node enters the scene tree for the first time.
func _ready():
	update_inventory()
	update_items()
	PlayerStats.inventory_changed.connect(update_inventory)
	PlayerStats.money_changed.connect(update_money)
	PlayerStats.items_changed.connect(update_items)

func _exit_tree():
	PlayerStats.inventory_changed.disconnect(update_inventory)
	PlayerStats.money_changed.disconnect(update_money)
	PlayerStats.items_changed.disconnect(update_items)

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

func _on_selected_upgrade_button_pressed():
	if not selected_upgrade:
		return
	if selected_upgrade.shop_item_type in PlayerStats.items:
		return
	if PlayerStats.money < selected_upgrade.cost:
		return
	PlayerStats.add_shop_item(selected_upgrade.shop_item_type)
	PlayerStats.money -= selected_upgrade.cost

func update_money() -> void:
	if not selected_upgrade:
		return
	if selected_upgrade.shop_item_type in PlayerStats.items:
		return
	if selected_upgrade.cost <= PlayerStats.money:
		return
	upgrade_buy_button.text = 'Too Expensive!'

func update_items() -> void:
	if selected_upgrade and selected_upgrade.shop_item_type in PlayerStats.items:
		upgrade_buy_button.text = 'Purchased!'

	for upgrade_panel in upgrade_panels:
		upgrade_panel.queue_free()
	upgrade_panels = []

	for shop_item_type in Constants.ShopItemToResource.keys():
		if shop_item_type in PlayerStats.items:
			continue

		var new_panel = shop_item_entry.instantiate()
		upgrade_container.add_child(new_panel)
		new_panel.shop_item_type = shop_item_type
		upgrade_panels.append(new_panel)
		new_panel.pressed.connect(func(): _select_upgrade(shop_item_type))

func _select_upgrade(shop_item_type: Constants.ShopItemType):
	selected_upgrade = Constants.ShopItemToResource[shop_item_type]
