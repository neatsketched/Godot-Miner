extends Button

@onready var upgrade_texture = %UpgradeTexture
@onready var upgrade_name_label = %UpgradeNameLabel
@onready var upgrade_cost_label = %UpgradeCostLabel

@export var shop_item_type := Constants.ShopItemType.STANDARD_PICKAXE:
	set(x):
		shop_item_type = x
		var shop_item_resource = Constants.ShopItemToResource[shop_item_type]
		upgrade_texture.texture = shop_item_resource.image.duplicate()
		upgrade_name_label.text = shop_item_resource.name
		upgrade_cost_label.text = '($' + str(shop_item_resource.cost) + ')'
