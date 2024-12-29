extends Node2D

# Speed of ring expansion
export var expansion_speed = 0.05
# Maximum radius the ring can expand to
export var max_radius = 5.0
# Initial radius
var current_radius = 0.0

func _process(delta):
	# Get the material of the ring node
	var material = $Sprite.material

	# Ensure the material is a ShaderMaterial
	if material is ShaderMaterial:
		# Update the radius value
		current_radius += expansion_speed * delta
		
		# Clamp the radius to ensure it doesn't exceed max_radius
		current_radius = min(current_radius, max_radius)
		
		# Set the radius in the shader
		material.set_shader_param("radius", current_radius)
		print(material)
		# Free the node when the ring reaches maximum radius
		if current_radius >= max_radius:
			queue_free()
