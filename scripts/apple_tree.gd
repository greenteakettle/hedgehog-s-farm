extends StaticBody2D

@export var apple_scene: PackedScene
@export var max_apples: int = 2       
@export var growth_time: float = 10   

var spawned_apples = [] 
var is_active = false 

@onready var spawn_points = [$Point1, $Point2, $Point3]
@onready var timer = $GrowthTimer

func _ready():
	timer.wait_time = growth_time


func start_growing_cycle():
	if is_active: 
		return 
	
	is_active = true
	timer.start()
	print("Tree is activated!")

func _on_growth_timer_timeout():
	clean_up_list()
	
	if spawned_apples.size() >= max_apples:
		return 
		
	spawn_one_apple()

func spawn_one_apple():
	if not apple_scene: return
	
	var random_point = spawn_points.pick_random()
	var new_apple = apple_scene.instantiate()
	
	get_parent().add_child(new_apple)
	
	new_apple.global_position = random_point.global_position
	
	var random_x = randf_range(-10, 10) 
	var random_y = randf_range(15, 35) 
	var ground_pos = random_point.global_position + Vector2(random_x, random_y)
	
	if "target_pos_on_ground" in new_apple:
		new_apple.target_pos_on_ground = ground_pos
	
	spawned_apples.append(new_apple)

func clean_up_list():
	spawned_apples = spawned_apples.filter(func(a): return is_instance_valid(a)) 
