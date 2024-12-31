extends Node2D

# Room and corridor parameters
var zone_size = Vector2(25, 25)
var tile_id = 0  # ID for walkable tiles
var door_scene = preload("res://door.tscn")
var incrementer_scene = preload("res://incrementer.tscn")
var iterator_scene = preload("res://iterator.tscn")
var rng = RandomNumberGenerator.new()
var zones = {}
var enemy_limit = 15
var key = KEY_0
var map_position = Vector2()
var current_zone_position = Vector2()
var zone = null
var current_room = null
var upgrades = ["adaptability", "velocity", "severity", "frequency"]
onready var tilemap = $TileMap
onready var tilemap2 = $TileMap2
onready var player = $Looper
onready var panel = $BreakerPanel

func _ready():
	# Seed the RNG
	rng.seed = OS.get_ticks_usec()

	generate_room(Vector2(0, 0))
	add_neighbors(Vector2(0, 0))
	
	player.position = tilemap.map_to_world(zones[Vector2()].position + zones[Vector2()].factory) + Vector2(16, 16)
	
	for _i in range(3):
		add_enemy(incrementer_scene)
	
func _process(_delta):
	$Camera2D.position = player.position + Vector2(-53, 0)
	var player_position = tilemap.world_to_map(player.position)
	map_position = player_position / zone_size
	current_zone_position = Vector2(floor(map_position.x), floor(map_position.y))
	var room = zones[current_zone_position]
	if current_room != room:
		var rect = Rect2(tilemap.map_to_world(room.position), tilemap.map_to_world(room.size))
		if rect.has_point(player.position):
			current_room = room
			panel.zones = room.neighbors
			panel.factory = room.factory
			panel.upgrade = room.upgrade
			panel.init()

func generate_room(zone_position: Vector2):
	# Randomly offset the room_position
	var room_position = zone_position * zone_size
	room_position += Vector2(rng.randi_range(1, 5), rng.randi_range(1, 5))
	
	# Randomly determine room size
	var size = Vector2(rng.randi_range(11, 15), rng.randi_range(11, 15))

	var spawners = []
	# Place floor tiles for the room
	for x in range(size.x):
		for y in range(size.y):
			if x % 2 and y % 2 and x > 2 and x < size.x - 2 and y > 2 and y < size.y - 2:
				spawners.append(Vector2(x, y))
			tilemap.set_cellv(room_position + Vector2(x, y), tile_id)
	
	# Update the autotile bitmask for the entire room region
	tilemap.update_bitmask_region(room_position, room_position + size)
	
	spawners.shuffle()
	spawners.resize(6)
	for spawner in spawners:
		tilemap2.set_cellv(room_position + spawner, 1)
	spawners.shuffle()
	var factory = spawners.pop_front()
	
	var upgrade = upgrades.pop_front()
	upgrades.shuffle()
	upgrades.append(upgrade)

	zones[zone_position] = {
		"position": room_position, 
		"size": size,
		"enemies": 0,
		"spawners": spawners,
		"factory": factory,
		"upgrade": upgrade,
		"door": null,
		"neighbors": [],
	}

func add_neighbors(zone_position: Vector2):
	var offsets = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	var free_positions = []
	for offset in offsets:
		if not zones.has(zone_position + offset):
			free_positions.append(zone_position + offset)
	if free_positions.size() == 0:
		return
	free_positions.shuffle()
	for free_position in free_positions:
		generate_room(free_position)
		connect_rooms(zone_position, free_position)
		if randi() % 2:
			break

