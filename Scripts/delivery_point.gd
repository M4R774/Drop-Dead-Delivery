extends Area3D

# Items get delivered here
# Checks if player's inventory has a wanted item and gives points
# Checking with name and having to write the name into two places correctly is dumb

@export var keycap_1: Sprite3D
@export var keycap_2: Sprite3D
@export var e_key_background: Texture
@export var e_key_filled: Texture
@export var b_button_background: Texture
@export var b_button_filled: Texture

@export var delivery_id = ""
@export var can_deliver_to = true
var player_near = false

var player
var inventory


func _ready():
	keycap_1.visible = true
	keycap_2.visible = false


func _physics_process(_delta):
	$Control/TextureProgressBar.value = ($Deliver.time_left / $Deliver.wait_time) * 100
	if $Deliver.time_left <= 0:
		$Control/TextureProgressBar.visible = false
	else:
		$Control/TextureProgressBar.visible = true


func activate_delivery_point():
	visible = true
	can_deliver_to = true


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		$Control.visible = player_near and can_deliver_to
		player = body
		inventory = body.get_node("Inventory")


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		$Control.visible = player_near
		$Deliver.stop()


func _input(event):
	if event.is_action_pressed("deliver_item") and player_near and can_deliver_to:
		print("Started delivering")
		$Deliver.start()
	if event.is_action_released("deliver_item") and player_near:
		$Deliver.stop()


# gives time for the sound effect to play
func _on_remover_timeout():
	self.queue_free()


func _on_deliver_timeout():
	var small_items = inventory.small_items.size()
	var items = inventory.inventory_items.size()
	if small_items or items > 0:
		$Item_delivered.play()
	if small_items > 0:
		player.add_score(25 * small_items)
		inventory.small_items = []
	if items > 0:
		inventory.remove_from_inventory(inventory.inventory_items[-1])
		player.add_score(100)
		visible = false
		can_deliver_to = false
		get_tree().get_current_scene().remove_delivery_point(self.owner)
	$Control.visible = player_near and can_deliver_to
	


func _on_keycap_blinker_timeout():
	keycap_1.visible = !keycap_1.visible
	keycap_2.visible = !keycap_2.visible


func switch_keycap_icons(is_button):
	if is_button:
		keycap_1.texture = b_button_background
		keycap_2.texture = b_button_filled
	else:
		keycap_1.texture = e_key_background
		keycap_2.texture = e_key_filled
