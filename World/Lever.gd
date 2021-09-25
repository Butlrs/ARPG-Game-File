extends StaticBody2D

onready var animation = $AnimatedSprite

var leverstate = null

signal lever_active

func _ready():
	leverstate = false

# warning-ignore:unused_argument
func _on_Area2D_area_entered(area):
	if leverstate == false:
		animation.play("Activated")
		$AudioStreamPlayer.play()
		emit_signal("lever_active")
		leverstate = true
	else:
		animation.play("Idle")
		$AudioStreamPlayer.play()
		leverstate = false
