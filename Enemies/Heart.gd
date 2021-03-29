extends Node2D

func _ready():
	$Despawn.start() # ALlows entity to despawn
	
func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		PlayerStats.health += 1
		$HeartPickup.play()
		self.visible = false
		yield ($HeartPickup, "finished")
		queue_free()

func _on_Despawn_timeout():
	queue_free()
