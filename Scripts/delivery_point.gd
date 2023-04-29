extends Area3D

# Items get delivered here
# Checks if player's inventory has a wanted item and gives points
# Checking with name and having to write the name into two places correctly is dumb

@export var wanted_item_name = ""


func _on_body_entered(body):
	if body.is_in_group("player"):
		var inventory = body.get_node("Inventory")
		if inventory.inventory_items.has(wanted_item_name):
			inventory.remove_from_inventory(wanted_item_name)
			body.add_score(100)
			$Item_delivered.play()
			self.visible = false
			$Remover.start()


# gives time for the sound effect to play
func _on_remover_timeout():
	self.queue_free()
