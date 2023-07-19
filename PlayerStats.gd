extends Node

signal no_health
signal level_up


var max_health:
	set(value):
		max_health = max(value, 1)

var health:
	get: return health
	set(value):
		health = clamp(value, 0, max_health)
		
		if health <= 0:
			emit_signal("no_health")
		
var experience_threshold:
	get: return experience_threshold
	set(current_threshold):
		experience_threshold = max(0, current_threshold)
		
var experience:
	get: return experience
	set(value):
		experience = max(value, 0)
		if experience >=experience_threshold:
			experience = max(experience - experience_threshold,0)
			experience_threshold += 2
			emit_signal("level_up")
			print("leveled up!")


var base_speed = 100

var movement_speed:
	get: return movement_speed
	set(value): 
		if movement_speed == null:
			movement_speed = base_speed
		else:
			movement_speed = movement_speed + movement_speed*value
func _ready():
	max_health = 3
	health = max_health
	
	experience_threshold = 2
	experience = 0

	movement_speed = 150
	print(movement_speed)
