extends Control

@onready var slots = $Slots.get_children()

var selected_slot_index: int = 0

func _ready():
	for i in $Slots.get_children():
		if i.has_method("update_slot_with_data"):
			i.update_slot_with_data(null, 0)
	
	update_selection_visuals()

	await get_tree().process_frame
	update_player_visuals()

func _input(event):
	var changed = false
	if event.is_action_pressed("slot_1"):
		selected_slot_index = 0
		changed = true
	elif event.is_action_pressed("slot_2"):
		selected_slot_index = 1
		changed = true
	elif event.is_action_pressed("slot_3"):
		selected_slot_index = 2
		changed = true
	elif event.is_action_pressed("slot_4"):
		selected_slot_index = 3
		changed = true
	elif event.is_action_pressed("slot_5"):
		selected_slot_index = 4
		changed = true
	
	if event.is_action_pressed("drop_item"): 
		drop_selected_item()	
	
	if changed:
		update_selection_visuals()
		update_player_visuals()


func update_selection_visuals():
	for i in range(slots.size()):
		if slots[i].has_method("set_selected"):
			slots[i].set_selected(i == selected_slot_index)


func add_item(data: CropData) -> bool:

	for slot in slots:

		if slot.my_crop_data == data and slot.count < 5:
			slot.update_slot_with_data(data, slot.count + 1)
			update_player_visuals()
			return true 
			

	for slot in slots:
		if slot.my_crop_data == null:
			slot.update_slot_with_data(data, 1)
			update_player_visuals()
			return true 
			

	print("Инвентарь полон!")
	return false 

func get_selected_crop_data_and_decrease() -> CropData:
	var current_slot = slots[selected_slot_index]
	
	if current_slot.count > 0 and current_slot.my_crop_data != null:
		var data_to_return = current_slot.my_crop_data
		
		current_slot.count -= 1
		
		if current_slot.count == 0:
			current_slot.update_slot_with_data(null, 0)
		else:
			current_slot.update_slot_with_data(current_slot.my_crop_data, current_slot.count)
		
		update_player_visuals()
			
		return data_to_return
		
	return null


func update_player_visuals():
	var player = get_tree().get_first_node_in_group("player")
	
	if not player or not player.has_method("update_held_item"):
		return

	var current_slot = slots[selected_slot_index]
	

	if current_slot.count > 0 and current_slot.my_crop_data != null:
		player.update_held_item(current_slot.my_crop_data.inventory_icon)
	else:
		player.update_held_item(null)
	
func add_item_force(data: CropData, amount: int):

	for slot in slots:
		if slot.my_crop_data == null:
			slot.update_slot_with_data(data, amount)
			return


func get_item_count(target_name: String) -> int:
	var total = 0
	for slot in slots:
		if slot.my_crop_data != null:

			if slot.my_crop_data.crop_name == target_name:
				total += slot.count
	return total


func remove_item_by_name(target_name: String, amount_needed: int):
	var left_to_remove = amount_needed
	
	for slot in slots:
		if slot.my_crop_data != null and slot.my_crop_data.crop_name == target_name:
			
			if slot.count > left_to_remove:
				var new_count = slot.count - left_to_remove
				slot.update_slot_with_data(slot.my_crop_data, new_count)
				left_to_remove = 0
				break 
				
			else:

				left_to_remove -= slot.count
				slot.update_slot_with_data(null, 0) 
				
			if left_to_remove <= 0:
				break

	update_player_visuals()
	
func drop_selected_item():
	var current_slot = slots[selected_slot_index]

	if current_slot.my_crop_data != null and current_slot.count > 0:
		var data_to_drop = current_slot.my_crop_data
		
		var new_count = current_slot.count - 1
		if new_count <= 0:
			current_slot.update_slot_with_data(null, 0)
		else:
			current_slot.update_slot_with_data(data_to_drop, new_count)
		
		update_player_visuals()
		spawn_drop_in_world(data_to_drop)


func spawn_drop_in_world(data: CropData):
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var drop_scene = load("res://scenes/harvest_item.tscn") 
	var drop_instance = drop_scene.instantiate()
	drop_instance.crop_data = data

	var drop_offset = Vector2(0, 15) 
	var target_pos = player.global_position + drop_offset

	var y_sort = get_tree().current_scene.get_node_or_null("YSortLayer")
	
	if y_sort:
		y_sort.add_child(drop_instance)
	else:
		get_tree().current_scene.add_child(drop_instance)
	
	drop_instance.global_position = target_pos
	drop_instance.z_index = 5
