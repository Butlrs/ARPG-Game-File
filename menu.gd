extends Control

func _ready():
	$Main_music.play()

func _on_TextureButton_pressed():
	_stat_reset()
	$ButtonPressed.play()
	$Main_music.stop()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World.tscn")

func _stat_reset():
	PlayerStats.max_health = 5
	PlayerStats.shields = PlayerStats.max_shields
	PlayerStats.health = PlayerStats.max_health 
	GlobalCanvas.kc = 0
	GlobalCanvas.score = 0
	PlayerStats.player_timer = false
