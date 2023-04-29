extends Node3D

var rotation_speed: float = 1.5
var ammo: int = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Rotate slowly
	self.rotation.y += rotation_speed * delta


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.add_ammo(10)
		self.queue_free()
