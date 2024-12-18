extends KinematicBody2D

# Declare variables
var speed = 10
var shoot_cooldown = 1.0 # Time between shots
var velocity = Vector2()
var target_player = null  # The player to chase
export(PackedScene) var projectile_scene

onready var timer = $Timer  # Assuming the Timer node is a child of the enemy node

# Setup enemy's timer
func _ready():
	# Find the player node, assuming it's in the scene tree
	target_player = get_node("/root/Map/Looper")
	timer.start(shoot_cooldown)

func _process(_delta):
	# Make the enemy chase the player
	if target_player:
		 # Calculate the direction vector to the player
		var direction_to_player = (target_player.global_position - global_position).normalized()

		# Set rotation to face the player
		rotation = direction_to_player.angle()

		# Calculate movement velocity towards the player
		velocity = direction_to_player * speed

		# Move the enemy
		# warning-ignore:return_value_discarded
		move_and_slide(velocity)

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
