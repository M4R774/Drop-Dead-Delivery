extends AudioStreamPlayer3D


var sounds=[]

func _ready():
	sounds.append(load("res://Sounds/Perttu/anna-tänne-se-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/anna-tänne-se-murina.wav"))
	sounds.append(load("res://Sounds/Perttu/paketti-paketti-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/siellä-se-on-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/siellä-se-onmurina.wav"))
	play_random_sound()


func play_random_sound():
	var sound = sounds.pick_random()
	self.stream = sound
	self.play()
