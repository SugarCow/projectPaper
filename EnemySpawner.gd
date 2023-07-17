extends Node2D

@export var list_of_enemies: PackedScene
@onready var main = get_tree().current_scene
# Called when the node enters the scene tree for the first time.

var scenes = []

func _ready():
	load_enemies()
	
	
func spawn_enemy():
	var my_enemy = scenes.pick_random().instantiate()
	main.get_node("World").add_child(my_enemy)
	my_enemy.global_position = self.global_position

	
func load_enemies(): 
	var scenePaths = []
	var folder_path = "res://Scripts/Entities/Enemies/"
	var directory = DirAccess.open(folder_path)
	directory.list_dir_begin()
	var file_name = directory.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var scenePath = folder_path + file_name
			scenePaths.append(scenePath)
		file_name = directory.get_next()

	directory.list_dir_end()

	
	for scenePath in scenePaths:
		var scene = ResourceLoader.load(scenePath)
		print(scenePath)
		scenes.append(scene)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	spawn_enemy()
	$Timer.set_deferred("wait_time", randf_range(2,6))
	print($Timer.wait_time)
	
	
