extends Area2D

@export var item_data: Resource     
@export var growth_time: float = 5.0
@onready var appear_sound = $AppearSound
@onready var sprite = $AnimatedSprite2D
@onready var timer = $GrowthTimer

var is_grown: bool = false         
var can_be_picked: bool = false    
var player_in_zone: bool = false    
var is_ready_to_harvest: bool = false 


func _ready():
	sprite.frame = 0     
	timer.wait_time = growth_time
	timer.start()

func _process(_delta):

	if Input.is_action_just_pressed("interact"):
		if player_in_zone and is_grown and not can_be_picked:
			start_falling()

	if can_be_picked and player_in_zone:
		collect()

func _on_growth_timer_timeout():
	is_grown = true
	is_ready_to_harvest = true 
	sprite.frame = 1           

func start_falling():
	is_ready_to_harvest = false 
	
	appear_sound.play()

	var random_offset = Vector2(randf_range(-10, 10), randf_range(20, 35))
	var target_pos = global_position + random_offset
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	can_be_picked = true


func collect():
	var inventory = get_tree().get_first_node_in_group("inventory")
	
	if inventory and item_data:
		print("Подобрали ягоду: ", item_data.crop_name)
		inventory.add_item(item_data)
		

		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("pick_up_sound"):
			player.pick_up_sound()

		
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true
		
		if can_be_picked:
			collect()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
