extends CPUParticles2D

func _ready():
	emitting = true
	# Wait for the lifetime to finish, then delete object
	await finished
	queue_free()
