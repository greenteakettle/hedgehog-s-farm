extends Area2D

# --- НАСТРОЙКИ ---
@export_multiline var story_lines: Array[String] 

# УНИКАЛЬНОЕ ИМЯ (ОБЯЗАТЕЛЬНО ДЛЯ СОХРАНЕНИЯ!)
# Назови каждый триггер по-разному: "intro_1", "bed_tutorial", "well_hint"
@export var trigger_id: String = "" 

@export var one_shot: bool = true 
@export var unlock_gardening_mechanic: bool = false 

func _ready():
	# ГЛАВНАЯ ПРОВЕРКА:
	# Если у триггера есть имя И это имя уже в списке "виденных" -> удаляемся сразу
	if trigger_id != "" and Global.seen_triggers.has(trigger_id):
		queue_free()
		return # Остальной код не выполняем

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		
		# 1. Запоминаем этот триггер как "просмотренный"
		if trigger_id != "":
			if not Global.seen_triggers.has(trigger_id):
				Global.seen_triggers.append(trigger_id)
		
		# 2. Показываем текст
		for line in story_lines:
			StoryLine.show_message(line)
		
		# 3. (Опционально) Разблокируем механику
		if unlock_gardening_mechanic:
			if "can_build_beds" in body:
				body.can_build_beds = true
		
		# 4. Удаляемся
		if one_shot:
			queue_free()
