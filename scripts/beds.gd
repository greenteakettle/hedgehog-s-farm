extends Node2D

@export var plant_scene = preload("res://scenes/plant.tscn")
@export var plant_positions: Array[Vector2] = [
	Vector2(100, 200),
	Vector2(200, 200),
	Vector2(300, 200),
	Vector2(400, 200)
]

func _ready():
	for pos in plant_positions:
		var plant = plant_scene.instantiate()
		plant.position = pos
		add_child(plant)


func has_plant() -> bool:
	print("[BEDS] Проверка: можно ли удалить грядку?")
	
	# Пробегаемся по всем детям грядки (там должны быть растения)
	for child in get_children():
		
		# Если у ребенка есть нужная функция (значит это растение)
		if child.has_method("is_growing"):
			var is_busy = child.is_growing()
			print(" -> Растение найдено. Растет что-то? ", is_busy)
			
			# Если растение говорит "да" (true), значит удалять нельзя
			if is_busy:
				return true
				
	print(" -> Все чисто, можно удалять.")
	return false
