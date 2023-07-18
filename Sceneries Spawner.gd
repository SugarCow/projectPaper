extends Node2D

var scenes = []
	
var spawnArea = Rect2(0, 0, 800, 600)
var sceneryDensity = 0.1  # Adjust as desired

func _ready():
	
	load_scenes()
	generateSceneries()

func generateSceneries():

	for x in range(int(spawnArea.size.x * sceneryDensity)):
		for y in range(int(spawnArea.size.y * sceneryDensity)):
			if randf() <= sceneryDensity:
				var randomTemplateIndex = randi() % scenes.size()
				print(randomTemplateIndex)
				var sceneryInstance = scenes[randomTemplateIndex].instantiate()
#				print(sceneryInstance.owner)
#				print( sceneryInstance.owner.get_children())
				var position = Vector2(x, y) * sceneryInstance.get_node("Sprite2D").texture.get_size()
				position += spawnArea.position
				sceneryInstance.position = position
				add_child(sceneryInstance)
				
				
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
