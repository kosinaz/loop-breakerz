extends Area2D

var powerup_scene = preload("res://powerup.tscn")

func _process(_delta):
	$Sprite.rotation_degrees -= 3
	$Sprite2.rotation_degrees += 1


func _on_token_body_entered(body):
	if body.name != "Looper":
		return
	var powerup = powerup_scene.instance()
	powerup.global_position = global_position
	get_parent().add_child(powerup)
	get_parent().get_node("BreakerPanel").reveal_next()
	queue_free()
