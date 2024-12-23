extends Node2D

# Room and corridor parameters
export (int) var room_min_size = 7
export (int) var room_max_size = 10
export (int) var corridor_width = 3
export (int) var tile_id = 0  # ID for walkable tiles

onready var tilemap = $TileMap
var rng = RandomNumberGenerator.new()

func _ready():
	# Seed the RNG
	rng.seed = OS.get_ticks_usec()

	# Generate Room A at the origin
	var room_a = generate_room(Vector2.ZERO)

	# Generate Room B at least 10 tiles away (hardcoded for now)
	var room_b_position = Vector2(15, 0)
	var room_b = generate_room(room_b_position)

	# Connect Room A and Room B with a corridor
	connect_rooms(room_a, room_b)

func generate_room(origin: Vector2) -> Rect2:
	# Randomly determine room size
	var width = rng.randi_range(room_min_size, room_max_size)
	var height = rng.randi_range(room_min_size, room_max_size)

	# Place floor tiles for the room
	for x in range(width):
		for y in range(height):
			tilemap.set_cellv(origin + Vector2(x, y), tile_id)

	# Update the autotile bitmask for the entire room region
	tilemap.update_bitmask_region(origin, Vector2(width, height))

	# Return the room's bounds for corridor placement
	return Rect2(origin, Vector2(width, height))

func connect_rooms(room_a: Rect2, room_b: Rect2):
	# Find the center of each room
	var center_a = room_a.position + room_a.size / 2
	var center_b = room_b.position + room_b.size / 2

	# Create a horizontal corridor
	var start_x = int(min(center_a.x, center_b.x))
	var end_x = int(max(center_a.x, center_b.x))

	for x in range(start_x, end_x + 1):
		for y in range(corridor_width):
			var y_pos = int(center_a.y + y - corridor_width / 2)
			tilemap.set_cellv(Vector2(x, y_pos), tile_id)

	# Update the autotile bitmask for the corridor region
	var corridor_region_origin = Vector2(start_x, center_a.y - int(corridor_width / 2))
	var corridor_region = Vector2(end_x - start_x + 1, corridor_width)
	tilemap.update_bitmask_region(corridor_region_origin, corridor_region)
