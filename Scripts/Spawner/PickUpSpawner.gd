extends Node2D


@onready var main = get_tree().current_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func spawn_item():
	var pickup = load("res://Scripts/Entities/Pickups/Treasure.tscn")
	var my_pickup = pickup.instantiate()
	main.get_node("World").add_child(my_pickup)
	my_pickup.global_position = self.global_position



func _on_timer_timeout():
	spawn_item()
	$Timer.wait_time = randf_range(10,20)

