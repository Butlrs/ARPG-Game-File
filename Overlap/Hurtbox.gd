extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")
const CritHitEffect = preload("res://Effects/CritHitEffect.tscn")

var invincible = false setget set_invincible
export (bool) var  player = false

onready var time  = $Timer
onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true #starts timer
	time.start(duration)

func stop_invincibility():
	self.invincible = false

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position
	
func create_crit_hit_effect():
	var effect = CritHitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_Timer_timeout():
	self.invincible = false # removes recursion # sets back to false

func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled  = false
