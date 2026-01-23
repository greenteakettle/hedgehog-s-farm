extends Area2D

# 1. Черный квадрат для затемнения
@export var transition_screen: ColorRect

# 2. Весь слой интерфейса (Инвентарь, кнопки и т.д.)
@export var ui_layer: CanvasLayer

@onready var e_label = $E_Indicator

# 3. Путь к сцене конца игры
@export var end_scene_path: String = "res://scenes/end_game.tscn"

# --- НАСТРОЙКИ ---
var anim_node_name = "AnimatedSprite2D" # Имя узла анимации у ежика

var player_ref = null
var is_sleeping = false

func _ready():
	e_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	if not is_sleeping and player_ref and event.is_action_pressed("interact"):
		go_to_sleep()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		e_label.visible = true

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null
		e_label.visible = false

func go_to_sleep():
	print("--- НАЧАЛО СЦЕНЫ СНА ---")
	is_sleeping = true
	e_label.visible = false
	
	# 1. Прячем ВЕСЬ интерфейс (Инвентарь)
	if ui_layer:
		ui_layer.visible = false
	else:
		print("Внимание: UI_Layer не привязан! Инвентарь останется виден.")

	# 2. Ставим ежика на точку
	if has_node("SleepPoint"):
		player_ref.global_position = $SleepPoint.global_position
	else:
		player_ref.global_position = global_position
	
	# 3. Отключаем управление и прячем предмет в руках
	player_ref.set_physics_process(false)
	var item_sprite = player_ref.get_node_or_null("HeldItemSprite")
	if item_sprite: item_sprite.visible = false
	
	# 4. Анимация сна
	var anim_sprite = player_ref.get_node_or_null(anim_node_name)
	if anim_sprite:
		anim_sprite.play("sleep")
	
	# 5. Сценарий финала
	if transition_screen:
		var tween = create_tween()
		print("Ждем 3 секунды...")
		tween.tween_interval(3.0) # Смотрим как спит
		
		print("Начинаем затемнение...")
		
		# Делаем экран черным
		tween.tween_property(transition_screen, "modulate:a", 1.0, 2.0)
	
		
		# Меняем сцену
		tween.finished.connect(_change_scene)
	else:
		print("ОШИБКА: Transition Screen (черный квадрат) не привязан!")
		print("Переход произойдет резко через 3 секунды.")
		await get_tree().create_timer(3.0).timeout
		_change_scene()

func _change_scene():
	print("Переход на финальную сцену!")
	get_tree().change_scene_to_file(end_scene_path)
