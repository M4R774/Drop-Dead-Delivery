extends Label


func _on_player_player_health_updated(new_health):
	self.text = " Health: " + str(new_health) + " %"

