extends KinematicBody2D

# Player speed and velocity
var health = 10
var damaged = false
var died = false
var level = 1
var adaptability = 0
var frequency = 0
var severity = 0
var velocity = 0
var adaptabilities = [10, 13, 16, 19, 25, 28, 34, 37, 43, 52, 61, 73, 82, 94, 107, 123, 141, 162, 185, 210]
var frequencies = [2, 1.7, 1.5, 1.3, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1]
var severities = [[4, 10], [5, 13], [6, 16], [8, 20], [10, 24], [12, 31], [15, 38], [19, 48], [24, 60], [30, 75], [37, 93], [47, 116], [58, 146], [73, 182], [91, 227], [114, 284], [142, 355], [178, 444], [222, 555], [278, 694]]
var velocities = [40, 53, 63, 71, 78, 84, 89, 93, 97, 101, 104, 107, 110, 113, 115, 118, 120, 122, 124, 126]

# Direction the player is moving in (store last pressed direction)
var move_direction = Vector2()

# Maximum rotation and movement angle delta per frame
const MAX_ANGLE_DELTA = PI / 8

# Shooting control
var can_shoot = true
var projectile_scene = preload("res://projectile_looper.tscn")
var ring_scene = preload("res://ring.tscn")

var expansion_speed = 0.5  # Speed of ring expansion
var max_radius = 1.0  # Maximum radius

onready var health_bar = $"%HealthBar"
onready var attack_timer = $AttackTimer
onready var damage_timer = $DamageTimer
onready var animation_player = $AnimationPlayer

func _process(_delta):
	if died:
		return
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
	
	# Move the player
	# warning-ignore:return_value_discarded
	move_and_slide(restricted_direction * velocities[velocity])


func shoot():
	var projectile = projectile_scene.instance()
	projectile.global_position = global_position
	projectile.rotation = rotation
	projectile.damage = severities[severity]
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
func _on_attack_timer_timeout():
	if died:
		return
	shoot()

func take_damage(amount):
	if died:
		return
	if damaged:
		return
	damaged = true
	damage_timer.start()
	health -= amount
	health_bar.value = health
	animation_player.play("hit")
	get_parent().get_node("Camera2D").start_shake_and_modulate(2.0, 0.4, "red")
	if health <= 0:
		die()

func die():
	died = true
	var ring = ring_scene.instance()
	ring.global_position = global_position
	get_parent().add_child(ring)
	animation_player.play("dead")
	get_parent().panel.eliminate()
	$DeathTimer.start()
	
func revive():
	died = false
	animation_player.play("hit")
	health = adaptabilities[adaptability]
	health_bar.value = health

func _on_damage_timer_timeout():
	damaged = false

func _on_death_timer_timeout():
	var r = randi() % 4
	if r == 0 and adaptability > 0:
		adaptability -= 1
		level -= 1
		health_bar.max_value = adaptabilities[adaptability]
	if r == 1 and frequency > 0:
		frequency -= 1
		level -= 1
	if r == 2 and severity > 0:
		severity -= 1
		level -= 1
	if r == 3 and velocity > 0:
		velocity -= 1
		level -= 1
	get_parent().panel.update_stats()
