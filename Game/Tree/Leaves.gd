extends Spatial
class_name Leaf

# This script is ported from an article written by Peter Winslow on
# how to generate procedural planets in unity to godot. 
# https://peter-winslow.medium.com/creating-procedural-planets-in-unity-part-1-df83ecb12e91
# ported by codat https://www.youtube.com/watch?v=tgkGysJnHbs
# i tinkered with some values in order the achieve what i desired 

var polygons = []
var m_verticies = []
var subdivisions = 1
var surface_tool : SurfaceTool = null
var noise = null

func _init(subdivisions):
	self.subdivisions = subdivisions
	
	generate_icosphere()
	subdivide_icosphere()
	generate_mesh()
	

func generate_icosphere():
	
	var t = (1.0 + sqrt(5.0)) / 2
	
	m_verticies.push_back(Vector3(-1, t, 0).normalized())
	m_verticies.push_back(Vector3(1, t, 0).normalized())
	m_verticies.push_back(Vector3(-1, -t, 0).normalized())
	m_verticies.push_back(Vector3(1, -t, 0).normalized())
	m_verticies.push_back(Vector3(0, -1, t).normalized())
	m_verticies.push_back(Vector3(0, 1, t).normalized())
	m_verticies.push_back(Vector3(0, -1, -t).normalized())
	m_verticies.push_back(Vector3(0, 1, -t).normalized())
	m_verticies.push_back(Vector3(t, 0, -1).normalized())
	m_verticies.push_back(Vector3(t, 0, 1).normalized())
	m_verticies.push_back(Vector3(-t, 0, -1).normalized())
	m_verticies.push_back(Vector3(-t, 0, 1).normalized())
	
	polygons.push_back(Polygon.new(0, 11, 5))
	polygons.push_back(Polygon.new(0, 5, 1))
	polygons.push_back(Polygon.new(0, 1, 7))
	polygons.push_back(Polygon.new(0, 7, 10))
	polygons.push_back(Polygon.new(0, 10, 11))
	polygons.push_back(Polygon.new(1, 5, 9))
	polygons.push_back(Polygon.new(5, 11, 4))
	polygons.push_back(Polygon.new(11, 10, 2))
	polygons.push_back(Polygon.new(10, 7, 6))
	polygons.push_back(Polygon.new(7, 1, 8))
	polygons.push_back(Polygon.new(3, 9, 4))
	polygons.push_back(Polygon.new(3, 4, 2))
	polygons.push_back(Polygon.new(3, 2, 6))
	polygons.push_back(Polygon.new(3, 6, 8))
	polygons.push_back(Polygon.new(3, 8, 9))
	polygons.push_back(Polygon.new(4, 9, 5))
	polygons.push_back(Polygon.new(2, 4, 11))
	polygons.push_back(Polygon.new(6, 2, 10))
	polygons.push_back(Polygon.new(8, 6, 7))
	polygons.push_back(Polygon.new(9, 8, 1))
	

func subdivide_icosphere():
	
	var mid_point_cache = {}
	
	for i in subdivisions:
		var new_poly = []
		
		for poly in polygons:
			var a = poly.verticies[2]
			var b = poly.verticies[1]
			var c = poly.verticies[0]
			
			var ab = get_mid(mid_point_cache, a, b)
			var bc = get_mid(mid_point_cache, b, c)
			var ca = get_mid(mid_point_cache, c, a)
			
			new_poly.push_back(Polygon.new(a, ab, ca))
			new_poly.push_back(Polygon.new(b, bc, ab))
			new_poly.push_back(Polygon.new(c, ca, bc))
			new_poly.push_back(Polygon.new(ab, bc, ca))

		polygons = new_poly
	

func generate_mesh():
	
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in polygons.size():
		var poly = polygons[i]
		
		for index in poly.verticies.size():
			var vertex = m_verticies[poly.verticies[(poly.verticies.size() - 1) - index]]
			
			var normal = vertex.normalized()
			var u = normal.x * noise.period
			var v = normal.y * noise.period
			var noise_value = noise.get_noise_2d(u, v)
			vertex = vertex + ((normal * noise_value) * 0.9)
			
			surface_tool.add_vertex(vertex)
		
	
	surface_tool.index()
	surface_tool.generate_normals()
	
	var mesh = surface_tool.commit()
	var mesh_instance = MeshInstance.new()
	mesh_instance.material_override = generate_random_material()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	mesh_instance.scale = Vector3(rand_range(0.5, 2.5),rand_range(0.5, 2.5),rand_range(0.5, 2.5))
	mesh_instance.scale *= rand_range(1, 2.5)

		

func get_mid(cache : Dictionary, index_a, index_b):
	var smaller = min(index_a, index_b)
	var greater = max(index_a, index_b)
	var key = (smaller << 16) + greater
	
	if cache.has(key):
		return cache.get(key)
		
	var p1 = m_verticies[index_a]
	var p2 = m_verticies[index_b]
	var middle = lerp(p1, p2, 0.5).normalized()
	
	var ret = m_verticies.size()
	m_verticies.push_back(middle)
	
	cache[key] = ret
	return ret
	
class Polygon:
	var verticies = []
	func _init(a, b, c):
		verticies.push_back(a)
		verticies.push_back(b)
		verticies.push_back(c)


func generate_random_material():
	var material = SpatialMaterial.new()
	material.albedo_color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	return material
