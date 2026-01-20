extends Node2D

# Настройка цены в Инспекторе
@export var requirements = {
	"Wheat Item": 1,
	"Eggplant Item": 1
}

var paid_items = {} # Счетчик оплаты

# Ссылки на детей (Убедись, что имена в дереве совпадают!)
@onready var label = $BuyingZone/Label
@onready var buying_area = $BuyingZone # Твоя Area2D
# ВАЖНО: Нам нужна именно CollisionShape2D внутри StaticBody2D
@onready var wall_collision = $StaticBody2D/CollisionShape2D 
@onready var sprite = $Sprite2D

func _ready():
	# Инициализация
	for item in requirements:
		paid_items[item] = 0
	
	update_label()
	
	# Подключаем сигнал входа в зону покупки
	# (Если ты переименовала Area2D по-другому, поправь $BuyingZone на свое имя)
	buying_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что зашел игрок
	if body.name == "Hedgehog" or body.is_in_group("player"):
		check_and_pay()

func check_and_pay():
	# Ищем инвентарь
	var inventory = get_tree().get_first_node_in_group("inventory")
	if not inventory:
		print("Ошибка: Инвентарь не найден (нет группы inventory)")
		return
	
	var is_fully_open = true
	var something_changed = false
	
	for item_name in requirements:
		var needed = requirements[item_name]
		var paid = paid_items[item_name]
		var left_to_pay = needed - paid
		
		if left_to_pay > 0:
			# 1. Сколько есть у игрока?
			var count_in_bag = inventory.get_item_count(item_name)
			
			if count_in_bag > 0:
				# 2. Забираем сколько нужно или сколько есть
				var take = min(left_to_pay, count_in_bag)
				inventory.remove_item_by_name(item_name, take)
				
				# 3. Обновляем прогресс
				paid_items[item_name] += take
				something_changed = true
				print("Туман забрал: ", item_name, " ", take, " шт.")
			
			# Если все еще должны - ворота не открываем
			if paid_items[item_name] < needed:
				is_fully_open = false
	
	if something_changed:
		update_label()
		
	if is_fully_open:
		open_gate()

func update_label():
	var text = "NEED:\n"
	for item in requirements:
		var needed = requirements[item]
		var paid = paid_items[item]
		var left = needed - paid
		
		if left > 0:
			text += item + ": " + str(paid) + "/" + str(needed) + "\n"
	
	if text == "NEED:\n":
		text = "OPEN!"
		
	label.text = text

func open_gate():
	# 1. Прячем текст
	label.visible = false
	
	# 2. Отключаем физическую стену (обязательно через set_deferred!)
	wall_collision.set_deferred("disabled", true)
	
	# 3. Анимация исчезновения тумана
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5) # Прозрачность в 0
	
	# 4. Удаляем объект после анимации
	tween.tween_callback(queue_free)
