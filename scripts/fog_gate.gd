extends Node2D

# Настройка цены в Инспекторе
@export var requirements = {
	"Wheat Item": 3,
	"Eggplant Item": 3,
	"Apple": 3,
	"Berry": 3,
}

var item_textures = {
	"Wheat Item": preload("res://textures/wheat_item.tres"), # <-- ПОМЕНЯЙ ПУТИ НА СВОИ!
	"Eggplant Item": preload("res://textures/eggplant_item.tres"),
	"Apple": preload("res://textures/apple.tres"),
	"Berry": preload("res://textures/berry.tres")
}

var paid_items = {} # Счетчик оплаты
var is_open: bool = false # Запоминаем состояние

@onready var open_sound = $OpenSound

# Ссылки на детей (Убедись, что имена в дереве совпадают!)
@onready var items_list = $BuyingZone/ItemsList
@onready var buying_area = $BuyingZone # Твоя Area2D
# ВАЖНО: Нам нужна именно CollisionShape2D внутри StaticBody2D
@onready var wall_collision = $StaticBody2D/CollisionShape2D 
@onready var sprite = $Sprite2D


func _ready():
	add_to_group("persisted_items")
	# Инициализация
	for item in requirements:
		paid_items[item] = 0
	update_visuals()
	
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
		update_visuals()
		
	if is_fully_open:
		open_gate()

func update_visuals():
	# 1. Удаляем всё старое, что было в списке
	for child in items_list.get_children():
		child.queue_free()
	
	# 2. Создаем новые строчки
	for item_name in requirements:
		var needed = requirements[item_name]
		var paid = paid_items[item_name]
		var left = needed - paid
		
		# Показываем только то, что еще нужно оплатить
		if left > 0:
			create_row(item_name, paid, needed)

func create_row(item_name, paid, needed):
	# Создаем горизонтальный контейнер (строчку)
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER # По центру
	
	# 1. КАРТИНКА
	var icon = TextureRect.new()
	# Берем картинку из нашего словаря. Если нет - будет пусто.
	if item_textures.has(item_name):
		icon.texture = item_textures[item_name]
	
	# Настраиваем размер картинки (чтобы не была огромной)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(20, 20) # <-- РАЗМЕР ИКОНКИ (поменяй если надо)
	
	# 2. ТЕКСТ (ЦИФРЫ)
	var label = Label.new()
	label.text = str(paid) + "/" + str(needed)
	
	# Добавляем всё в строчку, а строчку в общий список
	row.add_child(icon)
	row.add_child(label)
	items_list.add_child(row)

func open_gate():
	is_open = true # 1. Запоминаем, что открыто
	
	# 2. Прячем текст интерфейса
	if items_list: items_list.visible = false # Если ты уже добавила список картинок
	
	# 3. Отключаем стену
	wall_collision.set_deferred("disabled", true)
	
	open_sound.play()
	
	# 4. Анимация исчезновения
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
	
	# 5. ВАЖНО: УБИРАЕМ queue_free()!
	# Вместо удаления, просто делаем объект невидимым в конце анимации (на всякий случай)
	tween.tween_callback(func(): visible = false)

func get_save_data():
	return {
		"is_open": is_open
	}

func restore_state(data):
	is_open = data.get("is_open", false)
	
	if is_open:
		# Если при загрузке ворота должны быть открыты:
		
		# 1. Мгновенно убираем стену
		wall_collision.set_deferred("disabled", true)
		
		# 2. Мгновенно делаем прозрачным/невидимым (без анимации и звука!)
		sprite.modulate.a = 0.0
		visible = false
		
		if items_list: items_list.visible = false 
		
	else:
		# Если закрыто - убеждаемся, что все видно (на всякий случай)
		sprite.modulate.a = 1.0
		visible = true
		wall_collision.set_deferred("disabled", false)
		# update_visuals() # Раскомментируй, если используешь картинки
