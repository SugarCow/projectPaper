extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var random_particle = str(randi_range(1,4))
	var string = "animate" + random_particle
	self.play(string)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	self.queue_free()

