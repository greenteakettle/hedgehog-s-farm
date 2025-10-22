extends CharacterBody2D

@export var autonomous_mode := false
@export var autonomous_speed := 40  # Быстрее
@export var player_speed := 10      # Медленнее

var left_limit := 256.0
var right_limit := 704.0
var direction := 1  # 1 = вправо, -1 = влево
var target_y := 80.0

func _ready():
	if autonomous_mode:
		position = Vector2(left_limit, target_y)
		direction = 1
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
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
		$AnimatedSprite2D.flip_h = true
	elif position.x <= left_limit:
		position.x = left_limit
		direction = 1
		$AnimatedSprite2D.flip_h = false

	$AnimatedSprite2D.play("walk")

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
		$AnimatedSprite2D.play("walk")
		if input_dir.x != 0:
			$AnimatedSprite2D.flip_h = input_dir.x < 0
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		$AnimatedSprite2D.play("idle")
