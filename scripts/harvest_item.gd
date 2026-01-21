extends Area2D

@export var crop_data: CropData 

@onready var sprite = $Sprite2D


var can_be_picked_up: bool = false

func _ready():

	if crop_data != null:
		sprite.texture = crop_data.inventory_icon
	
	var tween = create_tween()
	
	var target_y = global_position.y
	
	tween.tween_property(self, "global_position:y", target_y - 25, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", target_y, 0.25)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	await get_tree().create_timer(0.5).timeout
	
	
	
	can_be_picked_up = true


func _on_body_entered(body):
	if body.name == "Hedgehog" and can_be_picked_up:
		if crop_data != null:
			get_tree().call_group("inventory", "add_item", crop_data)
			Global.hedgehog.pick_up_sound()
			queue_free()
