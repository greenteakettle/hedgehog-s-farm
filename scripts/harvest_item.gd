extends Area2D

@export var item_name: String = "Corn"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Hedgehog":
		queue_free()  # при сборе удаляем объект
