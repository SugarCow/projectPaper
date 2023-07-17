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
var is_attacked: bool = false
var ouch_countrer:int = 0

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
	if input_dir != Vector2.ZERO :
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
	print(animation_player.current_animation)
	if animation_player.current_animation.contains("Hurt") == false:
#		print("im in pain")
#		await animation_player.animation_finished(animation_player.current_animation)
		
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
	
	else:
		stun_state()
		
	velocity = input_dir * speed

	move_and_slide()


func idle_state():
	if facing_dir.x <= 0:
		animation_player.play("IdleLeft")
	if facing_dir.x >= 0:
		animation_player.play("IdleRight")


#	animation_player.play("HurtRight")
#	await animation_player.animation_finished
#	state = IDLE

func stun_state():
	print(animation_player.current_animation) 
	if animation_player.current_animation.contains("Hurt") == false:
		animation_player.stop()
		
		
		if input_dir.x > 0:
			animation_player.play("HurtRight")
			

		if input_dir.x < 0:
			animation_player.play("HurtLeft")
			
		
		if input_dir.x == 0:
			if facing_dir.x > 0:
				animation_player.play("HurtIdleRight")
			else:
				animation_player.play("HurtIdleLeft")

		#Animating moving Up and Down
		if input_dir.y >0 and facing_dir.x >0: 
			animation_player.play("HurtRight")

		
		if input_dir.y >0 and facing_dir.x <0: 
			animation_player.play("HurtLeft")

		
		if input_dir.y <0 and facing_dir.x >0: 
			animation_player.play("HurtRight")

		
		if input_dir.y <0 and facing_dir.x <0: 
			animation_player.play("HurtLeft")
		
		
		
		print(animation_player.current_animation)
		state = MOVE


func _on_dust_particle_cd_timeout():
	particle_ready = true
	

#handles player being hurt
func _on_hurt_box_area_entered(_area):
	if invincible == false:

		ouch_countrer +=1 
		print("ouch", ouch_countrer)
		invincible = true
		$HurtTimer.start()
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		state = STUN

func _on_hurt_timer_timeout():
	$HurtBox/CollisionShape2D.disabled = false
	invincible = false
	
	


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "HurtRight" or anim_name == "HurtLeft":
		state = MOVE

