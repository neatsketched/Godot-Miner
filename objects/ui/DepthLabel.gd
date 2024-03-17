extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.instance:
		text = 'Depth: ' + str(Constants.get_player_depth_value())
