extends CharacterBody3D


@export var speed = 10
@export var jump_velocity = 4.5
@export var camera: Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0

# gamepad controls
var is_using_gamepad = false
const SPEED = 5
var angle = 0
# aiming with left trigger enables scheme 1 and moves the reticle with the right stick
# control_schemes: 0 = rotate with right stick, 1 = move reticle with right stick
var control_scheme = 0
@onready var aim_reticle = $"../aim_reticle"


func _physics_process(delta):
	update_position(delta)
	if Input.get_connected_joypads().size() > 0:
		update_gamepad_rotation(delta)
	else:
		update_rotation()


func update_position(delta):
	var horizontal_velocity = Input.get_vector("move_west","move_east","move_north","move_south").normalized() * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.y
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity 
		else: 
			velocity_y = 0
	else:
		velocity_y -= gravity * delta
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


func update_gamepad_rotation(delta):
	if Input.is_action_pressed("aim"):
		control_scheme = 1
	if Input.is_action_just_released("aim"):
		control_scheme = 0

	if control_scheme == 0:
		# gamepad controls
		angle+= SPEED * delta * delta 
		angle = wrapf(angle, 0, 360)
		
		if Input.is_action_pressed("look_right"):
			rotate_y(-SPEED * delta)
		elif Input.is_action_pressed("look_left"):
			rotate_y(+SPEED * delta)
		elif Input.is_action_pressed("look_up"):
			pass
			#rotate_x(SPEED * delta)
		elif Input.is_action_pressed("look_down"):
			pass
			#rotate_x(-SPEED * delta)
	elif control_scheme == 1:
		var horizontal_velocity = Input.get_vector("look_left", "look_right","look_up","look_down").normalized() * speed
		aim_reticle.position.x += horizontal_velocity.x * delta
		aim_reticle.position.y = get_global_transform().origin.y
		aim_reticle.position.z += horizontal_velocity.y * delta
		#aim_reticle.velocity.x = horizontal_velocity.x
		#aim_reticle.velocity.z = horizontal_velocity.y
		#aim_reticle.move_and_slide()
		#var aim_pos = Vector3(aim_reticle.position.x,  get_global_transform().origin.y, aim_reticle.position.z)
		look_at(aim_reticle.position, Vector3.UP)

