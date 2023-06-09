extends Area3D

class_name DeliveryPoint

# Items get delivered here
# Checks if player's inventory has a wanted item and gives points
# Checking with name and having to write the name into two places correctly is dumb

@export var keycap_1: Sprite3D
@export var keycap_2: Sprite3D
@export var e_key_background: Texture
@export var e_key_filled: Texture
@export var b_button_background: Texture
@export var b_button_filled: Texture
var can_blink = false

@export var delivery_id = ""
@export var can_deliver_to = true
var player_near = false

var player
var inventory


func _ready():
	reset_blinking()


func _physics_process(_delta):
	$Control/TextureProgressBar.value = ($Deliver.time_left / $Deliver.wait_time) * 100
	if $Deliver.time_left <= 0:
		$Control/TextureProgressBar.visible = false
	else:
		$Control/TextureProgressBar.visible = true
		$Control/TextureProgressBar.position = get_viewport().get_camera_3d().unproject_position(keycap_1.global_transform.origin)
		$Control/TextureProgressBar.position -= $Control/TextureProgressBar.size / 2


func activate_delivery_point():
	$post_box/Cylinder/StaticBody3D/CollisionShape3D.set_deferred("disabled", false)
	$new_post_box/post_box/StaticBody3D/CollisionShape3D.set_deferred("disabled", false)
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
		$KeycapBlinker.stop()
		can_blink = false
		keycap_1.visible = false
		keycap_2.visible = false
		$Deliver.start()
	if event.is_action_released("deliver_item") and player_near:
		$Deliver.stop()
		reset_blinking()
		


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
		$post_box/Cylinder/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
		$new_post_box/post_box/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
		can_deliver_to = false
		get_tree().get_current_scene().remove_delivery_map_tile(self)
	$Control.visible = player_near and can_deliver_to
	

func reset_blinking():
	can_blink = true
	$KeycapBlinker.start()
	keycap_1.visible = true
	keycap_2.visible = false


func _on_keycap_blinker_timeout():
	if can_blink:
		keycap_1.visible = not keycap_1.visible
		keycap_2.visible = not keycap_2.visible


func switch_keycap_icons(is_button):
	if is_button:
		keycap_1.texture = b_button_background
		keycap_2.texture = b_button_filled
	else:
		keycap_1.texture = e_key_background
		keycap_2.texture = e_key_filled
