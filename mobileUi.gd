extends CanvasLayer


func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if $Drag.is_pressed():
			var move_vector = calculate_move_vector(event.position)
			emit_signal("use_move_vector", move_vector)

func calculate_move_vector(event_position):
	var texture_center = $Drag.position + Vector2(16,16)
	return (event_position - texture_center).normalized()
