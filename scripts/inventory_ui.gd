extends Control

@onready var slots = $Slots.get_children()

var selected_slot_index: int = 0

func _ready():
	for i in $Slots.get_children():
		# Используем безопасный вызов, если метод существует
		if i.has_method("update_slot_with_data"):
			i.update_slot_with_data(null, 0)
	
	update_selection_visuals()
	
	# Ждем кадр, чтобы ежик успел загрузиться, и обновляем его вид
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
	
	# Если слот изменился, обновляем рамку и ежика
	if changed:
		update_selection_visuals()
		update_player_visuals()


func update_selection_visuals():
	for i in range(slots.size()):
		if slots[i].has_method("set_selected"):
			slots[i].set_selected(i == selected_slot_index)


func add_item(data: CropData):
	# 1. Ищем слот с таким же предметом
	for slot in slots:
		if slot.my_crop_data == data and slot.count < 5:
			slot.update_slot_with_data(data, slot.count + 1)
			update_player_visuals() # Обновляем вид, если добавили в текущий слот
			return

	# 2. Ищем пустой слот
	for slot in slots:
		if slot.my_crop_data == null:
			slot.update_slot_with_data(data, 1)
			update_player_visuals() # Обновляем вид
			return
			
	print("Инвентарь полон!")

func get_selected_crop_data_and_decrease() -> CropData:
	var current_slot = slots[selected_slot_index]
	
	if current_slot.count > 0 and current_slot.my_crop_data != null:
		var data_to_return = current_slot.my_crop_data
		
		current_slot.count -= 1
		
		if current_slot.count == 0:
			current_slot.update_slot_with_data(null, 0)
		else:
			current_slot.update_slot_with_data(current_slot.my_crop_data, current_slot.count)
		
		# Обновляем ежика (вдруг предмет кончился)
		update_player_visuals()
			
		return data_to_return
		
	return null

# Исправленная функция без лишних отступов и символов
func update_player_visuals():
	var player = get_tree().get_first_node_in_group("player")
	
	# Проверяем, существует ли игрок и скрипт на нем
	if not player or not player.has_method("update_held_item"):
		return

	var current_slot = slots[selected_slot_index]
	
	# Если в слоте есть предмет
	if current_slot.count > 0 and current_slot.my_crop_data != null:
		# Отправляем Ёжику иконку этого предмета
		player.update_held_item(current_slot.my_crop_data.inventory_icon)
	else:
		# Слот пуст - говорим Ёжику спрятать предмет
		player.update_held_item(null)
	
func add_item_force(data: CropData, amount: int):
	# Ищем пустой слот
	for slot in slots:
		if slot.my_crop_data == null:
			slot.update_slot_with_data(data, amount)
			return
