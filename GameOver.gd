extends Control

func _ready():
	$GameOverMusic.play()


func _on_Reset_pressed():
	$ButtonPressed.play()
	PlayerStats.max_health = 5
	PlayerStats.shields = PlayerStats.max_shields
	PlayerStats.health = PlayerStats.max_health 
	GlobalCanvas.kc = 0
	GlobalCanvas.score = 0
	PlayerStats.player_timer = false
	$GameOverMusic.stop()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World.tscn")


func _on_Menu_pressed():
	$ButtonPressed.play()
	$GameOverMusic.stop()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu.tscn")
