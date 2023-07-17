extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var experience = preload("res://Scripts/Entities/Pickups/exp.tscn")
@onready var main =  get_tree().current_scene
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")

# Called when the node enters the scene tree for the first time.
enum{
	FOLLOW,
	DEAD,
	STUN
}
@export var speed: int 
@export var max_health: float
@export var is_boss: bool
@onready var health = max_health
var state: int
var player
func _ready():
	player = $"../Player"
	state = FOLLOW


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	match state:
		FOLLOW:
			follow_state()
		DEAD:
			dead_state()
		STUN:
			stun_state()


func follow_state():
	animation.play("MoveLeft")
	
	var target_direction = ((player.position - self.position)- Vector2(0,10)).normalized()
	
	if target_direction.x > 0:
		animation.flip_h = true
	else: animation.flip_h = false
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()

func dead_state():
	
	$HurtBox/CollisionShape2D.disabled =true
	
	if is_boss == true:
		animation.play("PreDeath")
		await animation.animation_finished
		animation.play("Death")
	
	else:
		animation.play("Death")
	
	if animation.is_playing() == true:
		await animation.animation_finished
	var my_exp = experience.instantiate()
	main.get_node("World").add_child(my_exp)
	my_exp.get_node("AnimatedSprite2D").play("animate")
	my_exp.global_position = animation.global_position
	queue_free()

func stun_state():
	
	animation.play("Hurt")
	await animation.animation_finished
	state = FOLLOW

func _on_hurt_box_area_entered(_area):

	health -=15
	if health <=0:
		state = DEAD
	else:
		state = STUN

func handle_hit_marker():
	pass
