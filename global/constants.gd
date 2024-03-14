class_name Constants extends RefCounted

enum BlockType {
	# Nothing is a block that doesn't exist yet
	NOTHING,
	# Air is a broken block type, indicating that nothing should spawn here
	AIR,
	# Generic, not particularly valuable block types
	DIRT, STONE, GRANITE, OBSIDIAN,
	# Ores and valuables
	COPPER, SILVER, GOLD, DIAMOND, PLATINUM
}

static var BlockToResource: Dictionary = {
	BlockType.NOTHING: load("res://resources/blocks/air.tres"),
	BlockType.AIR: load("res://resources/blocks/air.tres"),
	BlockType.DIRT: load("res://resources/blocks/dirt.tres"),
	BlockType.STONE: load("res://resources/blocks/stone.tres"),
}

static func get_block_resource_from_type(block_type: BlockType) -> Block:
	var block_resource = BlockToResource.get(block_type)
	if not block_resource:
		print("WARNING! Invalid block type: " + str(block_type))
		return BlockToResource[BlockType.NOTHING]
	return block_resource
