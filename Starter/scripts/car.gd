extends PathObject
class_name Car

#region Initialized by platform manager
var corners = []
# index of next corner
var next_corner_index: int
#endregion

func _physics_process(_delta: float) -> void:
	# if on a corner, update next corner (and turn if car)
	if position == corners[next_corner_index]:
		next_corner_index = (next_corner_index + 1) % corners.size()
		if is_car and corners.size() == 4:
			rotate_y(PI/2)
	# move towards next corner
	position = position.move_toward(corners[next_corner_index], 2)
