extends Node3D

# Inventory for items
@export var capacity = 3
var inventory_items = []
var small_items = []
@export var pickup_volume: Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_area_entered(area):
	if area.is_in_group("item") and inventory_items.size() < capacity:
		inventory_items.append(area.item_name)
		area.queue_free()
		print(inventory_items)
		if inventory_items.size() == 3: # all items are onboard
			get_tree().get_current_scene().create_delivery_order() # calling gameplay to start the round
	if area.is_in_group("small_item"):
		small_items.append(area.item_name)
		area.queue_free()
		print(inventory_items)


func remove_from_inventory(item_to_remove):
	inventory_items.erase(item_to_remove)
