extends Control

@onready var label = $TextureRect/RichTextLabel # Или $Label, проверь свой путь!
@onready var timer = $LifeTimer
@onready var sound = $NotificationSound

func _ready():
	# Анимация появления (выцветание + небольшой сдвиг)
	modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	sound.play()
	# Если таймер не настроен в инспекторе, запускаем тут
	timer.start(10.0) # Пусть висит 5 секунд

func set_text(text: String):
	# Ждем кадр, чтобы узлы точно загрузились (иногда бывает нужно)
	if not is_inside_tree(): await ready
	label.text = text

func _on_life_timer_timeout():
	# Исчезаем
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	queue_free() # Просто удаляемся, список сам сдвинется!
