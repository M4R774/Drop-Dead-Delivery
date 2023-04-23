extends Camera3D

@export var player: CharacterBody3D

var center = Vector2()
var damping = 12.0

func _physics_process(delta):
	apply_camera(delta)

func apply_camera(delta):
	var player_position = player.position + Vector3(0,7,2)
	self.position = lerp(self.position, player_position, delta * damping)
