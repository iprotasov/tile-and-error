extends Camera2D

# Call this function to shake the screen
# intensity = how many pixels to shake (e.g., 2.0 for subtle, 5.0 for heavy)
# duration = how long it lasts (e.g., 0.2 seconds)
func shake(intensity: float, duration: float):
	var tween = create_tween()
	# Shake rapidly back and forth
	for i in range(10):
		# Pick a random tiny offset
		var random_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		# Move camera there instantly
		tween.tween_property(self, "offset", random_offset, duration / 10.0)
	
	# Reset to center at the end
	tween.tween_callback(func(): offset = Vector2.ZERO)
