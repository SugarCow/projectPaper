extends CharacterBody2D

@onready var main =  get_tree().current_scene

var state 
var player
var speed : int = 150
# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"../Player"
	state = "idle"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		"idle":
			pass
		"follow":
			follow_state()

func follow_state():
	var target_direction = (player.global_position - self.global_position).normalized()
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()

	if abs(player.position - self.position) <=Vector2(3,3):
#		$AudioStreamPlayer2D.play()
#		await $AudioStreamPlayer2D.finished
		queue_free()

func _on_area_2d_area_entered(_area):
	state = "follow"
	
