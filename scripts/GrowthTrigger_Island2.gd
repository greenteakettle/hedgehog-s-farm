extends Area2D
@export var target_groups: Array[String] = ["island2_trees", "island2_berrybushes"]

var has_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if (body.name == "Hedgehog" or body.is_in_group("player")) and not has_triggered:
		has_triggered = true

		for group_name in target_groups:
			get_tree().call_group(group_name, "start_growing_cycle")
		
