extends CharacterBody3D


@export var speed = 10
@export var jump_velocity = 4.5
@export var camera: Camera3D

var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0
@export var friction = 0.05
var acceleration = 1

# gamepad controls
var is_using_gamepad = true
var right_stick_look = Vector2(0,0)

# shooting
@onready var raycast = $RayCast3D


func _ready():
	# GuliKit Controller map for mac
	Input.add_joy_mapping("03000000790000001c18000000010000,GuliKit Controller A,a:b0,b:b1,y:b4,x:b3,start:b11,back:b10,leftstick:b13,rightstick:b14,leftshoulder:b6,rightshoulder:b7,dpup:b12,dpleft:b14,dpdown:b13,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a5,righttrigger:a4,platform:Mac OS X", true)
	if camera == null:
		camera = get_viewport().get_camera_3d()

func _physics_process(delta):
	# player movement and rotation
	update_position(delta)
	if is_using_gamepad:
		update_gamepad_rotation(delta)
	else:
		update_rotation()
	# player actions
	update_shooting()


# checking if player is using kb and mouse or gamepad
# this should only be run for player 1, as player 2 is always on gamepad
# player 1 might be on kb and player 2 on gamepad on the same device
# this needs to be resolved, perhaps with a is_multiplayer boolean or smt
func _input(event):
	if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		is_using_gamepad = true
	else:
		is_using_gamepad = false


func update_position(delta):
	# old movement code
	#var horizontal_velocity = Input.get_vector("move_left","move_right","move_up","move_down").normalized() * speed
	#velocity.x = horizontal_velocity.x
	#velocity.z = horizontal_velocity.y
	
	direction.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * speed
	direction.z = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * speed
	# jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity 
		else: 
			velocity_y = 0
		
		# slipperiness
		# acceleration variable is meaningless when we are already using speed
		if direction.length() > 0:
			velocity = Vector3((velocity.x + (direction.x - velocity.x) * acceleration), velocity.y, (velocity.z + (direction.z - velocity.z) * acceleration))
		else:
			velocity = Vector3((velocity.x + (0 - velocity.x) * friction), velocity.y, (velocity.z + (0 - velocity.z) * friction))
	else:
		velocity_y -= gravity * delta
		velocity.x = velocity.x + (direction.x - velocity.x) * acceleration
		velocity.z = velocity.z + (direction.z - velocity.z) * acceleration

	velocity.y = velocity_y
	move_and_slide()


func update_rotation():
	var player_pos = global_transform.origin
	var dropPlane = Plane(Vector3(0,1,0), player_pos.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from, to)

	#cursor.global_transfrom.origin = cursor_pos + Vector3(0,1,0)

	look_at(cursor_pos, Vector3.UP)


func update_gamepad_rotation(_delta):
	right_stick_look.x = Input.get_axis("look_down", "look_up")#Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	right_stick_look.y = Input.get_axis("look_right", "look_left")#Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if right_stick_look.length() >= 0.1:
		# how to lerp this?
		rotation.y = right_stick_look.angle()
		#rotation.y = lerp(rotation.y, rs_look.angle(), delta * 2)


func update_shooting():
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("enemy"):
				raycast.get_collider().die()


func got_shot():
	print("I got shot! ", name)
