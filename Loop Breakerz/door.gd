extends StaticBody2D

var key = KEY_0
var to_zone = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_key_pressed(key):
		get_parent().add_neighbors(to_zone)
		queue_free()
