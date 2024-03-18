class_name Constants extends RefCounted

enum BlockType {
	# Nothing is a block that doesn't exist yet
	NOTHING,
	# Air is a broken block type, indicating that nothing should spawn here
	AIR,
	# Generic, not particularly valuable block types
	DIRT, STONE, GRANITE, OBSIDIAN,
	# Ores and valuables
	COPPER, SILVER, GOLD, DIAMOND, VERANTITE,
	# Unbreakable block type
	BEDROCK,
}

const BlockSize: int = 2
# These blocks can't be selected/broken
const UnbreakableBlocks = [BlockType.AIR, BlockType.NOTHING, BlockType.BEDROCK]

static var BlockToResource: Dictionary = {
	BlockType.NOTHING: load("res://resources/blocks/air.tres"),
	BlockType.AIR: load("res://resources/blocks/air.tres"),
	# Generics
	BlockType.DIRT: load("res://resources/blocks/dirt.tres"),
	BlockType.STONE: load("res://resources/blocks/stone.tres"),
	BlockType.GRANITE: load("res://resources/blocks/granite.tres"),
	# Ores
	BlockType.COPPER: load("res://resources/blocks/copper.tres"),
	BlockType.SILVER: load("res://resources/blocks/silver.tres"),
	BlockType.GOLD: load("res://resources/blocks/gold.tres"),
	BlockType.DIAMOND: load("res://resources/blocks/diamond.tres"),
	BlockType.VERANTITE: load("res://resources/blocks/verantite.tres"),
	# Unbreakable
	BlockType.BEDROCK: load("res://resources/blocks/bedrock.tres"),
}

static func get_block_resource_from_type(block_type: BlockType) -> Block:
	var block_resource = BlockToResource.get(block_type)
	if not block_resource:
		print("WARNING! Invalid block type: " + str(block_type))
		return BlockToResource[BlockType.NOTHING]
	return block_resource

static func get_block_spawn_weight(block_type: BlockType) -> int:
	var block_resource = BlockToResource.get(block_type)
	if not block_resource:
		print("WARNING! Invalid block type: " + str(block_type))
		return 0
	return block_resource.spawn_weight

static func get_valid_blocks_for_depth(depth: int) -> Array[BlockType]:
	var valid_types: Array[BlockType] = []

	for block_type in BlockToResource.keys():
		if block_type in [BlockType.NOTHING, BlockType.AIR]:
			continue
		var block_resource = BlockToResource[block_type]
		if depth >= block_resource.spawn_range_min and depth <= block_resource.spawn_range_max:
			valid_types.append(block_type)

	if valid_types.size() == 0:
		# If we have nothing, just throw in bedrock at this point
		valid_types.append(BlockType.BEDROCK)

	return valid_types

enum PickaxeType {
	# The base pickaxe you start with
	SHODDY,
	# Quick upgrade as part of the tutorial
	STANDARD,
	# Actual upgraded pickaxes
	REINFORCED,
	SUPREME,
	OMEGA,
	ZENITH,
}

static var PickaxeToResource: Dictionary = {
	PickaxeType.SHODDY: load("res://resources/pickaxes/shoddy_pickaxe.tres"),
	PickaxeType.STANDARD: load("res://resources/pickaxes/standard_pickaxe.tres"),
	PickaxeType.REINFORCED: load("res://resources/pickaxes/reinforced_pickaxe.tres"),
	PickaxeType.SUPREME: load("res://resources/pickaxes/supreme_pickaxe.tres"),
	PickaxeType.OMEGA: load("res://resources/pickaxes/omega_pickaxe.tres"),
	PickaxeType.ZENITH: load("res://resources/pickaxes/zenith_pickaxe.tres"),
}

static func get_pickaxe_resource_from_type(pickaxe_type: PickaxeType) -> Pickaxe:
	var pickaxe_resource = PickaxeToResource.get(pickaxe_type)
	if not pickaxe_resource:
		print("WARNING! Invalid pickaxe type: " + str(pickaxe_type))
		return PickaxeToResource[PickaxeType.SHODDY]
	return pickaxe_resource

enum ShopItemType {
	# Pickaxes
	STANDARD_PICKAXE,
	REINFORCED_PICKAXE,
	SUPREME_PICKAXE,
	OMEGA_PICKAXE,
	# Placeholder no item
	NO_ITEM,
	# Inventory space
	INVENTORY_SPACE_25,    # 25 -> 50
	INVENTORY_SPACE_50,    # 50 -> 100
	INVENTORY_SPACE_100,   # 100 -> 200
	INVENTORY_SPACE_150,   # 200 -> 350
	INVENTORY_SPACE_250,   # 350 -> 600
	INVENTORY_SPACE_400,   # 600 -> 1000
	INVENTORY_SPACE_750,   # 1000 -> 1750
	INVENTORY_SPACE_1250,  # 1750 -> 3000
	ZENITH_PICKAXE,
}

static var ShopItemToResource: Dictionary = {
	ShopItemType.STANDARD_PICKAXE: load("res://resources/shopitems/item_pickaxe_standard.tres"),
	ShopItemType.REINFORCED_PICKAXE: load("res://resources/shopitems/item_pickaxe_reinforced.tres"),
	ShopItemType.SUPREME_PICKAXE: load("res://resources/shopitems/item_pickaxe_supreme.tres"),
	ShopItemType.OMEGA_PICKAXE: load("res://resources/shopitems/item_pickaxe_omega.tres"),
	ShopItemType.INVENTORY_SPACE_25: load("res://resources/shopitems/item_inventory_25.tres"),
	ShopItemType.INVENTORY_SPACE_50: load("res://resources/shopitems/item_inventory_50.tres"),
	ShopItemType.INVENTORY_SPACE_100: load("res://resources/shopitems/item_inventory_100.tres"),
	ShopItemType.INVENTORY_SPACE_150: load("res://resources/shopitems/item_inventory_150.tres"),
	ShopItemType.INVENTORY_SPACE_250: load("res://resources/shopitems/item_inventory_250.tres"),
	ShopItemType.INVENTORY_SPACE_400: load("res://resources/shopitems/item_inventory_400.tres"),
	ShopItemType.INVENTORY_SPACE_750: load("res://resources/shopitems/item_inventory_750.tres"),
	ShopItemType.INVENTORY_SPACE_1250: load("res://resources/shopitems/item_inventory_1250.tres"),
	ShopItemType.ZENITH_PICKAXE: load("res://resources/shopitems/item_pickaxe_zenith.tres"),
}

static func random_weights(d: Dictionary):
	var weight_sum: float = d.keys().reduce(func (x, y): return x+y)
	var weight_rng: float = randf() * weight_sum
	var tw: float = 0
	for w in d.keys():
		tw += w
		if weight_rng <= tw:
			return d[w]

static func calculate_teleport_time() -> int:
	# Teleport time is equal to the player's depth (in blocks) divided by 15
	if not Player.instance:
		return 5
	return int(round(Player.instance.global_position.y / (-15*BlockSize)))

static func get_player_depth_value() -> int:
	if not Player.instance:
		return 0
	return max(int(1+round(Player.instance.global_position.y / -BlockSize)), 0)

static func calculate_break_time(block: WorldBlock) -> float:
	var pickaxe_resource = get_pickaxe_resource_from_type(PlayerStats.pickaxe_type)
	return 4.0 * block.block_resource.break_time * (1/pickaxe_resource.break_time)
