class_name WorldBlockGrid extends Node3D

const LayerSize: Array = [8, 8]
const SpotsAroundBlocks: Array = [
	Vector3(-1, 0, 0), Vector3(1, 0, 0),
	Vector3(0, 0, -1), Vector3(0, 0, 1),
	Vector3(0, 1, 0), Vector3(0, -1, 0),
]

@export var block_scene: PackedScene

var block_state_matrix: Dictionary = {}


func _ready() -> void:
	_create_blocks_on_layer(0)

func _create_blocks_on_layer(layer: int) -> void:
	var x_size = LayerSize[0]
	var z_size = LayerSize[1]
	if layer > 0:
		# Add an extra block around the border if depth 1 or below
		# so that we can add "bedrock" blocks that can't be broken
		x_size += 2
		z_size += 2
	for i in range(x_size):
		for j in range(z_size):
			var block_pos = Vector3(i, j, layer)
			var block_type = _get_random_block_type(block_pos)
			create_block(block_pos, block_type)

func _get_random_block_type(block_pos: Vector3) -> Constants.BlockType:
	var real_x = int(round(block_pos.x))
	var real_y = int(round(block_pos.y))
	var real_z = int(round(block_pos.z))
	var want_bedrock_x = real_x >= LayerSize[0] or real_x <= -1
	var want_bedrock_y = real_y >= LayerSize[0] or real_y <= -1
	if (want_bedrock_x or want_bedrock_y) and real_z == 1:
		return Constants.BlockType.BEDROCK

	var possible_blocks: Array[Constants.BlockType] = Constants.get_valid_blocks_for_depth(real_z)
	var spawn_weights: Dictionary = {}
	for block_type in possible_blocks:
		spawn_weights[Constants.get_block_spawn_weight(block_type)] = block_type

	return Constants.random_weights(spawn_weights)

func create_block(pos: Vector3, block_type: Constants.BlockType) -> void:
	var block_resource = Constants.get_block_resource_from_type(block_type)
	var new_block = block_scene.instantiate()
	new_block.block_resource = block_resource
	new_block.block_position = pos
	add_child(new_block)
	new_block.position = Vector3((pos.x)*Constants.BlockSize, pos.z*-Constants.BlockSize, (pos.y)*Constants.BlockSize)
	_add_block_to_matrix(new_block, block_type)
	new_block.s_break_block.connect(break_block)

func break_block(block: WorldBlock) -> void:
	PlayerStats.add_block_to_inventory(block.block_resource.block_type, 1)
	# Mark this block to now be air, so it won't have stuff spawn in its place
	_add_block_to_matrix(block, Constants.BlockType.AIR)

	# Need to create all of the blocks that may be visible around this block
	_create_blocks_around_block(block)

	block.s_break_block.disconnect(break_block)
	block.break_block()

func _create_blocks_around_block(block: WorldBlock) -> void:
	var block_pos: Vector3 = block.block_position
	var viable_positions: Array[Vector3] = []
	for delta_vec in SpotsAroundBlocks:
		var temp_vec = Vector3(block_pos.x + delta_vec.x, block_pos.y + delta_vec.y, block_pos.z + delta_vec.z)
		if int(round(temp_vec.z)) > 0 and not _is_block_in_matrix(temp_vec):
			viable_positions.append(temp_vec)

	for new_block_pos in viable_positions:
		create_block(new_block_pos, _get_random_block_type(new_block_pos))

func _add_block_to_matrix(block: WorldBlock, block_type: Constants.BlockType):
	var pos = block.block_position
	var real_x = int(round(pos.x))
	var real_y = int(round(pos.y))
	var real_z = int(round(pos.z))
	block_state_matrix[Vector3(real_x, real_y, real_z)] = block_type

func _is_block_in_matrix(pos: Vector3) -> bool:
	var real_x = int(round(pos.x))
	var real_y = int(round(pos.y))
	var real_z = int(round(pos.z))
	return Vector3(real_x, real_y, real_z) in block_state_matrix.keys()
