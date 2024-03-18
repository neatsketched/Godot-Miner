class_name WorldBlock extends StaticBody3D

signal s_break_block

static var break_material: BlockBreakMaterial = preload("res://assets/material/break_material.tres")

@onready var block_mesh = %BlockMesh
@onready var block_coll = %BlockCollision
@onready var death_timer = %DeathTimer
@onready var particle_timer = %ParticleTimer
@onready var block_particles = %BlockParticles
@onready var air_resource = load("res://resources/blocks/air.tres")

var standard_color = Color.WHITE
var local_break_mat: BlockBreakMaterial = null
var breaking_block: bool = false
var break_timer: Timer = null

@export var block_resource: Block
@export var block_position := Vector3(0, 0, 0)
@export var selected := false:
	set(x):
		selected = x
		var albedo_color = Color.WHITE
		if selected:
			albedo_color = Color(0.7, 0.7, 1, 1) if is_valid_for_selection() else Color(1, 0.6, 0.6, 1)
		else:
			albedo_color = standard_color
		block_mesh.get_surface_override_material(0).albedo_color = albedo_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_block_mesh()
	# Add the break material as another material overlaying the block
	local_break_mat = break_material.duplicate()
	block_mesh.get_surface_override_material(0).next_pass = local_break_mat

func update_block_mesh() -> void:
	# Set the material on the block mesh to be our stored material from the resource
	block_mesh.set_surface_override_material(0, block_resource.material.duplicate())
	standard_color = block_mesh.get_surface_override_material(0).albedo_color

func begin_attempt_break_block() -> void:
	if not is_valid_for_selection():
		return
	if breaking_block:
		return

	breaking_block = true
	if break_timer:
		break_timer.queue_free()
	break_timer = Timer.new()
	add_child(break_timer)
	break_timer.timeout.connect(_progress_break_stage)
	var total_break_time = Constants.calculate_break_time(self)
	var individual_break_time = total_break_time / BlockBreakMaterial.BreakStage.keys().size()
	break_timer.start(individual_break_time)
	Signals.s_break_block_ui_begin.emit(total_break_time)

func stop_attempt_break_block() -> void:
	breaking_block = false
	if break_timer:
		break_timer.queue_free()
		break_timer = null
	local_break_mat.break_stage = BlockBreakMaterial.BreakStage.NONE
	Signals.s_break_block_ui_end.emit()

func _progress_break_stage() -> void:
	if local_break_mat.break_stage == BlockBreakMaterial.BreakStage.SEVEN:
		emit_break_block()
	else:
		local_break_mat.progress_break_stage()

func emit_break_block():
	stop_attempt_break_block()
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
	if block_resource.block_type in Constants.UnbreakableBlocks:
		return false
	elif block_resource.break_strength > Constants.get_pickaxe_resource_from_type(PlayerStats.pickaxe_type).break_strength:
		return false
	elif PlayerStats.is_inventory_full():
		return false
	return true