func connect_rooms(zone_a_position: Vector2, zone_b_position: Vector2):
	var room_a_position = Vector2()
	var room_a_size = Vector2()
	var wall_a_position = Vector2()
	var door_a_position = Vector2()
	var corridor_a_position = Vector2()
	var room_b_position = Vector2()
	var room_b_size = Vector2()
	var door_b_position = Vector2()
	var corridor_b_position = Vector2()
	var corridor_ab_position = Vector2()
	var switched = false
	var rotated = false
	if zone_a_position.y == zone_b_position.y:
		if zone_a_position.x < zone_b_position.x:
			room_a_position = zones[zone_a_position].position
			room_a_size = zones[zone_a_position].size
			room_b_position = zones[zone_b_position].position
			room_b_size = zones[zone_b_position].size
		if zone_b_position.x < zone_a_position.x:
			room_a_position = zones[zone_b_position].position
			room_a_size = zones[zone_b_position].size
			room_b_position = zones[zone_a_position].position
			room_b_size = zones[zone_a_position].size
			switched = true
		wall_a_position = room_a_position + Vector2(room_a_size.x, 0)
		door_a_position = wall_a_position + Vector2(-1, randi() % int(room_a_size.y - 4) + 2)
		corridor_a_position = door_a_position + Vector2(0, -1)
		corridor_ab_position = zone_a_position * zone_size + Vector2(zone_size.x - 3, door_a_position.y)
		if zone_b_position.x < zone_a_position.x:
			corridor_ab_position -= zone_size
		door_b_position = room_b_position + Vector2(0, randi() % int(room_b_size.y - 4) + 2)
		corridor_b_position = door_b_position + Vector2(0, -1)
		for x in range(corridor_a_position.x, corridor_ab_position.x + 3):
			for y in range(corridor_a_position.y, corridor_a_position.y + 3):
				tilemap.set_cellv(Vector2(x, y), tile_id)
		for x in range(corridor_ab_position.x, corridor_ab_position.x + 3):
			if door_a_position.y < door_b_position.y:
				for y in range(door_a_position.y, door_b_position.y):
					tilemap.set_cellv(Vector2(x, y), tile_id)
			else:
				for y in range(door_b_position.y, door_a_position.y):
					tilemap.set_cellv(Vector2(x, y), tile_id)
		for x in range(corridor_ab_position.x, corridor_b_position.x):
			for y in range(corridor_b_position.y, corridor_b_position.y + 3):
				tilemap.set_cellv(Vector2(x, y), tile_id)
	else:
		rotated = true
		if zone_a_position.y < zone_b_position.y:
			room_a_position = zones[zone_a_position].position
			room_a_size = zones[zone_a_position].size
			room_b_position = zones[zone_b_position].position
			room_b_size = zones[zone_b_position].size
		if zone_b_position.y < zone_a_position.y:
			room_a_position = zones[zone_b_position].position
			room_a_size = zones[zone_b_position].size
			room_b_position = zones[zone_a_position].position
			room_b_size = zones[zone_a_position].size
			switched = true
		wall_a_position = room_a_position + Vector2(0, room_a_size.y)
		door_a_position = wall_a_position + Vector2(randi() % int(room_a_size.x - 4) + 2, -1)
		corridor_a_position = door_a_position + Vector2(-1, 0)
		corridor_ab_position = zone_a_position * zone_size + Vector2(door_a_position.x, zone_size.y - 3)
		if zone_b_position.y < zone_a_position.y:
			corridor_ab_position -= zone_size
		door_b_position = room_b_position + Vector2(randi() % int(room_b_size.x - 4) + 2, 0)
		corridor_b_position = door_b_position + Vector2(-1, 0)
		for x in range(corridor_a_position.x, corridor_a_position.x + 3):
			for y in range(corridor_a_position.y, corridor_ab_position.y + 3):
				tilemap.set_cellv(Vector2(x, y), tile_id)
		for y in range(corridor_ab_position.y, corridor_ab_position.y + 3):
			if door_a_position.x < door_b_position.x:
				for x in range(door_a_position.x, door_b_position.x):
					tilemap.set_cellv(Vector2(x, y), tile_id)
			else:
				for x in range(door_b_position.x, door_a_position.x):
					tilemap.set_cellv(Vector2(x, y), tile_id)
		for x in range(corridor_b_position.x, corridor_b_position.x + 3):
			for y in range(corridor_ab_position.y, corridor_b_position.y + 3):
				tilemap.set_cellv(Vector2(x, y), tile_id)
	var door = door_scene.instance()
	door.position = tilemap.map_to_world(door_b_position if switched else door_a_position)
	door.room_position = tilemap.world_to_map(door.position) - (room_b_position if switched else room_a_position)
	door.get_node("Sprite").rotation_degrees = 0 if rotated else 90
	door.to_zone = zone_b_position
	zones[zone_b_position].door = door
	zones[zone_a_position].neighbors.append(zones[zone_b_position])
	key += 1
	add_child(door)
	print(door.room_position)
	tilemap.update_bitmask_region(zone_a_position * zone_size, zone_a_position * zone_size + zone_size)
	tilemap.update_bitmask_region(zone_b_position * zone_size, zone_b_position * zone_size + zone_size)

func _on_timer_timeout():
	if player.died:
		return
	if randi() % 6:
		add_enemy(incrementer_scene)
	else:
		add_enemy(iterator_scene)
		
func add_enemy(scene):
	if not zones.has(current_zone_position):
		return
	if get_enemies_in_room(zones[current_zone_position]).size() > 25:
		return
	var room = zones[current_zone_position]
	var rect = Rect2(tilemap.map_to_world(room.position), tilemap.map_to_world(room.size))
	if not rect.has_point(player.position):
		return
	zones[current_zone_position].enemies += 1
	var room_position = zones[current_zone_position].position
	var spawner = zones[current_zone_position].spawners.pop_front()
	zones[current_zone_position].spawners.append(spawner)
	var enemy = scene.instance()
	enemy.position = tilemap.map_to_world(room_position + spawner) + Vector2(16, 16)
	add_child(enemy)

func get_enemies_in_room(room):
	var rect = Rect2(tilemap.map_to_world(room.position), tilemap.map_to_world(room.size))
	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if rect.has_point(enemy.position):
			enemies.append(enemy)
	return enemies
