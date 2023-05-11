extends Node3D

# Logic for neighbourhood level
@export var level_manager: Node

#@export var player: CharacterBody3D
#@export var zombie_scene: PackedScene
#@export var ammo_box_scene: PackedScene
#@export var health_kit_scene: PackedScene
#@export var map_size: int = 0
#@export var map_tile_scenes: Array[PackedScene]

var delivery_points = []
var map_tiles = []

# round variables
@export var item_bundle_spawn_location: Vector3
@export var item_bundle: PackedScene
var active_delivery_map_tiles = []
var active_delivery_points = []
var zombie_speed = 2.5
var rng = RandomNumberGenerator.new()
var first_delivery = true

var x_offset = rng.randi_range(0, 1)
var y_offset = rng.randi_range(0, 1)

# debug
var debug_round_index = -1
var debug_time_elapsed = 0


func get_active_delivery_point():
	if active_delivery_points.size() > 0:
		return active_delivery_points[0]#active_delivery_map_tiles[0].active_delivery_point
	else: 
		return null


func get_active_delivery_points():
	#var active_delivery_points = []
	#for level_tile in active_delivery_map_tiles:
		#active_delivery_points.append(level_tile.active_delivery_point)
	return active_delivery_points


func _ready():
	delivery_points = $Level_manager/Delivery_points.get_children()
	#self.rotation.y = deg_to_rad(90 * rng.randi_range(0, 3))
	$HUD.set_player_for_compass($Player)
	#generate_map()
	spawn_zombie()
	spawn_loot_box()
	$LootBoxSpawner.start()
	$ZombieSpawner.start()
	spawn_item_bundle()


#func generate_map():
#	for i in range(map_size):
#		for j in range(map_size):
#			var new_tile = map_tile_scenes.pick_random().instantiate()
#			new_tile.player = player
#			map_tiles.append(new_tile)
#			new_tile.position = Vector3(j * 39 - (39 * x_offset), 0, i * 39 - (39 * y_offset))
#			#new_tile.position = Vector3(j * 39, 0, i * 39)
#			add_child(new_tile)
#			new_tile.rotation.y = deg_to_rad(90 * rng.randi_range(0, 3))
#	map_tiles[x_offset + y_offset*2].global_rotation = Vector3(0, deg_to_rad(270), 0)


# this activates a delivery point in each tile
# makes a list of them that needs to be visited in order
func create_delivery_order():
	#if not first_delivery:
		#$"Power up".open_power_up_menu()
	first_delivery = false
	#var delivery_map_tiles = [] + map_tiles
	#delivery_map_tiles.remove_at(x_offset + y_offset*2) # we don't want to have a delivery point in the spawn tile. this needs to change accordign to map size
	#delivery_map_tiles.shuffle()
	#active_delivery_map_tiles.append($Level_manager)
	#for location in active_delivery_map_tiles:
		#var _active_delivery_location = location.activate_delivery_point()
	#$Level_manager.activate_delivery_point()
	# instead of calling the level manager, let's just create an array here
	delivery_points.shuffle()
	for point in range(3):
		delivery_points[point].activate_delivery_point()
		active_delivery_points.append(delivery_points[point])
		#active_delivery_map_tiles.append($Level_manager) # hack to keep the old system working
	$HUD.set_compass_target(get_active_delivery_point())
	
	# debug checking how long rounds take
	debug_round_index += 1
	print("round ", debug_round_index, " took ", (Time.get_ticks_msec() - debug_time_elapsed) / 1000, " seconds.")
	debug_time_elapsed = Time.get_ticks_msec()


func increase_difficulty():
	$LootBoxSpawner.wait_time = $LootBoxSpawner.wait_time + 2
	$ZombieSpawnTimer.wait_time = $ZombieSpawnTimer.wait_time * 0.9
	zombie_speed += 0.2


func remove_delivery_map_tile(map_tile):
	#print(map_tile)
	#print("removing delivery point from array")
	#active_delivery_map_tiles.erase(map_tile.get_child(0))
	active_delivery_points.erase(map_tile)
	#print(active_delivery_points)
	if active_delivery_points.size() == 0: # next round
		spawn_item_bundle()
	else: 
		$HUD.set_compass_target(get_active_delivery_point())


func spawn_zombie():
	level_manager.spawn_zombie(zombie_speed)


func spawn_loot_box():
	level_manager.spawn_loot_box()


func spawn_item_bundle():
	var bundle = item_bundle.instantiate()
	add_child(bundle)
	bundle.global_position = item_bundle_spawn_location
	$HUD.set_compass_target(bundle)


func _on_zombie_spawner_timeout():
	spawn_zombie()


func _on_loot_box_spawner_timeout():
	spawn_loot_box()


func change_delivery_prompt_icons(is_button):
	for d_p in delivery_points:
		d_p.switch_keycap_icons(is_button)


func _on_increase_difficulty_timeout():
	increase_difficulty()
