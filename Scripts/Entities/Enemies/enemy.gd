extends CharacterBody2D

@onready var animation = $EnemyMode
@onready var coin = preload("res://Scripts/Entities/Pickups/coin.tscn")
@onready var heart = preload("res://Scripts/Entities/Pickups/health_pick_up.tscn")
@onready var main =  get_tree().current_scene
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")
@onready var projectile = preload("res://Scripts/Entities/enemyProjectile.tscn")
@export var arrow = preload("res://Scripts/Entities/enemyArrow.tscn")
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
@export var is_range: bool
@onready var health = max_health
@onready var cost = max_cost
@export var type: String

var state: int
var player
var dropped_coin: bool = false
var dropped_health: bool = false
var is_allied: bool = false
var my_target: CharacterBody2D
var facing_dir = Vector2(0,0)
var my_attacker: CharacterBody2D
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
	
	if is_allied == true:
		$TextureProgressBar.value = $AliveTimer.time_left/$AliveTimer.wait_time

func idle_state():
	animation.play("IdleLeft")

func follow_state(target):
	
	if my_target == null:
		state = IDLE
		return
	if abs(my_target.global_position - self.global_position) <= Vector2(5,5):
		state = ATTACK
	
	
	animation.play("MoveLeft")

	var target_direction = ((target.position - self.position)- Vector2(2,2)).normalized()

	if target_direction.x > 0:
		animation.flip_h = true
		facing_dir = Vector2(1,0)
	else: 
		animation.flip_h = false
		facing_dir = Vector2(-1,0)
	velocity = velocity.move_toward(target_direction * speed , 200)

	if (target.position.distance_to(self.position) <= 100 and is_range == true):
		state = ATTACK
	
	move_and_slide()

func attack_state(target):
	
	if my_target == null:
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
	if my_target == null:
		return
	var my_projectile
	if type.contains("archer"):
		my_projectile =  arrow.instantiate()
	else:
		my_projectile = projectile.instantiate()
		
	my_projectile.position  = $ProjectileSpawn.global_position
	
	var direction = (my_target.global_position - self.global_position).normalized()

	my_projectile.set_direction(direction)

	get_tree().current_scene.call_deferred("add_child", my_projectile)

func dead_state():
	state = DEAD
	$HurtBox/CollisionShape2D.disabled = true
	$CostBox/CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.disabled = true
	$DetectEnemies/CollisionShape2D.disabled = true
	$HurtBox/CollisionShape2D.disabled = true
	$MyIdentification/CollisionShape2D.disabled = true
	
	animation.play("Death")
	
	if animation.is_playing() == true:
		await animation.animation_finished
	if dropped_coin == false:
		var my_exp = coin.instantiate()
		main.get_node("World").add_child(my_exp)
		my_exp.get_node("AnimatedSprite2D").play("animate")
		my_exp.global_position = animation.global_position
		dropped_coin = true
		if randf_range(0,1) <= 0.2 and dropped_health == false:
			var my_health_pickup = heart.instantiate()
			main.get_node("World").add_child(my_health_pickup)
			my_health_pickup.get_node("AnimatedSprite2D").play("animate")
			my_health_pickup.global_position = animation.global_position
			dropped_health = true
		
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
func allied_state():
	$DetectEnemies/CollisionShape2D.set_deferred("disabled", false)
	is_allied = true
	state = IDLE
	$HurtBox.set_collision_layer_value(4,false)
	$HurtBox.set_collision_mask_value(12,true)
	$HitBox.set_collision_layer_value(11, true)
	$HitBox.set_collision_layer_value(3, false)
	$HitBox.set_collision_mask_value(7, false)
	$HitBox.set_collision_mask_value(4, true)
	$MyIdentification.set_collision_layer_value(12, true)
	$MyIdentification.set_collision_layer_value(6, false)
	$HitBox/CollisionShape2D.scale = Vector2(4,4)
	$EnemyMode.visible = false
	$AllyMode.visible = true
	$TextureProgressBar.visible = true
	$TextureProgressBar.value = 1
	$AliveTimer.start()
	animation = $AllyMode
	my_target = null
	$AlliedMode.play()
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
	print (area.owner.name) 
	if area.owner == my_target:
		state = ATTACK
	if my_target == null:
		my_target = area.owner

func _on_cost_box_area_entered(_area):
	cost -=15
	if cost <=0:
		state = ALLIED
	else:
		state = STUN
		$AudioStreamPlayer2D.play()

func _on_detect_enemies_area_entered(area):
	

	my_target = area.owner
	state = FOLLOW


func _on_detect_enemies_area_exited(_area):
	my_target = null
	


func _on_alive_timer_timeout():
	state = DEAD
	dropped_coin =true
