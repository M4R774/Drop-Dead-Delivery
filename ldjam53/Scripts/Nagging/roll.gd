extends Label


func _input(_event):
	if Input.is_action_just_pressed("roll"):
		self.visible = false
