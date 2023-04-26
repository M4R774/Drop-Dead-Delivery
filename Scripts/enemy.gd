extends CharacterBody3D

# enemies could be of two types
# melee and rifle
# melee tries to get close
# rifle stays further away
# both have a cooldown in their attacks

@onready var raycast = $RayCast3D
var target
@onready var reload_timer = $ReloadTimer

var attack_cooldown = 1


func _process(_delta):
	if target != null:
		look_at(target.position, Vector3.UP)
		if raycast.is_colliding() and raycast.get_collider().is_in_group("player"):
			if reload_timer.time_left == 0:
				shoot(raycast.get_collider())


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		target = body
		print("player seen")


func die():
	queue_free()
	

func shoot(victim):
	victim.got_shot()
	reload_timer.start(1)
	
