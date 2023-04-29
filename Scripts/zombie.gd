extends CharacterBody3D

@export var target: CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var SPEED = 3.0


func _ready():
	$Melee_cooldown.start()


func _physics_process(_delta):
	nav_agent.set_target_position(target.global_position)
	if nav_agent.is_target_reachable():
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - global_position).normalized() * SPEED
		nav_agent.set_velocity(new_velocity)
		rotation.y = atan2(-velocity.x, -velocity.z)
		# var direction = global_position.direction_to(next_location)
		# global_position += direction * _delta
	else:
		print("target unreachable")


func _on_navigation_agent_3d_target_reached():
	print("target reached")


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()


func die():
	queue_free()


func _on_hands_body_entered(body:Node3D):
	if body.is_in_group("player") and $Melee_cooldown.time_left == 0:
		$Melee_cooldown.start()
		body.add_health(-10)
