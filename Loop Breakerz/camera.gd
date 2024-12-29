extends Camera2D

# Shake intensity and duration
var shake_intensity = 0.0
var shake_duration = 0.0
var original_offset = Vector2()
var is_modulating = false
var modulate_color = ""
onready var panel = $"../BreakerPanel"

func start_shake_and_modulate(intensity: float, duration: float, color: String):
	shake_intensity = intensity
	shake_duration = duration
	modulate_color = color
	original_offset = offset  # Store the original offset
	print(panel.overlay)
	panel.overlay.visible = true
	is_modulating = true
	set_process(true)

func _process(delta):
	if not panel.overlay:
		return
	if shake_duration > 0:
		# Apply random shake
		offset.x = original_offset.x + rand_range(-shake_intensity, shake_intensity)
		offset.y = original_offset.y + rand_range(-shake_intensity, shake_intensity)
		
		# Decrease the shake duration
		shake_duration -= delta

		# Modulate the red screen effect
		if is_modulating:
			var progress = 1.0 - (shake_duration / 0.4)  # Assuming 0.2s effect duration
			var red = 1 if modulate_color == "red" else 0
			var green = 1 if modulate_color == "green" else 0
			panel.overlay.color = Color(red, green, 0, lerp(0.2, 0, progress))  # Fade out

	else:
		# Reset shake and modulation
		offset = original_offset
		panel.overlay.visible = false
		set_process(false)
