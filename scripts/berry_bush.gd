extends Node2D

@export var cluster_scene: PackedScene 
@export var respawn_time: float = 5.0

@onready var spawn_points = [$Point1, $Point2, $Point3]
@onready var timer = $RespawnTimer
@onready var label = $E_Indicator # Ссылка на общую надпись



var active_clusters = []
var player_is_near: bool = false # Стоит ли еж у куста?

func _ready():
	timer.wait_time = respawn_time
	timer.one_shot = true
	if not timer.timeout.is_connected(_on_respawn_timer_timeout):
		timer.timeout.connect(_on_respawn_timer_timeout)
	
	label.visible = false # Прячем надпись на старте
	spawn_all_clusters()

func _process(_delta):
	clean_up_list()
	
	# 1. Логика респавна (если пусто - запускаем таймер)
	if active_clusters.size() == 0 and timer.is_stopped():
		timer.start()
		label.visible = false # Если ягод нет, надпись точно не нужна

	# 2. Логика Надписи
	if player_is_near:
		# Проверяем, есть ли хоть одна спелая ягода
		if has_ripe_berries():
			label.visible = true
		else:
			label.visible = false
	else:
		label.visible = false

# Пробегаем по всем ягодам и спрашиваем "Ты созрела?"
func has_ripe_berries() -> bool:
	for berry in active_clusters:
		# is_ready_to_harvest - это переменная из скрипта ягоды
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
