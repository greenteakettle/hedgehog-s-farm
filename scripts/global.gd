# global.gd
extends Node

const SAVE_PATH = "user://savegame.save"
const ITEM_SCENE_PATH = "res://scenes/harvest_item.tscn" # <--- ПРОВЕРЬТЕ ЭТОТ ПУТЬ!
var hedgehog = 0

var game_data = {
	"player_pos_x": 0,
	"player_pos_y": 0,
	"inventory": [],
	"level_items": [], # Список предметов на земле
	"beds_data": {}    # Состояние грядок
}

func save_game():
	# 1. ИГРОК
	var player = get_tree().get_first_node_in_group("player")
	if player:
		game_data["player_pos_x"] = player.global_position.x
		game_data["player_pos_y"] = player.global_position.y
	
	# 2. ИНВЕНТАРЬ
	game_data["inventory"] = []
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		for slot in inventory.slots:
			if slot.count > 0 and slot.my_crop_data != null:
				game_data["inventory"].append({
					"path": slot.my_crop_data.resource_path,
					"count": slot.count
				})

	# 3. ПРЕДМЕТЫ НА ЗЕМЛЕ (Новое!)
	game_data["level_items"] = []
	var dropped_items = get_tree().get_nodes_in_group("persisted_items")
	for item in dropped_items:
		# Сохраняем только если у предмета есть данные
		if item.crop_data != null:
			game_data["level_items"].append({
				"pos_x": item.global_position.x,
				"pos_y": item.global_position.y,
				"crop_path": item.crop_data.resource_path
			})

	# 4. ГРЯДКИ (Новое!)
	game_data["beds_data"] = {}
	var beds = get_tree().get_nodes_in_group("persisted_beds")
	for bed in beds:
		# Используем путь к узлу как уникальный ID (например NodePath("Main/Bed1"))
		var bed_path = str(bed.get_path())
		game_data["beds_data"][bed_path] = bed.get_save_data()

	# ЗАПИСЬ
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(game_data)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	game_data = file.get_var()
	
	# Перезагружаем сцену
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. ИГРОК
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(game_data["player_pos_x"], game_data["player_pos_y"])
		
	# 2. ИНВЕНТАРЬ
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		# Очистка
		for slot in inventory.slots:
			if slot.has_method("update_slot_with_data"):
				slot.update_slot_with_data(null, 0)
		# Заполнение
		for item_info in game_data["inventory"]:
			if ResourceLoader.exists(item_info["path"]):
				var data = load(item_info["path"])
				inventory.add_item_force(data, item_info["count"])
			
	# 3. ВОССТАНОВЛЕНИЕ ПРЕДМЕТОВ НА ЗЕМЛЕ
	# Сначала удаляем те, что есть сейчас (чтобы не дублировались)
	var existing_items = get_tree().get_nodes_in_group("persisted_items")
	for item in existing_items:
		item.queue_free()
	
	# Создаем сохраненные
	var item_scene = load(ITEM_SCENE_PATH)
	for item_data in game_data["level_items"]:
		if ResourceLoader.exists(item_data["crop_path"]):
			var new_item = item_scene.instantiate()
			new_item.position = Vector2(item_data["pos_x"], item_data["pos_y"])
			new_item.crop_data = load(item_data["crop_path"])
			# Важно: отключаем анимацию подпрыгивания при загрузке, 
			# но для простоты можно оставить как есть
			get_tree().current_scene.add_child(new_item)

	# 4. ВОССТАНОВЛЕНИЕ ГРЯДОК
	for bed_path_str in game_data["beds_data"]:
		# Пытаемся найти грядку по её старому адресу
		if get_tree().root.has_node(bed_path_str):
			var bed_node = get_tree().root.get_node(bed_path_str)
			var saved_state = game_data["beds_data"][bed_path_str]
			# Вызываем нашу новую функцию в plant.gd
			bed_node.restore_state(saved_state)

	print("Все загружено!")
