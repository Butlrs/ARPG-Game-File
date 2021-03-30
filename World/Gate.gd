extends Node
var state = false

func _ready():
	state = false

func _process(_delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		if state == false:
			state = true
			$GateEffect.play()
			yield($GateEffect, "finished")
			queue_free()
