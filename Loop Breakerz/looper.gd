extends Node2D

# Speed of the player movement
export var speed: float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get the global position of the mouse cursor
	var mouse_position: Vector2 = get_global_mouse_position()
	
	# Calculate the direction vector from the player to the mouse
	var direction_to_mouse: Vector2 = (mouse_position - global_position).normalized()
	
	# Set the rotation of the player to face the mouse
	rotation = direction_to_mouse.angle()
	
	# Move the player towards the mouse cursor
	global_position += direction_to_mouse * speed * delta
