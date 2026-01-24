extends Control

@onready var label = $TextureRect/RichTextLabel 
@onready var timer = $LifeTimer
@onready var sound = $NotificationSound

func _ready():

	modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	sound.play()
	timer.start(10.0) 

func set_text(text: String):
	if not is_inside_tree(): await ready
	label.text = text

func _on_life_timer_timeout():

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	queue_free() 
