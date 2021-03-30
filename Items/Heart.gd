extends Node2D

func _ready():
	pass
	
func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if PlayerStats.health != PlayerStats.max_health:
			self.visible = false
			PlayerStats.health += 1
			$HeartPickup.play()
			yield ($HeartPickup, "finished")
			queue_free()
		else:
			self.visible = false
			$HeartPickup.play()
			yield ($HeartPickup, "finished")
			queue_free()
			

