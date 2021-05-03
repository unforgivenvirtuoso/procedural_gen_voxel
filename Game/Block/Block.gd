tool
extends StaticBody

export var size := Vector3.ONE setget _set_size
func _set_size(value):
	size = value
	
	$CollisionShape.shape.extents = size / 2
	$CollisionShape.translation.y = size.y / 2
	$MeshInstance.mesh.size = size
	$MeshInstance.translation.y = size.y / 2
	


