extends Node2D

@export var font_style: LabelSettings

@export var requirements = {
	"Wheat Item": 3,
	"Eggplant Item": 3,
	"Apple": 3,
	"Berry": 3,
}

var item_textures = {
	"Wheat Item": preload("res://textures/wheat_item.tres"), 
	"Eggplant Item": preload("res://textures/eggplant_item.tres"),
	"Apple": preload("res://textures/apple.tres"),
	"Berry": preload("res://textures/berry.tres")
}

var paid_items = {} 
var is_open: bool = false 

@onready var open_sound = $OpenSound
@onready var items_list = $BuyingZone/ItemsList
@onready var buying_area = $BuyingZone 
@onready var wall_collision = $StaticBody2D/CollisionShape2D 
@onready var sprite = $Sprite2D


func _ready():
	add_to_group("persisted_items")

	for item in requirements:
		paid_items[item] = 0
	update_visuals()
	
	buying_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body.name == "Hedgehog" or body.is_in_group("player"):
		check_and_pay()

func check_and_pay():

	var inventory = get_tree().get_first_node_in_group("inventory")
	if not inventory:
		return
	
	var is_fully_open = true
	var something_changed = false
	
	for item_name in requirements:
		var needed = requirements[item_name]
		var paid = paid_items[item_name]
		var left_to_pay = needed - paid
		
		if left_to_pay > 0:

			var count_in_bag = inventory.get_item_count(item_name)
			
			if count_in_bag > 0:

				var take = min(left_to_pay, count_in_bag)
				inventory.remove_item_by_name(item_name, take)
				

				paid_items[item_name] += take
				something_changed = true
				print("Fog take: ", item_name, " ", take, " шт.")
			

			if paid_items[item_name] < needed:
				is_fully_open = false
	
	if something_changed:
		update_visuals()
		
	if is_fully_open:
		open_gate()

func update_visuals():
	
	for child in items_list.get_children():
		child.queue_free()

	for item_name in requirements:
		var needed = requirements[item_name]
		var paid = paid_items[item_name]
		var left = needed - paid
		

		if left > 0:
			create_row(item_name, paid, needed)


func create_row(item_name, paid, needed):
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER 
	
	var icon = TextureRect.new()
	if item_textures.has(item_name):
		icon.texture = item_textures[item_name]
	
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(15, 15) 
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER 
	
	var label = Label.new()
	label.text = str(paid) + "/" + str(needed)
	
	if font_style:
		label.label_settings = font_style

	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER 
	
	row.add_child(icon)
	row.add_child(label)
	items_list.add_child(row)

func open_gate():
	if is_open: return 
	is_open = true
	
	wall_collision.set_deferred("disabled", true)
	$BuyingZone/CollisionShape2D.set_deferred("disabled", true)

	if open_sound: open_sound.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	

	tween.tween_property(sprite, "modulate:a", 0.0, 2.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if items_list:
		tween.tween_property(items_list, "modulate:a", 0.0, 1.0)
	

	tween.chain().tween_callback(func(): 
		visible = false
		if items_list: items_list.visible = false 
	)

func get_save_data():
	return {
		"is_open": is_open
	}

func restore_state(data):
	is_open = data.get("is_open", false)
	
	if is_open:
		wall_collision.set_deferred("disabled", true)
		
		sprite.modulate.a = 0.0
		visible = false
		
		if items_list: items_list.visible = false 
		
	else:
		
		sprite.modulate.a = 1.0
		visible = true
		wall_collision.set_deferred("disabled", false)
		update_visuals() 
