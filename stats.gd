extends Node
export(int) var max_health = 1 setget set_max_health # allows for script variables - altering value
var health = max_health setget set_health# use function every variable change (health)

export (bool) var state = false
export (bool) var hard = false

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
		else:
			if state == false:
				GlobalCanvas.kc += 1
			else:
				pass


func _ready():
	self.health = max_health

