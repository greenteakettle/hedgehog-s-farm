extends Area2D

@export var crop_data: CropData

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

var target_pos_on_ground: Vector2 

func _ready():

	collision.disabled = true
	sprite.play("apple_grow")
	
	await sprite.animation_finished
	
	_start_falling()

func _start_falling():

	var tween = create_tween()
	
	tween.tween_property(self, "global_position", target_pos_on_ground, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	collision.disabled = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		var inventory = get_tree().get_first_node_in_group("inventory")
		if inventory:
			inventory.add_item(crop_data)
			queue_free()
