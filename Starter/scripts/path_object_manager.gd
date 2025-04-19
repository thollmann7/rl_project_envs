extends Node3D
class_name PathObjectManager

@export var map: Map
@export var car_scene: PackedScene
@export var platform_scene: PackedScene

var cars: Array[Node] 
var platforms: Array[Node]

var rng = RandomNumberGenerator.new()

# path_objects are explicitly instantiated and removed

func create_car(corners):
	var new_car = car_scene.instantiate()
	new_car.is_car = true
	if rng.randi_range(0, 1) == 1:
		corners.reverse()
	new_car.corners = corners
	new_car.step_size = map.tile_size
	var min_z = 0
	for corner in corners:
		if corner.z < min_z:
			min_z = corner.z
	new_car.remove_on_row_deletion = min_z / 2
	
	# find random spawn point:
	var random_index = rng.randi_range(0, corners.size()-1)
	# this is very ugly but i think i have to do it like that to cover all tiles
	var random_corner = corners[random_index]
	var random_next_corner = corners[(random_index + 1) % corners.size()]
	var x_range = []
	var z_range = []
	if random_corner.x != random_next_corner.x:
		new_car.position.x = rng.randi_range(
			min(random_corner.x/2, random_next_corner.x/2),
			max(random_corner.x/2, random_next_corner.x/2)
			) * 2
		new_car.position.z = random_corner.z
	else:
		new_car.position.x = random_corner.x
		new_car.position.z = rng.randi_range(
			min(random_corner.z/2, random_next_corner.z/2),
			max(random_corner.z/2, random_next_corner.z/2)
			) * 2
		new_car.rotate_y(PI/2)
	new_car.position.y = 0
	new_car.next_corner_index = (random_index + 1) % corners.size()
	add_child(new_car)
	cars.append(new_car)
			
func create_platform(start_field, end_field):
	var new_platform = platform_scene.instantiate()
	new_platform.is_car = false
	new_platform.start_field = start_field
	new_platform.end_field = end_field
	new_platform.step_size = map.tile_size
	new_platform.remove_on_row_deletion = end_field.z / 2
	
	new_platform.position = start_field
	new_platform.position.y = 0			
	add_child(new_platform)
	platforms.append(new_platform)
