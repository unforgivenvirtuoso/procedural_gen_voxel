extends Spatial
class_name PolyTree

func _ready():
	add_child(Trunks.new(Leaf.new(2)))
