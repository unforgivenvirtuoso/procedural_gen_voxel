extends StaticBody

var game_over := false
var player_won := false

export(float, 0.0, 1.0) var progress = 0.5 setget _set_progress
func _set_progress(value):
	if game_over:
		return
	
	progress = value
	
	$CanvasLayer/MarginContainer/HSlider.value = value
	
	if progress <= 0.0:
		game_over = true
		player_won = true
	elif progress >= 1.0:
		game_over = true
		player_won = false

func _ready():
	self.progress = self.progress
	
	# Set the y position to the block's position
	translation.y = yield($"../Generator".get_height_at3(translation), "completed")
	var voxel_tool: VoxelTool = $"../Generator/VoxelTerrain".get_voxel_tool()
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	voxel_tool.do_sphere(translation, 3.0)
	voxel_tool.mode = VoxelTool.MODE_ADD
	voxel_tool.do_sphere(translation + Vector3.DOWN * 4.0, 5.0)

func _process(_delta):
	$CanvasLayer/GameOver.visible = game_over
	$CanvasLayer/GameOver/TabContainer.current_tab = 1 if player_won else 0

func _physics_process(delta):
	var delta_progress := 0.0
	for body in $Area.get_overlapping_bodies():
		if "player" in body.get_groups():
			delta_progress -= 0.2
		if "enemy" in body.get_groups():
			delta_progress += 0.2
	
	self.progress += delta_progress * delta * 0.05
