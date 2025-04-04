extends Node3D
class_name PathObject

## Platform, moves along x or z axis,
## and changes direction once an edge is reached
## 
## the edges HAVE to be a square or a line!

#region Initialized by platform manager
var is_car : bool
var step_size: int
# we give 4 corners, to allow circular paths. If a single-line path is desired,
# top_right=bottom_right and top_left=bottom_left for a left-to-right path.
# analogous for a top-to-bottom path
var corners = []
# index of next corner
var next_corner_index: int
# this tells the manager when to remove this platform
# (corresponds to the top-most row where this object can be seen. If that row
# gets removed, also remove the object)
var remove_on_row_deletion: int
#endregion

var stop = false


func _physics_process(_delta: float) -> void:
	if not stop:
		# if on a corner, update next corner (and turn if car)
		if position == corners[next_corner_index]:
			next_corner_index = (next_corner_index + 1) % corners.size()
			if is_car and corners.size() == 4:
				rotate_y(PI/2)
		# move towards next corner
		position = position.move_toward(corners[next_corner_index], 2)
