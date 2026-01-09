extends CanvasLayer

@onready var resume_btn = $VBoxContainer/ResumeButton
@onready var save_btn = $VBoxContainer/SaveButton
@onready var quit_btn = $VBoxContainer/QuitButton

func _ready():
	visible = false # Спрятать меню при старте

func _input(event):
	# Если нажали ESC
	if event.is_action_pressed("ui_cancel"):
		print("КНОПКА ESC НАЖАТА! (Скрипт работает)")
		toggle_pause()


func toggle_pause():
	visible = not visible
	get_tree().paused = visible # Ставим игру на ПАУЗУ (физика и таймеры остановятся)

func _on_resume_pressed():
	toggle_pause() # Просто снимаем паузу

func _on_save_pressed():
	Global.save_game() # Зовем наш глобальный скрипт!
	# Можно добавить надпись "Saved!"

func _on_quit_pressed():
	toggle_pause() # Снимаем паузу перед выходом
	get_tree().change_scene_to_file("res://scenes/menu.tscn") # Возврат в главное меню

func _on_resume_button_pressed() -> void:
	pass # Replace with function body.
