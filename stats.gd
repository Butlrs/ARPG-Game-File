extends Node
export(int) var max_health = 1 setget set_max_health # allows for script variables - altering value
var health = max_health setget set_health# use function every variable change (health)

export (bool) var player = false
export (bool) var bat = false
export (bool) var hard = false
export (bool) var boss = false
export (bool) var mini_slime = false

var boss_state = false
var player_timer = false

signal no_health()
signal health_changed(value)
signal max_health_changed(value)


func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value # whenever health is changed, emit signal
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		if hard == true:
			GlobalCanvas.kc += 2
		if bat == true:
			GlobalCanvas.kc += 1
		if boss == true:
			GlobalCanvas.kc += 10
		if player == true:
			if player_timer == false:
				$player_death.start()

func _ready():
	self.health = max_health
	boss_state = false

func _on_player_death_timeout():
	player_timer = true
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu.tscn")
