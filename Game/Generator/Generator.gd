extends Spatial

# Map size on X and Z axis. Y axis is effectively infinite.
export var map_size := Vector2(640, 640)

# Chunk size on X and Z axis.
# Larger chunks mean less nodes, but less accurate culling and slower updates.
# Smaller chunks mean more nodes, but more accurate culling and faster updates.
export var chunk_size := Vector2(8, 8)

# Base height map for voxels.
export var height_map: OpenSimplexNoise
# Multiply the height map by this for mountainous/flat regions.
export var height_mult_map: OpenSimplexNoise

export var base_height := -64
export var height_range := 128

var chunks := {}
func chunk_pos3(pos: Vector3) -> Vector2:
	return chunk_pos(Vector2(pos.x, pos.z))
func chunk_pos(pos: Vector2) -> Vector2:
	return (pos / chunk_size).floor()

func chunk_local3(pos: Vector3) -> Vector3:
	var local := chunk_local(Vector2(pos.x, pos.z))
	var result := Vector3(local.x, pos.y, local.y)
	return result
func chunk_local(pos: Vector2) -> Vector2:
	return pos.posmodv(chunk_size)

func chunk_data(pos: Vector2) -> Dictionary:
	if not chunks.has(pos):
		chunks[pos] = {}
	
	return chunks[pos]

func _enter_tree():
	randomize()
	$VoxelTerrain.generator.noise.seed = randi()
	
	generate_buildings()
	generate_trees()

func get_height_at3(pos: Vector3) -> float:
	return get_height_at(Vector2(pos.x, pos.z))
func get_height_at(pos: Vector2) -> float:
	for _i in 200:
		yield(get_tree(), "idle_frame")
		var state := get_world().direct_space_state
		var result := state.intersect_ray(Vector3(pos.x, 1000.0, pos.y), Vector3(pos.x, -1000.0, pos.y), [], 1)
		if result.has("position"):
			return result["position"].y
	
	return 0.0

func generate_buildings() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	for _i in 25:
		generate_building(rng)

func generate_building(rng: RandomNumberGenerator):
	var phi = rng.randf() * TAU
	var r = lerp(20.0, 100.0, rng.randf())

	var sx := rng.randi_range(3, 18)
	var sy := rng.randi_range(3, 18)
	var sz := rng.randi_range(3, 18)

	var px := int(cos(phi) * r)
	var pz := int(sin(phi) * r)
	var py := INF
	for i in sx:
		for j in sz:
			var h = yield(get_height_at(Vector2(px + i, pz + j)), "completed")
			py = min(py, h - 1)
	
	var block := preload("res://Game/Block/Block.tscn").instance()
	block.size = Vector3(sx, sy, sz)
	block.translation = Vector3(px, py, pz)
	add_child(block)
	
	
	

func generate_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	for _i in 50:
		generate_tree(rng)

func generate_tree(rng: RandomNumberGenerator):
	var phi = rng.randf() * TAU
	var r = lerp(20.0, 100.0, rng.randf())

	var sx := rng.randi_range(3, 18)
	var sy := rng.randi_range(3, 18)
	var sz := rng.randi_range(3, 18)

	var px := int(cos(phi) * r)
	var pz := int(sin(phi) * r)
	var py := INF
	for i in sx:
		for j in sz:
			var h = yield(get_height_at(Vector2(px + i, pz + j)), "completed")
			py = min(py, h - 1)
	
	var tree := preload("res://Game/Tree/Tree.tscn").instance()
	
	tree.translation = Vector3(px, py, pz)
	add_child(tree)

