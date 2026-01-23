extends Node

var notification_scene = preload("res://scenes/story_notification.tscn")

var queue: Array[String] = []
var is_queue_active = false # <--- ПЕРЕИМЕНОВАЛИ (было is_processing)

var notification_container: VBoxContainer = null


func _ready():
	_create_ui_layer()

func _create_ui_layer():
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	
	notification_container = VBoxContainer.new()
	layer.add_child(notification_container)
	
	# --- НАСТРОЙКИ ДЛЯ ЛЕВОГО ВЕРХНЕГО УГЛА ---
	notification_container.anchor_left = 0.01  # Отступ слева
	notification_container.anchor_top = 0.01   # Отступ сверху
	notification_container.anchor_right = 0.10  # Ширина контейнера (30% экрана)
	notification_container.anchor_bottom = 1.0 
	
	# Выстраиваем сверху вниз
	notification_container.alignment = BoxContainer.ALIGNMENT_BEGIN 
	
	# Расстояние между табличками
	notification_container.add_theme_constant_override("separation", 2)
	
	notification_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_message(text: String):
	queue.append(text)
	_process_queue()

func _process_queue():
	# Используем новое имя переменной
	if is_queue_active: return
	is_queue_active = true
	
	while queue.size() > 0:
		var text = queue.pop_front()
		_spawn_notification(text)
		
		# Задержка между появлением следующей таблички (0.5 сек)
		await get_tree().create_timer(0.5).timeout 
	
	is_queue_active = false

func _spawn_notification(text):
	var notif = notification_scene.instantiate()
	notification_container.add_child(notif)
	notif.set_text(text)
