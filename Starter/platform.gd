extends Node3D
class_name Platform

## Platform, moves along x or z axis,
## and changes direction once an edge is reached

#region Initialized by platform manager
var platform_type: int
var step_size: int
# this corresponds to the static number (row if moving on x, column if moving on z)
var static_number: int
# these correspond to the edges (left/right if moving on x, top/bot if moving on z)
var edge_1: int
var edge_2: int
var current_direction: int = 1
# this tells the manager when to remove this platform
var remove_on: int
#endregion

func _physics_process(_delta: float) -> void:
	match platform_type:
		0:
			# platform moves on x axis
			if not (position.x > edge_1 and position.x < edge_2):
				current_direction = -current_direction
			position.x += step_size * current_direction
		1:
			# platform moves on z axis
			if not (position.z > edge_1 and position.z < edge_2):
				current_direction = -current_direction
			position.z += step_size * current_direction
