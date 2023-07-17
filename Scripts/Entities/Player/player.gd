extends CharacterBody2D

var animation_player


enum {
	IDLE, 
	MOVE,
	ATTACK,
	STUN,
	DEAD
}

var state: int
var input_dir: Vector2 
var facing_dir: Vector2 
var speed: int = 100 
var acceleration: int = 300
var dust_particle = load("res://Scripts/Particle/dustParticle.tscn")
var particle_ready = true
var invincible = false

@onready var main = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = $AnimationPlayer
	state = IDLE
	facing_dir = Vector2(1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	input_dir = Vector2(Input.get_action_raw_strength("ui_left") - Input.get_action_strength("ui_right"), 
						Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	input_dir = input_dir.normalized()
	
	
	
	#state machine
	match state:
		IDLE:
			idle_state()
		MOVE:
			move_state()
		STUN:
			stun_state()
	if input_dir != Vector2.ZERO:
		state = MOVE

func move_state():
	
	#walking dust particle
	if particle_ready == true:
		var my_dust = dust_particle.instantiate()
		main.add_child(my_dust)
		my_dust.global_position = $Area2D2.global_position + Vector2(-3,0)
		particle_ready = false
		$DustParticleCD.start()
		
	#Animating moving Right and left
	if input_dir.x > 0:
		animation_player.play("MoveRight")
		facing_dir.x = input_dir.x

	if input_dir.x < 0:
		animation_player.play("MoveLeft")
		facing_dir.x = input_dir.x
	
	if input_dir.x == 0:
		state = IDLE

	#Animating moving Up and Down
	if input_dir.y >0 and facing_dir.x >0: 
		animation_player.play("MoveRight")
	
	if input_dir.y >0 and facing_dir.x <0: 
		animation_player.play("MoveLeft")
	
	if input_dir.y <0 and facing_dir.x >0: 
		animation_player.play("MoveRight")
	
	if input_dir.y <0 and facing_dir.x <0: 
		animation_player.play("MoveLeft")
	
	velocity = input_dir * speed
#	velocity = velocity.move_toward(input_dir* speed, acceleration* delta)
	move_and_slide()
	
	
func idle_state():
	if facing_dir.x <= 0:
		animation_player.play("IdleLeft")
	if facing_dir.x >= 0:
		animation_player.play("IdleRight")


	animation_player.play("Hurt")
	await animation_player.animation_finished
	state = IDLE

func stun_state():
	print("ouch")
	animation_player.play("Hurt")
	await animation_player.animation_finished
	


func _on_dust_particle_cd_timeout():
	particle_ready = true
	

#handles player being hurt
func _on_hurt_box_area_entered(_area):
	if invincible == false:
		
		invincible = true
		$HurtTimer.start()
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		state = STUN

func _on_hurt_timer_timeout():
	$HurtBox/CollisionShape2D.disabled = false
	invincible = false
	
