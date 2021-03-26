extends Control

const SECOND = 100
var timer = 200*SECOND

func _process(delta):
	var secondarytimer = 0
	timer -=1 
	secondarytimer = (timer/SECOND)
	$timing.text=str("", secondarytimer)
	if timer == 0:
		pass

