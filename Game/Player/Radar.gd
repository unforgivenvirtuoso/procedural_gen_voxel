extends ColorRect

export var scale := 3.0

func _process(_delta):
	update()

func _draw():
	radar_draw(Vector3.ZERO, Color.blue, 3.0)
	radar_draw(owner.translation, Color.green, 3.0)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		radar_draw(enemy.translation, Color.red, 2.0)

func radar_draw(position: Vector3, color: Color, size: float) -> void:
	var position_xz = Vector2(position.x, position.z)
	var origin_xz = Vector2(owner.translation.x, owner.translation.z)
	var relative_position = (position_xz - origin_xz).rotated(owner.rotation.y) * scale
	draw_circle(rect_size / 2.0 + relative_position, size, color)
