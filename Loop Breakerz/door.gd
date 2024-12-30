extends StaticBody2D

var to_zone = Vector2()
var room_position = Vector2()

func unlock():
	get_parent().add_neighbors(to_zone)
	queue_free()
