extends Node3D

const RAY_LENGTH = 8

var last_block_hit: WorldBlock = null:
	set(x):
		if last_block_hit and is_instance_valid(last_block_hit):
			last_block_hit.selected = false
			if last_block_hit.breaking_block:
				last_block_hit.stop_attempt_break_block()
			last_block_hit.tree_exited.disconnect(lost_last_block_hit)
			Signals.s_break_block_ui_invalid_selection_end.emit()

		last_block_hit = x

		if last_block_hit:
			last_block_hit.selected = true
			last_block_hit.tree_exited.connect(lost_last_block_hit)

			if not last_block_hit.is_valid_for_selection():
				Signals.s_break_block_ui_invalid_selection_begin.emit()

			# If we target a new block and the break is still held,
			# then go ahead and begin breaking this new one
			if Input.is_action_pressed("break_block"):
				last_block_hit.begin_attempt_break_block()

func lost_last_block_hit() -> void:
	last_block_hit = null

func _process(_delta) -> void:
	if not last_block_hit:
		return

	if Input.is_action_just_pressed("break_block"):
		last_block_hit.begin_attempt_break_block()
	elif Input.is_action_just_released("break_block"):
		last_block_hit.stop_attempt_break_block()

func _physics_process(_delta) -> void:
	if not Player.instance:
		return

	var space_state = get_world_3d().direct_space_state
	var cam = Player.instance.get_node("RotationHelper/Camera")
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	# If we have a result, and the result has a collider, and the collider is a world block,
	# and the world block is not the same as our currently selected one, then select the new one
	if result and result.collider and result.collider is WorldBlock and result.collider != last_block_hit:
		last_block_hit = result.collider
	# If we don't have a result, or the collider isn't a world block, then clear the last hit
	elif ((not result) or (not result.collider is WorldBlock)) and last_block_hit and is_instance_valid(last_block_hit):
		last_block_hit = null
