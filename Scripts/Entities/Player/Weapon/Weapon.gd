extends Node2D

@onready var pivot = $Pivot
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
#	var global_mouse_pos = get_global_mouse_position()
#	var local_mouse_pos = pivot.to_local(global_mouse_pos)
#	print(get_local_mouse_position())
#	var angle_rad = get_local_mouse_position().angle()
#	var angle_deg = rad_to_deg(angle_rad)
#
#	pivot.rotation = lerp_angle(pivot.rotation, angle_deg, 50)
