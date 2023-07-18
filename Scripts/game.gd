extends Node2D
var cursor = preload("res://Assets/UI/Cursor/Reticle1.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	

	Input.set_custom_mouse_cursor(cursor)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
