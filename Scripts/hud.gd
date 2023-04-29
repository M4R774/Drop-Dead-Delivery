extends Control


func _on_player_player_health_updated(new_health):
	$Health._on_player_player_health_updated(new_health)


func _on_player_player_died():
	$"Death screen"._on_player_player_died()


func _on_player_player_ammo_updated(new_ammo):
	$Ammo._on_player_player_ammo_updated(new_ammo)
