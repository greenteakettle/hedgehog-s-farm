extends CharacterBody2D

const speed = 5  # скорость передвижения

func _physics_process(delta):
	var direction = Vector2.ZERO  # направление движения

	# Поддержка WASD + стрелок
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		position += direction * speed * delta

		# Воспроизведение анимации "walk"
		$AnimatedSprite2D.play("walk")

		# Отражение спрайта по горизонтали при движении влево
		if direction.x != 0:
			$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		# Воспроизведение анимации "idle"
		$AnimatedSprite2D.play("idle")
