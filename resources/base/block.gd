class_name Block extends Resource
## A Block resource containing information on a given block type

@export var block_type: Constants.BlockType
@export var material: StandardMaterial3D
@export var value: int
@export var spawn_range_min: int
@export var spawn_range_max: int
@export var spawn_weight: int
