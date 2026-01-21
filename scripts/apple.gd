extends Area2D

@export var crop_data: CropData

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

# Эту переменную заполнит Дерево при создании яблока
var target_pos_on_ground: Vector2 

func _ready():
	# 1. Сразу отключаем подбор (чтобы нельзя было сорвать недозрелое)
	collision.disabled = true
	
	# 2. Запускаем анимацию роста (убедись, что она называется "grow")
	sprite.play("apple_grow")
	
	# 3. Ждем, пока анимация закончится
	await sprite.animation_finished
	
	# 4. Как только выросло — начинаем падать
	_start_falling()

func _start_falling():
	# Создаем анимацию падения
	var tween = create_tween()
	
	# Падаем в точку, которую нам передало дерево
	tween.tween_property(self, "global_position", target_pos_on_ground, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Ждем окончания падения
	await tween.finished
	
	# 5. Теперь яблоко на земле — включаем возможность подбора!
	collision.disabled = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		var inventory = get_tree().get_first_node_in_group("inventory")
		if inventory:
			inventory.add_item(crop_data)
			queue_free()
