extends Area2D

var powerup_scene = preload("res://powerup.tscn")
var upgrade_type = ""

func _process(_delta):
	$Sprite2.rotation_degrees += 8

func set_type(new_upgrade_type):
	upgrade_type = new_upgrade_type
	$Sprite.texture = load("res://assets/" + new_upgrade_type.to_lower() + ".png")

func _on_token_body_entered(body):
	if body.name != "Looper":
		return
	if upgrade_type == "Adaptability":
		body.adaptability += 1
		body.health_bar.max_value = body.adaptabilities[body.adaptability]
	if upgrade_type == "Frequency":
		body.frequency += 1
		body.get_node("AttackTimer").wait_time = body.frequencies[body.frequency]
	if upgrade_type == "Severity":
		body.severity += 1
	if upgrade_type == "Velocity":
		body.velocity += 1
	body.health = body.adaptabilities[body.adaptability]
	body.health_bar.value = body.health
	var powerup = powerup_scene.instance()
	powerup.global_position = global_position
	body.level += 1
	get_parent().current_room.upgrade = "Void"
	get_parent().panel.update_stats()
	get_parent().add_child(powerup)
	get_parent().get_node("Camera2D").start_shake_and_modulate(0.5, 0.4, "green")
	queue_free()
