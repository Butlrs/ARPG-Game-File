extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func _process(_delta):
	var stats = Stats.health
	self.text=str("",stats)
