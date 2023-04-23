extends Node

@onready var fps_as_text = $Control/Label

func _process(delta):
	fps_as_text.text = str(Engine.get_frames_per_second())
