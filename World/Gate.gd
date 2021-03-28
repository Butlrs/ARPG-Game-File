extends Node
var state = false
onready var door = get_node("AudioStreamPlayer")

func _ready():
	state = false

func _process(delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		if state == false:
			state = true
			$AudioStreamPlayer.play()
			yield($AudioStreamPlayer, "finished")
			queue_free()
