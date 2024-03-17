extends Control

var teleport_tween: Tween = null

@onready var teleport_particles = %TeleportParticles
@onready var depth_remain_label = %TeleportingLabelDepthRemain
@onready var dots_label = %TeleportingLabelDots
@onready var teleport_timer = %TeleportTimer
@onready var dots_timer = %DotsTimer

@export var teleport_time: int = 0:
	set(x):
		teleport_time = x
		if teleport_time > 0:
			teleport_particles.emitting = true
			dots_timer.start()
			teleport_timer.start(x)
			teleport_timer.timeout.connect(_timer_done)
			depth_remain_label.total_time = x
			depth_remain_label.depth = Constants.get_player_depth_value()
			# Do an initial update on this so the time remaining isn't weird for a few frames
			depth_remain_label.update_time_left()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_filter = Control.MOUSE_FILTER_STOP
			_begin_teleport_tween()
		else:
			teleport_particles.emitting = false
			dots_timer.stop()
			if teleport_timer.timeout.is_connected(_timer_done):
				teleport_timer.timeout.disconnect(_timer_done)
			teleport_timer.stop()
			depth_remain_label.total_time = 0
			depth_remain_label.depth = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			Signals.s_teleport_surface_done.emit()
			_end_teleport_tween()
			
func _ready():
	Signals.s_teleport_surface.connect(_begin_teleport)

func _begin_teleport():
	if teleport_time <= 0:
		# Only begin the teleporting sequence if we don't already have one active
		teleport_time = Constants.calculate_teleport_time()

func _timer_done():
	teleport_time = 0

func _begin_teleport_tween():
	_cleanup_tween()
	teleport_tween = create_tween()
	teleport_tween.tween_property(self, "modulate:a", 1, 1.0)

func _end_teleport_tween():
	_cleanup_tween()
	teleport_tween = create_tween()
	teleport_tween.tween_property(self, "modulate:a", 0, 1.0)

func _cleanup_tween():
	if teleport_tween:
		teleport_tween.kill()
		teleport_tween = null

func _exit_tree():
	_cleanup_tween()
	Signals.s_teleport_surface.disconnect(_begin_teleport)
