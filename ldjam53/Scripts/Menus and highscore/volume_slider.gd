extends HSlider

var master_bus_index = AudioServer.get_bus_index("Master")


func _ready():
	connect("value_changed", _on_HSlider_value_changed)
	self.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))


func _on_HSlider_value_changed(new_value):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(new_value))
