extends Node2D

@export var harvest_scene: PackedScene
@export var growth_time: float = 3.0
@export var growth_frames: int = 4

var stage: int = 0
var player_in_area: bool = false
var is_ready_for_plant: bool = true
var timer: Timer

# Узлы сцены
@onready var crop_sprite = $CropSprite
@onready var e_label = $E_Indicator
@onready var seed_indicator = $SeedIndicator
@onready var interaction_zone = $InteractionZone
@onready var harvest_spawn_point = $HarvestSpawnPoint

func _ready():
	if not crop_sprite or not e_label or not seed_indicator or not interaction_zone or not harvest_spawn_point:
		push_error("Plant nodes are missing!")
		return

	_hide_all()

	timer = Timer.new()
	timer.wait_time = growth_time
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_grow"))
	add_child(timer)

	interaction_zone.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_zone.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		_on_interact()

# --- Зона посадки ---
func _on_body_entered(body):
	if body.name == "Hedgehog":
		player_in_area = true
		if stage == 0 and is_ready_for_plant:
			_show_indicators(true)

func _on_body_exited(body):
	if body.name == "Hedgehog":
		player_in_area = false
		if stage == 0:
			_hide_all()

# --- Посадка и сбор ---
func _on_interact():
	if stage == 0 and player_in_area and is_ready_for_plant:
		stage = 1
		is_ready_for_plant = false
		_hide_all()
		crop_sprite.visible = true
		crop_sprite.frame = stage
		timer.start()
	elif stage == growth_frames:
		_spawn_harvest()
		stage = 0
		is_ready_for_plant = true
		crop_sprite.visible = false
		crop_sprite.frame = 0
		timer.stop()
		_hide_all()

# --- Рост растения ---
func _on_grow():
	if stage > 0 and stage < growth_frames:
		stage += 1
		crop_sprite.frame = stage

	if stage == growth_frames:
		timer.stop()
		_show_indicators(false) # E для сбора урожая

# --- Спавн урожая ---
func _spawn_harvest():
	if not harvest_scene:
		return

	var drop = harvest_scene.instantiate()
	# позиционируем относительно глобальной позиции Marker2D
	drop.global_position = harvest_spawn_point.global_position + Vector2(randf()*30 -15, -15)
	# добавляем в родителя сцены, чтобы объект был на том же уровне, что и игрок
	get_tree().current_scene.add_child(drop)

# --- Вспомогательные функции ---
func _hide_all():
	e_label.visible = false
	seed_indicator.visible = false

func _show_indicators(show_seed: bool):
	e_label.visible = true
	seed_indicator.visible = show_seed
