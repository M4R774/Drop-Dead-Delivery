extends Node3D

# Inventory for items
@export var capacity = 3
var inventory_items = []
var small_items = []
@export var pickup_volume: Area3D
@export var backpack_mesh: Node3D


func _on_area_3d_area_entered(area):
	if area.is_in_group("item") and inventory_items.size() < capacity:
		backpack_mesh.visible = true
		inventory_items.append(area.item_name)
		area.queue_free()
		if inventory_items.size() == 3: # all items are onboard
			get_tree().get_current_scene().create_delivery_order() # calling gameplay to start the round
		$blip.play()
	if area.is_in_group("small_item"):
		small_items.append(area.item_name)
		area.queue_free()
		$blip.play()


func remove_from_inventory(item_to_remove):
	inventory_items.erase(item_to_remove)
	if inventory_items.size() <= 0:
		backpack_mesh.visible = false
