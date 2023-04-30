extends Area3D

# Items get delivered here
# Checks if player's inventory has a wanted item and gives points
# Checking with name and having to write the name into two places correctly is dumb

@export var delivery_id = ""
@export var can_deliver_to = true
var player_near = false

var player
var inventory

#func _ready():
#	print(self.owner)

func activate_delivery_point():
	visible = true
	can_deliver_to = true


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		player = body
		inventory = body.get_node("Inventory")
#		#if inventory.inventory_items.has(delivery_id):
#		var items = inventory.inventory_items.size()
#		if ites != 0:
#			inventory.inventory_items = []
#			#inventory.remove_from_inventory(delivery_id)
#			body.add_score(100 * items)
#			$Item_delivered.play()
			# for now delivery points are in predefined places, no respawning them
			#self.visible = false
			#$Remover.start()


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		$Deliver.stop()


func _input(event):
	if event.is_action_pressed("deliver_item") and player_near and can_deliver_to:
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
	
