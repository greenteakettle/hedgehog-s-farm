extends Area2D

# Название группы деревьев, которую будем будить
@export var target_group_name: String = "island1_trees"

var has_triggered = false

func _ready():
	# Подключаем сигнал входа
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что вошел Ежик и мы еще не запускали этот триггер
	if body.name == "Hedgehog" and not has_triggered:
		has_triggered = true
		
		# МАГИЯ: Зовем функцию "start_growing_cycle" у ВСЕХ объектов в группе
		get_tree().call_group(target_group_name, "start_growing_cycle")
		
		print("Активирован рост для группы: ", target_group_name)
		# Если зона больше не нужна, можно её удалить:
		# queue_free()
