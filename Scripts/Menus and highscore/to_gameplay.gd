extends Button


func _ready():
	self.grab_focus()


func _pressed():
	$"../../../LoadingScreen".visible = true
	call_deferred("to_gameplay")

func to_gameplay():
	await get_tree().create_timer(.05).timeout
	get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")