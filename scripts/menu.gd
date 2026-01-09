extends Control # или какой у вас корень

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_load_button_pressed():
	# Загрузка
	Global.load_game()
