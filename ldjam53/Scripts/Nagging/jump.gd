extends Label


func _input(_event):
	if Input.is_action_just_pressed("jump"):
		self.visible = false
