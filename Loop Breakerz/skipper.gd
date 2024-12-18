extends KinematicBody2D

# Declare variables
var speed = 20
var shoot_cooldown = 1.0 # Time between shots
var velocity = Vector2()
var target_player = null  # The player to chase
export(PackedScene) var projectile_scene

onready var timer = $Timer  # Assuming the Timer node is a child of the enemy node

# Movement direction (up, down, left, right)
var move_direction = Vector2()

# Maximum distance before changing direction
var direction_change_distance = 8

# Last position the enemy was at
var last_position = Vector2()

# Timer to change direction
var direction_change_timer = 0.0

# Setup enemy's timer
func _ready():
	# Find the player node, assuming it's in the scene tree
	target_player = get_node("/root/Map/Looper")
	timer.start(shoot_cooldown)

func _process(delta):
	# Make the enemy chase the player
	if target_player:
		# Calculate the direction vector to the player
		var direction_to_player = (target_player.global_position - global_position).normalized()

		# Determine the closest cardinal direction (up, down, left, right)
		# Get the absolute X and Y distances to the player
		var x_distance = abs(direction_to_player.x)
		var y_distance = abs(direction_to_player.y)

		# Determine the cardinal direction based on which axis has the greater distance
		if x_distance > y_distance:
			# Move left or right
			if direction_to_player.x > 0:
				move_direction = Vector2(1, 0)  # Move right
			else:
				move_direction = Vector2(-1, 0)  # Move left
		else:
			# Move up or down
			if direction_to_player.y > 0:
				move_direction = Vector2(0, 1)  # Move down
			else:
				move_direction = Vector2(0, -1)  # Move up

		# Move the enemy
		velocity = move_direction * speed
		move_and_slide(velocity)

		# Rotate the enemy to face the player
		rotation = direction_to_player.angle()

	# Check if the enemy has moved at least 8 pixels from its last position
	if global_position.distance_to(last_position) >= direction_change_distance:
		# Update the last position
		last_position = global_position  # Update last position

func _on_timer_timeout():
	# Shoot at the player (implement projectile spawn or action here)
	shoot_at_player()

func shoot_at_player():
	var projectile = projectile_scene.instance()
	projectile.global_position = global_position
	projectile.rotation = rotation
	var direction_to_player = (target_player.global_position - global_position).normalized()
	projectile.set_direction(direction_to_player)
	get_parent().add_child(projectile)
