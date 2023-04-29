extends RigidBody3D

var SPEED = 40

func _ready():
	linear_velocity = -get_global_transform().basis.z * SPEED * RandomNumberGenerator.new().randf_range(0.95, 1.05)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	if $Lifetime.time_left == 0:
		self.queue_free()

	

func _on_area_3d_body_entered(_body:Node3D):
	pass 
	# TODO: Deal damage to enemy
	# TODO: Check hitting to wall
	# TODO: Particle effect
	# TODO: Small change for deflection
