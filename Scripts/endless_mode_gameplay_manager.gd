extends Node3D

# Spawns in enemies and items in an endless gameplay mode

@export var player: CharacterBody3D
@export var zombie_scene: PackedScene
@export var ammo_box_scene: PackedScene
@export var health_kit_scene: PackedScene
@export var map_size: int = 0
@export var map_tile_scenes: Array[PackedScene]

var map_tiles = []

# round variables
@export var item_bundle_spawn_location: Vector3
@export var item_bundle: PackedScene
var current_delivery_points = []


func _ready():
	generate_map()
	for i in range(6):
		spawn_zombie()
	spawn_loot_box()
	$LootBoxSpawner.start()
	$ZombieSpawnTimer.start()
	$DeliverableItemSpawner.start()
	spawn_item_bundle()
	#create_delivery_order()


func generate_map():
	for i in range(map_size):
		for j in range(map_size):
			var new_tile = map_tile_scenes.pick_random().instantiate()
			new_tile.player = player
			map_tiles.append(new_tile)
			new_tile.position = Vector3(j * 39 - 39, 0, i * 39 - 39)
			add_child(new_tile)


# this activates a delivery point in each tile
# makes a list of them that needs to be visited in order
func create_delivery_order():
	var delivery_locations = [] + map_tiles
	delivery_locations.remove_at(3) # we don't want to have a delivery point in the spawn tile. this needs to change accordign to map size
	delivery_locations.shuffle()
	current_delivery_points = [] + delivery_locations
	#print(current_delivery_points)
	for location in delivery_locations:
		location.activate_delivery_point()


func remove_delivery_point(point):
	current_delivery_points.erase(point)
	if current_delivery_points.size() == 0: # next round
		spawn_item_bundle()


func spawn_zombie():
	map_tiles.pick_random().spawn_zombie()


func spawn_loot_box():
	map_tiles.pick_random().spawn_loot_box()


func spawn_small_deliverable_item():
	map_tiles.pick_random().spawn_deliverable_item()


func spawn_item_bundle():
	var bundle = item_bundle.instantiate()
	bundle.global_position = item_bundle_spawn_location
	add_child(bundle)


func _on_zombie_spawn_timer_timeout():
	spawn_zombie()


func _on_loot_box_spawner_timeout():
	spawn_loot_box()


func _on_deliverable_item_spawner_timeout():
	spawn_small_deliverable_item()
