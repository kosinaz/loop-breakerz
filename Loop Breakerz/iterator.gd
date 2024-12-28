extends KinematicBody2D

# Declare variables
var speed = 30
onready var target_player = $"../Looper"
export var health = 1
var explosion_scene = preload("res://explosion_big.tscn")
var token_scene = preload("res://token.tscn")

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
	var explosion = explosion_scene.instance()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	var token = token_scene.instance()
	token.global_position = global_position
	get_parent().add_child(token)
	queue_free()
