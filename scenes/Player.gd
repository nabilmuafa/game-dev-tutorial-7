extends CharacterBody3D

@export var speed: float
@export var acceleration: float = 3.0
@export var gravity: float = 9.8
@export var jump_power: float = 4.5
@export var mouse_sensitivity: float = 0.3
@export var crouch_height: float = -0.5
@export var standing_height: float = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var camera_x_rotation: float = 0.0
var target_camera_height: float = 0.0

const CROUCH_SPEED = 4.0
const WALK_SPEED = 8.0
const SPRINT_SPEED = 16.0

#head bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
		
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		target_camera_height = standing_height
	elif Input.is_action_pressed("crouch"):
		speed = CROUCH_SPEED
		target_camera_height = crouch_height
	else:
		speed = WALK_SPEED
		target_camera_height = standing_height
		
	var input_dir = Input.get_vector("movement_left", "movement_right", "movement_forward", "movement_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * acceleration)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	var bob_offset = _headbob(t_bob)
	camera.transform.origin = bob_offset

	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	if target_camera_height == crouch_height:
		pos.y -= 0.5
	return pos
	
