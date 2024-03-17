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

static var BlockToResource: Dictionary = {
	BlockType.NOTHING: load("res://resources/blocks/air.tres"),
	BlockType.AIR: load("res://resources/blocks/air.tres"),
	# Generics
	BlockType.DIRT: load("res://resources/blocks/dirt.tres"),
	BlockType.STONE: load("res://resources/blocks/stone.tres"),
	# Ores
	BlockType.COPPER: load("res://resources/blocks/copper.tres"),
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

static func random_weights(d: Dictionary):
	var weight_sum: float = d.keys().reduce(func (x, y): return x+y)
	var weight_rng: float = randf() * weight_sum
	var tw: float = 0
	for w in d.keys():
		tw += w
		if weight_rng <= tw:
			return d[w]
