extends CharacterBody2D

@export var projectile_speed: float

var direction:= Vector2.ZERO
@onready var hit_effect = preload("res://Scripts/Particle/hit_effect.tscn")
@onready var main = get_tree().current_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsedd time since the previous frame.
func _process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * projectile_speed
		global_position += velocity
	
func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_hit_box_area_entered(area):
	var my_hit_effect = hit_effect.instantiate()
	main.add_child(my_hit_effect)
	
	my_hit_effect.global_position = area.global_position
	my_hit_effect.play("animate")
	$Sprite2D.visible = false
	
	queue_free()

