extends Node2D

func _ready():
	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		self.visible = false
		PlayerStats.max_health += 1
		PlayerStats.health = PlayerStats.max_health
		$HeartContainerPickup.play()
		yield ($HeartContainerPickup, "finished")
		queue_free()
