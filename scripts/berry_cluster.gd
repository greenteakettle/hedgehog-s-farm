extends Area2D

# --- НАСТРОЙКИ ---
@export var item_data: Resource     # Сюда berry_data.tres
@export var growth_time: float = 5.0

@onready var appear_sound = $AppearSound

# --- СОСТОЯНИЕ ---
var is_grown: bool = false          # Выросли?
var can_be_picked: bool = false     # Можно подбирать? (Только когда упала)
var player_in_zone: bool = false    # Игрок рядом?

# Эта переменная нужна Кусту, чтобы показывать надпись
var is_ready_to_harvest: bool = false 

@onready var sprite = $AnimatedSprite2D
@onready var timer = $GrowthTimer

func _ready():
	sprite.frame = 0       # Начинаем с маленьких
	timer.wait_time = growth_time
	timer.start()

func _process(_delta):
	# 1. ЛОГИКА СРЫВАНИЯ (на ветке)
	if Input.is_action_just_pressed("interact"):
		# Если ягода выросла, еж рядом И она еще не упала
		if player_in_zone and is_grown and not can_be_picked:
			start_falling()

	# 2. ЛОГИКА ПОДБОРА (на земле) - Исправление бага!
	# Если ягода уже лежит (can_be_picked), и мы стоим на ней (player_in_zone)
	# Мы забираем её, даже если сигнал body_entered не сработал.
	if can_be_picked and player_in_zone:
		collect()

func _on_growth_timer_timeout():
	is_grown = true
	is_ready_to_harvest = true 
	sprite.frame = 1           

func start_falling():
	is_ready_to_harvest = false # Прячем надпись "PRESS E"
	
	appear_sound.play()
	# --- РАСЧЕТ ПАДЕНИЯ ---
	var random_offset = Vector2(randf_range(-10, 10), randf_range(20, 35))
	var target_pos = global_position + random_offset
	
	# --- АНИМАЦИЯ ---
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# ВАЖНО: Ждем, пока упадет!
	await tween.finished
	
	# Теперь разрешаем подбор
	can_be_picked = true

# Функция сбора в инвентарь (вынесена отдельно)
func collect():
	var inventory = get_tree().get_first_node_in_group("inventory")
	
	if inventory and item_data:
		print("Подобрали ягоду: ", item_data.crop_name)
		inventory.add_item(item_data)
		
		# --- НОВОЕ: ИЩЕМ ЕЖА И ВКЛЮЧАЕМ ЗВУК ---
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("pick_up_sound"):
			player.pick_up_sound()
		# ---------------------------------------
		
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true
		
		# Если мы набежали на уже лежащую ягоду
		if can_be_picked:
			collect()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
