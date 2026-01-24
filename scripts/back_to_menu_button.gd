extends Button

@export var menu_scene_path: String = "res://scenes/menu.tscn"
@onready var click_sound = $"../../ClickSound"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	click_sound.play()
	
	get_tree().change_scene_to_file(menu_scene_path)
