extends StaticBody2D

@export var apple_scene: PackedScene
@export var max_apples: int = 2       # СТРОГИЙ ЛИМИТ: Максимум 2 яблока
@export var growth_time: float = 10   # Как часто дерево пытается родить яблоко

var spawned_apples = [] 
var is_active = false # Флаг: активно дерево или спит?

@onready var spawn_points = [$Point1, $Point2, $Point3]
@onready var timer = $GrowthTimer

func _ready():
	timer.wait_time = growth_time
	# МЫ УБРАЛИ timer.start() ОТСЮДА!
	# Дерево рождается выключенным.

# Эту функцию позовет Зона (Area2D) через call_group
func start_growing_cycle():
	# Если уже активно - выходим, чтобы не сбросить таймер
	if is_active: 
		return 
	
	is_active = true
	timer.start()
	print("Дерево активировано и начало растить яблоки!")

func _on_growth_timer_timeout():
	# 1. Убираем из списка те, что уже собрали
	clean_up_list()
	
	# 2. Главная проверка
	if spawned_apples.size() >= max_apples:
		return 
		
	# 3. Если места есть - рожаем
	spawn_one_apple()

func spawn_one_apple():
	if not apple_scene: return
	
	var random_point = spawn_points.pick_random()
	var new_apple = apple_scene.instantiate()
	
	# Важно: добавляем в Main (или родителя), а не в само дерево
	get_parent().add_child(new_apple)
	
	new_apple.global_position = random_point.global_position
	
	var random_x = randf_range(-10, 10) 
	var random_y = randf_range(15, 35) 
	var ground_pos = random_point.global_position + Vector2(random_x, random_y)
	
	# Если у яблока есть скрипт падения, передаем цель
	if "target_pos_on_ground" in new_apple:
		new_apple.target_pos_on_ground = ground_pos
	
	spawned_apples.append(new_apple)

func clean_up_list():
	spawned_apples = spawned_apples.filter(func(a): return is_instance_valid(a)) 
