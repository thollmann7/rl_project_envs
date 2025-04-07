extends Node3D
class_name PathObjectManager

@export var map: Map
@export var car_scene: PackedScene
@export var platform_scene: PackedScene

var cars: Array[Node] 
var platforms: Array[Node]

var rng = RandomNumberGenerator.new()

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
	if rng.randi_range(0, 1) == 1:
		corners.reverse()
	new_path_object.corners = corners
	new_path_object.step_size = map.tile_size
	var min_z = 0
	for corner in corners:
		if corner.z < min_z:
			min_z = corner.z
	new_path_object.remove_on_row_deletion = min_z / 2
	
	# find random spawn point:
	var random_index = rng.randi_range(0, corners.size()-1)
	# this is very ugly but i think i have to do it like that to cover all tiles
	var random_corner = corners[random_index]
	var random_next_corner = corners[(random_index + 1) % corners.size()]
	var x_range = []
	var z_range = []
	if random_corner.x != random_next_corner.x:
		new_path_object.position.x = rng.randi_range(
			min(random_corner.x/2, random_next_corner.x/2),
			max(random_corner.x/2, random_next_corner.x/2)
			) * 2
		new_path_object.position.z = random_corner.z
	else:
		new_path_object.position.x = random_corner.x
		new_path_object.position.z = rng.randi_range(
			min(random_corner.z/2, random_next_corner.z/2),
			max(random_corner.z/2, random_next_corner.z/2)
			) * 2
		if new_path_object.is_car:
			new_path_object.rotate_y(PI/2)
	new_path_object.position.y = 0
	new_path_object.next_corner_index = (random_index + 1) % corners.size()
			
	add_child(new_path_object)
	
	match path_object_type:
		0:
			cars.append(new_path_object)
		1:
			platforms.append(new_path_object)
