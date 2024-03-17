extends Button


func _process(_delta):
	if Input.is_action_just_pressed("teleport_surface"):
		_on_pressed()

func _on_pressed():
	if Constants.calculate_teleport_time() < 5:
		# Just do an instant teleport man no one cares
		Signals.s_teleport_surface_done.emit()
		return
	Signals.s_teleport_surface.emit()
