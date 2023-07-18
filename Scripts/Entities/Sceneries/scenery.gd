extends StaticBody2D

@export var scene_type: String
var scenes = []
# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name)
	load_image()
	$Sprite2D.texture = scenes.pick_random()




func load_image():
	var scenePaths = []
	var folder_path = "res://Assets/Sceneries/" + scene_type + "/"
	print(self.name)
	var directory = DirAccess.open(folder_path)
	directory.list_dir_begin()
	var file_name = directory.get_next()

	while file_name != "":
		if file_name.ends_with(".png"):
			var scenePath = folder_path + file_name
			scenePaths.append(scenePath)
		file_name = directory.get_next()

	directory.list_dir_end()

	
	for scenePath in scenePaths:
		var scene = ResourceLoader.load(scenePath)
		scenes.append(scene)
