extends Control
#@onready var label = $Label
@onready var heart_ui_full = $HeartFull
@onready var heart_ui_empty = $HeartEmpty

var ms: float =0
var second = 0
var minute = 0


var max_hearts:
	set(value):
		max_hearts = max(value,2)
		if heart_ui_empty != null:
			heart_ui_empty.size = Vector2(max_hearts * 28,22)
var hearts: 
	set(value):
		hearts = clamp(value, 0, max_hearts)
		if heart_ui_full != null:
			heart_ui_full.size =  Vector2(hearts * 28,22)
	get:
		return hearts

var max_exp_charge:
	set(value):
		max_exp_charge = max(value, 0)
		$TextureProgressBar.max_value = max_exp_charge
var exp_charge:
	set(value):
		exp_charge = clamp(value, 0, max_exp_charge)
		$TextureProgressBar.max_value = exp_charge
		
	get:
		return exp_charge



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if ms >= 9:
		second +=1
		ms =0
	if second >59:
		minute += 1
	
	$timer_text.text = str(minute) + ":" + str(second) + ":" + str(ms)
	
	
	
	max_hearts = PlayerStats.max_health
	hearts = PlayerStats.health
	
	max_exp_charge = PlayerStats.experience_threshold
	exp_charge = PlayerStats.experience
	
	
	
#	$Label.text = "Health: " +  str(hearts)
	$experience.text = "Experience: " + str(exp_charge)
#	$Time.text = str(Game.minute) + ":" + str(Game.second) + ":" + str(Game.ms)
	
	


func _on_timer_timeout():
	ms += 1

