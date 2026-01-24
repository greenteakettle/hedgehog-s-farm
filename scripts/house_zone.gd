extends Area2D

@export var roof_layer: Node2D 
@export var world_light: CanvasModulate 
@export var indoor_light: PointLight2D
	
func _ready():

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if indoor_light:
		indoor_light.enabled = false 

func _on_body_entered(body):
	if body.is_in_group("player"): 
		enter_house_animation()

func _on_body_exited(body):
	if body.is_in_group("player"):
		exit_house_animation()


const LIGHT_ENERGY = 1

func enter_house_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	if roof_layer:
		tween.tween_property(roof_layer, "modulate:a", 0.0, 0.5)
	
	if indoor_light:
		indoor_light.enabled = true
		indoor_light.energy = LIGHT_ENERGY 


	if world_light:
		tween.tween_property(world_light, "color", Color(0.5, 0.5, 0.6, 1), 0.5)

func exit_house_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	if roof_layer:
		tween.tween_property(roof_layer, "modulate:a", 1.0, 0.5)
	
	if world_light:
		tween.tween_property(world_light, "color", Color.WHITE, 0.5)
	
	if indoor_light:
		get_tree().create_timer(0.5).timeout.connect(func(): indoor_light.enabled = false)
