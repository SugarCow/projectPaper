extends Node2D

@onready var pivot = $Pivot
@onready var muzzle_flash = $Pivot/muzzleFlash
@onready var weapon_shoot = $Pivot/Weapon

@onready var projectile = preload("res://Scripts/Entities/Player/Weapon/plasma_shot.tscn")
@onready var shotsound = $shotsound
var mouse_left_down: bool
var attack_ready: bool = true


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
			
		elif event.button_index ==1 and not event.is_pressed():
			mouse_left_down = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	look_at(get_global_mouse_position())
	if mouse_left_down ==true and attack_ready == true and PlayerStats.coin != 0:
		muzzle_flash.play("animate")
		weapon_shoot.play("Shoot")
		spawn_projectile()
		attack_ready = false
		PlayerStats.coin -= 1

func spawn_projectile():
	shotsound.play()
	var my_projectile = projectile.instantiate()
	my_projectile.position = $Pivot/muzzleFlash.global_position
	
	var direction = (get_global_mouse_position() - $Pivot/muzzleFlash.global_position).normalized()

	my_projectile.set_direction(direction)

	get_tree().current_scene.call_deferred("add_child", my_projectile)


func _on_attack_cd_timeout():
	attack_ready =true

