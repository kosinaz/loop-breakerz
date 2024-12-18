extends KinematicBody2D

# Player speed and velocity
var speed = 50
var velocity = Vector2()

# Maximum rotation and movement angle delta per frame
const MAX_ANGLE_DELTA = PI / 16

# Shooting control
var can_shoot = true
export(PackedScene) var projectile_scene

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

	# Handle shooting
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot:
		shoot(direction_to_mouse)

func shoot(direction: Vector2):
	# Create a new projectile instance
	var projectile = projectile_scene.instance()
	get_parent().add_child(projectile)
	
	# Set the position and direction of the projectile
	projectile.global_position = global_position
	projectile.set_direction(direction)
	
	# Start the shooting cooldown
	can_shoot = false
	$Timer.start()

# Callback when the Timer times out
func _on_timer_timeout():
	can_shoot = true
