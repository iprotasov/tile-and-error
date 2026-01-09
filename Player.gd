extends CharacterBody2D

var dust_scene = preload("res://DustEffect.tscn")

@onready var ray = $RayCast2D
@onready var anim = $AnimationPlayer

const TILE_SIZE = 16
var move_speed = 4.0

var is_moving = false

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.75)

func _process(delta: float) -> void:
	if is_moving:
		return
	
	check_death_status()
	
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		input_dir = Vector2.RIGHT
	
	if input_dir != Vector2.ZERO:
		update_facing(input_dir)
		move(input_dir)

func update_facing(direction: Vector2):
	if direction == Vector2.RIGHT:
		$Sprite2D.flip_h = false
	elif direction == Vector2.LEFT:
		$Sprite2D.flip_h = true

func move(direction: Vector2):
	ray.target_position = direction * TILE_SIZE
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		var tween = create_tween()
		var target_pos = position + (direction * TILE_SIZE)
		
		is_moving = true
		tween.tween_property(self, "position", target_pos, 1.0 / move_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			is_moving = false
			
			var dust = dust_scene.instantiate()
			dust.position = position
			dust.z_index = -1
			dust.amount = 4
			dust.lifetime = 0.4
			dust.scale_amount_min = 0.3
			dust.scale_amount_max = 0.5
			dust.explosiveness = 0.8
			
			get_parent().add_child(dust)
			
			check_floor()
			)

func check_floor():
	var map = get_parent().get_node("Floor")
	
	var tile_pos = map.local_to_map(position)
	
	var data = map.get_cell_tile_data(tile_pos)
	
	if data:
		if data.get_custom_data("is_hole") != true:
			initiate_hole(map, tile_pos)

func initiate_hole(map, hole_pos):
	print("WARNING: Tile is cracking!")
	
	var cracks = CrackVisuals.new()
	cracks.position = map.map_to_local(hole_pos)
	get_parent().add_child(cracks)
	cracks.animate_and_destroy(3.0)
	
	await get_tree().create_timer(3.0).timeout
	
	var hole_coords = Vector2i(8,7)
	map.set_cell(hole_pos, 0, hole_coords)

func check_death_status():
	var map = get_parent().get_node("Floor") 
	var tile_pos = map.local_to_map(position)
	var data = map.get_cell_tile_data(tile_pos)
	
	if data:
		if data.get_custom_data("is_hole") == true:
			print("Standing on a hole! Falling...")
			die()

func die():
	is_moving = true
	set_process(false)
	
	var cam = $Camera2D 
	if cam and cam.has_method("shake"):
		# Shake by 2 pixels for 0.3 seconds
		cam.shake(2.0, 0.3)
		
	var dust = dust_scene.instantiate()
	dust.position = position
	get_parent().add_child(dust)
	
	anim.play("fall")
	
	await anim.animation_finished
	
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
