extends CanvasLayer

@onready var resume_btn = $VBoxContainer/ResumeButton
@onready var save_btn = $VBoxContainer/SaveButton
@onready var quit_btn = $VBoxContainer/QuitButton
@onready var click_sound = $ClickSound

func _ready():
	visible = false 

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("КНОПКА ESC НАЖАТА! (Скрипт работает)")
		toggle_pause()


func toggle_pause():
	visible = not visible
	get_tree().paused = visible # 

func _on_resume_pressed():
	click_sound.play()
	toggle_pause() 

func _on_save_pressed():
	click_sound.play()
	Global.save_game() 

func _on_quit_pressed():
	click_sound.play()
	toggle_pause() 
	Global.clear_ui() 
	get_tree().change_scene_to_file("res://scenes/menu.tscn") 

func _on_resume_button_pressed() -> void:
	pass 
