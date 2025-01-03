extends KinematicBody2D

# Declare variables
var speed = 30
onready var target_player = $"../Looper"
export var health = 1
export var damage = 1  # Amount of damage dealt to the player
var explosion_scene = preload("res://explosion_big.tscn")
var token_scene = preload("res://token.tscn")

func _process(delta):
	$Sprite2.rotation_degrees += 7
	
	# Make the enemy chase the player
	if not target_player:
		return
		
	if target_player.died:
		return

	var collision = move_and_collide(position.direction_to(target_player.position) * speed * delta)
	
	# Check for collision
	if not collision:
		return
	if collision.collider != target_player:
		return
	target_player.take_damage(damage)
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die(ring_of_death = false):
	var explosion = explosion_scene.instance()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	if not ring_of_death:
		var token = token_scene.instance()
		token.global_position = global_position
		get_parent().add_child(token)
	queue_free()
