extends TextureRect

var player: Node3D
var compass_target: Node3D


func _physics_process(_delta):
	var angle = rad_to_deg(atan2(player.global_position.z - compass_target.global_position.z + 2, player.global_position.x- compass_target.global_position.x))
	rotation_degrees = angle + 180
