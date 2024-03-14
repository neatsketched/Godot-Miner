extends Area3D

@export var shop_scene: PackedScene

var shop_obj: Object = null


func _on_body_entered(body):
	if body != Player.instance:
		return
	if shop_obj:
		return

	shop_obj = shop_scene.instantiate()
	var ui_layer = Player.instance.get_node("UILayer")
	ui_layer.add_child(shop_obj)
	shop_obj.get_x_button().pressed.connect(x_button_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func x_button_pressed():
	if shop_obj:
		shop_obj.queue_free()
		shop_obj = null
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
