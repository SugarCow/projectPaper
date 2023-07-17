extends CharacterBody2D

@export var projectile_speed: float

enum {
	STUN
}

var direction:= Vector2.ZERO
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")
@onready var main = get_tree().current_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsedd time since the previous frame.
func _process(_delta):
	if direction != Vector2.ZERO:
		velocity = direction * projectile_speed
		global_position += velocity
	
func set_direction(dir: Vector2):
	self.direction = dir
	rotation += dir.angle()


func _on_hit_box_area_entered(area):

	if get_parent() != null:
		var my_hit_effect = hit_effect.instantiate()
		main.add_child(my_hit_effect)
#		print(area.owner.name)s
		my_hit_effect.global_position = self.global_position
		
		my_hit_effect.play("animate")
#		print(get_parent())
		get_parent().call_deferred("remove_child", self)
#		print(get_parent())
#		$Sprite2D.visible = false
		await my_hit_effect.animation_finished
		my_hit_effect.queue_free()
		call_deferred("queue_free")
	print("pass")
