extends Area2D

# Reference to the Sprite node
onready var ring_sprite = $Sprite

# Speed of expansion and maximum radius
export var expansion_speed = 1.25
export var max_radius = 5.0

# Current radius of the ring
var current_radius = 0.0

onready var collision = $CollisionShape2D

func _ready():
	# Initialize the shader radius to 0
	var material = ring_sprite.material
	if material is ShaderMaterial:
		material.set_shader_param("radius", current_radius)

func _process(delta):

	# Update and expand the radius
	if current_radius < max_radius:
		current_radius += expansion_speed * delta
		collision.shape.radius = current_radius * 200
		# Update the shader parameter
		var material = ring_sprite.material
		if material is ShaderMaterial:
			material.set_shader_param("radius", current_radius)
	else:
		# Stop expansion and optionally free the node
		queue_free()


func _on_ring_body_entered(body):
	if not body.is_in_group("enemies"):
		return
	body.die(true)
