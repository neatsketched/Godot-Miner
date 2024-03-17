extends Label

@onready var dots_timer = %DotsTimer
var curr_dots: int = 1


func _on_dots_timer_timeout():
	curr_dots += 1
	if curr_dots >= 4:
		curr_dots = 1
	match curr_dots:
		1:
			text = '.'
		2:
			text = '..'
		3:
			text = '...'
