extends Node3D

# Spawns in enemies and items in an endless gameplay mode

@export var player: CharacterBody3D
@export var zombie_scene: PackedScene
@export var loot_box_scene: PackedScene


func _ready():
	for spawns in range(6):
		spawn_zombie()
	spawn_loot_box()
	$ZombieSpawnTimer.start()


func _process(delta):
	pass


func spawn_zombie():
	# first check if can spawn
	# first get place
	# then spawn zombie
	# add player as their target
	var zombie = zombie_scene.instantiate()
	var zombie_spawn_location = $ZombieSpawnPath/ZombieSpawnLocation
	zombie_spawn_location.progress_ratio = randf()
	zombie.position = zombie_spawn_location.position
	zombie.target = player
	add_child(zombie)


func spawn_loot_box():
	var loot_box = loot_box_scene.instantiate()
	var zombie_spawn_location = $ZombieSpawnPath/ZombieSpawnLocation
	zombie_spawn_location.progress_ratio = randf()
	loot_box.position = zombie_spawn_location.position
	loot_box.position.y = 1
	add_child(loot_box)

func _on_zombie_spawn_timer_timeout():
	spawn_zombie()


func _on_loot_box_spawner_timeout():
	spawn_loot_box()
