extends Label


func _on_player_player_ammo_updated(ammo: int):
	self.text = "Ammo: " + str(ammo) + " "
