extends Camera3D

@export var player : Player

var follow_distance = 5

func _process(delta: float) -> void:
	if abs(player.position.z - position.z) > follow_distance:
		position.z -= 2
