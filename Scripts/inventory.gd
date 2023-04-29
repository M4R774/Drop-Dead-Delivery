extends Node3D

# Inventory fo items
var inventory_items = []
@export var pickup_volume: Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_area_entered(area):
	if area.is_in_group("item"):
		inventory_items.append(area.item_name)
		area.queue_free()
		print(inventory_items)


func remove_from_inventory(item_to_remove):
	inventory_items.erase(item_to_remove)
