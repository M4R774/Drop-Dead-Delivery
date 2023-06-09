extends NavigationRegion3D


@export var player: CharacterBody3D
@export var zombie_scene: PackedScene
@export var ammo_box_scene: PackedScene
@export var health_kit_scene: PackedScene
@export var deliverable_item: PackedScene
@onready var delivery_points = [$Delivery_points/Delivery_point, $Delivery_points/Delivery_point3, $Delivery_points/Delivery_point2]

var active_delivery_point: DeliveryPoint
var rng = RandomNumberGenerator.new()

func _ready():
	print(self.scale)


func spawn_zombie(zombie_speed):
	# first check if can spawn
	# first get place
	# then spawn zombie
	# add player as their target
	var zombie = zombie_scene.instantiate()
	zombie.position = get_spawning_location()
	zombie.target = player
	zombie.SPEED = zombie_speed
	add_child(zombie)


func get_spawning_location():
	var spawn_area = $Spawn_areas.get_children().pick_random()
	var spawn_size: Vector3 = spawn_area.shape.size
	var spawn_location_offset = Vector3(rng.randf_range(-spawn_size.x/2, spawn_size.x/2), 
										0, 
										rng.randf_range(-spawn_size.z/2, spawn_size.z/2))
	return spawn_area.position + spawn_location_offset


func spawn_loot_box():
	var spawn_probability = 49 # 0-49 = ammo, 50-100 = health
	# allow health spawning only after player is under 50 health
	if player.health_percentage <= 50:
		spawn_probability = 100
	var loot_box
	var spawned_item = int(randf_range(0, spawn_probability))
	if spawned_item < 50:
		loot_box = ammo_box_scene.instantiate()
		loot_box.ammo = 3
	else:
		loot_box = health_kit_scene.instantiate()
	loot_box.position = get_spawning_location()
	add_child(loot_box)


func spawn_deliverable_item():
	var item = deliverable_item.instantiate()

	item.position = get_spawning_location()
	item.position.y = 1
	add_child(item)


func activate_delivery_point():
	active_delivery_point = delivery_points.pick_random()
	active_delivery_point.activate_delivery_point()
	return active_delivery_point
