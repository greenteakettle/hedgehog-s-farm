extends StaticBody2D

@export var apple_scene: PackedScene
@export var max_apples: int = 2      # СТРОГИЙ ЛИМИТ: Максимум 2 яблока
@export var growth_time: float = 5.0 # Как часто дерево пытается родить яблоко

var spawned_apples = [] 
@onready var spawn_points = [$Point1, $Point2, $Point3]
@onready var timer = $GrowthTimer

func _ready():
	timer.wait_time = growth_time
	timer.start()

func _on_growth_timer_timeout():
	# 1. Убираем из списка те, что уже собрали
	clean_up_list()
	
	# 2. Главная проверка: если яблок уже 2 или больше - ничего не делаем
	if spawned_apples.size() >= max_apples:
		return 
		
	# 3. Если места есть - рожаем ТОЛЬКО ОДНО яблоко за раз
	spawn_one_apple()

func spawn_one_apple():
	if not apple_scene: return
	
	# Выбираем случайную точку из трех, чтобы было разнообразие
	var random_point = spawn_points.pick_random()
	
	var new_apple = apple_scene.instantiate()
	get_parent().add_child(new_apple)
	
	# Ставим на ветку
	new_apple.global_position = random_point.global_position
	
	# Настраиваем куда падать (чуть-чуть разброса, чтобы не в одну точку)
	var random_x = randf_range(-10, 10) 
	var random_y = randf_range(15, 35) 
	var ground_pos = random_point.global_position + Vector2(random_x, random_y)
	
	# Передаем координаты яблоку
	new_apple.target_pos_on_ground = ground_pos
	
	# Добавляем в список
	spawned_apples.append(new_apple)

func clean_up_list():
	spawned_apples = spawned_apples.filter(func(a): return is_instance_valid(a))
