extends CharacterBody2D

@onready var animation = $EnemyMode
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
@onready var health = max_health
@onready var cost = max_cost
var attack_ready: bool  = true
var state: int
var player
var dropped_exp: bool = false
var my_target: Node2D
var facing_dir = Vector2(0,0)
var my_attacker: CharacterBody2D
func _ready():
	player = $"../Player"
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
	animation.play("IdleLeft")
	if player.global_position.distance_to(self.global_position) >= 20:
		state = FOLLOW

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
	animation.play("MoveLeft")
#	print(target.global_position)
	var target_direction = ((target.global_position - self.global_position)- Vector2(2,2)).normalized()

	#Change the facing direction relative to the player's and this object position 
	if target_direction.x > 0:
		animation.flip_h = true
		facing_dir = Vector2(1,0)
	else: 
		animation.flip_h = false
		facing_dir = Vector2(-1,0)
		
		
	velocity = velocity.move_toward(target_direction * speed , 200)
	move_and_slide()

func attack_state(target):
	
	if target == null:
		state = IDLE
		return
	
	$HitBox/CollisionShape2D.disabled = true
	velocity = Vector2.ZERO
	animation.play("AttackLeft")
	var target_direction = ((target.position - self.position)- Vector2(2,2)).normalized()
	if target_direction.x > 0:
		animation.flip_h = true
	else: animation.flip_h = false
	
	if $HitBox.has_overlapping_areas() == true:
		
		state = ATTACK
	else:
		
		await animation.animation_finished
		state = FOLLOW
	
	
	
	await animation.animation_finished
	
	if is_range == true:
		spawn_projectile()
	
	$HitBox/CollisionShape2D.disabled = false
	
	
func spawn_projectile():
	var my_projectile = projectile.instantiate()
	my_projectile.position  = $ProjectileSpawn.global_position
	
	var direction = (my_target.global_position - self.global_position).normalized()

	my_projectile.set_direction(direction)

	get_tree().current_scene.call_deferred("add_child", my_projectile)

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
		$HurtBox/CollisionShape2D.disabled = true
		await animation.animation_finished
		$HurtBox/CollisionShape2D.disabled = false
		state = FOLLOW

func knockback_state():
	velocity = (facing_dir*-1)* 50
	if animation.animation != "Hurt":
		animation.stop()
		animation.play("Hurt")
		$HurtBox/CollisionShape2D.disabled = true
		move_and_slide()
		await animation.animation_finished
		$HurtBox/CollisionShape2D.disabled = false
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
			state = STUN




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
	if my_target == null:
		my_target = area.owner
		state = FOLLOW


func _on_detect_enemies_area_exited(_area):
	if $DetectEnemies.get_overlapping_areas() == null:
		my_target = null
	#finds the nearest target to begin attacking
	
	elif $DetectEnemies.get_overlapping_areas() != null and my_target == null:
		var closest_target: Area2D
		var closest_range: float = INF 
		for enemy in $DetectEnemies.get_overlapping_areas():
			if enemy.global_distance.distance_to(self.global_position) < closest_range:
				closest_range = enemy.global_distance.distance_to(self.global_position)
				closest_target = enemy
		my_target = closest_target

func _on_alive_timer_timeout():
	state = DEAD
	dropped_exp =true
