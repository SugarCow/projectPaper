extends Node2D

var scenes = []
	
var spawnArea = Rect2(0, 0, 800, 600)
var sceneryDensity = 0.15  # Adjust as desired
@onready var main = get_tree().current_scene

func _ready():
	
	load_scenes()
	generateSceneries()

func generateSceneries():

	for x in range(int(spawnArea.size.x * sceneryDensity)):
		for y in range(int(spawnArea.size.y * sceneryDensity)):
			if randf() <= sceneryDensity:
#				var randomTemplateIndex = randi() % scenes.size()
				var random = randf_range(0,1)
				var sceneryInstance
				print(scenes.find("res://Scripts/Entities/Sceneries/FireBowl.tscn"))
				print(scenes.find("res://Scripts/Entities/Sceneries/Tower.tscn"))
				if random <=.1: 
					
					sceneryInstance = scenes[0].instantiate()
				elif random <= .15: 
					sceneryInstance = scenes[1].instantiate()
				elif random <=.7: 
					sceneryInstance = scenes[2].instantiate()
				else:
					continue
#					sceneryInstance = scenes.pick_random().instantiate()
				print(sceneryInstance.name)
#				print( sceneryInstance.owner.get_children())
				var pos = Vector2(x, y) * sceneryInstance.get_node("Sprite2D").texture.get_size()
				pos += spawnArea.position
				main.get_node("World").add_child(sceneryInstance)
				sceneryInstance.position = pos
				

func load_scenes():
	var scenePaths = []
	var folder_path = "res://Scripts/Entities/Sceneries/"
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

		scenes.append(scene)
