extends Control
@export var main_game_scene: String = "res://scenes/main.tscn"
@export var wait_time: float = 10.0

func _ready():
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(start_game)
	set_process_input(true)

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			start_game()

func start_game():
	if not is_inside_tree(): return

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): 
		get_tree().change_scene_to_file(main_game_scene)) 
