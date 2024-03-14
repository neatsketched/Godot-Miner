class_name WorldBlockGrid extends Node3D

const StartBlocks: Array = [8, 8]

@export var block_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(StartBlocks[0]):
		for j in range(StartBlocks[1]):
			create_block(Vector3(i*2, 0, j*2), _get_random_block_type())

func _get_random_block_type() -> Constants.BlockType:
	# TODO: Make this actually random
	return Constants.BlockType.DIRT

func create_block(pos: Vector3, block_type: Constants.BlockType) -> void:
	var block_resource = Constants.get_block_resource_from_type(block_type)
	var new_block = block_scene.instantiate()
	new_block.block_resource = block_resource
	add_child(new_block)
	new_block.position = pos
	new_block.s_break_block.connect(break_block)

func break_block(block: WorldBlock) -> void:
	PlayerStats.add_block_to_inventory(block.block_resource.block_type, 1)
	block.s_break_block.disconnect(break_block)
	block.break_block()
