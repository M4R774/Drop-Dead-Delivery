extends Node3D

var rotation_speed: float = 1.5
var health: int = 20


func _physics_process(delta):
	# Rotate slowly
	self.rotation.y += rotation_speed * delta


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.add_health(health)
		self.queue_free()
