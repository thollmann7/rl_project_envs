extends PathObject
class_name Platform

var waiting = true
var stopped = false


#region Initialized by platform manager
var start_field: Vector3
var end_field: Vector3
#endregion

func _physics_process(_delta: float) -> void:
	if not (waiting or stopped):
		if position == end_field:
			stopped = true
		else:
			position = position.move_toward(end_field, 2)
