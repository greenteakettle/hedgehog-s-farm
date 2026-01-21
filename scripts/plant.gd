extends Node2D

@export var harvest_scene: PackedScene
@export var growth_time: float = 3
@export var growth_frames: int = 3

var current_crop_data: CropData = null 

var stage: int = 0
var player_in_area: bool = false
var timer: Timer

@onready var crop_sprite = $CropSprite
@onready var e_label = $E_Indicator
@onready var interaction_zone = $InteractionZone
@onready var harvest_spawn_point = $HarvestSpawnPoint
@onready var appear_sound = $AppearSound

# Функция для восстановления состояния при загрузке
func restore_state(data):
	# 1. Восстанавливаем стадию
	stage = data["stage"]
	
	# 2. Восстанавливаем растение
	if data["crop_path"] != "":
		current_crop_data = load(data["crop_path"])
		crop_sprite.visible = true
		crop_sprite.play(current_crop_data.animation_name)
		crop_sprite.frame = stage
	else:
		current_crop_data = null
		crop_sprite.visible = false
		_show_indicators() # Показать "PRESS E TO PLANT"

	# 3. Восстанавливаем таймер
	if data["time_left"] > 0 and stage < growth_frames:
		timer.start(data["time_left"])
		print("Таймер грядки перезапущен: ", data["time_left"])
	else:
		timer.stop()

func _ready():

	_hide_all()
	crop_sprite.visible = false 
	timer = Timer.new()
	timer.wait_time = growth_time
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_grow"))
	add_child(timer)

	interaction_zone.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_zone.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		_on_interact()

func _on_body_entered(body):
	if body.name == "Hedgehog" or body.is_in_group("player"):
		player_in_area = true
		_show_indicators()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		_hide_all()

func _on_interact():
	if stage == 0 and player_in_area:
		var inventory = get_tree().get_first_node_in_group("inventory")
		
		if inventory:
			var item_data = inventory.get_selected_crop_data_and_decrease()
			if item_data != null:
				if item_data.animation_name != "":
					current_crop_data = item_data
					stage = 0
					
					_hide_all()
					crop_sprite.visible = true
					
					crop_sprite.play(current_crop_data.animation_name)
					growth_frames = crop_sprite.sprite_frames.get_frame_count(current_crop_data.animation_name) - 1
					crop_sprite.frame = 0 
					crop_sprite.pause()   
					
					timer.start()
					print("Посажено: ", item_data.crop_name)
					
				else:

					inventory.add_item(item_data)
			else:
				print("В руках пусто!")

	elif stage >= growth_frames and player_in_area:
		_spawn_harvest()
		
		stage = 0
		current_crop_data = null
		crop_sprite.visible = false
		timer.stop()
		
		_show_indicators() 

func _on_grow():
	if stage < growth_frames:
		stage += 1
		crop_sprite.frame = stage
		
		if stage == growth_frames:
			timer.stop()
		
		if player_in_area:
				_show_indicators()

func _spawn_harvest():
	if not harvest_scene:
		return
	
	# 1. Спавним ВОЗВРАТ СЕМЯН (то, что мы сажали)
	spawn_item(current_crop_data, Vector2(-10, -10)) 
	
	# 2. Спавним УРОЖАЙ (если он указан в паспорте)
	if current_crop_data.produce_data != null:
		spawn_item(current_crop_data.produce_data, Vector2(10, -10))
		appear_sound.play() 

# Вспомогательная функция, чтобы не дублировать код спавна
func spawn_item(data: CropData, offset: Vector2):
	var drop = harvest_scene.instantiate()
	
	drop.global_position = harvest_spawn_point.global_position + offset
	drop.crop_data = data
	
	get_tree().current_scene.add_child(drop)

func _hide_all():
	if e_label:
		e_label.visible = false

func _show_indicators():
	
	if not player_in_area:
		if e_label: e_label.visible = false
		return

	if not e_label: return
	
	# 1. Если грядка пустая - зовем сажать
	if stage == 0:
		e_label.text = "PRESS E TO PLANT"
		e_label.visible = true
		
	# 2. Если урожай созрел - зовем собирать
	elif stage >= growth_frames:
		e_label.text = "PRESS E TO COLLECT"
		e_label.visible = true
		
	# 3. Если еще растет - прячем надпись 
	else:
		e_label.visible = false
# Функция для получения словаря с данными для сохранения

func get_save_data():
	var save_dict = {
		"stage": stage,
		"time_left": timer.time_left, # Сколько секунд осталось расти
		"crop_path": "" # Путь к файлу ресурса растения
	}
	# Если что-то растет, сохраняем путь к ресурсу
	if current_crop_data != null:
		save_dict["crop_path"] = current_crop_data.resource_path
		
	return save_dict

func is_growing() -> bool:
	# Если current_crop_data не равно null, значит что-то посажено
	if current_crop_data != null:
		return true
	return false
