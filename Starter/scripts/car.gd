extends Node3D
class_name Car

## Car, moves along x axis,
## and changes direction once left or right edge is reached

#region Initialized by car manager
var row_number: int
var car_type: int
var step_size: int
var left_edge_x: int
var right_edge_x: int
var current_direction: int = 1
#endregion

func _physics_process(_delta: float) -> void:
	var skip_move = false
	match car_type:
		0:
			if not (position.x > left_edge_x and position.x < right_edge_x):
				current_direction = -current_direction
				rotation.y = current_direction / 2.0 * PI
		1:
			if position.x == right_edge_x:
				position.x = left_edge_x
				skip_move = true
		2:
			if position.x == left_edge_x:
				position.x = right_edge_x
				skip_move = true
				
	if not skip_move:
		position.x += step_size * current_direction
