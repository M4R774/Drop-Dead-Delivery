extends Area3D

# Items get delivered here
# Checks if player's inventory has a wanted item and gives points
# Checking with name and having to write the name into two places correctly is dumb

@export var delivery_id = ""


func _on_body_entered(body):
	if body.is_in_group("player"):
		var inventory = body.get_node("Inventory")
		#if inventory.inventory_items.has(delivery_id):
		var items = inventory.inventory_items.size()
		if items != 0:
			inventory.inventory_items = []
			#inventory.remove_from_inventory(delivery_id)
			body.add_score(100 * items)
			$Item_delivered.play()
			# for now delivery points are in predefined places, no respawning them
			#self.visible = false
			#$Remover.start()


# gives time for the sound effect to play
func _on_remover_timeout():
	self.queue_free()
