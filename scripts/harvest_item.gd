extends Area2D

@export var crop_data: CropData:
	set(value):
		crop_data = value
		if sprite:
			sprite.texture = crop_data.inventory_icon

@onready var sprite = $Sprite2D
var can_be_picked_up: bool = false


func _ready():
	
	can_be_picked_up = false 
	await get_tree().process_frame 
	
	if crop_data != null:
		sprite.texture = crop_data.inventory_icon
	
	var target_y = global_position.y
	var tween = create_tween()
	
	tween.tween_property(self, "global_position:y", target_y - 25, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", target_y, 0.25)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


	await get_tree().create_timer(0.7).timeout
	can_be_picked_up = true


func _on_body_entered(body):
	if not can_be_picked_up: return
	
	if body.name == "Hedgehog" or body.is_in_group("player"):
		var inventory = get_tree().get_first_node_in_group("inventory")
		if inventory:
			var result = inventory.add_item(crop_data)
			if result == true:

				if body.has_method("pick_up_sound"):
					body.pick_up_sound()
				
				queue_free()
