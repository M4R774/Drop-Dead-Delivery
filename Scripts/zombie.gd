extends CharacterBody3D

@export var target: CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var SPEED = 3.0
var health = 5
var dead: bool = false

var current_target

func _ready():
	$WalkAnimationOffset.start(randf_range(0, 1.5))
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
		pass
		#print("target unreachable")


func _on_navigation_agent_3d_target_reached():
	print("target reached")


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()


func die():
	HIGHSCORE_SINGLETON.SCORE += 1
	dead = true
	queue_free()
	# TODO: Dying sounds?


func add_health(health_to_add: int):
	health += health_to_add
	if health <= 0 and !dead:
		die()


func _on_hands_body_entered(body:Node3D):
	if body.is_in_group("player") and $Melee_cooldown.time_left == 0:
		$Melee_cooldown.start()
		$MeleeHitDelay.start()
		current_target = body


func _on_walk_animation_offset_timeout():
	var animation_player = $ghoul.get_node("AnimationPlayer")
	animation_player.play("ghoul_walk")
	animation_player.speed_scale = randf_range(0.75, 1.25)


# Enemy only hits after a short delay, giving the player a chance to kill the enemy first
func _on_melee_hit_delay_timeout():
	current_target.add_health(-10)
