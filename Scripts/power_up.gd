extends Panel


@export var buttons: Array[Node]
@export var player: CharacterBody3D

func _ready():
	visible = false
	buttons = [$MarginContainer/HBoxContainer2/HBoxContainer/HP, 
				$"MarginContainer/HBoxContainer2/HBoxContainer/Movement-speed",
				$MarginContainer/HBoxContainer2/HBoxContainer/Ammo,
				$MarginContainer/HBoxContainer2/HBoxContainer/Projectiles,
				$MarginContainer/HBoxContainer2/HBoxContainer/Flashlight]


func open_power_up_menu():
	activate_random_power_ups()
	visible = true
	get_tree().paused = true


func activate_random_power_ups():
	for i in range(5):
		buttons[i].visible = false
	buttons.pick_random().visible = true
	while true:
		var button = buttons.pick_random()
		if button.visible:
			continue
		else:
			button.visible = true
			break


func continue_gameplay():
	get_tree().paused = false
	visible = false


func _on_hp_pressed():
	player.max_health += 10
	player.health_percentage = player.max_health
	player.add_health(1)
	continue_gameplay()


func _on_movementspeed_pressed():
	player.speed = player.speed * 1.05
	continue_gameplay()


func _on_flashlight_pressed():
	player.increase_light()
	continue_gameplay()


func _on_projectiles_pressed():
	player.projectile_count += 5
	continue_gameplay()


func _on_ammo_pressed():
	player.add_ammo(10)
	continue_gameplay()


func _input(_event):
	if Input.is_action_just_pressed("cheat"):
		pass #open_power_up_menu()
	if Input.is_action_just_pressed("cheat"):
		_on_flashlight_pressed()
