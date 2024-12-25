extends KinematicBody2D

# Speed of the projectile
export var speed = 200
var direction = Vector2()

# Explosion scene reference
export (PackedScene) var explosion_scene

# Set the direction of the projectile
func set_direction(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	# Move the projectile and detect collisions
	var collision = move_and_collide(direction * speed * delta)
	
	# Destroy the projectile if it collides with the map
	if collision:
		handle_collision(collision)
		queue_free()  # Destroy the projectile after explosion

# Function to trigger the explosion
func handle_collision(collision):
	# Instance the explosion scene
	var explosion = explosion_scene.instance()

	# Set the explosion position to the projectile's current position
	explosion.global_position = global_position
	
	var collider = collision.collider
	if collider.has_method("take_damage"):
		collider.take_damage(1)
	
	# Add the explosion to the scene (assuming map node or parent is available)
	get_parent().add_child(explosion)
