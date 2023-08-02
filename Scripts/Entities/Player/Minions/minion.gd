extends CharacterBody2D

@onready var animation = $AnimationPlayer
@onready var experience = preload("res://Scripts/Entities/Pickups/exp.tscn")
@onready var main =  get_tree().current_scene
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")
@onready var projectile = preload("res://Scripts/Entities/enemyProjectile.tscn")
# Called when the node enters the scene tree for the first time.
enum{
	IDLE,
	FOLLOW,
	DEAD,
	STUN,
	ATTACK
}
@export var speed: int 
@export var max_health: float
@export var max_cost: float
@export var is_boss: bool
@export var is_range: bool
@export var attack_cd: float
@onready var health = max_health
@onready var cost = max_cost
var attack_ready: bool = true
var state: int
var player
var dropped_exp: bool = false
var my_target: Node2D
var facing_dir = Vector2(0,0)
var my_attacker: CharacterBody2D
func _ready():
	$HurtBox/CollisionShape2D.set_deferred("disabled", false)
	$HitBox/CollisionShape2D.set_deferred("disabled", false)
	$DetectEnemies/CollisionShape2D.set_deferred("disabled", false)
	
	$AttackCD.wait_time = attack_cd
	player = $"../Player".get_node("RallyPoint")
	state = FOLLOW
	my_target = null
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	match state:
		IDLE:
			idle_state()
		FOLLOW:
			if my_target == null:
				follow_state(player)
			else:
				follow_state(my_target)
		ATTACK:
			attack_state(my_target)
		DEAD:
			dead_state()
		STUN:
			stun_state()


func idle_state():
	if facing_dir.x > 0:
		animation.play("IdleRight")
	else:
		animation.play("IdleLeft")
	if player.global_position.distance_to(self.global_position) >= 20:
		state = FOLLOW

func flash():
	$EnemyMode.material.set_shader_parameter("flash_modifier", 1)
	$FlashTimer.start()
func follow_state(target):
	
	#when close to enemy, attack them
	if my_target != null:
		if abs(my_target.global_position - self.global_position) <= Vector2(5,5):
			state = ATTACK
			return
		if (my_target.global_position.distance_to(self.global_position) <= 100 and is_range == true):
			state = ATTACK
			return
		
	if target.global_position.distance_to(self.global_position) <= randf_range(1,20):
		state = IDLE
		return
	
	#play the animation for moving
#	print(target.global_position)
	var target_direction = ((target.global_position - self.global_position)- Vector2(2,2)).normalized()

	#Change the facing direction relative to the player's and this object position 
	if target_direction.x > 0:
		animation.play("MoveRight")
		
		facing_dir = Vector2(1,0)
	else: 
		animation.play("MoveLeft")
		facing_dir = Vector2(-1,0)
		
		
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()

func attack_state(target):
	#if attack is ready
	if attack_ready == true:
		if target == null:
			state = IDLE
			return
		
#		$HitBox/CollisionShape2D.disabled = true
		velocity = Vector2.ZERO
		
		
		var target_direction = ((target.global_position - self.global_position)- Vector2(2,2)).normalized()
		if target_direction.x > 0:
			animation.play("AttackRight")
			
		else:
			animation.play("AttackLeft")
		
		if $HitBox.has_overlapping_areas() == true:
			
			state = ATTACK
		else:
			
			
			state = FOLLOW
		
		
		
		
		
		if is_range == true:
			spawn_projectile()
		
		attack_ready = false
		


func spawn_projectile():
	var my_projectile = projectile.instantiate()
	my_projectile.position  = $ProjectileSpawn.global_position
	
	var direction = (my_target.global_position - self.global_position).normalized()

	my_projectile.set_direction(direction)

	get_tree().current_scene.call_deferred("add_child", my_projectile)

func dead_state():
	
#	$HurtBox/CollisionShape2D.disabled =true
	
	
	if facing_dir.x > 0:
		animation.play("DeathAnimationRight")
	else:
		animation.play("DeathAnimationLeft")
	
	
#	if animation.is_playing() == true:
#		await animation.animation_finished
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
#		$HurtBox/CollisionShape2D.disabled = true
		await animation.animation_finished
#		$HurtBox/CollisionShape2D.disabled = false
		state = FOLLOW

func knockback_state():
	velocity = (facing_dir*-1)* 50
	if animation.animation != "Hurt":
		animation.stop()
		animation.play("Hurt")
#		$HurtBox/CollisionShape2D.disabled = true
		move_and_slide()
		await animation.animation_finished
#		$HurtBox/CollisionShape2D.disabled = false
		state = FOLLOW
#func allied_state():
#	$DetectEnemies/CollisionShape2D.set_deferred("disabled", false)
#
#	state = IDLE
#	$HurtBox.set_collision_layer_value(4,false)
#	$HurtBox.set_collision_mask_value(12,true)
#	$HitBox.set_collision_layer_value(11, true)
#	$HitBox.set_collision_layer_value(3, false)
#	$HitBox.set_collision_mask_value(7, false)
#	$HitBox.set_collision_mask_value(4, true)
#	$MyIdentification.set_collision_layer_value(2, true)
#	$MyIdentification.set_collision_layer_value(6, false)
#	$HitBox/CollisionShape2D.scale = Vector2(4,4)
#	$EnemyMode.visible = false
#	$AllyMode.visible = true
#	$TextureProgressBar.visible = true
#	$AliveTimer.start()
#	animation = $AllyMode
func _on_hurt_box_area_entered(area):
	if area != $HitBox:
#		print(area.owner.name)
		my_attacker = area.owner
		
		health -=15
		if health <=0:
			
			state = DEAD
		else:
			
			flash()
			
#			state = STUN




func _on_hit_box_area_entered(area):
	if area.owner == my_target:
		state = ATTACK


func _on_cost_box_area_entered(_area):
	cost -=15
	if cost <=0:
		pass
	else:
		state = STUN


func _on_detect_enemies_area_entered(area):
	my_target = area.owner
	state = FOLLOW


func _on_detect_enemies_area_exited(_area):
	my_target = null
	


func _on_alive_timer_timeout():
	state = DEAD
	dropped_exp =true


func _on_attack_cd_timeout():
	$HitBox/CollisionShape2D.disabled = false
	print("attack ready")
	attack_ready = true

func _on_flash_timer_timeout():
	$EnemyMode.material.set_shader_parameter("flash_modifier", 0)

