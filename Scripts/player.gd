extends CharacterBody3D

signal player_died
signal player_ammo_updated
signal player_health_updated

@export var speed = 10
@export var jump_velocity = 4.5
@export var camera: Camera3D
@export var shotgunSound: AudioStreamPlayer3D
@export var meleeSound: AudioStreamPlayer3D
@export var movementSound: AudioStreamPlayer3D
@export var damageSound: AudioStreamPlayer3D
@export var friction = 0.2


var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0
var acceleration = 1

# gamepad controls
var is_using_gamepad = true
var left_stick_turn = Vector2(0,0)
var right_stick_look = Vector2(0,0)

# shooting
@export var raycast : RayCast3D
var shotgun_range = 10
var projectile_count = 10
var inaccuracy = .2
var melee_range = 2
@export var ammo: int = 10
var rng = RandomNumberGenerator.new()
var projectile_prefab

# rolling
var is_rolling = false
var roll_factor = 1

# animation
var animation_player

@export var health_percentage = 100


func _ready():
	projectile_prefab = preload("res://Scenes/shotgun_projectile.tscn")
	emit_signal("player_ammo_updated", ammo)
	init_mac()
	if camera == null:
		camera = get_viewport().get_camera_3d()
	animation_player = $player.get_node("AnimationPlayer")


func _physics_process(delta):
	if health_percentage <= 0:
		get_tree().paused = true
	if out_of_bounds():
		die()

	# player movement and rotation
	update_position(delta)
	if is_using_gamepad:
		update_gamepad_rotation(delta)
	else:
		update_rotation()
	# player actions
	update_shooting()


func out_of_bounds():
	return self.position.y < -10


func die():
	if !damageSound.is_playing():
		damageSound.play()
	emit_signal("player_died")
	get_tree().paused = true


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
	direction.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	direction.z = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	direction = direction.normalized() * speed * roll_factor
	
	if is_on_floor():
		# jump
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity 
		else: 
			velocity_y = 0
		# roll
		if Input.is_action_just_pressed("roll") and !is_rolling and $Roll_cooldown.time_left == 0:
			#animation_player.play("roll")
			is_rolling = true
			roll_factor = 1.25
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "rotation_degrees", Vector3(-360, rotation_degrees.y, 0), 1)
			tween.tween_callback(reset_rolling)
		
		# slipperiness
		# acceleration variable is meaningless when we are already using speed
		if direction.length() > 0:
			velocity = Vector3((velocity.x + (direction.x - velocity.x) * acceleration), velocity.y, (velocity.z + (direction.z - velocity.z) * acceleration))
			animation_player.play("player_walk")
		else:
			velocity = Vector3((velocity.x + (0 - velocity.x) * friction), velocity.y, (velocity.z + (0 - velocity.z) * friction))
			animation_player.play("hold_gun")
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
		rotation.y = atan2(right_stick_look.y, right_stick_look.x)
		


func update_shooting():
	# add melee with raycast range 0.1?
	if Input.is_action_just_pressed("shoot") and $Shoot_cooldown.time_left == 0:
		if ammo > 0:
			#animation_player.play("shoot")
			ammo -= 1
			emit_signal("player_ammo_updated", ammo)
			shotgunSound.play()
			for i in range(projectile_count):
				call_deferred("instantiate_projectile")
			$Shoot_cooldown.start()
		else:
			$EmptyGunSound.play()
	if Input.is_action_just_pressed("melee") and $Melee_cooldown.time_left == 0:
		#animation_player.play("melee")
		meleeSound.play()
		$Melee_cooldown.start()
		var collided_bodies = raycast.get_colliding_bodies()
		if collided_bodies.size() > 0:
			for body in collided_bodies:
				if global_position.distance_to(body.global_position) <= melee_range:
					body.die()
					add_score(10)


func instantiate_projectile():
	var projectile = projectile_prefab.instantiate()
	projectile.rotation = global_rotation + Vector3(rng.randf_range(-inaccuracy, inaccuracy), rng.randf_range(-inaccuracy, inaccuracy), 0)
	projectile.position += $player/Shotgun.global_position
	add_sibling(projectile)


func add_score(score: int):
	if HIGHSCORE_SINGLETON.SCORE == null:
		HIGHSCORE_SINGLETON.SCORE = 0
	HIGHSCORE_SINGLETON.SCORE += score


func add_ammo(ammo_to_add: int):
	ammo += ammo_to_add
	emit_signal("player_ammo_updated", ammo)
	$ReloadSound.play()


func add_health(health_to_add: int):
	if health_to_add > 0:
		$HealthSound.play()
	health_percentage += health_to_add
	if health_percentage <= 0:
		die()
	elif health_percentage > 100:
		health_percentage = 100
	emit_signal("player_health_updated", health_percentage)


func got_shot():
	# player has "i-frames"
	if is_rolling:
		return
	add_health(-10)
	damageSound.play()


func init_mac():
	# GuliKit Controller map for mac
	Input.add_joy_mapping("03000000790000001c18000000010000,
		GuliKit Controller A,a:b0,b:b1,y:b4,x:b3,start:b11,back:b10,
		leftstick:b13,rightstick:b14,leftshoulder:b6,rightshoulder:b7,
		dpup:b12,dpleft:b14,dpdown:b13,dpright:b15,leftx:a0,lefty:a1,rightx:a2
		,righty:a3,lefttrigger:a5,righttrigger:a4,platform:Mac OS X", true)

