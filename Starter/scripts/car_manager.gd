extends Node3D
class_name CarManager

@export var map: Map
@export var car_scene: PackedScene

var car_left_edge_x: int
var car_right_edge_x: int

@onready var cars: Array[Node] = get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func create_car(row_number, car_type):
	var new_car = car_scene.instantiate()
	new_car.row_number = row_number
	new_car.car_type = car_type
	# type 0:
	new_car.left_edge_x = 0
	new_car.right_edge_x = (map.grid_size_x - 1) * map.tile_size
	new_car.step_size = map.tile_size
	
	new_car.position.x = range(new_car.left_edge_x + 2, new_car.right_edge_x - 2, 2).pick_random()
	new_car.position.y = map.tile_size / 2 + 0.75 # 0.75 is to make the bottom of the car be at road height
	new_car.position.z = row_number * 2

	new_car.current_direction = 1 if randi_range(0, 1) == 0 else -1
	
	add_child(new_car)
	cars.append(new_car)
		
func update_cars():
	print(cars)
	# remove cars that don't belong to any row (bc it got deleted)
	for car in cars:
		# we use 'greater than' bc we go towards negative z with higher rows
		if car.row_number > map.road_rows[0].x:
			remove_child(car)
			cars = get_children()
	# add cars to empty rows
	for road_row in map.road_rows:
		var has_car = false
		for car in cars:
			if road_row.x == car.row_number:
				has_car = true
				break
		if not has_car:
			create_car(road_row.x, road_row.y)
