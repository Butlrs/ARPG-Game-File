extends Control

func _ready():
	pass
	
func _on_Button_pressed():
	PlayerStats.max_health = 5
	PlayerStats.health = PlayerStats.max_health 
	GlobalCanvas.kc = 0
	GlobalCanvas.score = 0
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World.tscn")
	
