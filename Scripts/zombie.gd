extends CharacterBody3D

@export var target: CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player = $ghoul.get_node("AnimationPlayer")

var SPEED = 3.0
var health = 5
var dead: bool = false
var sounds=[]
var rng = RandomNumberGenerator.new()
var current_target


func _ready():
	sounds.append(load("res://Sounds/Perttu/korahdus-1.wav"))
	sounds.append(load("res://Sounds/Perttu/korahdus-2.wav"))
	sounds.append(load("res://Sounds/Perttu/korahdus-3.wav"))
	$WalkAnimationOffset.start(randf_range(0, 1.5))
	$Melee_cooldown.start()


func _physics_process(_delta):
	if not dead:
		nav_agent.set_target_position(target.global_position)
		#if nav_agent.is_target_reachable():
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - global_position).normalized() * SPEED
		nav_agent.set_velocity(new_velocity)
		rotation.y = atan2(-velocity.x, -velocity.z)
	else:
		pass
		# TODO: Dying animation


func _on_navigation_agent_3d_target_reached():
	print("target reached")


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()


func die():
	HIGHSCORE_SINGLETON.SCORE += 1
	dead = true
	play_random_sound()
	$Hands.visible = false
	if $CollisionShape3D.visible == not null:
		$CollisionShape3D.visible = false
	$NavigationAgent3D.queue_free()
	$DyingAnimationDuration.start()


func add_health(health_to_add: int):
	health += health_to_add
	if health <= 0 and !dead:
		die()


func _on_hands_body_entered(body:Node3D):
	if body.is_in_group("player") and $Melee_cooldown.time_left == 0:
		$Melee_cooldown.start()
		#$MeleeHitDelay.start()
		body.add_health(-10)


func _on_walk_animation_offset_timeout():
	animation_player.play("ghoul_walk")
	animation_player.speed_scale = randf_range(0.75, 1.25)
	

func play_random_sound():
	var sound = sounds.pick_random()
	$DeathSound.stream = sound
	$DeathSound.play()
	

func _on_dying_animation_duration_timeout():
	queue_free()
