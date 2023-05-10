extends AudioStreamPlayer3D


var sounds=[]
var rng = RandomNumberGenerator.new()

func _ready():
	sounds.append(load("res://Sounds/Perttu/anna-tänne-se-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/anna-tänne-se-murina.wav"))
	sounds.append(load("res://Sounds/Perttu/paketti-paketti-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/siellä-se-on-helari.wav"))
	sounds.append(load("res://Sounds/Perttu/siellä-se-onmurina.wav"))
	$"../BarkDelay".start(rng.randf_range(1, 20))


func _on_bark_delay_timeout():
	play_random_sound()


func play_random_sound():
	var sound = sounds.pick_random()
	self.stream = sound
	self.play()
	$"../BarkDelay".start(rng.randf_range(10, 30))
