extends KinematicBody2D

# Declare variables
var speed = 10
var projectile_scene = preload("res://projectile_skipper.tscn")
onready var target_player = $"../Looper"
export var health = 1
var explosion_scene = preload("res://explosion_big.tscn")
var token_scene = preload("res://token.tscn")

func _process(delta):
	# Make the enemy chase the player
	if not target_player:
		return
		
	if target_player.died:
		return
	
	# Move the enemy
# warning-ignore:return_value_discarded
	move_and_collide(position.direction_to(target_player.position) * speed * delta)

	# Rotate the enemy to face the player
	var direction = global_position.direction_to(target_player.global_position)

	rotation = lerp_angle(rotation, atan2(direction.y, direction.x), 0.1)


func _on_timer_timeout():
	var projectile = projectile_scene.instance()
	projectile.global_position = global_position
	projectile.rotation = rotation
	projectile.damage = [1, 3]
	projectile.set_direction(position.direction_to(target_player.position))
	get_parent().add_child(projectile)
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	var explosion = explosion_scene.instance()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	var token = token_scene.instance()
	token.global_position = global_position
	get_parent().add_child(token)
	queue_free()
