extends Label

@export var depth: int = 0
@export var total_time: int = 0

@onready var teleport_control = get_parent()
@onready var dots_timer = %DotsTimer
@onready var teleport_timer = %TeleportTimer


func update_time_left():
	text = str(int(round(depth * (teleport_timer.time_left/total_time))))

func _process(_delta):
	if total_time:
		update_time_left()
