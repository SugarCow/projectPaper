extends Control
@onready var label = $Label

var max_hearts:
	set(value):
		max_hearts = max(value,2)

var hearts: 
	set(value):
		hearts = clamp(value, 0, max_hearts)
	get:
		return hearts

var max_exp_charge:
	set(value):
		max_exp_charge = max(value, 0)
		
var exp_charge:
	set(value):
		exp_charge = clamp(value, 0, max_exp_charge)
	get:
		return exp_charge



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	max_hearts = PlayerStats.max_health
	hearts = PlayerStats.health
	
	max_exp_charge = PlayerStats.experience_threshold
	exp_charge = PlayerStats.experience
	
	$Label.text = "Health: " +  str(hearts)
	$experience.text = "Experience: " + str(exp_charge)
