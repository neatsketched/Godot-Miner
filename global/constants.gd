class_name Constants extends RefCounted

enum BlockType {
	# Nothing is a block that doesn't exist yet
	NOTHING,
	# Air is a broken block type, indicating that nothing should spawn here
	AIR,
	# Generic, not particularly valuable block types
	DIRT, STONE, GRANITE, OBSIDIAN,
	# Ores and valuables
	COPPER, SILVER, GOLD, DIAMOND, PLATINUM,
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
	# Ores
	BlockType.COPPER: load("res://resources/blocks/copper.tres"),
	BlockType.SILVER: load("res://resources/blocks/silver.tres"),
	BlockType.GOLD: load("res://resources/blocks/gold.tres"),
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
}

static var PickaxeToResource: Dictionary = {
	PickaxeType.SHODDY: load("res://resources/pickaxes/shoddy_pickaxe.tres"),
	PickaxeType.STANDARD: load("res://resources/pickaxes/standard_pickaxe.tres"),
	PickaxeType.REINFORCED: load("res://resources/pickaxes/reinforced_pickaxe.tres"),
	PickaxeType.SUPREME: load("res://resources/pickaxes/supreme_pickaxe.tres"),
	PickaxeType.OMEGA: load("res://resources/pickaxes/omega_pickaxe.tres"),
}

static func get_pickaxe_resource_from_type(pickaxe_type: PickaxeType) -> Pickaxe:
	var pickaxe_resource = PickaxeToResource.get(pickaxe_type)
	if not pickaxe_resource:
		print("WARNING! Invalid pickaxe type: " + str(pickaxe_type))
		return PickaxeToResource[PickaxeType.SHODDY]
	return pickaxe_resource

static func random_weights(d: Dictionary):
	var weight_sum: float = d.keys().reduce(func (x, y): return x+y)
	var weight_rng: float = randf() * weight_sum
	var tw: float = 0
	for w in d.keys():
		tw += w
		if weight_rng <= tw:
			return d[w]

static func calculate_teleport_time() -> int:
	# Teleport time is equal to the player's depth (in blocks) divided by 10
	if not Player.instance:
		return 5
	return int(round(Player.instance.global_position.y / (-10*BlockSize)))

static func get_player_depth_value() -> int:
	if not Player.instance:
		return 0
	return max(int(1+round(Player.instance.global_position.y / -BlockSize)), 0)

static func calculate_break_time(block: WorldBlock) -> float:
	var pickaxe_resource = get_pickaxe_resource_from_type(PlayerStats.pickaxe_type)
	return 4.0 * block.block_resource.break_time * (1/pickaxe_resource.break_time)
