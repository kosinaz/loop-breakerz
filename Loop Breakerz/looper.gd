extends KinematicBody2D

# Player speed and velocity
var speed = 40
var velocity = Vector2()

# Direction the player is moving in (store last pressed direction)
var move_direction = Vector2()

# Maximum rotation and movement angle delta per frame
const MAX_ANGLE_DELTA = PI / 8

# Shooting control
var can_shoot = true
var projectile_scene = preload("res://projectile_looper.tscn")

onready var health_bar = $"%HealthBar"

func _process(_delta):
	# Get the mouse position
	var mouse_position = get_global_mouse_position()
	
	# Calculate the direction vector from the player to the mouse
	var direction_to_mouse: Vector2 = (mouse_position - global_position).normalized()
	
	# Calculate the target rotation angle
	var target_rotation = direction_to_mouse.angle()
	
	# Smoothly interpolate the rotation, limiting to MAX_ANGLE_DELTA
	rotation = lerp_angle(rotation, target_rotation, MAX_ANGLE_DELTA)
	
	# Restrict movement direction based on the limited rotation
	var restricted_direction = Vector2(cos(rotation), sin(rotation)).normalized()
	
	# Calculate the restricted velocity
	velocity = restricted_direction * speed
	
	# Move the player
	# warning-ignore:return_value_discarded
	move_and_slide(velocity)

func shoot():
	var projectile = projectile_scene.instance()
	projectile.global_position = global_position
	projectile.rotation = rotation
	var enemies = get_tree().get_nodes_in_group("enemies")
	if not enemies:
		return
	var closest = enemies[0]
	for enemy in enemies:
		if position.distance_to(enemy.position) < position.distance_to(closest.position):
			closest = enemy
	if position.distance_to(closest.position) > 100:
		return
	projectile.set_direction(position.direction_to(closest.position))
	get_parent().add_child(projectile)

# Callback when the Timer times out
func _on_timer_timeout():
	shoot()
