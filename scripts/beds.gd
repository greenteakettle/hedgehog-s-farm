extends Node2D

@export var plant_scene: PackedScene 

@onready var interaction_zone = $InteractionZone
@onready var status_label = $StatusLabel 

var player_in_area = false

func _ready():

	if interaction_zone:
		interaction_zone.body_entered.connect(_on_body_entered)
		interaction_zone.body_exited.connect(_on_body_exited)
	
		_update_ui()

func _process(_delta):

	if player_in_area and Input.is_action_just_pressed("interact"):
		_on_interact()

func _on_interact():
	var plant = get_node_or_null("Plant")
	
	if plant != null:
		if plant.has_method("is_grown") and plant.is_grown():
			print("[BED] Harvest is ready! Collecting...")
			plant.harvest()
			_update_ui()    
		else:
			print("[BED] Still growing.")
		return 

	var inventory = get_tree().get_first_node_in_group("inventory")
	if not inventory:
		return

	var item_data = inventory.get_selected_crop_data_and_decrease()
	
	if item_data:

		if item_data.get("is_seed") == true or (item_data.animation_name != "" and item_data.produce_data != null):
			print("[BED] Planting: ", item_data.crop_name)
			spawn_plant(item_data)
		else:
			print("[BED] You can't plant it.")
			inventory.add_item(item_data)
	else:
		print("Don't have anything to plant.")

func spawn_plant(crop_data):
	if not plant_scene:
				return

	var new_plant = plant_scene.instantiate()
	new_plant.name = "Plant" 
	add_child(new_plant)
	
	new_plant.init_crop(crop_data)
	_update_ui()


func _update_ui():
	if not status_label: return
	
	if not player_in_area:
		status_label.visible = false
		return

	var plant = get_node_or_null("Plant")
	
	if plant == null:
		status_label.text = "PRESS E TO PLANT"
		status_label.visible = true
	else:
		if plant.has_method("is_grown") and plant.is_grown():
			status_label.text = "PRESS E TO COLLECT"
			status_label.visible = true
		else:
			status_label.visible = false


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		_update_ui()


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		_update_ui()


func get_save_data():
	var data = { "has_plant": false, "plant_internal_data": {} }
	var plant = get_node_or_null("Plant")
	if plant != null:
		data["has_plant"] = true
		data["plant_internal_data"] = plant.get_save_data()
	return data


func restore_state(data):
	if has_node("Plant"):
		get_node("Plant").queue_free()
	

	if typeof(data) != TYPE_DICTIONARY:
		return

	if data.get("has_plant", false) == true:
		
		if plant_scene:
			var new_plant = plant_scene.instantiate()
			new_plant.name = "Plant"
			add_child(new_plant)
			

			var plant_data = data.get("plant_internal_data", {})
			new_plant.restore_state(plant_data)
	
	_update_ui()
