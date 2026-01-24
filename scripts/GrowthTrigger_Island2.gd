extends Area2D

# 1. Изменяем тип переменной на Массив (Array)
# Теперь в Инспекторе ты увидишь список, куда можно добавлять много названий
@export var target_groups: Array[String] = ["island2_trees", "island2_berrybushes"]

var has_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что вошел Ежик (можно добавить проверку группы "player" для надежности)
	if (body.name == "Hedgehog" or body.is_in_group("player")) and not has_triggered:
		has_triggered = true
		
		# 2. Пробегаемся циклом по всем группам в нашем списке
		for group_name in target_groups:
			get_tree().call_group(group_name, "start_growing_cycle")
			print("Активирован рост для группы: ", group_name)
		
		# queue_free() # Можно удалить зону, если она одноразовая
