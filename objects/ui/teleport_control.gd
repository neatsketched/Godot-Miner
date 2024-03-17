extends Control

@onready var teleport_particles = %TeleportParticles
@onready var depth_remain_label = %TeleportingLabelDepthRemain
@onready var dots_label = %TeleportingLabelDots
@onready var teleport_timer = %TeleportTimer
@onready var dots_timer = %DotsTimer

var teleport_tween: Tween = null
var teleport_time: int = 0

func _ready():
	Signals.s_teleport_surface.connect(_begin_teleport)

func _begin_teleport():
	if teleport_time <= 0:
		# Only begin the teleporting sequence if we don't already have one active
		_teleport_visual_begin(Constants.calculate_teleport_time())

func _timer_done():
	teleport_time = 0
	_teleport_visual_cleanup()

func _teleport_visual_begin(new_time: int):
	teleport_time = new_time
	teleport_particles.emitting = true
	dots_timer.start()
	# Connect to teleport timer that cleans up this screen when its done
	teleport_timer.start(new_time)
	teleport_timer.timeout.connect(_timer_done)
	# Set time/depth on the depth label that counts down
	depth_remain_label.total_time = new_time
	depth_remain_label.depth = Constants.get_player_depth_value()
	depth_remain_label.update_time_left()
	# Move the mouse to 'standard' mode while on the TP screen
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	_begin_teleport_tween()

func _teleport_visual_cleanup():
	teleport_particles.emitting = false
	dots_timer.stop()
	if teleport_timer.timeout.is_connected(_timer_done):
		teleport_timer.timeout.disconnect(_timer_done)
	teleport_timer.stop()
	depth_remain_label.total_time = 0
	depth_remain_label.depth = 0
	# Move mouse control back to "captured" (first person) mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Call the actual signal that will take the player to the surface
	Signals.s_teleport_surface_done.emit()
	_end_teleport_tween()

func _begin_teleport_tween():
	_cleanup_tween()
	teleport_tween = create_tween()
	teleport_tween.tween_property(self, "modulate:a", 1, 1.0)

func _end_teleport_tween():
	_cleanup_tween()
	teleport_tween = create_tween()
	teleport_tween.tween_property(self, "modulate:a", 0, 1.0)
	
	var hide_me_func = func():
		visible = false
	
	teleport_tween.tween_callback(hide_me_func)

func _cleanup_tween():
	if teleport_tween:
		teleport_tween.kill()
		teleport_tween = null

func _exit_tree():
	_cleanup_tween()
	Signals.s_teleport_surface.disconnect(_begin_teleport)
