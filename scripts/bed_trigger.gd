extends Area2D

@export var transition_screen: ColorRect
@export var ui_layer: CanvasLayer
@onready var e_label = $E_Indicator
@export var end_scene_path: String = "res://scenes/end_game.tscn"

var anim_node_name = "AnimatedSprite2D" 
var player_ref = null
var is_sleeping = false

func _ready():
	e_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	if not is_sleeping and player_ref and event.is_action_pressed("interact"):
		go_to_sleep()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		e_label.visible = true

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null
		e_label.visible = false

func go_to_sleep():
	print("Sleep scene is starting")
	is_sleeping = true
	e_label.visible = false
	
	if ui_layer:
		ui_layer.visible = false


	if has_node("SleepPoint"):
		player_ref.global_position = $SleepPoint.global_position
	else:
		player_ref.global_position = global_position
	
	player_ref.set_physics_process(false)
	var item_sprite = player_ref.get_node_or_null("HeldItemSprite")
	if item_sprite: item_sprite.visible = false
	
	var anim_sprite = player_ref.get_node_or_null(anim_node_name)
	if anim_sprite:
		anim_sprite.play("sleep")
	
	if transition_screen:
		
		var tween = create_tween()
		tween.tween_interval(3.0) 
		tween.tween_property(transition_screen, "modulate:a", 1.0, 2.0)
	
		for n in get_tree().get_nodes_in_group("notifications"):
			var t = create_tween()
			t.tween_property(n, "modulate:a", 0.0, 1.0)

		tween.finished.connect(_change_scene)
		
	else:
		await get_tree().create_timer(3.0).timeout
		_change_scene()

func _change_scene():
	get_tree().change_scene_to_file(end_scene_path)
