extends Button # Или TextureButton, смотря что ты использовала

# Укажи путь к твоей сцене ГЛАВНОГО МЕНЮ
# (Скопируй путь в файловой системе: ПКМ -> Copy Path)
@export var menu_scene_path: String = "res://scenes/menu.tscn"

# Ссылка на звук (если скрипт на кнопке, а звук рядом - используй путь к нему)
# Например, если звук лежит внутри кнопки или рядом в сцене
@onready var click_sound = $"../../ClickSound"
# (Если не найдет - перетащи узел звука в скрипт через @export)

func _ready():
	# Подключаем нажатие
	pressed.connect(_on_pressed)

func _on_pressed():
	# 1. Играем звук
	click_sound.play()
	
	# 2. Переходим в меню
	get_tree().change_scene_to_file(menu_scene_path)
