extends Node2D

# Room and corridor parameters
export (Vector2) var zone_size = Vector2(25, 25)
export (int) var tile_id = 0  # ID for walkable tiles

onready var tilemap = $TileMap
var rng = RandomNumberGenerator.new()
var zones = {}

func _ready():
	# Seed the RNG
	rng.seed = OS.get_ticks_usec()

	generate_room(Vector2(0, 0))
	add_neighbors(Vector2(0, 0))
	
func _process(_delta):
	if Input.is_action_just_released("ui_accept"):
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()

func generate_room(zone_position: Vector2):
	# Randomly offset the room_position
	var room_position = zone_position * zone_size
	room_position += Vector2(rng.randi_range(1, 5), rng.randi_range(1, 5))
	
	# Randomly determine room size
	var size = Vector2(rng.randi_range(11, 15), rng.randi_range(11, 15))

	# Place floor tiles for the room
	for x in range(size.x):
		for y in range(size.y):
			tilemap.set_cellv(room_position + Vector2(x, y), tile_id)
	
	# Update the autotile bitmask for the entire room region
	tilemap.update_bitmask_region(room_position, room_position + size)

	# Return the room's bounds for corridor placement
	zones[zone_position] = {
		"position": room_position, 
		"size": size,
	}

func add_neighbors(zone_position: Vector2):
	var offsets = [Vector2(-1, 0), Vector2(1, 0)] #, Vector2(-1, 0), Vector2(0, -1)]
	var free_positions = []
	for offset in offsets:
		if not zones.has(zone_position + offset):
			free_positions.append(zone_position + offset)
	if free_positions.size() == 0:
		return
#	free_positions.shuffle()
	for free_position in free_positions:
		generate_room(free_position)
		connect_rooms(zone_position, free_position)
#		if randi() % 2:
#			break

func connect_rooms(zone_a_position: Vector2, zone_b_position: Vector2):
	var room_a_position = Vector2()
	var room_a_size = Vector2()
	var room_b_position = Vector2()
	var room_b_size = Vector2()
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
	var wall_a_position = room_a_position + Vector2(room_a_size.x, 0)
	var door_a_position = wall_a_position + Vector2(0, randi() % int(room_a_size.y - 4) + 2)
	var corridor_a_position = door_a_position + Vector2(0, -1)
	var corridor_ab_position = zone_a_position * zone_size + Vector2(zone_size.x - 3, door_a_position.y)
	if zone_b_position.x < zone_a_position.x:
		corridor_ab_position -= zone_size
	var door_b_position = room_b_position + Vector2(0, randi() % int(room_b_size.y - 4) + 2)
	var corridor_b_position = door_b_position + Vector2(0, -1)
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
	tilemap.update_bitmask_region(zone_a_position * zone_size, zone_a_position * zone_size + zone_size)
	tilemap.update_bitmask_region(zone_b_position * zone_size, zone_b_position * zone_size + zone_size)

#	var doors = []
#	# Top
#	if randi() % 2 + 1:
#		var door_position = room_position + Vector2(randi() % (int(size.x) - 4) + 2, -1)
#		for x in range(-1, 2):
#			tilemap.set_cellv(door_position + Vector2(x, 0), tile_id)
#		doors.append({
#			"position": door_position,
#			"direction": "up",
#		})
#
#	# Bottom door
#	if randi() % 2 + 1:
#		var door_position = room_position + Vector2(randi() % (int(size.x) - 4) + 2, size.y)
#		for x in range(-1, 2):
#			tilemap.set_cellv(door_position + Vector2(x, 0), tile_id)
#		doors.append({
#			"position": door_position,
#			"direction": "down",
#		})
#
#	# Left door
#	if randi() % 2 + 1:
#		var door_position = room_position + Vector2(-1, randi() % (int(size.y) - 4) + 2)
#		for y in range(-1, 2):
#			tilemap.set_cellv(door_position + Vector2(0, y), tile_id)
#		doors.append({
#			"position": door_position,
#			"direction": "left",
#		})
#
#	# Right door
#	if randi() % 2 + 1:
#		var door_position = room_position + Vector2(size.x, randi() % (int(size.y) - 4) + 2)
#		for y in range(-1, 2):
#			tilemap.set_cellv(door_position + Vector2(0, y), tile_id)
#		doors.append({
#			"position": door_position,
#			"direction": "right",
#		})


func get_valid_entrance(room: Rect2) -> Vector2:
	# Get valid tiles for corridor entrances, excluding corners
	var room_position = room.position
	var width = room.size.x
	var height = room.size.y

	# Horizontal edges: Exclude the corners of the room
	var top_edge = []
	var bottom_edge = []

	for x in range(1, width - 1):  # Exclude the corners by starting at 1 and ending before width - 1
		top_edge.append(room_position + Vector2(x, 0))  # Add positions on the top edge
		bottom_edge.append(room_position + Vector2(x, height - 1))  # Add positions on the bottom edge

	# Vertical edges: Exclude the corners of the room
	var left_edge = []
	var right_edge = []

	for y in range(1, height - 1):  # Exclude the corners by starting at 1 and ending before height - 1
		left_edge.append(room_position + Vector2(0, y))  #  Add positions on the left edge
		right_edge.append(room_position + Vector2(width - 1, y))  # Add positions on the right edge

	# Combine all valid edges
	var valid_positions = top_edge + bottom_edge + left_edge + right_edge

	# Choose a random position from the valid tiles
	return valid_positions[rng.randi_range(0, valid_positions.size() - 1)]
