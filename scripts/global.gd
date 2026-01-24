extends Node

const SAVE_PATH = "user://savegame.save"
const ITEM_SCENE_PATH = "res://scenes/harvest_item.tscn"
const BED_SCENE_PATH = "res://scenes/beds.tscn"

var seen_triggers: Array = []
var hedgehog = null

var game_data = {
	"player_pos_x": 0,
	"player_pos_y": 0,
	"can_build_beds": false,
	"inventory": [],
	"level_items": [], 
	"world_states": {}, 
	"beds_data": []
}

func save_game():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		game_data["player_pos_x"] = player.global_position.x
		game_data["player_pos_y"] = player.global_position.y
		if "can_build_beds" in player:
			game_data["can_build_beds"] = player.can_build_beds
	
	game_data["seen_triggers"] = seen_triggers
	
	game_data["inventory"] = []
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		for slot in inventory.slots:
			if slot.count > 0 and slot.my_crop_data != null:
				game_data["inventory"].append({
					"path": slot.my_crop_data.resource_path,
					"count": slot.count
				})

	game_data["level_items"] = []
	game_data["world_states"] = {} 
	
	var persisted_nodes = get_tree().get_nodes_in_group("persisted_items")
	for node in persisted_nodes:

		if node.has_method("get_save_data"):
			game_data["world_states"][node.name] = node.get_save_data()
			
		elif "crop_data" in node and node.crop_data != null:
			game_data["level_items"].append({
				"pos_x": node.global_position.x,
				"pos_y": node.global_position.y,
				"crop_path": node.crop_data.resource_path
			})


	game_data["beds_data"] = []
	var beds = get_tree().get_nodes_in_group("persisted_beds")
	for bed in beds:
		game_data["beds_data"].append({
			"pos_x": bed.position.x,
			"pos_y": bed.position.y,
			"saved_state": bed.get_save_data()
		})

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(game_data)
	print("Game is saved!")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	clear_ui()

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	game_data = file.get_var()
	

	get_tree().change_scene_to_file("res://scenes/main.tscn")

	await get_tree().process_frame
	await get_tree().process_frame
	
	seen_triggers = game_data.get("seen_triggers", [])
	

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(game_data["player_pos_x"], game_data["player_pos_y"])
		if "can_build_beds" in player:
			player.can_build_beds = game_data.get("can_build_beds", false)
		

	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		for slot in inventory.slots:
			if slot.has_method("update_slot_with_data"):
				slot.update_slot_with_data(null, 0)
		for item_info in game_data["inventory"]:
			if ResourceLoader.exists(item_info["path"]):
				var data = load(item_info["path"])
				inventory.add_item_force(data, item_info["count"])
			

	var existing_items = get_tree().get_nodes_in_group("persisted_items")
	for item in existing_items:

		if "crop_data" in item:
			item.queue_free()
	

	var item_scene = load(ITEM_SCENE_PATH)
	for item_data in game_data["level_items"]:
		if ResourceLoader.exists(item_data["crop_path"]):
			var new_item = item_scene.instantiate()
			new_item.position = Vector2(item_data["pos_x"], item_data["pos_y"])
			new_item.crop_data = load(item_data["crop_path"])
			get_tree().current_scene.add_child(new_item)


	var world_states = game_data.get("world_states", {})
	for node_name in world_states:

		var node = get_tree().current_scene.find_child(node_name, true, false)
		if node and node.has_method("restore_state"):
			node.restore_state(world_states[node_name])


	var existing_beds = get_tree().get_nodes_in_group("persisted_beds")
	for bed in existing_beds: bed.queue_free()

	var parent_node = get_tree().current_scene
	var tile_map = get_tree().get_first_node_in_group("farm_tilemap")
	if tile_map:
		parent_node = tile_map

	var bed_scene_res = load(BED_SCENE_PATH)
	for bed_info in game_data["beds_data"]:
		var new_bed = bed_scene_res.instantiate()
		new_bed.position = Vector2(bed_info["pos_x"], bed_info["pos_y"])
		parent_node.add_child(new_bed)
		if new_bed.has_method("restore_state"):
			new_bed.restore_state(bed_info["saved_state"])

	
func clear_ui():
		get_tree().call_group("notifications", "queue_free") 
