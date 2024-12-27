extends KinematicBody2D

# Declare variables
var speed = 20
onready var target_player = $"../Looper"
export var health = 1
var explosion_scene = preload("res://explosion_big.tscn")

func _process(_delta):
	$Sprite2.rotation_degrees += 7
	
	# Make the enemy chase the player
	if target_player:
		# warning-ignore:return_value_discarded
		move_and_slide(position.direction_to(target_player.position) * speed)
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	# Instance the explosion scene
	var explosion = explosion_scene.instance()

	# Set the explosion position to the projectile's current position
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	queue_free()
