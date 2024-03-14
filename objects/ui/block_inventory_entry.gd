extends PanelContainer

@onready var block_texture = %BlockTexture
@onready var block_name_label = %BlockNameLabel
@onready var block_quantity_label = %BlockQuantityLabel

@export var block_type := Constants.BlockType.DIRT:
	set(x):
		block_type = x
		var block_resource = Constants.BlockToResource[block_type]
		block_texture.texture = block_resource.material.albedo_texture.duplicate()
		block_name_label.text = block_resource.name
		block_quantity_label.text = '(x' + str(PlayerStats.get_inventory_quantity(block_type)) + ')'
