extends CharacterBody2D

@export var autonomous_mode := false
@export var autonomous_speed := 40  
@export var player_speed := 10        
@onready var held_item_sprite = $HeldItemSprite
@onready var main_sprite = $AnimatedSprite2D
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound
@export var tile_map: TileMapLayer 
@export var object_scene: PackedScene = preload("res://scenes/beds.tscn")
@export var bed_width_in_cells: int = 2 

var occupied_cells = {}
var left_limit := 232.0
var right_limit := 792
var direction := 1  
var target_y := 80.0 

func _ready():
	Global.hedgehog = self 
	
	if held_item_sprite: held_item_sprite.visible = false
	if autonomous_mode:
		position = Vector2(left_limit, target_y)
		direction = 1
		main_sprite.play("walk") 
	else:
		main_sprite.play("idle")
		

var can_build_beds: bool = false 

func _physics_process(_delta):

	if can_build_beds:

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if Input.is_action_just_pressed("draw") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				place_bed_on_grid()


		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if not was_rmb_pressed:
				remove_bed_from_grid()
				was_rmb_pressed = true
		else:
			was_rmb_pressed = false
		

	if autonomous_mode: _autonomous_move()
	else: _player_controlled_move()


var was_rmb_pressed = false 

func place_bed_on_grid():
	if not tile_map: return

	var mouse_pos = get_global_mouse_position()
	var local_pos = tile_map.to_local(mouse_pos)
	var map_coords = tile_map.local_to_map(local_pos)
	
	for i in range(bed_width_in_cells):
		if (map_coords + Vector2i(i, 0)) in occupied_cells:
			return 


	var new_bed = object_scene.instantiate()
	tile_map.add_child(new_bed)
	new_bed.position = tile_map.map_to_local(map_coords)
	
	for i in range(bed_width_in_cells):
		occupied_cells[map_coords + Vector2i(i, 0)] = new_bed
		


func remove_bed_from_grid():
	if not tile_map:
		return
	
	var mouse_pos = get_global_mouse_position()
	var local_pos = tile_map.to_local(mouse_pos)
	var map_coords = tile_map.local_to_map(local_pos)
	
	

	if map_coords in occupied_cells:
		var bed_to_remove = occupied_cells[map_coords]
		
		if is_instance_valid(bed_to_remove):
			if bed_to_remove.has_method("has_plant"):
				var busy = bed_to_remove.has_plant()
				if busy:
					return

			bed_to_remove.queue_free()
			

			var keys_to_erase = []
			for key in occupied_cells.keys():
				if occupied_cells[key] == bed_to_remove:
					keys_to_erase.append(key)
			for key in keys_to_erase:
				occupied_cells.erase(key)
		else:
			occupied_cells.erase(map_coords)


func _autonomous_move():
	velocity.x = direction * autonomous_speed
	velocity.y = 0
	move_and_slide()

	if position.x >= right_limit:
		position.x = right_limit
		direction = -1
		main_sprite.flip_h = true
	elif position.x <= left_limit:
		position.x = left_limit
		direction = 1
		main_sprite.flip_h = false
	
	main_sprite.play("walk")

func _player_controlled_move():
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		input_dir.y -= 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * player_speed
		move_and_slide()
		main_sprite.play("walk")
		
		if input_dir.x != 0:
			var is_flipped = input_dir.x < 0
			main_sprite.flip_h = is_flipped
			
			if held_item_sprite:
				held_item_sprite.flip_h = is_flipped
				var offset = abs(held_item_sprite.position.x)
				if is_flipped:
					held_item_sprite.position.x = offset 
				else:
					held_item_sprite.position.x = -offset
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		main_sprite.play("idle")

func update_held_item(item_texture: Texture2D):
	if item_texture != null:
		held_item_sprite.texture = item_texture
		held_item_sprite.visible = true
	else:
		held_item_sprite.visible = false

func pick_up_sound():
	collect_sound.play()
