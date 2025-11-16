extends Node2D

@export var plant_scene: PackedScene = preload("res://scenes/plant.tscn")
@export var plant_positions: Array[Vector2] = [
	Vector2(100, 200),
	Vector2(200, 200),
	Vector2(300, 200),
	Vector2(400, 200)
]

func _ready():
	for pos in plant_positions:
		var plant = plant_scene.instantiate()
		plant.position = pos
		add_child(plant)
