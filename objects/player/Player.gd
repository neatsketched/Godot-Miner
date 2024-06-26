class_name Player extends CharacterBody3D

static var instance: Player = null

@onready var camera: Camera3D = %Camera
@onready var rotation_helper: Node3D = %RotationHelper

const SPEED = 10.0
const JUMP_VELOCITY = 8.0
const SENSITIVITY = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_fov: float:
	get:
		return min(75 + max(0, abs(velocity.y) - 15), 150)

func _init():
	Player.instance = self

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Signals.s_teleport_surface_done.connect(_teleport_surface_done)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var direction = (rotation_helper.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	camera.fov = lerpf(camera.fov, target_fov, 0.1)

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_y(-event.relative.x*SENSITIVITY)
		camera.rotate_x(-event.relative.y*SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-85),deg_to_rad(85))

func _teleport_surface_done():
	# Move the player to the starting position
	global_position = Vector3(0, 3, 12.3)
	# Also clear out their rotation so they're not just facing a wall
	rotation_helper.rotate_y(-rotation_helper.rotation.y)
	camera.rotate_x(-camera.rotation.x)
