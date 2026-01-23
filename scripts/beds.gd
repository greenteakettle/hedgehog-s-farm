extends Node2D

@export var plant_scene: PackedScene 

# Ссылки на узлы внутри Грядки
@onready var interaction_zone = $InteractionZone
@onready var status_label = $StatusLabel # Та самая надпись, которую мы добавили

var player_in_area = false

func _ready():
	# Настраиваем зону (проверь, чтобы InteractionZone существовала!)
	if interaction_zone:
		interaction_zone.body_entered.connect(_on_body_entered)
		interaction_zone.body_exited.connect(_on_body_exited)
	
	_update_ui()

func _process(_delta):
	# Слушаем нажатие только если игрок рядом
	if player_in_area and Input.is_action_just_pressed("interact"):
		_on_interact()

func _on_interact():
	var plant = get_node_or_null("Plant")
	
	if plant == null:
		# --- ЛОГИКА ПОСАДКИ ---
		print("Грядка пустая, пытаемся посадить...")
		var inventory = get_tree().get_first_node_in_group("inventory")
		
		if inventory:
			# 1. Берем предмет из рук (он удаляется из инвентаря!)
			var item_data = inventory.get_selected_crop_data_and_decrease()
			
			if item_data:
				# 2. ПРОВЕРКА: ЭТО СЕМЕЧКО?
				# Мы считаем предмет семечком, если:
				# А) У него есть имя анимации роста (animation_name != "")
				# Б) У него есть produce_data (то, что из него вырастет)
				if item_data.animation_name != "" and item_data.produce_data != null:
					print("[BED] Семена получены: ", item_data.crop_name)
					spawn_plant(item_data)
				else:
					# 3. ЕСЛИ ЭТО НЕ СЕМЕЧКО -> ВЕРНУТЬ ОБРАТНО
					print("[BED] Это не семечко! Возвращаем в инвентарь.")
					inventory.add_item(item_data) # <--- Важная строка!
			else:
				print("Нет предметов в руках!")
		else:
			print("Ошибка: Инвентарь не найден")
			
	else:
		# --- ЛОГИКА СБОРА ---
		if plant.has_method("is_grown") and plant.is_grown():
			plant.harvest()
			_update_ui()
		else:
			print("Еще растет...")

func spawn_plant(crop_data):
	if not plant_scene:
		print("!!! ОШИБКА: Не назначена plant_scene в Инспекторе грядки!")
		return

	var new_plant = plant_scene.instantiate()
	new_plant.name = "Plant" # Важно для поиска
	add_child(new_plant)
	
	# Инициализируем (передаем данные семечка)
	new_plant.init_crop(crop_data)
	_update_ui()

# --- УПРАВЛЕНИЕ НАДПИСЯМИ ---
func _update_ui():
	if not status_label: return
	
	# Если игрока нет рядом - прячем всё
	if not player_in_area:
		status_label.visible = false
		return

	var plant = get_node_or_null("Plant")
	
	if plant == null:
		status_label.text = "PRESS E TO PLANT"
		status_label.visible = true
	else:
		if plant.has_method("is_grown") and plant.is_grown():
			status_label.text = "PRESS E TO COLLECT"
			status_label.visible = true
		else:
			# Растет - надпись не нужна (или можно написать "Growing...")
			status_label.visible = false

# --- СИГНАЛЫ ЗОНЫ ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		_update_ui()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		_update_ui()

# --- СОХРАНЕНИЕ ---
func get_save_data():
	var data = { "has_plant": false, "plant_internal_data": {} }
	var plant = get_node_or_null("Plant")
	if plant != null:
		data["has_plant"] = true
		data["plant_internal_data"] = plant.get_save_data()
	return data

func restore_state(data):
	# 1. Сначала очищаем грядку от старых растений
	if has_node("Plant"):
		get_node("Plant").queue_free()
	
	# 2. ПРОВЕРКА ДАННЫХ (БЕЗОПАСНАЯ)
	# Если data — это null или не Словарь, выходим сразу
	if typeof(data) != TYPE_DICTIONARY:
		return

	# ИСПОЛЬЗУЕМ .get() ВМЕСТО []
	# data.get("has_plant", false) вернет false, если ключа нет. Ошибки не будет.
	if data.get("has_plant", false) == true:
		
		if plant_scene:
			var new_plant = plant_scene.instantiate()
			new_plant.name = "Plant"
			add_child(new_plant)
			
			# Также безопасно достаем внутренние данные
			var plant_data = data.get("plant_internal_data", {})
			new_plant.restore_state(plant_data)
		else:
			print("!!! ОШИБКА: plant_scene не назначена в Инспекторе грядки!")
	
	# Обновляем интерфейс (надпись)
	_update_ui()
