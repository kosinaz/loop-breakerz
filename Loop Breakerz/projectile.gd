extends KinematicBody2D

# Speed of the projectile
export var speed = 200
var direction = Vector2()
var floating_text_scene = preload("res://floating_text.tscn")
var damage_mod = 1

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
	
	var damage = (4 + randi() % 12) * damage_mod
	var collider = collision.collider
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	
	# Add the explosion to the scene (assuming map node or parent is available)
	get_parent().add_child(explosion)
	
	var floating_text = floating_text_scene.instance()
	floating_text.position = position
	floating_text.get_node("Label").text = str(damage)
	get_parent().add_child(floating_text)
