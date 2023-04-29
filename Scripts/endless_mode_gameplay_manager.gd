extends Node3D

# Spawns in enemies and items in an endless gameplay mode

@export var player: CharacterBody3D
@export var zombie_scene: PackedScene
@export var ammo_box_scene: PackedScene
@export var health_kit_scene: PackedScene
@export var map_size: int = 3
@export var map_tile_scenes: Array[PackedScene]

var map_tiles = []

func _ready():
	generate_map()
	for i in range(6):
		spawn_zombie()
	spawn_loot_box()
	$LootBoxSpawner.start()
	$ZombieSpawnTimer.start()


func generate_map():
	for i in range(map_size):
		for j in range(map_size):
			var new_tile = map_tile_scenes.pick_random().instantiate()
			new_tile.player = player
			map_tiles.append(new_tile)
			new_tile.position = Vector3(j * 39 - 39, 0, i * 39 - 39)
			add_child(new_tile)


func spawn_zombie():
	map_tiles.pick_random().spawn_zombie()


func spawn_loot_box():
	map_tiles.pick_random().spawn_loot_box()


func _on_zombie_spawn_timer_timeout():
	spawn_zombie()


func _on_loot_box_spawner_timeout():
	spawn_loot_box()
