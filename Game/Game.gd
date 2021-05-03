extends Spatial

func spawn_enemy_after(time := 8.0):
	yield(get_tree().create_timer(time), "timeout")
	spawn_enemy()

func spawn_enemy():
	var enemy: KinematicBody = preload("res://Game/Enemy/Enemy.tscn").instance()
	
	var angle := randf() * TAU
	enemy.translation.x = cos(angle) * 50.0
	enemy.translation.z = sin(angle) * 50.0
	
	add_child(enemy)
	return enemy

func _ready():
	for _i in 3:
		spawn_enemy()
		yield(get_tree().create_timer(8.0), "timeout")
