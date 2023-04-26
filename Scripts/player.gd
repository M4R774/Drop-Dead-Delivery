extends CharacterBody3D


@export var speed = 10
@export var jump_velocity = 4.5
@export var camera: Camera3D
@export var shotgunSound: AudioStreamPlayer3D
@export var movementSound: AudioStreamPlayer3D
@export var damageSound: AudioStreamPlayer3D

var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0
@export var friction = 0.2
var acceleration = 1

# gamepad controls
var is_using_gamepad = true
var left_stick_turn = Vector2(0,0)
var right_stick_look = Vector2(0,0)

# shooting
@onready var raycast = $RayCast3D

# rolling
var is_rolling = false
var roll_factor = 1

func _ready():
	init_mac()
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
	direction.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * speed * roll_factor
	direction.z = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * speed * roll_factor

	
	if is_on_floor():
		# jump
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity 
		else: 
			velocity_y = 0
		# roll
		if Input.is_action_just_pressed("roll") and !is_rolling and $Roll_cooldown.time_left == 0:
			is_rolling = true
			roll_factor = 2
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "rotation_degrees", Vector3(-360, rotation_degrees.y, 0), 1)
			tween.tween_callback(reset_rolling)
		
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
	play_sound_if_moving()
	move_and_slide()
	

func reset_rolling():
	is_rolling = false
	roll_factor = 1                                               
	$Roll_cooldown.start()


func play_sound_if_moving():
	if velocity.length() > 1:
		if !movementSound.is_playing():
			movementSound.play()
	else:
		movementSound.stop()


func update_rotation():
	var player_pos = global_transform.origin
	var dropPlane = Plane(Vector3(0,1,0), player_pos.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from, to)
	if (cursor_pos != null):
		look_at(cursor_pos, Vector3.UP)


func update_gamepad_rotation(_delta):
	left_stick_turn.x = Input.get_axis("move_down", "move_up")
	left_stick_turn.y = Input.get_axis("move_right", "move_left")
	right_stick_look.x = Input.get_axis("look_down", "look_up")
	right_stick_look.y = Input.get_axis("look_right", "look_left")
	
	if left_stick_turn.length() >= 0.1:
		rotation.y = atan2(left_stick_turn.y, left_stick_turn.x)
	if right_stick_look.length() >= 0.1:
		# how to lerp this?
		# these two methods end up feeling the same
		#rotation.y = right_stick_look.angle()
		rotation.y = atan2(right_stick_look.y, right_stick_look.x)
		
		# attempt to lerp with quaternion, not good
		# Convert basis to quaternion, keep in mind scale is lost
#		var a = Quaternion(transform.basis)
#		var b = Quaternion(transform.basis)
#		b.y = right_stick_look.angle()
#		print(b.normalized())
#		# Interpolate using spherical-linear interpolation (SLERP).
#		var c = a.slerp(b.normalized(),0.1) # find halfway point between a and b
#		# Apply back
#		transform.basis = Basis(c)
	


func update_shooting():
	if Input.is_action_just_pressed("shoot") and $Shoot_cooldown.time_left == 0:
		shotgunSound.play()
		$Shoot_cooldown.start()
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("enemy"):
				raycast.get_collider().die()
				add_score(10)


func add_score(score: int):
	if HIGHSCORE_SINGLETON.SCORE == null:
		HIGHSCORE_SINGLETON.SCORE = 0
	HIGHSCORE_SINGLETON.SCORE += score


func got_shot():
	# player has "i-frames"
	if is_rolling:
		return
	damageSound.play()


func init_mac():
	# GuliKit Controller map for mac
	Input.add_joy_mapping("03000000790000001c18000000010000,
		GuliKit Controller A,a:b0,b:b1,y:b4,x:b3,start:b11,back:b10,
		leftstick:b13,rightstick:b14,leftshoulder:b6,rightshoulder:b7,
		dpup:b12,dpleft:b14,dpdown:b13,dpright:b15,leftx:a0,lefty:a1,rightx:a2
		,righty:a3,lefttrigger:a5,righttrigger:a4,platform:Mac OS X", true)

