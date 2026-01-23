extends Area2D


@export var roof_layer: Node2D 
@export var world_light: CanvasModulate 
@export var indoor_light: PointLight2D
	
func _ready():
	# Сразу подключаем сигналы входа и выхода
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Убедимся, что при старте игры свет в доме выключен (или включен, как хочешь)
	if indoor_light:
		indoor_light.enabled = false # Днем свет в доме не нужен

func _on_body_entered(body):
	if body.is_in_group("player"): # Убедись, что ежик в группе "player"
		enter_house_animation()

func _on_body_exited(body):
	if body.is_in_group("player"):
		exit_house_animation()

# Настрой это число под свою идеальную яркость (как ты настроила в инспекторе)
const LIGHT_ENERGY = 1

func enter_house_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Крыша исчезает
	if roof_layer:
		tween.tween_property(roof_layer, "modulate:a", 0.0, 0.5)
	
	# 2. Включаем свет МГНОВЕННО (без анимации)
	# Мы как бы говорим: "Эта комната теперь защищена от темноты"
	if indoor_light:
		indoor_light.enabled = true
		indoor_light.energy = LIGHT_ENERGY 
		# Мы НЕ анимируем энергию с 0. Мы сразу ставим нужную яркость.
		# Так как на улице еще светло, мы не заметим подмены, 
		# но когда улица начнет темнеть, комната останется яркой.

	# 3. На улице наступает ночь
	if world_light:
		tween.tween_property(world_light, "color", Color(0.5, 0.5, 0.6, 1), 0.5)

func exit_house_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Крыша появляется
	if roof_layer:
		tween.tween_property(roof_layer, "modulate:a", 1.0, 0.5)
	
	# 2. Улица светлеет
	if world_light:
		tween.tween_property(world_light, "color", Color.WHITE, 0.5)
	
	# 3. Свет выключаем ТОЛЬКО КОГДА на улице уже светло
	if indoor_light:
		# Ждем, пока tween закончится (0.5 сек), и только потом выключаем лампу
		# Чтобы не моргнуло черным напоследок
		get_tree().create_timer(0.5).timeout.connect(func(): indoor_light.enabled = false)
