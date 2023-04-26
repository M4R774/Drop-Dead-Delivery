extends CharacterBody3D

# enemies could be of two types
# melee and rifle
# melee tries to get close
# rifle stays further away
# both have a cooldown in their attacks

@onready var raycast = $RayCast3D
var aim_target
@onready var reload_timer = $ReloadTimer

var attack_cooldown = 1

@export var target: CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var SPEED = 3.0


func _process(_delta):
	if aim_target != null:
		look_at(aim_target.position, Vector3.UP)
		if raycast.is_colliding() and raycast.get_collider().is_in_group("player"):
			if reload_timer.time_left == 0:
				shoot(raycast.get_collider())


func _physics_process(_delta):
	nav_agent.set_target_position(target.global_position)
	if nav_agent.is_target_reachable():
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - global_position).normalized() * SPEED
		nav_agent.set_velocity(new_velocity)
		# var direction = global_position.direction_to(next_location)
		# global_position += direction * _delta
	else:
		print("target unreachable")
	if velocity != Vector3.ZERO:
		var lookdir = atan2(-velocity.x, -velocity.z)
		rotation.y = lookdir #lerp(rotation.y, lookdir, 0.1) lerping makes character rotate 360 sometimes


func _on_navigation_agent_3d_target_reached():
	print("target reached")


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		target = body
		print("player seen")


func die():
	queue_free()
	

func shoot(victim):
	victim.got_shot()
	reload_timer.start(1)
	
