extends Node2D

const GrassEffect = preload ("res://Effects/GrassEffect.tscn")
export (bool) var rock = false

func create_grass_effect():
	var grassEffect = GrassEffect.instance() # lower case instance upper case packed scene
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
