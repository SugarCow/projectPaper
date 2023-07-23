extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var experience = preload("res://Scripts/Entities/Pickups/exp.tscn")
@onready var main =  get_tree().current_scene
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")

# Called when the node enters the scene tree for the first time.
enum{
	IDLE,
	FOLLOW,
	DEAD,
	STUN,
	ATTACK,
	ALLIED
}
@export var speed: int 
@export var max_health: float
@export var max_cost: float
@export var is_boss: bool
@onready var health = max_health
@onready var cost = max_cost
var state: int
var player
var dropped_exp: bool = false
var my_target: CharacterBody2D
func _ready():
	player = $"../Player"
	state = FOLLOW
	my_target = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	match state:
		IDLE:
			idle_state()
		FOLLOW:
			follow_state(my_target)
		ATTACK:
			attack_state(my_target)
		DEAD:
			dead_state()
		STUN:
			stun_state()
		ALLIED:
			allied_state()

func idle_state():
	animation.play("IdleLeft")

func follow_state(target):
	animation.play("MoveLeft")
	
	var target_direction = ((target.position - self.position)- Vector2(2,2)).normalized()
	
	if target_direction.x > 0:
		animation.flip_h = true
	else: animation.flip_h = false
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()

func attack_state(target):
	velocity = Vector2.ZERO
	animation.play("AttackLeft")
	var target_direction = ((target.position - self.position)- Vector2(2,2)).normalized()
	if target_direction.x > 0:
		animation.flip_h = true
	else: animation.flip_h = false
	
	await animation.animation_finished
	state = FOLLOW

func dead_state():
	
	$HurtBox/CollisionShape2D.disabled =true
	
	
	animation.play("Death")
	
	if animation.is_playing() == true:
		await animation.animation_finished
	if dropped_exp == false:
		var my_exp = experience.instantiate()
		main.get_node("World").add_child(my_exp)
		my_exp.get_node("AnimatedSprite2D").play("animate")
		my_exp.global_position = animation.global_position
		dropped_exp = true
	queue_free()

func stun_state():
	velocity = Vector2.ZERO
	if animation.animation != "Hurt":
		animation.stop()
		animation.play("Hurt")
		await animation.animation_finished
		state = FOLLOW
func allied_state():
	$DetectEnemies/CollisionShape2D.set_deferred("disabled", false)
	print($HitBox.collision_mask) 
	state = IDLE
func _on_hurt_box_area_entered(_area):

	health -=15
	if health <=0:
		state = DEAD
	else:
		state = STUN




func _on_hit_box_area_entered(_area):
	state = ATTACK


func _on_cost_box_area_entered(_area):
	cost -=15
	if cost <=0:
		state = ALLIED
	else:
		state = STUN


func _on_detect_enemies_area_entered(area):
	print(area.owner)
	print(area.name)
	my_target = null
	state = FOLLOW
