extends CharacterBody2D

@onready var main =  get_tree().current_scene
@export var type: String


var state 
var player
var speed : int = 250
var pickup_spent: bool
var linear_velocity: Vector2 = Vector2.ZERO
var value: float = 0
signal increase_difficulty
# Called when the node enters the scene tree for the first time.
func _ready():
	
	if type == "Treasure":
		if randf_range(0,1) <= .1:
			$Sprite2D.texture = load("res://Assets/Drops/Treasure Chest4.png")
			value = 15
		elif randf_range(0,1) <= .4:
			$Sprite2D.texture = load("res://Assets/Drops/Treasure Chest3.png")
			value = 10
		elif randf_range(0,1) <= .7:
			$Sprite2D.texture = load("res://Assets/Drops/Treasure Chest2.png")
			value = 7
		elif randf_range(0,1) <= 1:
			$Sprite2D.texture = load("res://Assets/Drops/Treasure Chest1.png")
			value = 5
		
	
	pickup_spent = false
	player = $"../Player"
	state = "fly"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		"fly":
			pass
		"follow":
			follow_state()

func follow_state():
	var target_direction = (player.global_position - self.position).normalized()
	velocity = velocity.move_toward(target_direction * speed , 3)
	move_and_slide()

	if abs(player.position - self.position) <=Vector2(3,3):
		if pickup_spent == false and type == "coin":
			PlayerStats.coin +=1
			pickup_spent = true
			$AudioStreamPlayer2D.play()
#		$AudioStreamPlayer2D.play()
#		await $AudioStreamPlayer2D.finished
		elif pickup_spent == false and type == "health":
			PlayerStats.health += 1
			pickup_spent = true
			$AudioStreamPlayer2D.play()
		elif pickup_spent == false and type == "Treasure":
			PlayerStats.coin += value
			pickup_spent = true
			$AudioStreamPlayer2D.play()
		await $AudioStreamPlayer2D.finished
		self.queue_free()

func _on_area_2d_area_entered(_area):
	
	state = "follow"
	
