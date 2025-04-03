extends Node3D
class_name PathObjectManager

@export var map: Map
@export var car_scene: PackedScene
@export var platform_scene: PackedScene

@onready var path_objects: Array[Node] = get_children()

# path_objects are explicitly instantiated and removed

func create_path_object(corners, path_object_type : int):
	var new_path_object = null
	match path_object_type:
		0: # car
			new_path_object = car_scene.instantiate()
			new_path_object.is_car = true
		1: # platform
			new_path_object = platform_scene.instantiate()
			new_path_object.is_car = false
	if range(0,2).pick_random() == 1:
		corners.reverse()
	new_path_object.corners = corners
	new_path_object.step_size = map.tile_size
	var min_z = 0
	for corner in corners:
		if corner.z < min_z:
			min_z = corner.z
	new_path_object.remove_on_row_deletion = min_z
	
	# find random spawn point:
	var random_index = range(0, corners.size()).pick_random()
	# this is very ugly but i think i have to do it like that to cover all tiles
	var random_corner = corners[random_index]
	var random_next_corner = corners[(random_index + 1) % corners.size()]
	var x_range = []
	var z_range = []
	if random_corner.x != random_next_corner.x:
		new_path_object.position.x = range(
			min(random_corner.x, random_next_corner.x),
			max(random_corner.x, random_next_corner.x) + 2,
			2
			).pick_random()
		new_path_object.position.z = random_corner.z
	else:
		new_path_object.position.x = random_corner.x
		new_path_object.position.z = range(
			min(random_corner.z, random_next_corner.z),
			max(random_corner.z, random_next_corner.z) + 2,
			2
			).pick_random()
		if new_path_object.is_car:
			new_path_object.rotate_y(PI/2)
	new_path_object.position.y = map.tile_size / 2 + 0.75 # 0.75 is to make the bottom of the car be at road height
	new_path_object.next_corner_index = (random_index + 1) % corners.size()
			
	add_child(new_path_object)
	path_objects.append(new_path_object)
