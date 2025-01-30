extends Node3D

func display_number(value: int, position: Vector3, is_critical: bool = false):
	var number = Label3D.new()

	number.global_position = position
	number.text = str(value)
	number.font_size = 32
	number.outline_size = 1

	var color = Color(1, 1, 1) # Blanc
	if is_critical:
		color = Color(0.7, 0.13, 0.13) # Rouge foncé
	if value == 0:
		color = Color(1, 1, 1, 0.5) # Blanc semi-transparent

	number.modulate = color
	call_deferred("add_child", number)

	await get_tree().process_frame

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y + 0.5, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector3.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()
