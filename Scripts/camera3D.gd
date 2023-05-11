extends Camera3D

@export var player: CharacterBody3D
@export var camera_offset: Vector3

var center = Vector2()
var damping = 4


func _physics_process(delta):
	apply_camera(delta)


func apply_camera(delta):
	var player_position = player.position + camera_offset
	player_position += -player.get_global_transform().basis.z
	self.position = lerp(self.position, player_position, delta * damping)
