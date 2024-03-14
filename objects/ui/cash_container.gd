extends PanelContainer

@onready var cash_label = %CashLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	update_cash_label()
	PlayerStats.money_changed.connect(update_cash_label)

func _exit_tree():
	PlayerStats.money_changed.disconnect(update_cash_label)

func update_cash_label():
	cash_label.text = 'Cash: $' + str(PlayerStats.money)
