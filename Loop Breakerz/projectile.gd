extends KinematicBody2D

# Speed of the projectile
export var speed = 200
var direction = Vector2()

# Set the direction of the projectile
func set_direction(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	# Move the projectile and detect collisions
	var collision = move_and_collide(direction * speed * delta)
	
	# Destroy the projectile if it collides with the map
	if collision:
		queue_free()
