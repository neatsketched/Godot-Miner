class_name WorldBlock extends StaticBody3D

signal s_break_block

@onready var block_mesh = %BlockMesh
@onready var block_coll = %BlockCollision
@onready var death_timer = %DeathTimer
@onready var particle_timer = %ParticleTimer
@onready var block_particles = %BlockParticles
@onready var air_resource = load("res://resources/blocks/air.tres")

var standard_color = Color.WHITE

@export var block_resource: Block
@export var block_position := Vector3(0, 0, 0)
@export var selected := false:
	set(x):
		selected = x
		var albedo_color = Color.SKY_BLUE if selected else standard_color
		block_mesh.get_surface_override_material(0).albedo_color = albedo_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_block_mesh()

func update_block_mesh() -> void:
	# Set the material on the block mesh to be our stored material from the resource
	block_mesh.set_surface_override_material(0, block_resource.material.duplicate())
	standard_color = block_mesh.get_surface_override_material(0).albedo_color

func attempt_break_block() -> void:
	if not is_valid_for_selection():
		return

	s_break_block.emit(self)

func break_block() -> void:
	block_coll.disabled = true
	block_particles.draw_pass_1.material = block_resource.material.duplicate()
	block_particles.emitting = true
	# Just in case change this blocks resource to air
	block_resource = air_resource.duplicate()
	block_mesh.visible = false
	update_block_mesh()
	death_timer.timeout.connect(queue_free)
	death_timer.start()
	particle_timer.timeout.connect(stop_particles)
	particle_timer.start()

func stop_particles() -> void:
	block_particles.emitting = false

func is_valid_for_selection() -> bool:
	return block_resource.block_type not in Constants.UnbreakableBlocks
