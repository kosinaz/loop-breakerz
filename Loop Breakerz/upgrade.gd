extends Area2D

var powerup_scene = preload("res://powerup.tscn")
var upgrade_type = ""

func _process(_delta):
	$Sprite2.rotation_degrees += 1

func set_type(new_upgrade_type):
	upgrade_type == new_upgrade_type
	$Sprite.texture = load("res://assets/" + new_upgrade_type + ".png")

func _on_token_body_entered(body):
	if body.name != "Looper":
		return
	if upgrade_type == "adaptability":
		body.health_max *= 1.5
		body.health_bar.max_value = body.health_max
	if upgrade_type == "frequency":
		body.get_node("Timer").wait_time /= 1.5
	if upgrade_type == "severity":
		body.damage_mod *= 1.5
	if upgrade_type == "velocity":
		body.speed *= 1.5
	body.health = body.health_max
	body.health_bar.value = body.health_max
	var powerup = powerup_scene.instance()
	powerup.global_position = global_position
	get_parent().add_child(powerup)
	get_parent().get_node("Camera2D").start_shake_and_modulate(0.5, 0.4, "green")
	queue_free()
