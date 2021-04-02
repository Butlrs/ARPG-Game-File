extends Node2D

var state = false

func _ready():
	state = false
	$GateAnim.play("Closed")

func _process(_delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		if state == false:
			state = true
			$GateEffect.play() #play audio
			yield ($GateEffect, "finished") # wait 
			$GateAnim.play("Gate") # play animation
			yield ($GateAnim,"animation_finished") #wait
			queue_free() #remove
