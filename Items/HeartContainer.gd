extends Node2D
var has_been_picked_up = false

func _ready():
	has_been_picked_up = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		self.visible = false
		PlayerStats.max_health += 1
		PlayerStats.health = PlayerStats.max_health
		$HeartContainerPickup.play()
		yield ($HeartContainerPickup, "finished")
		queue_free()
