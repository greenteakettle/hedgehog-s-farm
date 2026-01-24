extends Area2D
@export var target_group_name: String = "island1_trees"

var has_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body.name == "Hedgehog" and not has_triggered:
		has_triggered = true

		get_tree().call_group(target_group_name, "start_growing_cycle")
		
