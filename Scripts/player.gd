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
var is_rolling = false
var rolling_axis = Vector3.ZERO
var rolling_direction = Vector3.FORWARD
var dead: bool = false
var external_force = Vector3.ZERO

# gamepad controls
var is_using_gamepad = false
var left_stick_turn = Vector2(0,0)
var right_stick_look = Vector2(0,0)

# shooting
@export var raycast : RayCast3D
var shotgun_range = 10
var projectile_count = 10
var inaccuracy = .2
var melee_range = 10
@export var ammo: int = 10
var rng = RandomNumberGenerator.new()
var projectile_prefab

# melee
@export var push_force = 5

# animation
var animation_player
@export var animation_tree: AnimationTree

@export var health_percentage = 100
var max_health = 100

func _ready():
	projectile_prefab = preload("res://Scenes/shotgun_projectile.tscn")
	emit_signal("player_ammo_updated", ammo)
	init_mac()
	if camera == null:
		camera = get_viewport().get_camera_3d()
	animation_player = $player.get_node("AnimationPlayer")


func _physics_process(delta):
	scale = Vector3(1,1,1)
	if not dead:
		if out_of_bounds():
			die()
		update_movement(delta)
		update_shooting()
	else:
		if $DyingAnimationDuration2.time_left > 0:
			var dying_animation_duration = $DyingAnimationDuration2.wait_time
			self.rotate(basis.x, delta * 1/dying_animation_duration * 6.2831853071 / 4)


func update_movement(delta):
	if Input.is_action_just_pressed("roll") and rolling_is_possible():
		$Rolling_duration.start()
		is_rolling = true
		rolling_axis = calculate_rolling_axis()
		rolling_direction = get_horizontal_velocity()

	if is_rolling:
		roll(delta)
	else:
		set_horizontal_velocity()
		if is_using_gamepad:
			update_gamepad_rotation(delta)
		else:
			update_rotation()

	set_vertical_velocity(delta)
	move_and_slide()


func rolling_is_possible():
	if $Roll_cooldown.time_left == 0 and !is_rolling:
		return true
	else: 
		return false


# +z left, -z right
# y aim
# x backward/forward
func roll(delta):
	if $Rolling_duration.time_left == 0:
		reset_rolling()
		return
	var _roll_time = $Rolling_duration.wait_time
	self.rotate(rolling_axis.normalized(), delta * 1/_roll_time * 6.2831853071)
	velocity = rolling_direction * speed * 1.5


func get_horizontal_velocity():
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	if horizontal_velocity == Vector3.ZERO:
		horizontal_velocity = -basis.z
	return horizontal_velocity.normalized()


func calculate_rolling_axis():
	var horizontal_velocity = get_horizontal_velocity()
	return horizontal_velocity.rotated(Vector3.UP, deg_to_rad(90))


func reset_rolling():
	self.rotation = Vector3(0,rotation.y,0)
	is_rolling = false
	$Roll_cooldown.start()


func set_horizontal_velocity():
	direction.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	direction.z = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	direction = direction.normalized() * speed
	velocity = direction + external_force
	external_force = external_force * .9
	animate_player()
	play_sound_if_moving()


func set_vertical_velocity(delta):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity 
		else: 
			velocity_y = 0
	else:
		velocity_y -= gravity * delta
	velocity.y = velocity_y


func animate_player():
	if direction.length() > 0:
		animation_tree.set("parameters/BlendWalk/blend_amount", 0.0)
	else:
		animation_tree.set("parameters/BlendWalk/blend_amount", 1.0)


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
			ammo -= 1
			emit_signal("player_ammo_updated", ammo)
			shotgunSound.play()
			for i in range(projectile_count):
				call_deferred("instantiate_projectile")
			$Shoot_cooldown.start()
		else:
			$EmptyGunSound.play()
	if Input.is_action_just_pressed("melee") and $Melee_cooldown.time_left == 0:
		animation_tree.set("parameters/OneShot/request", true)
		meleeSound.play()
		$Melee_cooldown.start()
		var collided_bodies = raycast.get_colliding_bodies()
		if collided_bodies.size() > 0:
			for body in collided_bodies:
				if global_position.distance_to(body.global_position) <= melee_range:
					body.set_velocity(-get_global_transform().basis.z * 10)
					body.add_health(-1)


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
	if health_percentage <= 0 and not dead:
		health_percentage = 0
		die()
	elif health_percentage > max_health:
		health_percentage = max_health
	elif health_percentage < 0:
		health_percentage = 0
	emit_signal("player_health_updated", health_percentage)
	if health_to_add < 0:
		damageSound.play()


func out_of_bounds():
	return self.position.y < -10


func die():
	dead = true
	$DyingAnimationDuration.start()
	$DyingAnimationDuration2.start()
	if !$DeathSound.is_playing():
		$DeathSound.play()


# checking if player is using kb and mouse or gamepad
# this should only be run for player 1, as player 2 is always on gamepad
# player 1 might be on kb and player 2 on gamepad on the same device
# this needs to be resolved, perhaps with a is_multiplayer boolean or smt
func _input(event):
	if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		if !is_using_gamepad:
			get_parent().change_delivery_prompt_icons(true)
		is_using_gamepad = true
	else:
		if is_using_gamepad:
			get_parent().change_delivery_prompt_icons(false)
		is_using_gamepad = false


func init_mac():
	# GuliKit Controller map for mac
	Input.add_joy_mapping("03000000790000001c18000000010000,
		GuliKit Controller A,a:b0,b:b1,y:b4,x:b3,start:b11,back:b10,
		leftstick:b13,rightstick:b14,leftshoulder:b6,rightshoulder:b7,
		dpup:b12,dpleft:b14,dpdown:b13,dpright:b15,leftx:a0,lefty:a1,rightx:a2
		,righty:a3,lefttrigger:a5,righttrigger:a4,platform:Mac OS X", true)

# Old rolling
			#animation_player.play("roll")
			#var tween = create_tween()
			#tween.set_ease(Tween.EASE_IN_OUT)
			#tween.tween_property(self, "rotation_degrees", Vector3(-360, rotation_degrees.y, 0), 1)
			#tween.tween_callback(reset_rolling)
		

func _on_dying_animation_duration_timeout():
	emit_signal("player_died")


func increase_light():
	$OmniLight3D.light_energy = $OmniLight3D.light_energy * 2
	$OmniLight3D.omni_range = $OmniLight3D.omni_range * 1.4
	$SpotLight3D.spot_range = $SpotLight3D.spot_range * 1.4
	$SpotLight3D.light_energy = $SpotLight3D.light_energy * 1.4
	$SpotLight3D.spot_angle = $SpotLight3D.spot_angle * 1.4
