extends Node

const SAVE_PATH = "user://savegame.save"
const ITEM_SCENE_PATH = "res://scenes/harvest_item.tscn"
# 1. ДОБАВЬ ПУТЬ К СЦЕНЕ ГРЯДКИ (проверь, как она у тебя называется!)
const BED_SCENE_PATH = "res://scenes/beds.tscn" 

var seen_triggers: Array = []
var hedgehog = null

var game_data = {
	"player_pos_x": 0,
	"player_pos_y": 0,
	"can_build_beds": false, # 2. СОХРАНЯЕМ НАВЫК СТРОИТЕЛЬСТВА
	"inventory": [],
	"level_items": [],
	"beds_data": [] # 3. ТЕПЕРЬ ЭТО СПИСОК (Array), А НЕ СЛОВАРЬ
}

func save_game():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		game_data["player_pos_x"] = player.global_position.x
		game_data["player_pos_y"] = player.global_position.y
		
		# Сохраняем навык
		if "can_build_beds" in player:
			game_data["can_build_beds"] = player.can_build_beds
	
	game_data["seen_triggers"] = seen_triggers
	# ИНВЕНТАРЬ (без изменений)
	game_data["inventory"] = []
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		for slot in inventory.slots:
			if slot.count > 0 and slot.my_crop_data != null:
				game_data["inventory"].append({
					"path": slot.my_crop_data.resource_path,
					"count": slot.count
				})

	# ПРЕДМЕТЫ НА ЗЕМЛЕ (без изменений)
	game_data["level_items"] = []
	var dropped_items = get_tree().get_nodes_in_group("persisted_items")
	for item in dropped_items:
		if item.crop_data != null:
			game_data["level_items"].append({
				"pos_x": item.global_position.x,
				"pos_y": item.global_position.y,
				"crop_path": item.crop_data.resource_path
			})

	# 4. ИСПРАВЛЕННОЕ СОХРАНЕНИЕ ГРЯДОК
	# Мы сохраняем не путь к узлу, а его позицию и данные растения
	game_data["beds_data"] = []
	var beds = get_tree().get_nodes_in_group("persisted_beds")
	for bed in beds:
		# Сохраняем позицию и состояние (растение, таймер)
		game_data["beds_data"].append({
			"pos_x": bed.position.x,
			"pos_y": bed.position.y,
			"saved_state": bed.get_save_data() # Твоя функция внутри грядки
		})

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(game_data)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	game_data = file.get_var()
	
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	
	seen_triggers = game_data.get("seen_triggers", [])
	
	# 1. ВОССТАНАВЛИВАЕМ ИГРОКА И НАВЫКИ
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(game_data["player_pos_x"], game_data["player_pos_y"])
		# Восстанавливаем возможность строить
		if "can_build_beds" in player:
			player.can_build_beds = game_data.get("can_build_beds", false)
		
	# 2. ИНВЕНТАРЬ (без изменений)
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		for slot in inventory.slots:
			if slot.has_method("update_slot_with_data"):
				slot.update_slot_with_data(null, 0)
		for item_info in game_data["inventory"]:
			if ResourceLoader.exists(item_info["path"]):
				var data = load(item_info["path"])
				inventory.add_item_force(data, item_info["count"])
			
	# 3. ПРЕДМЕТЫ НА ЗЕМЛЕ (без изменений)
	var existing_items = get_tree().get_nodes_in_group("persisted_items")
	for item in existing_items: item.queue_free()
	
	var item_scene = load(ITEM_SCENE_PATH)
	for item_data in game_data["level_items"]:
		if ResourceLoader.exists(item_data["crop_path"]):
			var new_item = item_scene.instantiate()
			new_item.position = Vector2(item_data["pos_x"], item_data["pos_y"])
			new_item.crop_data = load(item_data["crop_path"])
			get_tree().current_scene.add_child(new_item)

	# 4. ИСПРАВЛЕННАЯ ЗАГРУЗКА ГРЯДОК
	# Сначала удаляем старые (если они вдруг есть на сцене по умолчанию), 
	# чтобы не наслоились, если ты используешь одни и те же.
	# Если у тебя на карте НЕТ грядок по умолчанию, этот цикл удаления можно пропустить.
	var existing_beds = get_tree().get_nodes_in_group("persisted_beds")
	for bed in existing_beds: bed.queue_free()

	# Ищем TileMap, чтобы положить грядки внутрь него (для правильных координат)
	# Предполагаем, что TileMap есть в группе "ground_layer" или ищем по имени
	# Если не найдем, добавим просто на сцену
	var parent_node = get_tree().current_scene
	var tile_map = get_tree().get_first_node_in_group("farm_tilemap") # <--- ЖЕЛАТЕЛЬНО ДОБАВИТЬ TILEMAP В ЭТУ ГРУППУ
	if tile_map:
		parent_node = tile_map

	var bed_scene_res = load(BED_SCENE_PATH)
	
	for bed_info in game_data["beds_data"]:
		var new_bed = bed_scene_res.instantiate()
		new_bed.position = Vector2(bed_info["pos_x"], bed_info["pos_y"])
		
		# Добавляем на сцену
		parent_node.add_child(new_bed)
		
		# Восстанавливаем рост растения
		if new_bed.has_method("restore_state"):
			new_bed.restore_state(bed_info["saved_state"])
			
		# ВАЖНО: Если ты используешь occupied_cells в скрипте ежа, 
		# их тоже надо бы обновить, но это сложнее. 
		# Пока что просто восстановим грядки визуально и функционально.

	print("Все загружено!")
