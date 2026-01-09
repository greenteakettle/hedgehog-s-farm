extends CharacterBody2D

@export var autonomous_mode := false
@export var autonomous_speed := 40  
@export var player_speed := 10       
@onready var held_item_sprite = $HeldItemSprite
@onready var main_sprite = $AnimatedSprite2D

var left_limit := 232.0
var right_limit := 792
var direction := 1  
var target_y := 80.0 

func _ready():
	if held_item_sprite:
		held_item_sprite.visible = false
		
	if autonomous_mode:
		position = Vector2(left_limit, target_y)
		direction = 1
		main_sprite.play("walk") # Используем переменную main_sprite
	else:
		main_sprite.play("idle")

func _physics_process(_delta):
	if autonomous_mode:
		_autonomous_move()
	else:
		_player_controlled_move()
	

func _autonomous_move():
	# движение только по оси X
	velocity.x = direction * autonomous_speed
	velocity.y = 0
	move_and_slide()

	if position.x >= right_limit:
		position.x = right_limit
		direction = -1
		main_sprite.flip_h = true
	elif position.x <= left_limit:
		position.x = left_limit
		direction = 1
		main_sprite.flip_h = false
	
	main_sprite.play("walk")

func _player_controlled_move():
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		input_dir.y -= 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * player_speed
		move_and_slide()
		main_sprite.play("walk")
		
		# --- ЛОГИКА ПОВОРОТА И СДВИГА ПРЕДМЕТА ---
		if input_dir.x != 0:
			var is_flipped = input_dir.x < 0
			
			# 1. Поворачиваем самого ежа
			main_sprite.flip_h = is_flipped
			
			# 2. Если есть предмет - поворачиваем и двигаем его
			if held_item_sprite:
				held_item_sprite.flip_h = is_flipped
				
				# Магия с позицией:
				# Берем текущее смещение по модулю (всегда положительное число)
				var offset = abs(held_item_sprite.position.x)
				
				if is_flipped:
					# Если смотрим ВЛЕВО -> предмет должен быть правее центра (плюс)
					held_item_sprite.position.x = offset 
				else:
					# Если смотрим ВПРАВО -> предмет должен быть левее центра (минус)
					held_item_sprite.position.x = -offset
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		main_sprite.play("idle")

func update_held_item(item_texture: Texture2D):
	if item_texture != null:
		held_item_sprite.texture = item_texture
		held_item_sprite.visible = true
	else:
		held_item_sprite.visible = false
