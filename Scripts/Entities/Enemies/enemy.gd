extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
enum{
	FOLLOW,
	DEAD,
	STUN
}
@export var speed: int 
var state: int
var player
func _ready():
	player = $"../../Player"
	state = FOLLOW


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	match state:
		FOLLOW:
			follow_state()
	pass

func follow_state():
	animation.play("MoveLeft")
	
	var target_direction = ((player.position - self.position)- Vector2(0,10)).normalized()
	
	if target_direction.x > 0:
		animation.flip_h = true
	else: animation.flip_h = false
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()
