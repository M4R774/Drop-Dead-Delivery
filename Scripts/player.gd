extends CharacterBody3D

@export var speed = 10
@export var jump_velocity = 4.5
@export var camera: Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0

func _physics_process(delta):
	update_position(delta)
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
