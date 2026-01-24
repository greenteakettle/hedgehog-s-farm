extends Area2D

@export_multiline var story_lines: Array[String] 
@export var trigger_id: String = "" 
@export var one_shot: bool = true 
@export var unlock_gardening_mechanic: bool = false 

func _ready():

	if trigger_id != "" and Global.seen_triggers.has(trigger_id):
		queue_free()
		return 

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):

		if trigger_id != "":
			if not Global.seen_triggers.has(trigger_id):
				Global.seen_triggers.append(trigger_id)
		
		for line in story_lines:
			StoryLine.show_message(line)
		
		if unlock_gardening_mechanic:
			if "can_build_beds" in body:
				body.can_build_beds = true
		
		if one_shot:
			queue_free()
