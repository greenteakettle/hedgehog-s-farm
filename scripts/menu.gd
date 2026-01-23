extends Control 
@onready var click_sound = $ClickSound

func _on_play_button_pressed():
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_load_button_pressed():
	click_sound.play()
	Global.load_game()
