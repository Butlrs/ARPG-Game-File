extends StaticBody2D

var state = false

func _ready():
	state = false
	$AnimatedSprite.play("closed")
	#get_parent().get_node("Lever").connect("lever_activated", self, "on_lever_activated")

func _on_Lever_lever_active():
	$AnimatedSprite.play("open")
	yield ($AnimatedSprite, "animation_finished")
	queue_free()
