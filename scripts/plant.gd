extends Node2D

@export var harvest_scene: PackedScene 
@export var growth_time: float = 3.0

var current_crop_data = null
var stage: int = 0
var growth_frames: int = 3
var timer: Timer

@onready var crop_sprite = $CropSprite
@onready var harvest_spawn_point = $HarvestSpawnPoint 
@onready var appear_sound = $AppearSound

func _ready():
	crop_sprite.visible = false
	timer = Timer.new()
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_grow)

func init_crop(seed_data):
	current_crop_data = seed_data
	stage = 0
	_update_visuals()
	timer.start(growth_time)

func _on_grow():
	if stage < growth_frames:
		stage += 1
		crop_sprite.frame = stage
		if stage >= growth_frames:
			timer.stop()
			if get_parent().has_method("_update_ui"):
				get_parent()._update_ui()


func harvest():

	if not visible: 
		return

	if not harvest_scene or not current_crop_data: 
		queue_free()
		return
	
	if appear_sound:
		appear_sound.play()
	
	if current_crop_data.produce_data:
		_spawn_drop(current_crop_data.produce_data, Vector2(15, -20))
	
	_spawn_drop(current_crop_data, Vector2(-15, -20))

	visible = false 
	
	if appear_sound:
		await appear_sound.finished
	
	queue_free()


func _spawn_drop(item_data, offset: Vector2):
	var drop = harvest_scene.instantiate()
	
	var spawn_pos = global_position
	if harvest_spawn_point:
		spawn_pos = harvest_spawn_point.global_position
	
	drop.global_position = spawn_pos + offset
	drop.crop_data = item_data
	
	get_tree().current_scene.add_child(drop)
	

func is_grown() -> bool:
	return stage >= growth_frames

func _update_visuals():
	if current_crop_data:
		crop_sprite.visible = true
		crop_sprite.play(current_crop_data.animation_name)
		growth_frames = crop_sprite.sprite_frames.get_frame_count(current_crop_data.animation_name) - 1
		crop_sprite.frame = stage
		crop_sprite.pause()


func get_save_data():
	return {
		"stage": stage,
		"time_left": timer.time_left,
		"crop_path": current_crop_data.resource_path if current_crop_data else ""
	}


func restore_state(data):
	stage = int(data.get("stage", 0))
	var path = data.get("crop_path", "")
	if path != "":
		current_crop_data = load(path)
		_update_visuals()
		
		var t_left = data.get("time_left", 0.0)
		if t_left > 0 and stage < growth_frames:
			timer.start(t_left)
		else:
			timer.stop()
