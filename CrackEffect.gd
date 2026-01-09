class_name CrackVisuals extends Node2D

# Settings for 16x16 tiles
const TILE_CENTER = Vector2(0, 0)
var crack_color = Color(0.096, 0.096, 0.096, 1.0) # Dark grey/black
var line_width = 0.2

# Data to hold the random crack paths
var branches: Array[Vector2] = []

# The animation progress (0.0 = start, 1.0 = fully cracked)
var progress: float = 0.0:
	set(value):
		progress = value
		queue_redraw() # Tell Godot to run _draw() again immediately

func _ready():
	# Set z_index high so it draws ON TOP of the floor
	z_index = 0
	generate_random_cracks()

func generate_random_cracks():
	# Create 4 to 6 main crack branches radiating from the center
	var num_branches = randi_range(4, 6)
	
	for i in num_branches:
		# Pick a random angle (0 to 360 degrees)
		var angle = randf() * TAU
		# Pick a length that reaches near the edge of the 16px tile (5 to 9 pixels)
		var length = randf_range(5.0, 9.0)
		
		# Calculate the end point using trigonometry
		# Start at center + move outwards at angle * length
		var end_point = TILE_CENTER + Vector2.RIGHT.rotated(angle) * length
		branches.append(end_point)

# This is Godot's built-in drawing function
func _draw():
	# Loop through our generated branch destinations
	for destination in branches:
		# Calculate where the line should end RIGHT NOW based on progress.
		# lerp(start, end, 0.5) finds the halfway point.
		var current_end = TILE_CENTER.lerp(destination, progress)
		
		# Draw the line
		# draw_line(start_pos, end_pos, color, thickness)
		draw_line(TILE_CENTER, current_end, crack_color, line_width)

# A helper function to handle the animation and cleanup
func animate_and_destroy(duration):
	var tween = create_tween()
	# Animate the 'progress' variable from 0.0 to 1.0 over 'duration' seconds
	tween.tween_property(self, "progress", 1.0, duration)
	# When done, delete this object
	tween.tween_callback(queue_free)
