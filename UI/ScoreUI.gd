extends Control

var score = 0

func _process(_delta):
	score = (GlobalCanvas.kc * 10)
	$scoring.text=str("", score)
