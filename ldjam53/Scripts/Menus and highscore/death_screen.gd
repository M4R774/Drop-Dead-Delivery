extends PanelContainer


func _ready():
	self.visible = false


func _on_player_player_died():
	self.visible = true
