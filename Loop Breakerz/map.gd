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

	# Generate room at the origin
	zones[Vector2(0, 0)] = generate_room(Vector2.ZERO)
	zones[Vector2(-1, 0)] = generate_room(Vector2(-1, 0))
	zones[Vector2(0, -1)] = generate_room(Vector2(0, -1))
	zones[Vector2(-1, -1)] = generate_room(Vector2(-1, -1))
	zones[Vector2(1, -1)] = generate_room(Vector2(1, -1))
	zones[Vector2(1, 0)] = generate_room(Vector2(1, 0))
	
func _process(_delta):
	if Input.is_action_just_released("ui_accept"):
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()

func generate_room(origin: Vector2) -> Dictionary:	
	# Randomly offset the origin
	origin *= zone_size
	origin += Vector2(rng.randi_range(1, 5), rng.randi_range(1, 5))
	
	# Randomly determine room size
	var size = Vector2(rng.randi_range(11, 15), rng.randi_range(11, 15))

	# Place floor tiles for the room
	for x in range(size.x):
		for y in range(size.y):
			tilemap.set_cellv(origin + Vector2(x, y), tile_id)
	
	var doors = []

	# Top door
	if randi() % 2 + 1:
		var door_position = origin + Vector2(randi() % (int(size.x) - 4) + 2, -1)
		for x in range(-1, 2):
			tilemap.set_cellv(door_position + Vector2(x, 0), tile_id)
		doors.append({
			"position": door_position,
			"direction": "up",
		})

	# Bottom door
	if randi() % 2 + 1:
		var door_position = origin + Vector2(randi() % (int(size.x) - 4) + 2, size.y)
		for x in range(-1, 2):
			tilemap.set_cellv(door_position + Vector2(x, 0), tile_id)
		doors.append({
			"position": door_position,
			"direction": "down",
		})

	# Left door
	if randi() % 2 + 1:
		var door_position = origin + Vector2(-1, randi() % (int(size.y) - 4) + 2)
		for y in range(-1, 2):
			tilemap.set_cellv(door_position + Vector2(0, y), tile_id)
		doors.append({
			"position": door_position,
			"direction": "left",
		})

	# Right door
	if randi() % 2 + 1:
		var door_position = origin + Vector2(size.x, randi() % (int(size.y) - 4) + 2)
		for y in range(-1, 2):
			tilemap.set_cellv(door_position + Vector2(0, y), tile_id)
		doors.append({
			"position": door_position,
			"direction": "right",
		})

	# Update the autotile bitmask for the entire room region
	tilemap.update_bitmask_region(origin, origin + size)

	# Return the room's bounds for corridor placement
	return {
		"origin": origin, 
		"size": size,
#		"doors": doors,
	}

func get_valid_entrance(room: Rect2) -> Vector2:
	# Get valid tiles for corridor entrances, excluding corners
	var origin = room.position
	var width = room.size.x
	var height = room.size.y

	# Horizontal edges: Exclude the corners of the room
	var top_edge = []
	var bottom_edge = []

	for x in range(1, width - 1):  # Exclude the corners by starting at 1 and ending before width - 1
		top_edge.append(origin + Vector2(x, 0))  # Add positions on the top edge
		bottom_edge.append(origin + Vector2(x, height - 1))  # Add positions on the bottom edge

	# Vertical edges: Exclude the corners of the room
	var left_edge = []
	var right_edge = []

	for y in range(1, height - 1):  # Exclude the corners by starting at 1 and ending before height - 1
		left_edge.append(origin + Vector2(0, y))  #  Add positions on the left edge
		right_edge.append(origin + Vector2(width - 1, y))  # Add positions on the right edge

	# Combine all valid edges
	var valid_positions = top_edge + bottom_edge + left_edge + right_edge

	# Choose a random position from the valid tiles
	return valid_positions[rng.randi_range(0, valid_positions.size() - 1)]
