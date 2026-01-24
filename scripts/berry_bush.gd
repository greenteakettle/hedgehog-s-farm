extends Node2D

@export var cluster_scene: PackedScene 
@export var respawn_time: float = 5.0

@onready var spawn_points = [$Point1, $Point2, $Point3]
@onready var timer = $RespawnTimer
@onready var label = $E_Indicator 

var active_clusters = []
var player_is_near: bool = false 
var is_active: bool = false # <--- 1. Куст изначально спит

func _ready():
	timer.wait_time = respawn_time
	timer.one_shot = true
	if not timer.timeout.is_connected(_on_respawn_timer_timeout):
		timer.timeout.connect(_on_respawn_timer_timeout)
	
	label.visible = false 
	# spawn_all_clusters() <--- 2. УБРАЛИ ЭТО! Куст рождается пустым.

# --- ЭТУ ФУНКЦИЮ ВЫЗОВЕТ ТРИГГЕР ---
func start_growing_cycle():
	if is_active: return
	
	is_active = true
	call_deferred("spawn_all_clusters")
	print("Куст активирован!")

func _process(_delta):
	# Если куст "спит", мы ничего не делаем и не показываем
	if not is_active:
		return

	clean_up_list()
	
	# 3. Логика респавна
	# Таймер запускается только если куст АКТИВЕН, пуст и таймер стоит
	if active_clusters.size() == 0 and timer.is_stopped():
		print("Куст пуст, запускаем таймер респавна...")
		timer.start()
		label.visible = false 

	# 4. Логика Надписи
	if player_is_near:
		if has_ripe_berries():
			label.visible = true
		else:
			label.visible = false
	else:
		label.visible = false

# Пробегаем по всем ягодам и спрашиваем "Ты созрела?"
func has_ripe_berries() -> bool:
	for berry in active_clusters:
		# Проверка на null (на всякий случай, если ягоду удалили)
		if is_instance_valid(berry) and "is_ready_to_harvest" in berry:
			if berry.is_ready_to_harvest:
				return true
	return false

func _on_respawn_timer_timeout():
	spawn_all_clusters()

func spawn_all_clusters():
	if not cluster_scene: return
	for point in spawn_points:
		var new_cluster = cluster_scene.instantiate()
		add_child(new_cluster)
		new_cluster.position = point.position
		active_clusters.append(new_cluster)

func clean_up_list():
	active_clusters = active_clusters.filter(func(c): return is_instance_valid(c))

# --- СИГНАЛЫ ЗОНЫ (DetectionZone) ---
func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
