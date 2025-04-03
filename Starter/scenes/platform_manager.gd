extends Node3D
class_name PlatformManager

@export var map: Map
@export var platform_scene: PackedScene

@onready var platforms: Array[Node] = get_children()

# platforms are explicitly instantiated and removed

func create_platform(row_number, platform_type : int):
	var new_platform = platform_scene.instantiate()
	new_platform.row_number = row_number
	new_platform.platform_type = platform_type
	new_platform.left_edge_x = 0
	new_platform.right_edge_x = (map.grid_size_x - 1) * map.tile_size
	new_platform.step_size = map.tile_size
	
	new_platform.position.x = range(new_platform.left_edge_x + 2, new_platform.right_edge_x - 2, 2).pick_random()
	new_platform.position.y = map.tile_size / 2 + 0.75 # 0.75 is to make the bottom of the car be at road height
	new_platform.position.z = row_number * 2
	
	match platform_type:
		1:
			new_platform.current_direction = 1
		2:
			new_platform.current_direction = -1
			
	add_child(new_platform)
	platforms.append(new_platform)


func update_platforms():
	# remove cars that don't belong to any row (bc it got deleted)
	for platform in platforms:
		# we use 'greater than' bc we go towards negative z with higher rows
		var lowest_road_row = null
		if map.road_rows.size() > 0:
			lowest_road_row = map.road_rows[0].x
		if lowest_road_row == null or platform.row_number > lowest_road_row:
			remove_child(platform)
			platforms = get_children()
	# add cars to empty rows
	for road_row in map.road_rows:
		var has_platform = false
		for platform in platforms:
			if road_row.x == platform.row_number:
				has_platform = true
				break
		if not has_platform:
			create_platform(road_row.x, road_row.y)
