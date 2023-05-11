extends Control


func set_player_for_compass(player: Node3D):
	$Compass.player = player


func set_compass_target(target_object: Node3D):
	$Compass.compass_target = target_object


func _on_player_player_health_updated(new_health):
	$Health._on_player_player_health_updated(new_health)


func _on_player_player_died():
	$"Death screen"._on_player_player_died()


func _on_player_player_ammo_updated(new_ammo):
	$Ammo._on_player_player_ammo_updated(new_ammo)
