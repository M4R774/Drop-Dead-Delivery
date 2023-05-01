extends Label


func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		self.visible = false
