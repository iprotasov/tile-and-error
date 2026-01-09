extends Area2D

@onready var sprite = $Sprite2D
@export var variations: Array[Texture2D]

func _ready() -> void:
	if variations.size() > 0:
		sprite.texture = variations.pick_random()
		
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Fall...")
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
